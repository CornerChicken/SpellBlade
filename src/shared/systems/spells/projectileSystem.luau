local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Components
local Transform = require(ReplicatedStorage.Shared.components.Transform)
local Projectile = require(ReplicatedStorage.Shared.components.Projectile)
local DamagePayload = require(ReplicatedStorage.Shared.components.DamagePayload)
local Health = require(ReplicatedStorage.Shared.components.Health)
local StunTimer = require(ReplicatedStorage.Shared.components.StunTimer)
local Owner = require(ReplicatedStorage.Shared.components.Owner)
local RenderModel = require(ReplicatedStorage.Shared.components.RenderModel)

-- Raycast parameters setup
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function cleanupProjectileVisual(world, entityId)
	local renderModel = world:get(entityId, RenderModel)
	if renderModel and renderModel.model then
		renderModel.model:Destroy()
	end
end

local function projectileSystem(world, resources)
	local now = os.clock()
	-- Matter supplies deltaTime automatically in resources (or via default step delta)
	local dt = (resources and resources.deltaTime) or (1 / 60)

	for entityId, transform, projectile, payload in world:query(Transform, Projectile, DamagePayload) do
		-- 1. Expire old projectiles
		if now - projectile.spawnedAt >= projectile.lifetime then
			world:despawn(entityId)
			continue
		end

		-- 2. Calculate movement step for this frame
		local origin = transform.cframe.Position
		local moveVector = projectile.direction.Unit * (projectile.speed * dt)
		local targetPosition = origin + moveVector

		-- Build exclude list (ignore the caster's character visual instance)
		local ignoreList = {}
		if payload.casterEntity then
			local casterOwner = world:get(payload.casterEntity, Owner)
			if casterOwner and casterOwner.player and casterOwner.player.Character then
				table.insert(ignoreList, casterOwner.player.Character)
			end
		end

		raycastParams.FilterDescendantsInstances = ignoreList

		-- 3. Perform Raycast collision check
		local raycastResult = Workspace:Raycast(origin, moveVector, raycastParams)

		if raycastResult then
			local hitPart = raycastResult.Instance
			local hitModel = hitPart:FindFirstAncestorOfClass("Model")

			if hitModel then
				-- Find if the hit model corresponds to a registered player entity
				for targetEntityId, owner in world:query(Owner) do
					if targetEntityId ~= payload.casterEntity and owner.player and owner.player.Character == hitModel then
						
						-- Apply Damage
						local health = world:get(targetEntityId, Health)
						if health then
							local newHealth = math.clamp(health.current - payload.damage, 0, health.max)
							world:insert(targetEntityId, Health({
								current = newHealth,
								max = health.max,
							}))
							print("[ProjectileSystem] Hit entity " .. targetEntityId .. " for " .. payload.damage .. " damage! New HP: " .. newHealth)
						end

						-- Apply Stun (e.g. StunBolt payload)
						if payload.stunDuration and payload.stunDuration > 0 then
							world:insert(targetEntityId, StunTimer({
								endsAt = now + payload.stunDuration,
							}))
							print("[ProjectileSystem] Applied stun to entity " .. targetEntityId .. " for " .. payload.stunDuration .. " seconds.")
						end

						break
					end
				end
			end

			-- Despawn the projectile on impact (whether it hit a player or terrain/wall)
			cleanupProjectileVisual(world, entityId)
			world:despawn(entityId)
		else
			-- 4. No hit: Advance projectile transform
			local newCFrame = CFrame.lookAt(targetPosition, targetPosition + projectile.direction)
			world:insert(entityId, Transform({
				cframe = newCFrame,
			}))
		end
	end
end

return projectileSystem