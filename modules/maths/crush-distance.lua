-- This was going to be used for radar, but the 1:1 portion (defined by crushStart) just didn't look right on radar

local function crushDistance(distance, maxDistance, crushStart, crushEnd)
	local power = math.log(crushEnd / crushStart) / math.log(maxDistance / crushStart)
	return math.min(distance, crushStart * (distance / crushStart) ^ power)
end

return crushDistance
