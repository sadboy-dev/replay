local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LogRemote = ReplicatedStorage:WaitForChild("ReplayLogEvent")
local player = Players.LocalPlayer

local paused = false
local buffer = {}
local filters = {MOVE=true,ANIM=true,STATE=true,EVENT=true,SYSTEM=true}

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ReplayLogGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.65,0.65)
frame.Position = UDim2.fromScale(0.175,0.175)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Active = true
frame.Draggable = true

-- Scroll
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0,8,0,40)
scroll.Size = UDim2.new(1,-16,1,-90)
scroll.CanvasSize = UDim2.new()
scroll.ScrollBarImageTransparency = 0.2

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,4)

-- Add log
local function addLog(tag,text)
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
        tag=="MOVE" and Color3.fromRGB(170,170,170)
        or tag=="ANIM" and Color3.fromRGB(120,180,255)
        or tag=="EVENT" and Color3.fromRGB(255,180,120)
        or tag=="STATE" and Color3.fromRGB(180,255,180)
        or Color3.fromRGB(255,255,255)

    lbl.Parent = scroll
    task.wait()
    scroll.CanvasSize = UDim2.fromOffset(0,layout.AbsoluteContentSize.Y)
    scroll.CanvasPosition = Vector2.new(0, math.max(0,scroll.CanvasSize.Y.Offset-scroll.AbsoluteWindowSize.Y))
end

-- Remote
LogRemote.OnClientEvent:Connect(function(tag,text)
    if paused then
        table.insert(buffer,{tag,text})
    else
        addLog(tag,text)
    end
end)

-- Buttons
local function button(txt,x)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.15,0,0,30)
    b.Position = UDim2.new(x,5,0,5)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local pause = button("⏸ Pause",0)
local play = button("▶ Play",0.16)
local clear = button("🧹 Clear",0.32)

pause.MouseButton1Click:Connect(function() paused=true end)
play.MouseButton1Click:Connect(function()
    paused=false
    for _,v in ipairs(buffer) do addLog(v[1],v[2]) end
    buffer={}
end)
clear.MouseButton1Click:Connect(function()
    scroll:ClearAllChildren()
    layout.Parent = scroll
end)

-- Filters
local i=0
for k,_ in pairs(filters) do
    local f = button(k,0.5+i*0.12)
    f.MouseButton1Click:Connect(function()
        filters[k] = not filters[k]
        f.TextTransparency = filters[k] and 0 or 0.6
    end)
    i+=1
end
