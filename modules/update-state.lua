local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat

local consts = require("consts")
local settings = require("settings")

local normaliseOrZero = require("modules.normalise-or-zero")
local moveVectorToTarget = require("modules.move-vector-to-target")
local turnEntityToTarget = require("modules.turn-entity-to-target")
local sphereRaycast = require("modules.sphere-raycast")
local getGunRay = require("modules.get-gun-ray")
local traingleRaycast = require("modules.triangle-raycast")
local getTeamRelation = require("modules.get-team-relation")

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
		if love.keyboard.isDown(settings.controls.moveBackwards) then translation = translation - consts.forwardVector end
		if love.keyboard.isDown(settings.controls.moveForwards) then translation = translation + consts.forwardVector end
		if love.keyboard.isDown(settings.controls.moveLeft) then translation = translation - consts.rightVector end
		if love.keyboard.isDown(settings.controls.moveRight) then translation = translation + consts.rightVector end
		if love.keyboard.isDown(settings.controls.moveDown) then translation = translation - consts.upVector end
		if love.keyboard.isDown(settings.controls.moveUp) then translation = translation + consts.upVector end
		player.targetVelocity = vec3.rotate(normaliseOrZero(translation), player.orientation) * player.maxSpeed

		local rotation = vec3()
		if love.keyboard.isDown(settings.controls.yawLeft) then rotation = rotation - consts.upVector end -- Yaw left
		if love.keyboard.isDown(settings.controls.yawRight) then rotation = rotation + consts.upVector end -- Yaw right
		if love.keyboard.isDown(settings.controls.pitchUp) then rotation = rotation - consts.rightVector end -- Pitch up
		if love.keyboard.isDown(settings.controls.pitchDown) then rotation = rotation + consts.rightVector end -- Pitch down
		if love.keyboard.isDown(settings.controls.rollClockwise) then rotation = rotation - consts.forwardVector end -- Roll clockwise
		if love.keyboard.isDown(settings.controls.rollAnticlockwise) then rotation = rotation + consts.forwardVector end -- Roll anticlockwise
		-- rotation.y = rotation.y + mouseDx
		-- rotation.x = rotation.x + mouseDy
		player.targetAngularVelocity = normaliseOrZero(rotation) * player.maxAngularSpeed
	end

	if state.player then
		local entity = state.player
		if love.keyboard.isDown(settings.controls.shoot) then
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

	if state.player then
		if love.keyboard.isDown(settings.controls.setTargetAhead) then
			local viewPosition = (state.player.position + vec3.rotate((state.player.cameraOffset or vec3()) * state.player.scale, state.player.orientation))
			local highestScore, highestScoreEntity
			for potentialTarget in state.entities:elements() do
				local dot = vec3.dot(
					vec3.rotate(consts.forwardVector, state.player.orientation),
					vec3.normalise(potentialTarget.position - viewPosition)
				)
				local score = dot * consts.targettingDistanceVsAlignmentFactor / vec3.distance(viewPosition, potentialTarget.position)
				if
					dot > consts.setTargetDotThreshold and
					(not highestScore or highestScore < score)
				then
					highestScore = score
					highestScoreEntity = potentialTarget
				end
			end
			state.player.currentTarget = highestScoreEntity -- nil OK
		end
	end

	for entity in state.entities:elements() do
		if entity.ai and state.player ~= entity then
			-- TODO: Retargetting to closer enemy sometimes depending on dot and other factors
			-- if not entity.currentTarget then
				local closest, closestDistance
				for potentialTarget in state.entities:elements() do
					if entity ~= potentialTarget and getTeamRelation(entity, potentialTarget) == "enemy" then
						local distance = vec3.distance(entity.position, potentialTarget.position)
						if not closest or distance < closestDistance then
							closest = potentialTarget
							closestDistance = distance
						end
					end
				end
				entity.currentTarget = closest
			-- end

			if entity.currentTarget then
				-- TODO: Target angular velocity, not just hard turning
				turnEntityToTarget(entity, entity.currentTarget.position, dt)

				local entityToTarget = entity.currentTarget.position - entity.position
				local entityToTargetDirection = normaliseOrZero(entityToTarget)
				local entityToTargetDistance = #entityToTarget
				-- Could probably use math.max and math.min or something instead of two checks per if statement
				if entityToTargetDistance > entity.ai.preferredEngagementDistance and entityToTargetDistance > entity.ai.preferredEngagementDistance + entity.ai.engagementDistanceToleranceWidth / 2 then
					entity.targetVelocity = entityToTargetDirection * entity.maxSpeed
				elseif entityToTargetDistance < entity.ai.preferredEngagementDistance and entityToTargetDistance < entity.ai.preferredEngagementDistance - entity.ai.engagementDistanceToleranceWidth / 2 then
					entity.targetVelocity = -entityToTargetDirection * entity.maxSpeed
				else
					entity.targetVelocity = vec3()
				end
			end
		end

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

	state.time = state.time + dt
end

return updateState
