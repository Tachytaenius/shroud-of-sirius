local class = require("lib.middleclass")

local Gun = class("Gun")

function Gun:initialize(args)
	assert(args.offset)
	self.offset = args.offset

	self.triggered = nil
	self.firing = nil
end

function Gun:clearTemporaryFields()
	self.triggered = nil
	self.firing = nil
end

return Gun
