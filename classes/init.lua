-- Automatic loading of classes must be done after assets.load()

local classes = {}

function classes.load()
	for _, itemName in ipairs(love.filesystem.getDirectoryItems("classes")) do
		if itemName ~= "init.lua" then
			local itemNameTrimmed = itemName:gsub("%.lua$", "")
			classes[itemNameTrimmed] = require("classes." .. itemNameTrimmed)
		end
	end
end

return classes
