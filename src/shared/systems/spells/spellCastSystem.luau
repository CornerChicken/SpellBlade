local serverState = require(game:GetService("ServerScriptService").Server.serverState)

local CombatState = require(script.Parent.Parent.Parent.components.CombatState)
local SpellCooldowns = require(script.Parent.Parent.Parent.components.SpellCooldowns)
local ActiveSpellCast = require(script.Parent.Parent.Parent.components.ActiveSpellCast)
local StunTimer = require(script.Parent.Parent.Parent.components.StunTimer)
local SpellData = require(script.Parent.Parent.Parent.spells.spellData)
local SpellIntent = require(script.Parent.Parent.Parent.components.SpellIntent)

local function spellCastSystem(world)
	local now = os.clock()

	-- 1. Process all active spell intents
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
				print("[SpellCastSystem] Entity " .. entityId .. " casting " .. spellId)

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

		-- Always strip the intent at the end of the frame
		world:remove(entityId, SpellIntent)
	end

	-- 2. Resolve finished channel casts...
	for entityId, activeCast in world:query(ActiveSpellCast) do
		if now >= activeCast.startedAt + activeCast.channelTime then
			local combat = world:get(entityId, CombatState)
			if combat and combat.state == "Attacking" then
				world:insert(entityId, CombatState({ state = "Idle" }))
			end

			world:remove(entityId, ActiveSpellCast)
		end
	end
end

return spellCastSystem