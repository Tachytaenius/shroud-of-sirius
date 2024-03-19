local function handleTemporaryFrameVariables(state)
	for entity in state.entities:elements() do
		for _, gun in ipairs(entity.guns) do
			gun.triggered = false
			gun.firing = false
			gun.beamHitT = nil
			gun.beamHitEntity = nil
			gun.beamHitPos = nil
			gun.beamHitNormal = nil
		end
	end
end

return handleTemporaryFrameVariables
