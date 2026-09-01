local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)

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