local moveVectorToTarget = require("modules.maths.move-vector-to-target")

local function accelerateToTargetVelocities(entity, dt)
	if not entity.will then
		return
	end

	if entity.will.targetVelocity then
		entity.velocity = moveVectorToTarget(entity.velocity, entity.will.targetVelocity, entity.class.acceleration, dt)
	end
	if entity.will.targetAngularVelocity then
		entity.angularVelocity = moveVectorToTarget(entity.angularVelocity, entity.will.targetAngularVelocity, entity.class.angularAcceleration, dt)
	end
end

return accelerateToTargetVelocities
