-- ReplayLogGUI.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local REMOTE_NAME = "ReplayLogEvent"

local LogRemote = ReplicatedStorage:WaitForChild(REMOTE_NAME, 5)
if not LogRemote then
    warn("[ReplayLogGUI] ReplayLogEvent not found")
    return
end

-- ========================
-- STATE
-- ========================
local paused = false
local buffer = {}
local filters = {
    MOVE=true, ANIM=true, STATE=true, EVENT=true, SYSTEM=true
}

-- ========================
-- GUI
-- ========================
local gui = Instance.new("ScreenGui")
gui.Name = "ReplayLogGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.65,0.65)
frame.Position = UDim2.fromScale(0.175,0.175)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Active = true
frame.Draggable = true

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0,8,0,42)
scroll.Size = UDim2.new(1,-16,1,-92)
scroll.CanvasSize = UDim2.new()
scroll.ScrollBarImageTransparency = 0.2

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,4)

-- ========================
-- LOG DISPLAY
-- ========================
local function addLog(tag, text)
    if not filters[tag] then return end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,20)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.TextWrapped = true
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 14
    lbl.TextXAlignment = Left
    lbl.TextYAlignment = Top
    lbl.Text = "["..tag.."] "..text

    lbl.TextColor3 =
        tag=="MOVE" and Color3.fromRGB(180,180,180)
        or tag=="ANIM" and Color3.fromRGB(120,170,255)
        or tag=="STATE" and Color3.fromRGB(140,255,140)
        or tag=="EVENT" and Color3.fromRGB(255,190,120)
        or Color3.new(1,1,1)

    lbl.Parent = scroll
    task.wait()
    scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
    scroll.CanvasPosition = Vector2.new(
        0,
        math.max(0, scroll.CanvasSize.Y.Offset - scroll.AbsoluteWindowSize.Y)
    )
end

-- ========================
-- REMOTE HANDLER
-- ========================
LogRemote.OnClientEvent:Connect(function(tag, text)
    if paused then
        table.insert(buffer, {tag, text})
    else
        addLog(tag, text)
    end
end)

-- ========================
-- BUTTONS
-- ========================
local function button(txt, x)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.15,0,0,30)
    b.Position = UDim2.new(x,5,0,5)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local pauseBtn = button("⏸ Pause",0)
local playBtn  = button("▶ Play",0.16)
local clearBtn = button("🧹 Clear",0.32)

pauseBtn.MouseButton1Click:Connect(function()
    paused = true
end)

playBtn.MouseButton1Click:Connect(function()
    paused = false
    for _,v in ipairs(buffer) do
        addLog(v[1], v[2])
    end
    buffer = {}
end)

clearBtn.MouseButton1Click:Connect(function()
    scroll:ClearAllChildren()
    layout.Parent = scroll
end)

-- ========================
-- FILTER BUTTONS
-- ========================
local i = 0
for tag,_ in pairs(filters) do
    local f = button(tag, 0.5 + i*0.12)
    f.MouseButton1Click:Connect(function()
        filters[tag] = not filters[tag]
        f.TextTransparency = filters[tag] and 0 or 0.6
    end)
    i += 1
end
