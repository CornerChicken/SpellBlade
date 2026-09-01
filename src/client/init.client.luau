local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Shared.remotes)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent) -- gameProcessedEvent is true if the keypress was already used by the game (e.g. typing in chat). Checking it stops you from attacking while typing in chat
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Remotes.Attack:FireServer() --FireServer sends a message from the client to the server. The server can listen for this message and respond accordingly
    elseif input.KeyCode == Enum.KeyCode.Q then
        Remotes.Dodge:FireServer()
    elseif input.KeyCode == Enum.KeyCode.F then
        Remotes.Parry:FireServer()
    end
end)