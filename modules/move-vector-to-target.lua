local normaliseOrZero = require("modules.normalise-or-zero")

return function(current, target, rate, dt)
	local currentToTarget = target - current
	local direction = normaliseOrZero(currentToTarget)
	local distance = #currentToTarget
	local newDistance = math.max(0, distance - rate * dt)
	local newCurrentToTarget = direction * newDistance
	return target - newCurrentToTarget
end
