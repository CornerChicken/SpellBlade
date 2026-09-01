local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.components)
local Owner = require(ReplicatedStorage.Shared.components.Owner)
local RoundState = require(ReplicatedStorage.Shared.components.RoundState)
local Health = require(ReplicatedStorage.Shared.components.Health)
local Stamina = require(ReplicatedStorage.Shared.components.Stamina)

local ROUND_RESET_DELAY = 3 --seconds to pause on a dead screen before resetting

local matchRoundStateId = nil --Only need one roundstate entity, so track its id in a variable outside the loop function

local function ensureRoundState(world)
    if matchRoundStateId == nil then
        matchRoundStateId = world:spawn(RoundState({})) --Empty table means to use the defaults
    end
    return matchRoundStateId
end

local function respawnAll(world)
    for id, owner in world:query(Owner) do
        local health = world:get(id, Health)
        world:insert(id, health:patch({ current = health.max })) --Reset health to max
        local stamina = world:get(id, Stamina)
        world:insert(id, stamina:patch({ current = stamina.max })) --Reset stamina to max
        if owner.player.Character then
            owner.player.Character:PivotTo(CFrame.new(0, 5, 0)) --Move character to spawn point. Replace (0, 5, 0) with your actual spawn points later
        end
    end
end

local function RoundSystem(world)
    local stateId = ensureRoundState(world)
    local roundState = world:get(stateId, RoundState)

    if roundState.phase == "Fighting" then
        for id, health, owner in world:query(Health, Owner) do
            if health.current <= 0 then
                local winnerIsA = false
                for otherId, otherHealth in world:query(Health) do
                    if otherId ~= id and otherHealth.current > 0 then
                        winnerIsA = true
                    end
                end

                local newScoreA = roundState.scoreA + (winnerIsA and 1 or 0)
                local newScoreB = roundState.scoreB + (winnerIsA and 0 or 1)

                local phase = "RoundOver"
                if newScoreA >= 3 or newScoreB >= 3 then
                    phase = "MatchOver" 
                end
                world:insert(stateId, roundState:patch({
                    scoreA = newScoreA,
                    scoreB = newScoreB,
                    phase = phase,
                }))
                pendingResetAt = os.clock() + ROUND_RESET_DELAY
            end
        end
    elseif roundState.phase == "RoundOver" then
        if pendingResetAt and os.clock() >= pendingResetAt then 
            respawnAll(world)
            world:insert(stateId, roundState:patch({
                phase = "Fighting",
                currentRound = roundState.currentRound + 1,
            }))
            pendingResetAt = nil
        end
    end
    -- "Match over" phase wont do anything here. Show a win screen client-side and maybe queue for a rematch
end

return RoundSystem