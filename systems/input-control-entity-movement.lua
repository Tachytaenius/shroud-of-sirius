local vec3 = require("lib.mathsies").vec3

local settings = require("settings")
local consts = require("consts")

local normaliseOrZero = require("modules.maths.normalise-or-zero")

local function controlEntity(entity, mouseDx, mouseDy)
	assert(entity.will, "Controlled entity must have will")
	local translation = vec3()
	if love.keyboard.isDown(settings.controls.moveBackwards) then translation = translation - consts.forwardVector end
	if love.keyboard.isDown(settings.controls.moveForwards) then translation = translation + consts.forwardVector end
	if love.keyboard.isDown(settings.controls.moveLeft) then translation = translation - consts.rightVector end
	if love.keyboard.isDown(settings.controls.moveRight) then translation = translation + consts.rightVector end
	if love.keyboard.isDown(settings.controls.moveDown) then translation = translation - consts.upVector end
	if love.keyboard.isDown(settings.controls.moveUp) then translation = translation + consts.upVector end
	entity.will.targetVelocity = vec3.rotate(normaliseOrZero(translation), entity.orientation) * entity.class.maxSpeed

	local rotation = vec3()
	if love.keyboard.isDown(settings.controls.yawLeft) then rotation = rotation - consts.upVector end
	if love.keyboard.isDown(settings.controls.yawRight) then rotation = rotation + consts.upVector end
	if love.keyboard.isDown(settings.controls.pitchUp) then rotation = rotation - consts.rightVector end
	if love.keyboard.isDown(settings.controls.pitchDown) then rotation = rotation + consts.rightVector end
	if love.keyboard.isDown(settings.controls.rollClockwise) then rotation = rotation - consts.forwardVector end
	if love.keyboard.isDown(settings.controls.rollAnticlockwise) then rotation = rotation + consts.forwardVector end
	-- TODO: Mouse
	entity.will.targetAngularVelocity = normaliseOrZero(rotation) * entity.class.maxAngularSpeed
end

return controlEntity
