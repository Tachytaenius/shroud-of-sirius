local class = require("lib.middleclass")

local Gun = class("Gun")

function Gun:initialize(args)
	assert(args.offset)
	self.offset = args.offset

	self.triggered = false
	self.firing = false
end

return Gun
