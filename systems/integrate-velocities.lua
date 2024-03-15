local quat = require("lib.mathsies").quat

local function integrateVelocities(entity, dt)
	if entity.velocity then
		entity.position = entity.position + entity.velocity * dt
	end
	if entity.angularVelocity then
		entity.orientation = quat.normalise(entity.orientation * quat.fromAxisAngle(entity.angularVelocity * dt))  -- Relative frame of reference, second rotation on right of *?
	end
end

return integrateVelocities
