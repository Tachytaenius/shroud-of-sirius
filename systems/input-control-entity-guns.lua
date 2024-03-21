local settings = require("settings")

local function controlEntityGuns(entity)
	local shooting = love.keyboard.isDown(settings.controls.shoot)
	for _, gun in ipairs(entity.guns) do
		assert(gun.triggered == nil, "Gun triggered state should be unset at this point in update (its triggered state was not cleared)")
		gun.triggered = shooting
	end
end

return controlEntityGuns
