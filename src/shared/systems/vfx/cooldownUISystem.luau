local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpellCooldowns = require(ReplicatedStorage.Shared.components.SpellCooldowns)
local SpellData = require(ReplicatedStorage.Shared.spells.spellData)

local function cooldownUISystem(world, resources)
    if not resources then return end
	local localEntity = resources.LocalPlayerEntity
	if not localEntity then return end

	local cooldowns = world:get(localEntity, SpellCooldowns)
	local now = os.clock()

	-- UIFrames is passed in via resources from init.client.luau
	local uiFrames = resources.UIFrames
	if not uiFrames then return end

	for spellId, frame in pairs(uiFrames) do
		local spellDef = SpellData[spellId]
		if not spellDef then continue end

		local readyAt = (cooldowns and cooldowns.map[spellId]) or 0
		local remaining = math.max(0, readyAt - now)
		local progress = math.clamp(remaining / spellDef.cooldown, 0, 1)

		-- Update visual fill bar/overlay
		if frame:FindFirstChild("CooldownOverlay") then
			frame.CooldownOverlay.Size = UDim2.fromScale(1, progress)
		end

		-- Update countdown text
		if frame:FindFirstChild("TimerLabel") then
			frame.TimerLabel.Text = if remaining > 0 
				then string.format("%.1f", remaining) 
				else ""
		end
	end
end

return cooldownUISystem