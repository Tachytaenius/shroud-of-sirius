local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat

local normaliseOrZero = require("modules.normalise-or-zero")
local moveVectorToTarget = require("modules.move-vector-to-target")
local turnEntityToTarget = require("modules.turn-entity-to-target")

local function updateState(state, dt, mouseDx, mouseDy)
	if state.player then
		local player = state.player
		local translation = vec3()
		if love.keyboard.isDown("w") then translation.z = translation.z + 1 end
		if love.keyboard.isDown("s") then translation.z = translation.z - 1 end
		if love.keyboard.isDown("a") then translation.x = translation.x - 1 end
		if love.keyboard.isDown("d") then translation.x = translation.x + 1 end
		if love.keyboard.isDown("q") then translation.y = translation.y + 1 end
		if love.keyboard.isDown("e") then translation.y = translation.y - 1 end
		player.targetVelocity = vec3.rotate(normaliseOrZero(translation), player.orientation) * player.maxSpeed

		local rotation = vec3()
		if love.keyboard.isDown("j") then rotation.y = rotation.y - 1 end
		if love.keyboard.isDown("l") then rotation.y = rotation.y + 1 end
		if love.keyboard.isDown("i") then rotation.x = rotation.x + 1 end
		if love.keyboard.isDown("k") then rotation.x = rotation.x - 1 end
		if love.keyboard.isDown("u") then rotation.z = rotation.z - 1 end
		if love.keyboard.isDown("o") then rotation.z = rotation.z + 1 end
		-- rotation.y = rotation.y + mouseDx
		-- rotation.x = rotation.x - mouseDy
		player.targetAngularVelocity = normaliseOrZero(rotation) * player.maxAngularSpeed
	end

	for entity in state.entities:elements() do
		if entity.targetVelocity then
			entity.velocity = moveVectorToTarget(entity.velocity, entity.targetVelocity, entity.acceleration, dt)
		end
		if entity.targetAngularVelocity then
			entity.angularVelocity = moveVectorToTarget(entity.angularVelocity, entity.targetAngularVelocity, entity.angularAcceleration, dt)
		end

		if entity.velocity then
			entity.position = entity.position + entity.velocity * dt
		end
		if entity.angularVelocity then
			entity.orientation = quat.normalise(entity.orientation * quat.fromAxisAngle(entity.angularVelocity * dt))  -- Relative frame of reference, second rotation on right of *?
		end
	end

	-- turnEntityToTarget(state.entities:get(2), state.player.position, dt) -- TEMP. Also, TODO: *accelerate* for it

	state.time = state.time + dt
end

return updateState
