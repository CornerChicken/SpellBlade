local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.components)
local Owner = require(ReplicatedStorage.Shared.components.Owner)
local CombatState = require(ReplicatedStorage.Shared.components.CombatState)
local AttackWindup = require(ReplicatedStorage.Shared.components.AttackWindup)
local StunTimer = require(ReplicatedStorage.Shared.components.StunTimer)
local Health = require(ReplicatedStorage.Shared.components.Health)
local Stamina = require(ReplicatedStorage.Shared.components.Stamina)
local DodgeVelocity = require(ReplicatedStorage.Shared.components.DodgeVelocity)
local ParryWindow = require(ReplicatedStorage.Shared.components.ParryWindow)
local Remotes = require(ReplicatedStorage.Shared.remotes)

local ATTACK_RANGE = 8
local ATTACK_DAMAGE = 10
local ATTACK_WINDUP_TIME = 0.2
local STUN_DURATION = 1.2
local DODGE_DISTANCE = 8
local DODGE_DURATION = 0.15
local PARRY_DURATION = 0.3
local DODGE_STAMINA_COST = 20

-- Given a Roblox Player, find which ECS entity id belongs to them.
local function findEntityForPlayer(world, player)
    for id, owner in world:query(Owner) do
        if owner.player == player then
            return id
        end
    end
    return nil
end

-- 1v1 assumption: the opponent is "the other" entity with CharacterTag.
local function getOpponent(world, selfId)
    for id in world:query(Components.CharacterTag) do
        if id ~= selfId then
            return id
        end
    end
    return nil
end

local pendingAttacks = {}
local pendingDodges = {}
local pendingParries = {}

Remotes.Attack.OnServerEvent:Connect(function(player)
    print(player.Name, "requested an attack")
    table.insert(pendingAttacks, player)
end)

Remotes.Dodge.OnServerEvent:Connect(function(player)
    table.insert(pendingDodges, player)
end)

Remotes.Parry.OnServerEvent:Connect(function(player)
    print(player.Name, "requested a parry")
    table.insert(pendingParries, player)
end)

local function handleAttacks(world)
    for _, player in pendingAttacks do
        local id = findEntityForPlayer(world, player)
        if id then
            local state = world:get(id, CombatState)
            if state.state == "Idle" then
                world:insert(id, AttackWindup({
                    startedAt = os.clock(),
                    range = ATTACK_RANGE,
                    damage = ATTACK_DAMAGE,
                }))
                world:insert(id, state:patch({ state = "Attacking" }))
            end
        end
    end
    table.clear(pendingAttacks)
end

local function resolveAttackWindups(world)
    for id, windup, state, owner in world:query(AttackWindup, CombatState, Owner) do
        if os.clock() - windup.startedAt < ATTACK_WINDUP_TIME then
            continue
        end

        local targetId = getOpponent(world, id)
        if targetId then
            local targetState = world:get(targetId, CombatState)
            local attackerHRP = owner.player.Character
                and owner.player.Character:FindFirstChild("HumanoidRootPart")
            local targetOwner = world:get(targetId, Owner)
            local targetHRP = targetOwner and targetOwner.player.Character
                and targetOwner.player.Character:FindFirstChild("HumanoidRootPart")

            local inRange = attackerHRP and targetHRP
                and (attackerHRP.Position - targetHRP.Position).Magnitude <= windup.range

            if inRange then
                if targetState.state == "Parrying" then
                    world:insert(id, StunTimer({ endsAt = os.clock() + STUN_DURATION }))
                    world:insert(id, state:patch({ state = "Stunned" }))
                elseif targetState.state == "Dodging" then
                    -- Dodged, nothing happens
                else
                    local targetHealth = world:get(targetId, Health)
                    world:insert(targetId, targetHealth:patch({
                        current = math.max(0, targetHealth.current - windup.damage),
                    }))
                    world:insert(targetId, StunTimer({ endsAt = os.clock() + 0.4 }))
                    world:insert(targetId, targetState:patch({ state = "Stunned" }))
                end
            end
        end

        world:remove(id, AttackWindup)
        if world:get(id, CombatState).state == "Attacking" then
            world:insert(id, state:patch({ state = "Idle" }))
        end
    end
end

local function handleDodges(world)
    for _, player in pendingDodges do
        local id = findEntityForPlayer(world, player)
        if id then
            local state = world:get(id, CombatState)
            local stamina = world:get(id, Stamina)
            if state.state == "Idle" and stamina.current >= DODGE_STAMINA_COST then
                local owner = world:get(id, Owner)
                local hrp = owner.player.Character and owner.player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = owner.player.Character and owner.player.Character:FindFirstChildOfClass("Humanoid")
                if hrp and humanoid then
                    local moveDir = humanoid.MoveDirection
                    local dodgeDirection = if moveDir.Magnitude > 0.1
                        then moveDir.Unit
                        else hrp.CFrame.LookVector 

                    world:insert(id, DodgeVelocity({
                        direction = dodgeDirection,
                        speed = DODGE_DISTANCE / DODGE_DURATION,
                        endsAt = os.clock() + DODGE_DURATION,
                    }))
                    world:insert(id, state:patch({ state = "Dodging" }))
                    world:insert(id, stamina:patch({ current = stamina.current - DODGE_STAMINA_COST }))
                    humanoid.WalkSpeed = 0
                end
            end
        end
    end
    table.clear(pendingDodges)
end

local function handleParries(world)
    for _, player in pendingParries do
        local id = findEntityForPlayer(world, player)
        if id then
            local state = world:get(id, CombatState)
            if state.state == "Idle" then
                world:insert(id, ParryWindow({
                    startedAt = os.clock(),
                    duration = PARRY_DURATION,
                }))
                world:insert(id, state:patch({ state = "Parrying" }))
            end
        end
    end
    table.clear(pendingParries)
end

local function resolveParryWindows(world)
    for id, parry, state in world:query(ParryWindow, CombatState) do
        if os.clock() - parry.startedAt >= parry.duration then
            world:remove(id, ParryWindow)
            if state.state == "Parrying" then
                world:insert(id, state:patch({ state = "Idle" }))
            end
        end
    end
end

local function CombatSystem(world)
    handleAttacks(world)
    resolveAttackWindups(world)
    handleDodges(world)
    handleParries(world)
    resolveParryWindows(world)
end

return CombatSystem