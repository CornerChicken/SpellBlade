local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Components
local CombatState = require(ReplicatedStorage.Shared.components.CombatState)
local SpellCooldowns = require(ReplicatedStorage.Shared.components.SpellCooldowns)
local ActiveSpellCast = require(ReplicatedStorage.Shared.components.ActiveSpellCast)
local StunTimer = require(ReplicatedStorage.Shared.components.StunTimer)
local SpellIntent = require(ReplicatedStorage.Shared.components.SpellIntent)
local Health = require(ReplicatedStorage.Shared.components.Health)
local RenderModel = require(ReplicatedStorage.Shared.components.RenderModel)

-- Projectile Components
local Projectile = require(ReplicatedStorage.Shared.components.Projectile)
local DamagePayload = require(ReplicatedStorage.Shared.components.DamagePayload)
local Transform = require(ReplicatedStorage.Shared.components.Transform)
local Owner = require(ReplicatedStorage.Shared.components.Owner)

local SpellData = require(ReplicatedStorage.Shared.spells.spellData)
local projectileVisuals = require(ReplicatedStorage.Shared.systems.vfx.projectileVisuals)

-- Static RaycastParams to avoid frame-by-frame memory allocations
local dashRaycastParams = RaycastParams.new()
dashRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
dashRaycastParams.IgnoreWater = true

local function spellCastSystem(world)
	local now = os.clock()

	-- 1. Process new cast requests
	for entityId, intent in world:query(SpellIntent) do
		local spellId = intent.spellId
		local spellDef = SpellData[spellId]

		if spellDef then
			local combat = world:get(entityId, CombatState)
			local cooldowns = world:get(entityId, SpellCooldowns) or { map = {} }
			local stunned = world:get(entityId, StunTimer)

			local isIdle = combat and combat.state == "Idle"
			local isOnCooldown = (cooldowns.map[spellId] or 0) > now
			local isStunned = stunned and stunned.endsAt > now

			if isIdle and not isOnCooldown and not isStunned then
				world:insert(entityId, CombatState({ state = "Attacking" }))
				world:insert(entityId, ActiveSpellCast({
					spellId = spellId,
					startedAt = now,
					channelTime = spellDef.channelTime,
					targetCFrame = intent.targetCFrame,
				}))

				local updatedCooldowns = table.clone(cooldowns.map)
				updatedCooldowns[spellId] = now + spellDef.cooldown
				world:insert(entityId, SpellCooldowns({ map = updatedCooldowns }))
			end
		end

		world:remove(entityId, SpellIntent)
	end

	-- 2. Resolve finished channel casts (Spawning outcomes)
	for entityId, activeCast in world:query(ActiveSpellCast) do
		if now >= activeCast.startedAt + activeCast.channelTime then
			local spellId = activeCast.spellId
			local spellDef = SpellData[spellId]

			-- Release player back to Idle
			local combat = world:get(entityId, CombatState)
			if combat and combat.state == "Attacking" then
				world:insert(entityId, CombatState({ state = "Idle" }))
			end

			-- Determine spawn position & direction from player's current stance/target
			local ownerComponent = world:get(entityId, Owner)
			local player = ownerComponent and ownerComponent.player
			local character = player and player.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")

			if hrp then
				local spawnCFrame = hrp.CFrame * CFrame.new(0, 0, -3) -- Spawn slightly in front
				local direction = activeCast.targetCFrame.LookVector

				if spellId == "Fireball" then
					local fireballPart = projectileVisuals.createFireballPart(spawnCFrame)

					world:spawn(
						Transform({ cframe = CFrame.lookAt(spawnCFrame.Position, spawnCFrame.Position + direction) }),
						Projectile({
							speed = 75,
							lifetime = 3.5,
							spawnedAt = now,
							direction = direction,
						}),
						DamagePayload({
							casterEntity = entityId,
							damage = spellDef.damage or 35,
							stunDuration = 0,
						}),
						RenderModel({ model = fireballPart })
					)
					print("[SpellCastSystem] Spawned Fireball projectile!")

				elseif spellId == "StunBolt" then
					local stunBoltPart = projectileVisuals.createStunBoltPart(spawnCFrame)
					
					world:spawn(
						Transform({ cframe = CFrame.lookAt(spawnCFrame.Position, spawnCFrame.Position + direction) }),
						Projectile({
							speed = 110, -- Faster, narrower skillshot
							lifetime = 2.0,
							spawnedAt = now,
							direction = direction,
						}),
						DamagePayload({
							casterEntity = entityId,
							damage = spellDef.damage or 15,
							stunDuration = spellDef.stunDuration or 2.0, -- Applies StunTimer on hit
						}),
						RenderModel({ model = stunBoltPart })
					)
					print("[SpellCastSystem] Spawned StunBolt projectile!")
				elseif spellId == "DashStrike" then
					local dashDistance = spellDef.dashDistance or 25
					local dashDamage = spellDef.damage or 40
					local dashDirection = activeCast.targetCFrame.LookVector.Unit

					-- Ignore caster's character from clip raycasts
					dashRaycastParams.FilterDescendantsInstances = { character }

					local startPos = hrp.Position
					local rawTargetPos = startPos + (dashDirection * dashDistance)

					-- 1. Wall/Obstacle Collision Check
					-- Prevents player from clipping through terrain or walls
					local raycastResult = workspace:Raycast(startPos, dashDirection * dashDistance, dashRaycastParams)
					local finalPosition = rawTargetPos

					if raycastResult then
						-- Stop slightly before the wall surface (2 stud buffer)
						finalPosition = raycastResult.Position - (dashDirection * 2)
					end

					-- Construct target spatial CFrame
					local newCFrame = CFrame.lookAt(finalPosition, finalPosition + dashDirection)

					-- 2. Update Physical & ECS Spatial Position
					hrp.CFrame = newCFrame
					world:insert(entityId, Transform({ cframe = newCFrame }))

					print("[SpellCastSystem] DashStrike executed for entity " .. entityId)

					-- 3. Melee Sweep Hit Detection along the dash vector
					-- Checks all opponent player entities in the path
					local dashSweepRay = RaycastParams.new()
					dashSweepRay.FilterType = Enum.RaycastFilterType.Exclude
					dashSweepRay.FilterDescendantsInstances = { character }

					local sweepResult = workspace:Raycast(startPos, (finalPosition - startPos), dashSweepRay)

					if sweepResult then
						local hitModel = sweepResult.Instance:FindFirstAncestorOfClass("Model")
						if hitModel then
							for targetEntityId, targetOwner in world:query(Owner) do
								if targetEntityId ~= entityId and targetOwner.player and targetOwner.player.Character == hitModel then
									
									-- Apply damage to target entity
									local targetHealth = world:get(targetEntityId, Health)
									if targetHealth then
										local newHp = math.clamp(targetHealth.current - dashDamage, 0, targetHealth.max)
										world:insert(targetEntityId, Health({
											current = newHp,
											max = targetHealth.max,
										}))
										print("[SpellCastSystem] DashStrike hit target entity " .. targetEntityId .. " for " .. dashDamage .. " damage!")
									end

									-- Apply optional brief hit-stun
									if spellDef.stunDuration and spellDef.stunDuration > 0 then
										world:insert(targetEntityId, StunTimer({
											endsAt = now + spellDef.stunDuration,
										}))
									end

									break
								end
							end
						end
					end
				end
			end

			-- Clean up active spell cast
			world:remove(entityId, ActiveSpellCast)
		end
	end
end

return spellCastSystem