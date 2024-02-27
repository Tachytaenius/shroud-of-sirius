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
	graphicsObjects.radarBlipAndStalkShader = love.graphics.newShader("shaders/radar-blip-and-stalk.glsl")

	graphicsObjects.lineMesh = love.graphics.newMesh(consts.vertexFormat, {
		{1,1,1, 0,0, 0,0,0}, {0,0,0, 0,0, 0,0,0}, {0,0,0, 0,0, 0,0,0}
	}, "triangles")
	graphicsObjects.lineShader = love.graphics.newShader("shaders/line.glsl")

	graphicsObjects.radarPlaneMesh = love.graphics.newMesh(consts.vertexFormat, {
		{-1,0,-1, 0,0, 0,-1,0}, {-1,0,1, 0,1, 0,-1,0}, {1,0,-1, 1,0, 0,-1,0},
		{1,0,-1, 1,0, 0,-1,0}, {-1,0,1, 0,1, 0,-1,0}, {1,0,1, 1,1, 0,-1,0},
	}, "triangles")
	graphicsObjects.radarShader = love.graphics.newShader("shaders/radar.glsl")

	graphicsObjects.icosahedronMesh = loadObj("meshes/icosahedron.obj")

	state = {}
	state.time = 0
	state.entities = list()
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

		mesh = loadObj("meshes/ship.obj"),
		albedoTexture = love.graphics.newImage("textures/shipAlbedo.png"),

		verticalFov = math.rad(90),
		cameraOffset = vec3()
	}
	state.entities:add(player)
	state.player = player
	state.entities:add({
		position = vec3(0, 0, 100),
		velocity = vec3(),
		maxSpeed = 100,
		acceleration = 200,
		scale = 20,

		orientation = quat(),
		angularVelocity = vec3(),
		maxAngularSpeed = 1,
		angularAcceleration = 2,

		mesh = loadObj("meshes/ship.obj"),
		albedoTexture = love.graphics.newImage("textures/shipAlbedo.png"),

		verticalFov = math.rad(70),
		cameraOffset = vec3()
	})
end

function love.update(dt)
	updateState(state, dt, mouseDx or 0, mouseDy or 0)
	mouseDx, mouseDy = nil, nil
end

function love.draw()
	drawState(state, graphicsObjects)
end
