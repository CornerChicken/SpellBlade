local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local REMOTE_NAMES = { "Attack", "Dodge", "Parry", "CastSpell" }

local remotesFolder

if RunService:IsServer() then
    remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "Remotes"
        remotesFolder.Parent = ReplicatedStorage
    end

    for _, name in REMOTE_NAMES do
        if not remotesFolder:FindFirstChild(name) then
            local remote = Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = remotesFolder
        end
    end
else
    remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
    if not remotesFolder then
        error("Remotes folder never replicated from the server — is the server script running?")
    end
end

local function getRemote(name)
    return remotesFolder:WaitForChild(name, 10)
end

return {
    Attack = getRemote("Attack"),
    Dodge = getRemote("Dodge"),
    Parry = getRemote("Parry"),
    CastSpell = getRemote("CastSpell"),
}