local function handleTemporaryFrameVariables(state)
	for entity in state.entities:elements() do
		for _, gun in ipairs(entity.guns) do
			gun.firing = false
			gun.beamHitT = nil
		end
	end
end

return handleTemporaryFrameVariables
