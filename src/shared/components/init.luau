local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.matter)

local components = {}

components.CharacterTag = Matter.component("CharacterTag")

components.Health = Matter.component("Health", {
    current = 100,
    max = 100,
})

components.Stamina = Matter.component("Stamina", {
    current = 100,
    max = 100,
})

components.CombatState = Matter.component("CombatState",{
    state = "Idle", -- May be Idle, Attacking, Dodging, Parrying, Stunned
})

components.StunTimer = Matter.component("StunTimer", {
    endsAt = 0, -- A timestamp (os.clock() value), stunned until this moment
})

components.WeaponEquipped = Matter.component("WeaponEquipped", {
    weaponId = "basicSword",
})

components.AttackWindup = Matter.component("AttackWindup", {
    startedAt = 0,
    range = 6, --in studs
    damage = 20,
})

components.ParryWindow = Matter.component("ParryWindow", {
    startedAt = 0,
    duration = 0.3,
})

components.DodgeVelocity = Matter.component("DodgeVelocity", {
    direction = Vector3.new(0, 0, 0), -- unit vector (length 1), which way to dash
    speed = 0,                         -- studs per second
    endsAt = 0,
})

components.RoundState = Matter.component("RoundState", {
    scoreA = 0,
    scoreB = 0,
    currentRound = 1,
    phase = "Fighting", --Fighting, RoundOver, MatchOver
})

components.Owner = Matter.component("Owner", {
    player = nil, --Will hold Roblox Player object
})

return components