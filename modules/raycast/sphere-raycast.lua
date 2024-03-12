local vec3 = require("lib.mathsies").vec3

local function sphereRaycast(rayStart, rayEnd, spherePosition, sphereRadius)
	if rayStart == rayEnd then
		return
	end

	local startToEnd = rayEnd - rayStart
	local sphereToStart = rayStart - spherePosition

	local a = vec3.dot(startToEnd, startToEnd)
	local b = 2 * vec3.dot(sphereToStart, startToEnd)
	local c = vec3.dot(sphereToStart, sphereToStart) - sphereRadius ^ 2

	local discriminant = b ^ 2 - 4 * a * c
	if discriminant < 0 then
		return
	end

	return
		(-b - math.sqrt(discriminant)) / (2 * a),
		(-b + math.sqrt(discriminant)) / (2 * a)
end

return sphereRaycast
