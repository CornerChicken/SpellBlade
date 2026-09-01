local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

type SpellCooldownsData = {
	-- Dictionary mapping spellId string (e.g., "Fireball") to expiration timestamp (os.clock())
	map: { [string]: number },
}

local SpellCooldowns = Matter.component("SpellCooldowns", {
	map = {},
}) :: (defaultData: SpellCooldownsData?) -> SpellCooldownsData

return SpellCooldowns