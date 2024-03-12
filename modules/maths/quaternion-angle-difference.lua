local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat

local function quaternionAngleDifference(q1, q2)
	local diff = quat.inverse(q1) * q2 -- Should this be any different?
	return 2 * math.atan2(#vec3(diff.x, diff.y, diff.z), diff.w)
end

return quaternionAngleDifference
