local vec3 = require("lib.mathsies").vec3

local consts = require("consts")
local settings = require("settings")

local function controlEntityTargetting(state, entity)
	if love.keyboard.isDown(settings.controls.setTargetAhead) then
		local viewPosition = (entity.position + vec3.rotate((entity.cameraOffset or vec3()) * entity.scale, entity.orientation))
		local highestScore, highestScoreEntity
		for potentialTarget in state.entities:elements() do
			local dot = vec3.dot(
				vec3.rotate(consts.forwardVector, entity.orientation),
				vec3.normalise(potentialTarget.position - viewPosition)
			)
			local score = dot * consts.targettingDistanceVsAlignmentFactor / vec3.distance(viewPosition, potentialTarget.position)
			if
				dot > consts.setTargetDotThreshold and
				(not highestScore or highestScore < score)
			then
				highestScore = score
				highestScoreEntity = potentialTarget
			end
		end
		entity.currentTarget = highestScoreEntity -- nil OK
	end
end

return controlEntityTargetting
