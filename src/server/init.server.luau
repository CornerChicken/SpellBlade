local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Matter = require(ReplicatedStorage.Packages.matter)
local Components = require(ReplicatedStorage.Shared.components)

local MovementSystem = require(ReplicatedStorage.Shared.systems.movement)
local CombatSystem = require(ReplicatedStorage.Shared.systems.combat)
local StunSystem = require(ReplicatedStorage.Shared.systems.combat.stun)
local RoundSystem = require(ReplicatedStorage.Shared.systems.rounds)

local world = Matter.World.new() --World is database that holds every entity and its component.There is one on the server and a separate one on each client
local loop = Matter.Loop.new(world) -- Loop calls your systems every frame in order

loop:scheduleSystems({ --Order matters, such that we want stun resolved before combat rechecks state.
    MovementSystem,
    CombatSystem,
    StunSystem,
    RoundSystem,
})

loop:begin({
    default = RunService.Heartbeat, --RunService.Heartbeat is a signal that fires every frame, and is the best place to run game logic. Default means run all scheduled systems on this event
})

local function onCharacterAdded(player, character) -- world:spawn creates a new entity and attaches all components to it in one go. Each components.X() call creates an instance of that component with specified values
    world:spawn(
        Components.CharacterTag(),
        Components.Health({ current = 100, max = 100}),
        Components.Stamina({ current = 100, max = 100}),
        Components.CombatState({ state = "Idle" }),
        Components.WeaponEquipped({ weaponId = "basicSword" }),
        Components.Owner({ player = player })
    )
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player,character)
    end)
end)