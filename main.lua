-- Replay Logger GUI (iOS / Mobile SAFE)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer

-- ===== SELF CHECK REMOTE =====
local REMOTE_NAME = "ReplayLogEvent"
local LogRemote = RS:FindFirstChild(REMOTE_NAME)

if not LogRemote then
    warn("[ReplayGUI] ReplayLogEvent not found")
    return
end

-- ===== STATE =====
local paused = false
local buffer = {}
local lines = {}

table.insert(lines, "=== REPLAY ACTIVITY LOG ===")
table.insert(lines, "Status: LIVE")
table.insert(lines, "===========================\n")

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "ReplayLoggerGUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.9, 0.8)
frame.Position = UDim2.fromScale(0.05, 0.1)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- ===== TITLE =====
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "Replay Activity Logger (Tap & Copy)"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- ===== TEXT BOX (LOG) =====
local box = Instance.new("TextBox", frame)
box.Position = UDim2.new(0, 10, 0, 50)
box.Size = UDim2.new(1, -20, 1, -100)
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextWrapped = false
box.TextEditable = true -- WAJIB UNTUK iOS COPY
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.Font = Enum.Font.Code
box.TextSize = 13
box.TextColor3 = Color3.fromRGB(220,220,220)
box.BackgroundColor3 = Color3.fromRGB(15,15,15)
box.BorderSizePixel = 0
box.Text = table.concat(lines, "\n")
Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

-- ===== BUTTON MAKER =====
local function makeButton(text, x)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.28, 0, 0, 32)
    b.Position = UDim2.new(x, 0, 1, -38)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local pauseBtn = makeButton("⏸ PAUSE", 0.03)
local playBtn  = makeButton("▶ PLAY", 0.36)
local clearBtn = makeButton("🧹 CLEAR", 0.69)

-- ===== LOG FUNCTION =====
local function refresh()
    box.Text = table.concat(lines, "\n")
    box.CursorPosition = #box.Text + 1
end

local function addLine(text)
    table.insert(lines, text)
    refresh()
end

-- ===== REMOTE LISTENER =====
LogRemote.OnClientEvent:Connect(function(tag, text)
    local line = "[" .. tag .. "] " .. text

    if paused then
        table.insert(buffer, line)
    else
        addLine(line)
    end
end)

-- ===== BUTTON LOGIC =====
pauseBtn.MouseButton1Click:Connect(function()
    paused = true
    addLine("\n=== PAUSED ===")
end)

playBtn.MouseButton1Click:Connect(function()
    paused = false
    addLine("\n=== RESUMED ===")
    for _,l in ipairs(buffer) do
        addLine(l)
    end
    buffer = {}
end)

clearBtn.MouseButton1Click:Connect(function()
    lines = {
        "=== REPLAY ACTIVITY LOG ===",
        "CLEARED",
        "===========================\n"
    }
    buffer = {}
    refresh()
end)

-- ===== NOTIFICATION =====
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Replay Logger";
        Text = "Tap TextBox → Select All → Copy";
        Duration = 6;
    })
end)
