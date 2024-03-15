local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat

local settings = require("settings")

local sphereRaycast = require("modules.raycast.sphere-raycast")
local getGunRay = require("modules.util.get-gun-ray")
local triangleRaycast = require("modules.raycast.triangle-raycast")

local function controlEntityGuns(state, entity)
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

					-- Sphere as the collider:
					-- local t1, t2 = sphereRaycast(rayStart, rayEnd, entity2.position, entity2.colliderRadius * entity2.scale)
					-- Might make more sense to make it that if inside sphere, set t to 0 (solid sphere)
					-- if t1 and 0 <= t1 and t1 <= 1 and (not closestHitT or t1 < closestHitT) then
					-- 	hit
					-- end
					-- if t2 and 0 <= t2 and t2 <= 1 and (not closestHitT or t2 < closestHitT) then
					-- 	different hit
					-- end

					-- Do a sphere raycast to determine whether triangles should be checked against
					local t1, t2 = sphereRaycast(rayStart, rayEnd, entity2.position, entity2.meshRadius * entity2.scale)
					local checkMesh = false
					if t1 and t2 then -- Always returned together
						if 0 <= t1 and t1 <= 1 and (not closestHitT or t1 < closestHitT) then
							checkMesh = true
						-- Unless we're inside the sphere or the sphere is behind us, t2 should not be less than t1
						-- elseif 0 <= t2 and t2 <= 1 and (not closestHitT or t2 < closestHitT) then
						-- 	checkMesh = true
						elseif
							t1 <= 0 and 0 <= t2
							or t2 <= 0 and 0 <= t1 -- t2 should never be less than t1, but idk what limited precision can bring about
						then
							-- rayStart is inside sphere
							checkMesh = true
						end
					end
					if checkMesh then
						local rayStartTransformed = vec3.rotate(rayStart - entity2.position, quat.inverse(entity2.orientation)) / entity2.scale
						local rayEndTransformed = vec3.rotate(rayEnd - entity2.position, quat.inverse(entity2.orientation)) / entity2.scale
						for i = 1, #entity2.meshVertices, 3 do
							local v1Table = entity2.meshVertices[i]
							local v2Table = entity2.meshVertices[i + 1]
							local v3Table = entity2.meshVertices[i + 2]
							local v1 = vec3(v1Table[1], v1Table[2], v1Table[3])
							local v2 = vec3(v2Table[1], v2Table[2], v2Table[3])
							local v3 = vec3(v3Table[1], v3Table[2], v3Table[3])
							local t, normal = triangleRaycast(rayStartTransformed, rayEndTransformed, v1, v2, v3)
							if t and 0 <= t and t <= 1 and (not closestHitT or t < closestHitT) then
								closestHitT = t
								closestHitEntity = entity2
								closestHitNormal = normal
							end
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

return controlEntityGuns
