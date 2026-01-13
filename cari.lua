-- ===============================
-- CLIENT-SIDE VISUAL RADAR (Realtime)
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Model path
local modelPath = {"Assets","SearchItems","DeadManCompass","Model"}

-- ===============================
-- GUI SETUP
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "VisualRadarGUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25,0.25)
frame.Position = UDim2.fromScale(0.7,0.7)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-20,0,30)
title.Position = UDim2.new(0,10,0,5)
title.Text = "Radar: DeadManCompass"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Radar area (for blips)
local radarFrame = Instance.new("Frame", frame)
radarFrame.Size = UDim2.fromScale(1,1)
radarFrame.Position = UDim2.new(0,0,0,0)
radarFrame.BackgroundTransparency = 0.7
radarFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", radarFrame).CornerRadius = UDim.new(0,8)

-- ===============================
-- GET MODEL FUNCTION
-- ===============================
local function getModel(path)
    local current = RS
    for _, name in ipairs(path) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

local radarBlip
radarBlip = Instance.new("Frame", radarFrame)
radarBlip.Size = UDim2.new(0,10,0,10)
radarBlip.BackgroundColor3 = Color3.fromRGB(255,0,0)
radarBlip.BorderSizePixel = 0
Instance.new("UICorner", radarBlip).CornerRadius = UDim.new(0,5)
radarBlip.Visible = false -- awalnya hidden

-- ===============================
-- UPDATE RADAR BLIP POSITION
-- ===============================
local function updateRadar()
    local model = getModel(modelPath)
    if model and model.PrimaryPart then
        radarBlip.Visible = true
        local playerPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
        if not playerPos then return end
        local modelPos = model.PrimaryPart.Position

        -- Hitung arah relatif ke player
        local relative = Vector3.new(modelPos.X - playerPos.X, 0, modelPos.Z - playerPos.Z)
        local distance = relative.Magnitude
        local maxDistance = 50 -- jarak radar max
        local scale = math.clamp(distance/maxDistance,0,1)

        -- Posisi blip di radar frame
        local angle = math.atan2(relative.Z, relative.X)
        local radius = scale * (radarFrame.AbsoluteSize.X/2 - 5)
        local cx, cy = radarFrame.AbsoluteSize.X/2, radarFrame.AbsoluteSize.Y/2
        local bx = cx + radius * math.cos(angle) - radarBlip.AbsoluteSize.X/2
        local by = cy + radius * math.sin(angle) - radarBlip.AbsoluteSize.Y/2

        radarBlip.Position = UDim2.new(0, bx, 0, by)
    else
        radarBlip.Visible = false
    end
end

-- ===============================
-- RUN UPDATE EVERY FRAME
-- ===============================
RunService.RenderStepped:Connect(updateRadar)
