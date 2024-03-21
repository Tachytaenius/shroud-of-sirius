local function handleTemporaryFrameVariables(state)
	for entity in state.entities:elements() do
		entity:clearTemporaryFields()
		-- if entity.aiEnabled or entity == state.player then
			entity.will = {} -- Avoid any potential bugs with enabling AI or setting player mid-frame and then there not being a will table
		-- end
	end
end

return handleTemporaryFrameVariables
