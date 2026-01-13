-- ===============================
-- FishIt FULL Scanner + GUI Read-Only (Stable)
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- ===============================
-- SCAN REPLICATEDSTORAGE
-- ===============================
local lines = {}
table.insert(lines, "=== FISHIT REPLICATEDSTORAGE SCAN ===\n")

local count = 0
for _, v in ipairs(RS:GetDescendants()) do
    if v:IsA("Tool") or v:IsA("Model") then
        count += 1
        table.insert(lines, v.ClassName .. " | " .. v:GetFullName())
    end
end

table.insert(lines, "\nTOTAL FOUND: " .. count)
table.insert(lines, "=== END ===")

local finalText = table.concat(lines, "\n")

-- ===============================
-- GUI SETUP
-- ===============================
local minimized = false
local originalSize = UDim2.fromScale(0.9,0.8)
local originalPos  = UDim2.fromScale(0.05,0.1)

local gui = Instance.new("ScreenGui")
gui.Name = "FishItScannerGUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = originalSize
frame.Position = originalPos
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-60,0,40)
title.Position = UDim2.new(0,10,0,5)
title.Text = "FishIt FULL Scanner"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- ===============================
-- TEXTBOX (READ-ONLY & SCROLLABLE)
-- ===============================
local box = Instance.new("TextBox", frame)
box.Position = UDim2.new(0,10,0,50)
box.Size = UDim2.new(1,-20,1,-100)
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextWrapped = false
box.TextEditable = false   -- read-only
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.Font = Enum.Font.Code
box.TextSize = 13
box.TextColor3 = Color3.fromRGB(220,220,220)
box.BackgroundColor3 = Color3.fromRGB(15,15,15)
box.BorderSizePixel = 0
box.Text = finalText
box.ScrollingEnabled = true
Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

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
    box.Text = box.Text .. "\n[PAUSE CLICKED]"
end)

playBtn.MouseButton1Click:Connect(function()
    box.Text = box.Text .. "\n[PLAY CLICKED]"
end)

clearBtn.MouseButton1Click:Connect(function()
    box.Text = finalText
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
        frame.Size = originalSize
        frame.Position = originalPos
        box.Visible = true
        pauseBtn.Visible = true
        playBtn.Visible = true
        clearBtn.Visible = true
        minimized = false
    else
        frame.Size = UDim2.new(0,200,0,40)
        box.Visible = false
        pauseBtn.Visible = false
        playBtn.Visible = false
        clearBtn.Visible = false
        minimized = true
    end
end)

-- ===============================
-- iOS Notification
-- ===============================
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "FishIt Scanner",
        Text = "Tap TextBox → Select All → Copy\nMinimize button available",
        Duration = 6,
    })
end)
