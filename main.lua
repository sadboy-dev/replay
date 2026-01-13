-- ===============================
-- FIC: Fully Independent Client
-- ===============================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ===============================
-- CHARACTER SETUP
-- ===============================
local char = LP.Character or LP.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- ===============================
-- LOG STORAGE
-- ===============================
local logs = {}
local buffer = {}
local paused = false

-- helper: add log
local function addLog(line)
    if paused then
        table.insert(buffer,line)
    else
        table.insert(logs,line)
        box.Text = table.concat(logs,"\n")
        box.CursorPosition = #box.Text+1
    end
end

-- ===============================
-- GUI SETUP
-- ===============================
local StarterGui = game:GetService("StarterGui")

local gui = Instance.new("ScreenGui")
gui.Name = "FICReplayLogger"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.9,0.8)
frame.Position = UDim2.fromScale(0.05,0.1)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-20,0,40)
title.Position = UDim2.new(0,10,0,5)
title.Text = "FIC Replay Logger (Tap & Copy)"
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
box.Text = "=== FIC REPLAY LOG ===\n"

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
local playBtn = makeButton("▶ PLAY",0.36)
local clearBtn = makeButton("🧹 CLEAR",0.69)

pauseBtn.MouseButton1Click:Connect(function()
    paused = true
    table.insert(logs,"=== PAUSED ===")
    box.Text = table.concat(logs,"\n")
end)

playBtn.MouseButton1Click:Connect(function()
    paused = false
    table.insert(logs,"=== RESUMED ===")
    for _,v in ipairs(buffer) do table.insert(logs,v) end
    buffer = {}
    box.Text = table.concat(logs,"\n")
end)

clearBtn.MouseButton1Click:Connect(function()
    logs = {"=== FIC REPLAY LOG CLEARED ==="}
    buffer = {}
    box.Text = table.concat(logs,"\n")
end)

-- ===============================
-- CLIENT-ONLY REPLAY CAPTURE
-- ===============================
local replayData = {} -- store {time,pos,anim,state}

-- movement capture
RunService.Heartbeat:Connect(function(dt)
    local t = tick()
    table.insert(replayData,{
        Time = t,
        Pos = hrp.Position,
        Anim = nil,
        State = hum:GetState()
    })
    addLog(string.format("[MOVE] [%.2f] (%.1f,%.1f,%.1f)", t, hrp.Position.X, hrp.Position.Y, hrp.Position.Z))
end)

-- animation capture
hum.AnimationPlayed:Connect(function(track)
    local t = tick()
    table.insert(replayData,{
        Time = t,
        Pos = hrp.Position,
        Anim = track.Animation.AnimationId,
        State = hum:GetState()
    })
    addLog(string.format("[ANIM] [%.2f] %s", t, track.Animation.AnimationId))
end)

-- state capture
hum.StateChanged:Connect(function(_,new)
    local t = tick()
    table.insert(replayData,{
        Time = t,
        Pos = hrp.Position,
        Anim = nil,
        State = new
    })
    addLog(string.format("[STATE] [%.2f] %s", t, tostring(new)))
end)

-- ===============================
-- CLIENT-ONLY PLAYBACK FUNCTION
-- ===============================
local playing = false
local playIndex = 1
local playbackSpeed = 1 -- 1 = realtime

local function PlayReplay()
    if playing then return end
    playing = true
    playIndex = 1
    table.insert(logs,"\n=== REPLAY START ===")
    box.Text = table.concat(logs,"\n")
    
    spawn(function()
        while playing and playIndex <= #replayData do
            local entry = replayData[playIndex]
            hrp.CFrame = CFrame.new(entry.Pos)
            if entry.Anim then
                hum:LoadAnimation(Instance.new("Animation",hum){AnimationId = entry.Anim}):Play()
            end
            playIndex += 1
            wait(0.03/playbackSpeed)
        end
        table.insert(logs,"=== REPLAY END ===")
        box.Text = table.concat(logs,"\n")
        playing = false
    end)
end

-- optional: press P to start playback
game:GetService("UserInputService").InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P then
        PlayReplay()
    end
end)

-- ===============================
-- NOTIFICATION (iOS friendly)
-- ===============================
pcall(function()
    StarterGui:SetCore("SendNotification",{
        Title = "FIC Replay Logger",
        Text = "Tap TextBox → Select All → Copy\nPress P for Playback",
        Duration = 6
    })
end)
