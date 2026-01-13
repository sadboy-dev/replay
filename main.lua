-- ===============================
-- FIC: Client-Only Event Logger
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- ===============================
-- STATE
-- ===============================
local paused = false
local logs = {}
local buffer = {}

-- helper untuk add log
local function addLog(line)
    if paused then
        table.insert(buffer,line)
    else
        table.insert(logs,line)
        box.Text = table.concat(logs,"\n")
        -- auto-scroll ke bawah
        box.CursorPosition = #box.Text + 1
    end
end

-- ===============================
-- GUI SETUP
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "ClientEventLoggerGUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.9,0.8)
frame.Position = UDim2.fromScale(0.05,0.1)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
-- draggable disabled agar iOS aman
frame.Draggable = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-20,0,40)
title.Position = UDim2.new(0,10,0,5)
title.Text = "Client Event Logger (Tap & Copy)"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local box = Instance.new("TextBox", frame)
box.Position = UDim2.new(0,10,0,50)
box.Size = UDim2.new(1,-20,1,-100)
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextWrapped = false
box.TextEditable = true
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.Font = Enum.Font.Code
box.TextSize = 13
box.TextColor3 = Color3.fromRGB(220,220,220)
box.BackgroundColor3 = Color3.fromRGB(15,15,15)
box.BorderSizePixel = 0
Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
box.Text = "=== CLIENT EVENT LOG ===\n"

-- ===============================
-- BUTTONS
-- ===============================
local function makeButton(txt,x)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.28,0,0,32)
    b.Position = UDim2.new(x,0,1,-38)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local pauseBtn = makeButton("⏸ PAUSE",0.03)
local playBtn  = makeButton("▶ PLAY",0.36)
local clearBtn = makeButton("🧹 CLEAR",0.69)

pauseBtn.MouseButton1Click:Connect(function()
    paused = true
    addLog("=== PAUSED ===")
end)

playBtn.MouseButton1Click:Connect(function()
    paused = false
    addLog("=== RESUMED ===")
    for _,v in ipairs(buffer) do
        addLog(v)
    end
    buffer = {}
end)

clearBtn.MouseButton1Click:Connect(function()
    logs = {"=== CLIENT EVENT LOG CLEARED ==="}
    buffer = {}
    box.Text = table.concat(logs,"\n")
end)

-- ===============================
-- CLIENT-ONLY EVENT CAPTURE
-- ===============================
-- NOTE: hanya capture client-side simulated events
-- misalnya tombol, mouse click, key press
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    addLog(string.format("[INPUT] Key/Button pressed: %s", tostring(input.KeyCode or input.UserInputType)))
end)

-- contoh mouse button capture
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        addLog("[INPUT] Mouse Button 1 Click")
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        addLog("[INPUT] Mouse Button 2 Click")
    end
end)

-- ===============================
-- NOTIFICATION iOS
-- ===============================
pcall(function()
    StarterGui:SetCore("SendNotification",{
        Title = "Client Event Logger",
        Text = "Tap TextBox → Select All → Copy\nEvents captured client-only",
        Duration = 6
    })
end)
