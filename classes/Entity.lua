local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat

local class = require("lib.middleclass")

local Entity = class("Entity")

function Entity:initialize(args)
	assert(args.position)
	self.position = args.position

	self.orientation = self.orientation or quat()
	self.velocity = args.velocity or vec3()
	self.angularVelocity = args.angularVelocity or vec3()
end

function Entity:clearTemporaryFields()

end

return Entity
