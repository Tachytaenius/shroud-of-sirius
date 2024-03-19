local vec3 = require("lib.mathsies").vec3

local normaliseOrZero = require("modules.maths.normalise-or-zero")

local function aiControlEntityMovement(entity)
	if entity.currentTarget then
		local entityToTarget = entity.currentTarget.position - entity.position
		local entityToTargetDirection = normaliseOrZero(entityToTarget)
		local entityToTargetDistance = #entityToTarget
		-- Could probably use math.max and math.min or something instead of two checks per if statement
		if entityToTargetDistance > entity.class.preferredEngagementDistance and entityToTargetDistance > entity.class.preferredEngagementDistance + entity.class.engagementDistanceToleranceWidth / 2 then
			entity.targetVelocity = entityToTargetDirection * entity.class.maxSpeed
		elseif entityToTargetDistance < entity.class.preferredEngagementDistance and entityToTargetDistance < entity.class.preferredEngagementDistance - entity.class.engagementDistanceToleranceWidth / 2 then
			entity.targetVelocity = -entityToTargetDirection * entity.class.maxSpeed
		else
			entity.targetVelocity = vec3()
		end
	end
end

return aiControlEntityMovement
