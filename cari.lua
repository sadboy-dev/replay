-- ===============================
-- SAFE REMOTE LOGGER
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Folder target remotes
-- Ganti sesuai path remote yang ingin dipantau
local RemotesFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE")

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "SafeRemoteLoggerGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.35, 0.5)
frame.Position = UDim2.fromScale(0.3, 0.25)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "🔍 Safe Remote Logger"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local logBox = Instance.new("TextBox", frame)
logBox.Size = UDim2.new(1,-20,1,-40)
logBox.Position = UDim2.new(0,10,0,35)
logBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
logBox.TextColor3 = Color3.new(1,1,1)
logBox.Text = "=== LOG PARAMETER ASLI ===\n"
logBox.MultiLine = true
logBox.ClearTextOnFocus = false
logBox.TextWrapped = true
logBox.TextEditable = false
Instance.new("UICorner", logBox).CornerRadius = UDim.new(0,6)

local function log(msg)
    logBox.Text = logBox.Text .. "\n" .. msg
    logBox.CursorPosition = #logBox.Text + 1
end

-- ===============================
-- Hook FireServer / InvokeServer
-- ===============================
for _, remote in ipairs(RemotesFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            -- LOG PARAMETER ASLI SAAT DIPANGGIL MANUAL
            log("[EVENT] "..remote.Name.." called with args: "..table.concat(args,", "))
            return oldFire(self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
        local oldInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            -- LOG PARAMETER ASLI SAAT DIPANGGIL MANUAL
            log("[FUNC] "..remote.Name.." called with args: "..table.concat(args,", "))
            return oldInvoke(self, ...)
        end
    end
end

log("✅ Logger siap. Sekarang jalankan enchant manual di game untuk melihat parameter asli.")
