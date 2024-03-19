local moveVectorToTarget = require("modules.maths.move-vector-to-target")

local function accelerateToTargetVelocities(entity, dt)
	if entity.targetVelocity then
		entity.velocity = moveVectorToTarget(entity.velocity, entity.targetVelocity, entity.class.acceleration, dt)
	end
	if entity.targetAngularVelocity then
		entity.angularVelocity = moveVectorToTarget(entity.angularVelocity, entity.targetAngularVelocity, entity.class.angularAcceleration, dt)
	end
end

return accelerateToTargetVelocities
