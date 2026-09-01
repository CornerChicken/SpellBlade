local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Matter = require(ReplicatedStorage.Packages.matter)
local Remotes = require(ReplicatedStorage.Shared.remotes)
local Owner = require(ReplicatedStorage.Shared.components.Owner)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- System modules
local cooldownUISystem = require(ReplicatedStorage.Shared.systems.vfx.cooldownUISystem)
local vfxSystem = require(ReplicatedStorage.Shared.systems.vfx.vfxSystem)
local renderSystem = require(ReplicatedStorage.Shared.systems.vfx.renderSystem)

local SPELL_KEYBINDS: { [Enum.KeyCode]: string } = {
	[Enum.KeyCode.One] = "Fireball",
	[Enum.KeyCode.Two] = "DashStrike",
	[Enum.KeyCode.Three] = "StunBolt",
}

local world = Matter.World.new()
local loop = Matter.Loop.new(world)

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local spellGui = playerGui:WaitForChild("SpellBar")

local uiFrames = {
	Fireball = spellGui.Frame:WaitForChild("FireballIcon"),
	DashStrike = spellGui.Frame:WaitForChild("DashIcon"),
	StunBolt = spellGui.Frame:WaitForChild("StunIcon"),
}

local clientResources = {
	LocalPlayerEntity = nil,
	UIFrames = uiFrames,
}

local function getTargetCFrame(): CFrame
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return CFrame.identity
	end

	local origin = character.HumanoidRootPart.Position
	local hitPos = Mouse.Hit.Position
	-- Flatten Y axis so the player aims horizontally across the duel arena
	local targetPos = Vector3.new(hitPos.X, origin.Y, hitPos.Z)

	return CFrame.lookAt(origin, targetPos)
end

local function resolveLocalPlayerSystem(worldInstance, resources)
	if resources and resources.LocalPlayerEntity then return end -- Already resolved

	for entityId, owner in worldInstance:query(Owner) do
		if owner.player == LocalPlayer then
			resources.LocalPlayerEntity = entityId
			break
		end
	end
end

loop:scheduleSystems({
	resolveLocalPlayerSystem,
	renderSystem,
	vfxSystem,
	cooldownUISystem,
})

-- Handle client render step loop
loop:begin({
	default = RunService.RenderStepped,
}, clientResources)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent) -- gameProcessedEvent is true if the keypress was already used by the game (e.g. typing in chat). Checking it stops you from attacking while typing in chat
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        print("Attack pressed")
        Remotes.Attack:FireServer() --FireServer sends a message from the client to the server. The server can listen for this message and respond accordingly
    elseif input.KeyCode == Enum.KeyCode.Q then
        print("Dodge pressed")
        Remotes.Dodge:FireServer()
    elseif input.KeyCode == Enum.KeyCode.F then
        print("Parry pressed")
        Remotes.Parry:FireServer()
    end

    local spellId = SPELL_KEYBINDS[input.KeyCode]
	if spellId then
		print(spellId .. " pressed")
		local targetCFrame = getTargetCFrame()
		Remotes.CastSpell:FireServer(spellId, targetCFrame)
	end
end)

