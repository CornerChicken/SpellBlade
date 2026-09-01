local Workspace = game:GetService("Workspace")
local Projectile = require(script.Parent.Parent.Parent.components.Projectile)
local Health = require(script.Parent.Parent.Parent.components.Health)
local StunTimer = require(script.Parent.Parent.Parent.components.StunTimer)

local function projectileSystem(world, resources)
	local now = os.clock()

	for entityId, proj in world:query(Projectile) do
		-- 1. Check lifetime expiration
		if now - proj.spawnedAt >= proj.lifetime then
			world:despawn(entityId)
			continue
		end

		-- 2. Calculate movement for this frame
		local dt = resources.deltaTime or (1 / 60)
		local moveDistance = proj.speed * dt
		local currentPos = proj.position or Vector3.zero -- Track frame position via Spatial position or Transform component
		local nextPos = currentPos + (proj.direction * moveDistance)

		-- 3. Raycast for collision check
		local raycastResult = Workspace:Raycast(currentPos, proj.direction * moveDistance)
		if raycastResult then
			local hitInstance = raycastResult.Instance
			local targetEntity = resources.GetEntityFromInstance(hitInstance)

			if targetEntity and targetEntity ~= proj.casterEntity then
				-- Apply damage to target Health component
				local health = world:get(targetEntity, Health)
				if health then
					world:insert(targetEntity, Health({
						current = math.max(0, health.current - proj.damage),
						max = health.max,
					}))
				end

				-- Apply stun if spell has stun duration
				if proj.stunDuration and proj.stunDuration > 0 then
					world:insert(targetEntity, StunTimer({
						endsAt = now + proj.stunDuration,
					}))
				end

				world:despawn(entityId)
				continue
			elseif not targetEntity then
				-- Hit wall/environment
				world:despawn(entityId)
				continue
			end
		end
	end
end

return projectileSystem