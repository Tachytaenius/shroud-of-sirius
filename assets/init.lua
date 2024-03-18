-- In this project, assets handles both things that update logic uses as well as textures, meshes, etc used in graphics and audio, since there's some overlap (meshes are raycasted against in update)
-- Also, asset path names are in camelCase (rather than kebab-case) to simply match what they are in code

local loadObj = require("modules.mesh-generation.load-obj")

local assets = {}

-- TODO: Automate stuff
function assets.load()
	assets.meshes = {}
	assets.meshes.icosahedron = loadObj("assets/meshes/icosahedron.obj").mesh

	assets.ships = {}
	assets.ships.alienShip = {}
	assets.ships.alienShip.meshBundle = loadObj("assets/ships/alienShip/mesh.obj")
	assets.ships.alienShip.albedo = love.graphics.newImage("assets/ships/alienShip/albedo.png")
	assets.ships.humanShip = {}
	assets.ships.humanShip.meshBundle = loadObj("assets/ships/humanShip/mesh.obj")
	assets.ships.humanShip.albedo = love.graphics.newImage("assets/ships/humanShip/albedo.png")
end

return assets
