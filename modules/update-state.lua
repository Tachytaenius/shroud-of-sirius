local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat

local normaliseOrZero = require("modules.normalise-or-zero")
local moveVectorToTarget = require("modules.move-vector-to-target")
local turnEntityToTarget = require("modules.turn-entity-to-target")
local sphereRaycast = require("modules.sphere-raycast")
local getGunRay = require("modules.get-gun-ray")
local traingleRaycast = require("modules.triangle-raycast")

local function updateState(state, dt, mouseDx, mouseDy)
	for entity in state.entities:elements() do
		for _, gun in ipairs(entity.guns) do
			gun.firing = false
			gun.beamHitT = nil
		end
	end

	if state.player then
		local player = state.player
		local translation = vec3()
		if love.keyboard.isDown("w") then translation.z = translation.z + 1 end
		if love.keyboard.isDown("s") then translation.z = translation.z - 1 end
		if love.keyboard.isDown("a") then translation.x = translation.x - 1 end
		if love.keyboard.isDown("d") then translation.x = translation.x + 1 end
		if love.keyboard.isDown("q") then translation.y = translation.y - 1 end
		if love.keyboard.isDown("e") then translation.y = translation.y + 1 end
		player.targetVelocity = vec3.rotate(normaliseOrZero(translation), player.orientation) * player.maxSpeed

		local rotation = vec3()
		if love.keyboard.isDown("j") then rotation.y = rotation.y - 1 end
		if love.keyboard.isDown("l") then rotation.y = rotation.y + 1 end
		if love.keyboard.isDown("i") then rotation.x = rotation.x - 1 end
		if love.keyboard.isDown("k") then rotation.x = rotation.x + 1 end
		if love.keyboard.isDown("u") then rotation.z = rotation.z + 1 end
		if love.keyboard.isDown("o") then rotation.z = rotation.z - 1 end
		-- rotation.y = rotation.y + mouseDx
		-- rotation.x = rotation.x + mouseDy
		player.targetAngularVelocity = normaliseOrZero(rotation) * player.maxAngularSpeed
	end

	if state.player then
		local entity = state.player
		if love.keyboard.isDown("space") then
			for _, gun in ipairs(entity.guns) do
				assert(not gun.firing, "Gun should not be firing at this point in update (its firing state was not cleared)")
				gun.firing = true
				local closestHitT, closestHitEntity, closestHitNormal
				-- TODO: Rotate gun a little to target entity before calling
				local rayStart, ray = getGunRay(entity, gun) -- TODO: Spatial hashing
				for entity2 in state.entities:elements() do
					if entity ~= entity2 then
						local rayEnd = rayStart + ray

						-- local t1, t2 = sphereRaycast(rayStart, rayEnd, entity2.position, entity2.colliderRadius * entity2.scale)
						-- if t1 and 0 <= t1 and t1 <= 1 and (not closestHitT or t1 < closestHitT) then
						-- 	closestHitT = t1
						-- 	closestEntity = entity2
						-- end
						-- if t2 and 0 <= t2 and t2 <= 1 and (not closestHitT or t2 < closestHitT) then
						-- 	closestHitT = t2
						-- 	closestEntity = entity2
						-- end

						for i = 1, #entity2.meshVertices, 3 do
							local meshV1 = entity2.meshVertices[i]
							local meshV2 = entity2.meshVertices[i + 1]
							local meshV3 = entity2.meshVertices[i + 2]
							-- TODO: Probably rotate and translate beam instead of mesh
							local v1 = entity2.position + vec3.rotate(entity2.scale * vec3(meshV1[1], meshV1[2], meshV1[3]), entity2.orientation)
							local v2 = entity2.position + vec3.rotate(entity2.scale * vec3(meshV2[1], meshV2[2], meshV2[3]), entity2.orientation)
							local v3 = entity2.position + vec3.rotate(entity2.scale * vec3(meshV3[1], meshV3[2], meshV3[3]), entity2.orientation)
							local t, normal = traingleRaycast(rayStart, rayEnd, v1, v2, v3)
							if t and 0 <= t and t <= 1 and (not closestHitT or t < closestHitT) then
								closestHitT = t
								closestHitEntity = entity2
								closestHitNormal = normal
							end
						end
					end
				end
				-- TODO: Damage closestEntity
				gun.beamHitT = closestHitT
				if closestHitT then
					gun.beamHitPos = rayStart + ray * closestHitT
				end
				gun.beamHitEntity = closestHitEntity
				gun.beamHitNormal = closestHitNormal
			end
		end
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
