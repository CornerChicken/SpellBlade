local ActiveSpellCast = require(script.Parent.Parent.Parent.components.ActiveSpellCast)
local SpellData = require(script.Parent.Parent.Parent.spells.spellData)

local function vfxSystem(world)
	-- Listen for newly added or changed ActiveSpellCast components
	for entityId, record in world:queryChanged(ActiveSpellCast) do
		if record.new and not record.old then
			-- Cast started: Play cast sound & charge particle
			local spellDef = SpellData[record.new.spellId]
			print("[VFX] Trigger cast effect for: " .. spellDef.name)
			
		elseif not record.new and record.old then
			-- Cast completed / ended: Trigger release audio & spawn impact/release visual
			print("[VFX] Spell released: " .. record.old.spellId)
		end
	end
end

return vfxSystem