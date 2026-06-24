-- Net
-- Faster way to use Remote events, functions and more

local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Net = {}

local IS_SERVER = RunService:IsServer()
local FOLDER_NAME = 'NetRemotes' -- Change here for your remotes folder path // Or just let like this (the code creates one for you)

local remotesFolder
if IS_SERVER then
    remotesFolder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
    if not remotesFolder then
        remotesFolder = Instance.new('Folder')
        remotesFolder.Name = FOLDER_NAME
        remotesFolder.Parent = ReplicatedStorage
    end
else
    remotesFolder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
end

local function getRemote(name: string) : RemoteEvent
    if IS_SERVER then
        local remote = remotesFolder:FindFirstChild(name)
        if not remote then
            remote = Instance.new('RemoteEvent')
            remote.Name = name
            remote.Parent = remotesFolder
        end
        return remote
    end
    return remotesFolder:WaitForChild(name)
end

function Net.Ensure(...: string)
    assert(IS_SERVER, "Net.Ensure only on server")
    for _, name in {...} do
        getRemote(name)
    end
end

function Net.FireClient(name: string, player: Player, ...)
    assert(IS_SERVER, 'Net.FireClient only on server')
    getRemote(name):FireClient(player, ...)
end

function Net.FireAllClients(name: string, ...)
    assert(IS_SERVER, 'Net.FireAllClients only on server')
    getRemote(name):FireAllClients(...)
end

function Net.FireServer(name: string, ...)
    assert(not IS_SERVER, 'Net.FireServer only on client')
    getRemote(name):FireServer(...)
end

function Net.On(name: string, callback: (...any)->()): RBXScriptConnection
    local remote = getRemote(name)
    if IS_SERVER then
        return remote.OnServerEvent:Connect(callback)
    end
    return remote.OnClientEvent:Connect(callback)
end

return Net
