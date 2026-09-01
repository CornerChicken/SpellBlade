local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

export type SpellIntent = {
    spellId: string,
    targetCFrame: CFrame,
}

return Matter.component("SpellIntent", {
	spellId = "Fireball",
	targetCFrame = CFrame.new(),
})