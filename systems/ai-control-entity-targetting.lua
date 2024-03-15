local vec3 = require("lib.mathsies").vec3

local getTeamRelation = require("modules.util.get-team-relation")

local function aiControlEntityTargetting(state, entity)
	-- TODO: Retargetting to closer enemy sometimes depending on dot and other factors
		-- if not entity.currentTarget then
		local closest, closestDistance
		for potentialTarget in state.entities:elements() do
			if entity ~= potentialTarget and getTeamRelation(entity, potentialTarget) == "enemy" then
				local distance = vec3.distance(entity.position, potentialTarget.position)
				if not closest or distance < closestDistance then
					closest = potentialTarget
					closestDistance = distance
				end
			end
		end
		entity.currentTarget = closest
	-- end
end

return aiControlEntityTargetting
