require("monkeypatch")

local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat
local list = require("lib.list")

local consts = require("consts")

local loadObj = require("modules.load-obj")
local updateState = require("modules.update-state")
local drawState = require("modules.draw-state")

local state, graphicsObjects
local mouseDx, mouseDy

function love.mousemoved(_, _, dx, dy)
	mouseDx, mouseDy = dx, dy
end

function love.load()
	love.graphics.setLineStyle("rough")
	love.graphics.setFrontFaceWinding(consts.frontFaceWinding)
	love.graphics.setMeshCullMode(consts.meshCullMode)
	love.graphics.setDefaultFilter("nearest", "nearest")

	graphicsObjects = {}

	graphicsObjects.dummyTexture = love.graphics.newImage(love.image.newImageData(1, 1))

	graphicsObjects.shipShader = love.graphics.newShader(
		love.filesystem.read("shaders/include/lib/simplex3d.glsl") ..
		love.filesystem.read("shaders/include/sky.glsl") ..
		love.filesystem.read("shaders/ship.glsl")
	)
	graphicsObjects.backgroundShader = love.graphics.newShader(
		love.filesystem.read("shaders/include/lib/simplex3d.glsl") ..
		love.filesystem.read("shaders/include/sky.glsl") ..
		love.filesystem.read("shaders/background.glsl")
	)
	graphicsObjects.solidShader = love.graphics.newShader("shaders/solid.glsl")
	graphicsObjects.HUDShader = love.graphics.newShader("shaders/hud.glsl")

	graphicsObjects.lineMesh = love.graphics.newMesh(consts.vertexFormat, {
		{1,1,1, 0,0, 0,0,0}, {0,0,0, 0,0, 0,0,0}, {0,0,0, 0,0, 0,0,0}
	}, "triangles")
	graphicsObjects.lineShader = love.graphics.newShader("shaders/line.glsl")

	graphicsObjects.radarPlaneMesh = love.graphics.newMesh(consts.vertexFormat, {
		{-1,0,-1, 0,0, 0,-1,0}, {1,0,-1, 1,0, 0,-1,0}, {-1,0,1, 0,1, 0,-1,0},
		{1,0,-1, 1,0, 0,-1,0}, {1,0,1, 1,1, 0,-1,0}, {-1,0,1, 0,1, 0,-1,0}
	}, "triangles")
	graphicsObjects.radarShader = love.graphics.newShader("shaders/radar.glsl")

	graphicsObjects.icosahedronMesh = loadObj("meshes/icosahedron.obj").mesh

	graphicsObjects.worldCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
	graphicsObjects.worldCanvasSetup = {graphicsObjects.worldCanvas, depth = true}
	graphicsObjects.HUDCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
	graphicsObjects.HUDCanvasSetup = {graphicsObjects.HUDCanvas, depth = true}
	graphicsObjects.outputCanvas = love.graphics.newCanvas(love.graphics.getDimensions())

	state = {}

	state.time = 0

	state.teams = {}
	state.teams.aliens = {
		relations = {}
	}
	state.teams.humans = {
		relations = {}
	}
	state.teams.aliens.relations[state.teams.humans] = "enemy"
	state.teams.humans.relations[state.teams.aliens] = "enemy"

	state.entities = list()

	local loadedObj = loadObj("meshes/alien-ship.obj")
	local player = {
		position = vec3(),
		velocity = vec3(),
		maxSpeed = 100,
		acceleration = 200,
		scale = 20,

		orientation = quat(),
		angularVelocity = vec3(),
		maxAngularSpeed = 1,
		angularAcceleration = 2,

		mesh = loadedObj.mesh,
		meshVertices = loadedObj.vertices,
		meshRadius = loadedObj.radius,
		albedoTexture = love.graphics.newImage("textures/alien-ship-albedo.png"),

		currentTarget = nil,

		team = state.teams.aliens,
		guns = {
			{
				offset = vec3(-0.2, 0, 0), -- Scaled by scale
				type = "laser",
				beamColour = {0, 1, 1},
				damagePerSecond = 200,
				beamRange = 500,
				beamRadius = 0.4,

				beamHitT = nil,
				beamHitEntity = nil,
				beamHitPos = nil,
				beamHitNormal = nil,
				firing = false

				-- Etc
			},
			{
				offset = vec3(0.2, 0, 0), -- Scaled by scale
				type = "laser",
				beamColour = {0, 1, 1},
				damagePerSecond = 200,
				beamRange = 500,
				beamRadius = 0.4,

				beamHitT = nil,
				beamHitEntity = nil,
				beamHitPos = nil,
				beamHitNormal = nil,
				firing = false

				-- Etc
			}
		},

		maxHull = 1000,
		hull = 1000,

		verticalFov = math.rad(90),
		cameraOffset = vec3(0, 0.5, 0.5), -- Scaled by scale

		displayObjectColoursByRelation = {
			ally = {0, 1, 0},
			neutral = {1, 1, 0},
			enemy = {1, 0, 0}
		},
		scannerRange = 1000,
		radar = {
			exponent = 0.5,
			colour = {1, 0, 0.75, 0.5},
			blipRadius = 0.05,
			stalkRadius = 0.015,
			position = vec3(0, -1.1, 2),
			scale = 0.75,
			yOscillationFrequency = 0.5,
			yOscillationAmplitude = 0.05,
			distanceCircleCount = 6,
			lineThickness = 0.015,
			angleLineCount = 10
		}
	}
	state.entities:add(player)
	state.player = player

	for _=1, 50 do
		local alien = love.math.random() < 0.5
		local loadedObj = loadObj(alien and "meshes/alien-ship.obj" or "meshes/human-ship.obj")
		state.entities:add({
			position = 500 * (vec3(love.math.random(), love.math.random(), love.math.random()) * 2 - 1),
			velocity = vec3(),
			maxSpeed = 100,
			acceleration = 200,
			scale = 20,

			orientation = quat(),
			angularVelocity = vec3(),
			maxAngularSpeed = 1,
			angularAcceleration = 2,

			mesh = loadedObj.mesh,
			meshVertices = loadedObj.vertices,
			meshRadius = loadedObj.radius,
			albedoTexture = love.graphics.newImage(alien and "textures/alien-ship-albedo.png" or "textures/human-ship-albedo.png"),

			currentTarget = nil,

			team = alien and state.teams.aliens or state.teams.humans,
			guns = {

			},

			ai = {
				preferredEngagementDistance = 150,
				engagementDistanceToleranceWidth = 20
			},
			scannerRange = 1000,

			maxHull = 1000,
			hull = 1000,

			verticalFov = math.rad(70),
			cameraOffset = vec3(),

			colliderRadius = 0.75
		})
	end
end

function love.update(dt)
	updateState(state, dt, mouseDx or 0, mouseDy or 0)
	mouseDx, mouseDy = nil, nil
end

function love.draw()
	drawState(state, graphicsObjects)
	love.graphics.draw(graphicsObjects.outputCanvas, 0, graphicsObjects.outputCanvas:getHeight(), 0, 1, -1)
end
