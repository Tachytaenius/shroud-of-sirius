local vec3 = require("lib.mathsies").vec3

local class = require("lib.middleclass")

local assets = require("assets")

local Ship = require("classes.Ship")
local Laser = require("classes.Laser")

local AlienShip = class("AlienShip", Ship)

AlienShip.static.maxSpeed = 100
AlienShip.static.acceleration = 200
AlienShip.static.maxAngularSpeed = 1
AlienShip.static.angularAcceleration = 2

AlienShip.static.scale = 20

AlienShip.static.shipAsset = assets.ships.alienShip

AlienShip.static.maxHull = 1000

AlienShip.static.verticalFov = math.rad(90)
AlienShip.static.cameraOffset = vec3(0, 0.5, 0.5) -- Scaled by scale

AlienShip.static.scannerRange = 1000

AlienShip.static.radar = {
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

function AlienShip:initialize(args)
	AlienShip.super.initialize(self, args)

	self.guns[#self.guns + 1] = Laser({
		offset = vec3(-0.2, 0, 0), -- Scaled by scale
		beamColour = {0, 1, 1},
		damagePerSecond = 200,
		beamRange = 500,
		beamRadius = 0.4
	})
	self.guns[#self.guns + 1] = Laser({
		offset = vec3(0.2, 0, 0), -- Scaled by scale
		beamColour = {0, 1, 1},
		damagePerSecond = 200,
		beamRange = 500,
		beamRadius = 0.4
	})
end

return AlienShip
