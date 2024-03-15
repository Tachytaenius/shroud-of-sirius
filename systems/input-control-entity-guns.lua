local settings = require("settings")

local function controlEntityGuns(entity)
	if love.keyboard.isDown(settings.controls.shoot) then
		for _, gun in ipairs(entity.guns) do
			assert(not gun.triggered, "Gun should not be triggered at this point in update (its triggered state was not cleared)")
			gun.triggered = true
		end
	end
end

return controlEntityGuns
