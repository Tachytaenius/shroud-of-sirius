local vec3 = require("lib.mathsies").vec3

local normaliseOrZero = require("modules.maths.normalise-or-zero")

local function aiControlEntityMovement(entity)
	assert(entity.will, "AI entities should have wills")
	if entity.currentTarget then
		local entityToTarget = entity.currentTarget.position - entity.position
		local entityToTargetDirection = normaliseOrZero(entityToTarget)
		local entityToTargetDistance = #entityToTarget
		-- Could probably use math.max and math.min or something instead of two checks per if statement
		if entityToTargetDistance > entity.class.preferredEngagementDistance and entityToTargetDistance > entity.class.preferredEngagementDistance + entity.class.engagementDistanceToleranceWidth / 2 then
			entity.will.targetVelocity = entityToTargetDirection * entity.class.maxSpeed
		elseif entityToTargetDistance < entity.class.preferredEngagementDistance and entityToTargetDistance < entity.class.preferredEngagementDistance - entity.class.engagementDistanceToleranceWidth / 2 then
			entity.will.targetVelocity = -entityToTargetDirection * entity.class.maxSpeed
		else
			entity.will.targetVelocity = vec3()
		end
	end
end

return aiControlEntityMovement
