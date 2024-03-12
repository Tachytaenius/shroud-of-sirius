local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat

local consts = require("consts")

local axisAngleVectorBetweenVectors = require("modules.maths.axis-angle-between-vectors")

local function turnEntityToTarget(entity, targetPosition, dt)
	if targetPosition ~= entity.position then
		local entityToTargetDirection = vec3.normalise(targetPosition - entity.position)
		local curDirection = vec3.rotate(consts.forwardVector, entity.orientation)

		local rotationRequiredAxis, rotationRequiredAngle = axisAngleVectorBetweenVectors(curDirection, entityToTargetDirection)
		rotationRequiredAxis = rotationRequiredAxis or vec3.rotate(-consts.upVector, entity.orientation) -- nil means the two vectors are parallel, so pick an arbitrary direction (yaw right in this case)

		local maxAngle = entity.maxAngularSpeed * dt
		local cappedAngle = math.min(maxAngle, math.max(-maxAngle, rotationRequiredAngle))

		local rotationAxisAngle = rotationRequiredAxis * cappedAngle

		-- if math.abs(getShortestAngleDifference(0, rotationRequiredAngle)) > consts.aiTargetTurningAngleDistanceThreshold then
			entity.orientation = quat.normalise(quat.fromAxisAngle(rotationAxisAngle) * entity.orientation) -- Absolute frame of reference, second rotation on left of *?
		-- end
	end
end

return turnEntityToTarget
