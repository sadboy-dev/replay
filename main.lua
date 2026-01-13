-- ===============================
-- CLIENT-ONLY EVENT LOGGER (MINIMIZE)
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- ===============================
-- STATE
-- ===============================
local paused = false
local logs = {}
local buffer = {}
local minimized = false
local originalSize = UDim2.fromScale(0.9,0.8)
local originalPos  = UDim2.fromScale(0.05,0.1)

-- ===============================
-- GUI SETUP
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "ClientEventLoggerGUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = originalSize
frame.Position = originalPos
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-60,0,40) -- sisakan space untuk tombol minimize
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
    table.insert(logs,"=== PAUSED ===")
    box.Text = table.concat(logs,"\n")
    box.CursorPosition = #box.Text+1
end)

playBtn.MouseButton1Click:Connect(function()
    paused = false
    table.insert(logs,"=== RESUMED ===")
    for _,v in ipairs(buffer) do table.insert(logs,v) end
    buffer = {}
    box.Text = table.concat(logs,"\n")
    box.CursorPosition = #box.Text+1
end)

clearBtn.MouseButton1Click:Connect(function()
    logs = {"=== CLIENT EVENT LOG CLEARED ==="}
    buffer = {}
    box.Text = table.concat(logs,"\n")
end)

-- ===============================
-- MINIMIZE BUTTON
-- ===============================
local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Size = UDim2.new(0,40,0,32)
minimizeBtn.Position = UDim2.new(1,-45,0,4)
minimizeBtn.Text = "—"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0,6)

minimizeBtn.MouseButton1Click:Connect(function()
    if minimized then
        -- restore
        frame.Size = originalSize
        frame.Position = originalPos
        box.Visible = true
        pauseBtn.Visible = true
        playBtn.Visible = true
        clearBtn.Visible = true
        minimized = false
    else
        -- minimize
        frame.Size = UDim2.new(0,200,0,40)
        box.Visible = false
        pauseBtn.Visible = false
        playBtn.Visible = false
        clearBtn.Visible = false
        minimized = true
    end
end)

-- ===============================
-- CLIENT-ONLY EVENT CAPTURE
-- ===============================
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        table.insert(logs,"[KEY] "..tostring(input.KeyCode))
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        table.insert(logs,"[MOUSE] Left Click")
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        table.insert(logs,"[MOUSE] Right Click")
    elseif input.UserInputType == Enum.UserInputType.Touch then
        table.insert(logs,"[TOUCH] Screen tap")
    end
    box.Text = table.concat(logs,"\n")
    box.CursorPosition = #box.Text+1
end)

-- ===============================
-- iOS NOTIFICATION
-- ===============================
pcall(function()
    StarterGui:SetCore("SendNotification",{
        Title = "Client Event Logger",
        Text = "Tap TextBox → Copy\nMinimize button available",
        Duration = 6
    })
end)
