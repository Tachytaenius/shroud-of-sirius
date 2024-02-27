local vec3 = require("lib.mathsies").vec3

local function limitVectorLength(v, l)
	local len = #v
	return len > l and vec3.normalise(v) * l or vec3.clone(v)
end

return limitVectorLength
