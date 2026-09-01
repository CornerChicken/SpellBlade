local SpellCooldowns = require(script.Parent.Parent.Parent.components.SpellCooldowns)

local function cooldownSystem(world)
	local now = os.clock()

	for entityId, cooldowns in world:query(SpellCooldowns) do
		local updatedMap = {}
		local changed = false

		for spellId, readyAt in pairs(cooldowns.map) do
			if readyAt > now then
				updatedMap[spellId] = readyAt
			else
				changed = true -- Cleaned up expired entry
			end
		end

		if changed then
			world:insert(entityId, SpellCooldowns({ map = updatedMap }))
		end
	end
end

return cooldownSystem