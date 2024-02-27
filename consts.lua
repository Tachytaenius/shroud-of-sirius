local vec3 = require("lib.mathsies").vec3

local consts = {}

consts.vertexFormat = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"VertexNormal", "float", 3},
	-- {"VertexTangent", "float", 3},
	-- {"VertexBitangent", "float", 3}
}
consts.frontFaceWinding = "cw"
consts.meshCullMode = "back"
consts.farPlaneDistance = 10000
consts.nearPlaneDistance = 0.0001
-- Export OBJs from Blender with +Y up and +Z forward
consts.loadObjCoordMultiplier = vec3(1, 1, -1) -- TODO: Why?

consts.tau = math.pi * 2

consts.targettingAngleDistanceThreshold = 0.0025

-- TODO: Make controls use these
consts.forwardVector = vec3(0, 0, 1)
consts.upVector = vec3(0, 1, 0)

consts.verticesPerBeamCylinderSlice = 8

consts.radarColour = {1, 0, 0.75, 0.5}
consts.allyRadarColour = {0, 1, 0}
consts.neutralRadarColour = {1, 1, 0}
consts.enemyRadarColour = {1, 0, 0}
consts.radarBlipRadius = 0.05

consts.shipShaderSkyMultiplier = 0.4
consts.ambientLightIntensity = 0.2

consts.starDirection = vec3.normalise(vec3(1, 1, 1))
consts.starAngularRadius = 0.1
consts.starHaloAngularRange = 0.05
consts.starColour = {0.5, 0.5, 0.5}
consts.skyStarColourMultiplier = 5 -- Colour of star when you look straight at it in the sky is different to its effect on a surface

return consts
