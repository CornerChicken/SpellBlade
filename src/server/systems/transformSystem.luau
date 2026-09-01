local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Components
local Transform = require(ReplicatedStorage.Shared.components.Transform)
local Projectile = require(ReplicatedStorage.Shared.components.Projectile)
local Owner = require(ReplicatedStorage.Shared.components.Owner)
local RenderModel = require(ReplicatedStorage.Shared.components.RenderModel)

local function transformSystem(world)
	-- 1. SYNC CHARACTERS: Read physics from Roblox HumanoidRootPart into Matter World
	for entityId, owner, transform in world:query(Owner, Transform) do
		local player = owner.player
		local character = player and player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")

		if hrp then
			-- Only insert if CFrame actually changed to avoid unnecessary component mutation signals
			if transform.cframe ~= hrp.CFrame then
				world:insert(entityId, Transform({
					cframe = hrp.CFrame,
				}))
			end
		end
	end

	-- 2. SYNC PROJECTILES & VISUALS: Write Matter Transform CFrame to Workspace Parts/Models
	for entityId, renderModel, transform in world:query(RenderModel, Transform) do
		local model = renderModel.model
		if not model or not model.Parent then continue end

		-- Check if this entity is a projectile
		local isProjectile = world:get(entityId, Projectile) ~= nil

		if isProjectile then
			-- Projectiles use fast BulkMoveTo/PivotTo for maximum frame throughput
			if model:IsA("BasePart") then
				model.CFrame = transform.cframe
			elseif model:IsA("Model") and model.PrimaryPart then
				model:PivotTo(transform.cframe)
			end
		else
			-- Standard entity visual sync
			if model:IsA("Model") and model.PrimaryPart then
				if model.PrimaryPart.CFrame ~= transform.cframe then
					model:PivotTo(transform.cframe)
				end
			elseif model:IsA("BasePart") then
				model.CFrame = transform.cframe
			end
		end
	end
end

return transformSystem