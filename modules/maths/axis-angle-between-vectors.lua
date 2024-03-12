local vec3 = require("lib.mathsies").vec3

local function axisAngleVectorBetweenVectors(from, to)
	-- from and to should be normalised

	local crossResult = vec3.cross(from, to)
	local crossResultLength = #crossResult
	local rotationRequiredAxis
	if crossResultLength > 0 then
		rotationRequiredAxis = vec3.normalise(crossResult)
	end -- Else have nil, because there is no single axis of rotation (from and to are parallel), so an arbitray one must be chosen

	local dotClamped = math.max(-1, math.min(1, -- Clamping because it would sometimes be outside of [-1, 1] and therefore cause acos to return NaN
		vec3.dot(from, to)
	))
	local rotationRequiredAngle = math.acos(dotClamped)

	return rotationRequiredAxis, rotationRequiredAngle
end

return axisAngleVectorBetweenVectors
