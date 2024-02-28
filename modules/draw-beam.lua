local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat
local mat4 = mathsies.mat4

local consts = require("consts")

local axisAngleVectorBetweenVectors = require("modules.axis-angle-between-vectors")
local normalMatrix = require("modules.normal-matrix")

local baseCylinderMesh = require("modules.generate-base-cylinder")(consts.verticesPerBeamCylinderSlice)

local function drawBeam(origin, lineVector, radius, worldToScreenMatrix)
	local lineLength, lineDirection = #lineVector, vec3.normalise(lineVector)
	local rotationAxis, rotationAngle = axisAngleVectorBetweenVectors(consts.forwardVector, lineDirection)
	rotationAxis = rotationAxis or consts.upVector
	local rotation = quat.fromAxisAngle(rotationAxis * rotationAngle)
	local modelToWorldMatrix = mat4.transform(
		origin,
		rotation,
		vec3(radius, radius, lineLength)
	)
	local modelToScreenMatrix = worldToScreenMatrix * modelToWorldMatrix

	local shader = love.graphics.getShader()
	-- Can also use pcall here
	if shader:hasUniform("modelToWorld") then shader:send("modelToWorld", {mat4.components(modelToWorldMatrix)}) end
	if shader:hasUniform("modelToScreen") then shader:send("modelToScreen", {mat4.components(modelToScreenMatrix)}) end
	if shader:hasUniform("modelToWorldNormal") then shader:send("modelToWorldNormal", {normalMatrix(modelToWorldMatrix)}) end

	love.graphics.setMeshCullMode("none") -- Improves look

	love.graphics.draw(baseCylinderMesh)

	love.graphics.setMeshCullMode(consts.meshCullMode)
end

return drawBeam
