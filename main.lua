require("monkeypatch")

local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat
local list = require("lib.list")

local consts = require("consts")
local assets = require("assets")
local classes = require("classes")

local updateState = require("modules.update-state")
local drawState = require("modules.draw-state")

local state, graphicsObjects
local mouseDx, mouseDy

function love.mousemoved(_, _, dx, dy)
	mouseDx, mouseDy = dx, dy
end

function love.mousepressed()
	love.mouse.setRelativeMode(true)
end

function love.keypressed(key)
	if key == "escape" then
		love.mouse.setRelativeMode(false)
	end
end

function love.load()
	love.graphics.setLineStyle("rough")
	love.graphics.setFrontFaceWinding(consts.frontFaceWinding)
	love.graphics.setMeshCullMode(consts.meshCullMode)
	love.graphics.setDefaultFilter("nearest", "nearest")

	assets.load()
	classes.load()

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

	local player = classes.AlienShip({
		position = vec3(),
		team = state.teams.aliens
	})
	state.entities:add(player)
	state.player = player

	for _=1, 50 do
		local alien = love.math.random() < 0.5
		state.entities:add(
			(alien and classes.AlienShip or classes.HumanShip)({
				position = 500 * (vec3(love.math.random(), love.math.random(), love.math.random()) * 2 - 1),
				team = alien and state.teams.aliens or state.teams.humans,
				aiEnabled = true
			})
		)
	end

	state.rotationCursor = vec3() -- If switching player entities is added, ensure that this is reset
end

function love.update(dt)
	if not (mouseDx and mouseDy) or love.mouse.getRelativeMode() == false then
		mouseDx = 0
		mouseDy = 0
	end
	updateState(state, dt, mouseDx, mouseDy)
	mouseDx, mouseDy = nil, nil
end

function love.draw()
	drawState(state, graphicsObjects)
	love.graphics.draw(graphicsObjects.outputCanvas, 0, graphicsObjects.outputCanvas:getHeight(), 0, 1, -1)
end
