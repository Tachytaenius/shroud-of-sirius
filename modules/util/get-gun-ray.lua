local consts = require("consts")

local vec3 = require("lib.mathsies").vec3

local function getGunRay(entity, gun)
	local rayStart = entity.position + entity.class.scale * vec3.rotate(gun.offset, entity.orientation)
	local ray = vec3.rotate(consts.forwardVector, entity.orientation) * gun.beamRange
	return rayStart, ray
end

return getGunRay
