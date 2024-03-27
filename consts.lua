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
consts.nearPlaneDistance = 0.1
-- Export OBJs from Blender with +Y up and +Z forward
consts.loadObjCoordMultiplier = vec3(1, 1, -1) -- TODO: Why?

consts.tau = math.pi * 2

consts.targettingCircleMeshRadiusPadding = 5 -- Could do a multiplier instead

consts.aiTargetTurningAngleDistanceThreshold = 0.0025

consts.setTargetDotThreshold = 0.95
consts.targettingDistanceVsAlignmentFactor = 100 -- The higher this number is, the less distance reduces the score of a potentially targetted object (object with highest score is targetted, closer aim increases score)

consts.targetSphereOutlineAngularDistanceThreshold = 0.01 -- Thickness of target sphere outline
consts.targetSphereOutlineFadePortion = 0.75 -- Amount of targetSphereOutlineAngularDistanceThreshold which is fading to zero

consts.rotationCursorColour = {0.75, 0.75, 0.75}
consts.rotationCursorDisplayMultiplier = 0.175
consts.rotationCursorAngularRadius = 0.01

consts.centreDotColour = {1, 1, 1}
consts.centreDotAngularRadius = 0.005

consts.forwardVector = vec3(0, 0, 1)
consts.upVector = vec3(0, 1, 0)
consts.rightVector = vec3(1, 0, 0)

consts.verticesPerBeamCylinderSlice = 8

consts.shipShaderSkyMultiplier = 0.4
consts.ambientLightIntensity = 0.2

consts.starDirection = vec3.normalise(vec3(1, 1, 1))
consts.starAngularRadius = 0.01
consts.starHaloAngularRange = 0.03
consts.starColour = {0.5, 0.5, 0.5}
consts.skyStarColourMultiplier = 5 -- Colour of star when you look straight at it in the sky is different to its effect on a surface

return consts
