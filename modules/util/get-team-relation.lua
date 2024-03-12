local function getTeamRelation(entity, otherEntity)
	if entity.team == otherEntity.team then
		assert(not entity.team.relations[otherEntity.team], "Teams don't need to store their relation to themselves")
		return "ally"
	end
	local relation = entity.team.relations[otherEntity.team]
	assert(relation == otherEntity.team.relations[entity.team], "Inconsistency in team relations")
	return relation or "neutral"
end

return getTeamRelation
