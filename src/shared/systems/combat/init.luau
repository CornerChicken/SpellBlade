local EncodingService = game:GetService("EncodingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.components)
local Remotes = require(ReplicatedStorage.Shared.remotes)

local ATTACK_RANGE = 8
local ATTACK_DAMAGE = 10
local STUN_DURATION = 1.2
local DODGE_SPEED = 40
local DODGE_DURATION = 0.25
local PARRY_DURATION = 0.3

local function findEntityForPlayer(world, player) --Helper function to find which ECS entity id belongs to them
    for id, owner in world:query(Components.Owner) do
        if owner.player == player then
            return id
        end
    end
    return nil
end

local function getOpponent(world, selfId) --Helper function to find the opponent entity id. Assumes a 1v1 game, so the opponent is the only other entity with a CharacterTag
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
    table.insert(pendingAttacks, player)
end)

Remotes.Dodge.OnServerEvent:Connect(function(player)
    table.insert(pendingDodges, player)
end)

Remotes.Parry.OnServerEvent:Connect(function(player)
    table.insert(pendingParries, player)
end)

local function CombatSystem(world)
    for _, player in pendingAttacks do
        local id = findEntityForPlayer(world, player)
        if id then
            local state = world:get(id, Components.CombatState)
            if state.state == "Idle" then
                world:insert(id, Components.AttackWindup({
                    startedAt = os.clock(),
                    range = ATTACK_RANGE,
                    damage = ATTACK_DAMAGE,
                }))
                world:insert(id, state:patch({ state = "Attacking"}))
            end
        end
    end
    table.clear(pendingAttacks) -- empties the list so we don't reprocess the same attack next frame

    for id, windup, state, owner in world:query(Components.AttackWindup, Components.CombatState, Components.Owner) do --Resolve attack windups, check if it landed
        if os.clock() - windup.startedAt >= 0.2 then --0.2s "windup" before the hit actually registers, gives the opponent a moment to dodge/parry after seeing the swing
            local targetId = getOpponent(world, id)
            if targetId then
                local targetState = world:get(targetId, Components.CombatState)
                local attackerHRP = owner.player.Character and owner.plyer.Character:FindFirstChild("HumanoidRootPart")
                local targetOwner = world:get(targetId, Components.Owner)
                local targetHRP = targetOwner and targetOwner.player.Character and targetOwner.player.Character:FindFirstChild("HumanoidRootPart")

                local inRange = attackerHRP and targetHRP and (attackerHRP.Position - targetHRP.Position).Magnitude <= windup.range

                if inRange then
                    if targetState.state == "Parrying" then
                        -- Attack was parried
                        world:insert(id, Components.StunTimer({ endsAt = os.clock() + STUN_DURATION }))
                        world:insert(id, state:patch({ state = "Stunned" }))
                    elseif targetState.state == "Dodging" then
                        -- Attack was dodged
                    else
                        local targetHealth = world:get(targetId, Components.Health)
                        world:insert(targetId, targetHealth:patch({ current = math.max(0, targetHealth.current - windup.damage)}))
                        world:insert(targetId, targetState:patch({ state = "stunned"}))
                    end
                end
            end

            world:remove(id, Components.AttackWindup)
            if world:get(id, Components.CombatState).state == "Attacking" then
                world:insert(id, state:patch({ state = "Idle"}))
            end
        end
    end

    for _, player in pendingDodges do --Handle Dodges
        local id = findEntityForPlayer(world, player)
        if id then
            local state = world:get(id, Components.CombatState)
            local stamina = world:get(id, Components.Stamina)
            if state.state == "Idle" and stamina.current >= 20 then
                local owner = world:get(id, Components.Owner)
                local hrp = owner.player.Character and owner.player.Character:FindFirstChild("HumanoidRootPart")
                local direction = hrp and hrp.CFrame.LookVector * DODGE_SPEED or Vector3.new(0, 0, 0) --LookVector is a unit vector pointing whichever way the character currently is facing

                world:insert(id, Components.DodgeVelocity({
                    direction = direction,
                    endsAt = os.clock() + DODGE_DURATION,
                }))
                world:insert(id, state:patch({ state = "Dodging"}))
                world:insert(id, stamina:patch({ current = stamina.current - 20}))
            end
        end
    end
    table.clear(pendingDodges)

    for _, player in pendingParries do --Handle Parries
        local id = findEntityForPlayer(world, player)
        if id then 
            local state = world:get(id, Components.CombatState)
            if state.state == "Idle" then
                world:insert(id, Components.ParryWindow({
                    startedAt = os.clock(),
                    duration = PARRY_DURATION,
                }))
                world:insert(id, state:patch({ state = "Parrying"}))
            end
        end
    end
    table.clear(pendingParries)

    for id, parry, state in world:query(Components.ParryWindow, Components.CombatState) do --Resolve parries automatically after their duration ends
        if os.clock() - parry.startedAt >= parry.duration then
            world:remove(id, Components.ParryWindow)
            if state.state == "Parrying" then
                world:insert(id, state:patch({ state = "Idle"}))
            end
        end
    end
end

return CombatSystem