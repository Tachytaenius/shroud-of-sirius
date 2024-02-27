local consts = require("consts")

local function getShortestAngleDifference(a, b)
	-- a to b is b - a
	return (b - a + consts.tau / 2) % consts.tau - consts.tau / 2
end

return getShortestAngleDifference
