local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.components)
local DodgeVelocity = require(ReplicatedStorage.Shared.components.DodgeVelocity)
local CombatState = require(ReplicatedStorage.Shared.components.CombatState)
local Owner = require(ReplicatedStorage.Shared.components.Owner)

local NORMAL_WALK_SPEED = 16 -- 💡 Roblox's default Humanoid walk speed

local function MovementSystem(world)
    local now = os.clock()

    for id, dodge, combatState in world:query(DodgeVelocity, CombatState) do
        local owner = world:get(id, Owner)
        local character = owner and owner.player and owner.player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if now >= dodge.endsAt then
            local constraint = hrp:FindFirstChild("DodgeVelocity")
            if constraint then
                constraint:Destroy()
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = NORMAL_WALK_SPEED
            end

            world:remove(id, DodgeVelocity)
            world:insert(id, combatState:patch({ state = "Idle" }))
        else
            if not hrp:FindFirstChild("DodgeVelocity") then

                local attachment = hrp:FindFirstChild("DodgeAttachment")
                if not attachment then
                    attachment = Instance.new("Attachment")
                    attachment.Name = "DodgeAttachment"
                    attachment.Parent = hrp
                end

                local linearVelocity = Instance.new("LinearVelocity")
                linearVelocity.Name = "DodgeVelocity"
                linearVelocity.Attachment0 = attachment
                linearVelocity.MaxForce = math.huge
                linearVelocity.VectorVelocity = dodge.direction * dodge.speed
                linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
                linearVelocity.Parent = hrp
            end
        end
    end
end

return MovementSystem