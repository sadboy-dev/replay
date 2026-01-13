-- ===============================
-- Remote Logger (RE) untuk Enchant
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- Tunggu folder RE
local success, REFolder = pcall(function()
    return ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("RE")
end)

if not success then
    warn("Folder RE tidak ditemukan. Pastikan folder sleitnick_net@0.2.0/RE ada!")
    return
end

print("[LOGGER] Folder RE ditemukan, mulai monitoring RemoteEvent/RemoteFunction...")

-- Fungsi untuk log param
local function logParams(name, ...)
    local args = {...}
    print(string.rep("-",40))
    print("[LOGGER] Remote called:", name)
    for i,arg in ipairs(args) do
        print(string.format("Param %d:", i), arg)
    end
    print(string.rep("-",40))
end

-- Monitor semua anak di RE
for _, remote in ipairs(REFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            logParams(remote.Name, ...)
        end)
    elseif remote:IsA("RemoteFunction") then
        local oldInvoke = remote.InvokeClient
        -- override InvokeClient untuk log (jika digunakan)
        remote.InvokeClient = function(player, ...)
            logParams(remote.Name, ...)
            if oldInvoke then
                return oldInvoke(player, ...)
            end
        end
    end
end

StarterGui:SetCore("SendNotification", {
    Title = "Remote Logger",
    Text = "Logger RE aktif, semua RemoteEvent/Function akan tercatat.",
    Duration = 5
})
