local vec3 = require("lib.mathsies").vec3

local limitVectorLength = require("modules.maths.limit-vector-length")

local consts = require("consts")
local settings = require("settings")

local function handleRotationCursor(state, mouseDx, mouseDy)
	-- Move this amount to go move rotationCursor's magnitude from 0 to 1
	state.rotationCursor = limitVectorLength(
		(state.rotationCursor or vec3()) + -- Will never have anything on the z axis
			consts.upVector * mouseDx / settings.mouseMovementForMaxRotationCursorLength +
			consts.rightVector * mouseDy / settings.mouseMovementForMaxRotationCursorLength,
		1
	)
	if love.keyboard.isDown(settings.controls.recentreRotationCursor) then
		state.rotationCursor = vec3()
	end
end

return handleRotationCursor
