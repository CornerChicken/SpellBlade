local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Matter = require(ReplicatedStorage.Packages.matter)
local serverState = require(script.serverState)

local Components = require(ReplicatedStorage.Shared.components)
local Health = require(ReplicatedStorage.Shared.components.Health)
local Stamina = require(ReplicatedStorage.Shared.components.Stamina)
local CombatState = require(ReplicatedStorage.Shared.components.CombatState)
local WeaponEquipped = require(ReplicatedStorage.Shared.components.WeaponEquipped)
local Owner = require(ReplicatedStorage.Shared.components.Owner)
local SpellCooldowns = require(ReplicatedStorage.Shared.components.SpellCooldowns)
local SpellIntent = require(ReplicatedStorage.Shared.components.SpellIntent)

local MovementSystem = require(ReplicatedStorage.Shared.systems.movement)
local CombatSystem = require(ReplicatedStorage.Shared.systems.combat)
local StunSystem = require(ReplicatedStorage.Shared.systems.combat.stun)
local RoundSystem = require(ReplicatedStorage.Shared.systems.rounds)
local CooldownSystem = require(ReplicatedStorage.Shared.systems.spells.cooldownSystem)
local SpellCastSystem = require(ReplicatedStorage.Shared.systems.spells.spellCastSystem)
local ProjectilesSystem = require(ReplicatedStorage.Shared.systems.spells.projectileSystem)

local world = Matter.World.new() --World is database that holds every entity and its component.There is one on the server and a separate one on each client
local loop = Matter.Loop.new(world) -- Loop calls your systems every frame in order

local PlayerToEntityMap = {}



loop:scheduleSystems({ --Order matters, such that we want stun resolved before combat rechecks state.
    CooldownSystem,
	MovementSystem,
    CombatSystem,
	SpellCastSystem,
	ProjectilesSystem,
    StunSystem,
    RoundSystem,
})

loop:begin({
    default = RunService.Heartbeat, --RunService.Heartbeat is a signal that fires every frame, and is the best place to run game logic. Default means run all scheduled systems on this event
})

local function onCharacterAdded(player)
    local playerEntity = PlayerToEntityMap[player]
    if playerEntity then
        world:insert(playerEntity, Components.CharacterTag())
        world:insert(playerEntity, WeaponEquipped({ weaponId = "basicSword" }))
    end
end

Players.PlayerAdded:Connect(function(player)
    local playerEntity = world:spawn(
        Owner({ player = player }),
        Health({ current = 100, max = 100 }),
        Stamina({ current = 100, max = 100 }),
        CombatState({ state = "Idle" }),
        SpellCooldowns({ map = {} })
    )

    PlayerToEntityMap[player] = playerEntity

    player.CharacterAdded:Connect(function()
        onCharacterAdded(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
	local entityId = PlayerToEntityMap[player]
	if entityId then
		world:despawn(entityId)
		PlayerToEntityMap[player] = nil
	end
end)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Fire when client casts spell
Remotes.CastSpell.OnServerEvent:Connect(function(player, spellId, targetCFrame)
	local playerEntity = PlayerToEntityMap[player]
	if playerEntity then
		-- Overwrites any old intent with the new one
		world:insert(playerEntity, SpellIntent({
			spellId = spellId,
			targetCFrame = targetCFrame,
		}))
	end
end)