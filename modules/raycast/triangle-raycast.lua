local vec3 = require("lib.mathsies").vec3

local function triangleRaycast(rayStart, rayEnd, triangleVertex1, triangleVertex2, triangleVertex3)
	if rayStart == rayEnd then
		return
	end

	local startToEnd = rayEnd - rayStart
	local rayDirection = vec3.normalise(startToEnd)

	-- TODO: Is this consistent with game?
	-- TODO: Simplify away negations and such, maybe.

	local v1ToV2 = triangleVertex2 - triangleVertex1
	local v2ToV3 = triangleVertex3 - triangleVertex2
	local v3ToV1 = triangleVertex1 - triangleVertex3
	local normal = vec3.normalise(vec3.cross(v1ToV2, v3ToV1))

	local d = -vec3.dot(normal, triangleVertex1)
	local nDotDirection = vec3.dot(normal, rayDirection)
	if nDotDirection == 0 then
		-- Ray parallel to triangle plane
		return
	end
	local tForDirection = -(vec3.dot(normal, rayStart) + d) / nDotDirection
	local p = rayStart + rayDirection * tForDirection
	if
		vec3.dot(normal, vec3.cross(v1ToV2, triangleVertex1 - p)) > 0 and
		vec3.dot(normal, vec3.cross(v2ToV3, triangleVertex2 - p)) > 0 and
		vec3.dot(normal, vec3.cross(v3ToV1, triangleVertex3 - p)) > 0
	then
		return tForDirection / #startToEnd, normal
	end
end

return triangleRaycast
