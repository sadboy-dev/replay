-- ===============================
-- CLIENT-SIDE ESP + LINE TO MODEL
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Model path
local modelPath = {"Assets","SearchItems","DeadManCompass","Model"}

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

-- ===============================
-- CREATE ESP
-- ===============================
local currentESP
local linePart -- invisible part for line
local beam -- beam connecting player to target

local function createESP(model)
    if not model or not model.PrimaryPart then return end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255,255,255)
    highlight.OutlineTransparency = 0
    highlight.Parent = LP:WaitForChild("PlayerGui")

    -- Beam
    linePart = Instance.new("Part")
    linePart.Anchored = true
    linePart.CanCollide = false
    linePart.Transparency = 1
    linePart.Size = Vector3.new(0.2,0.2,0.2)
    linePart.Parent = workspace

    local attachment0 = Instance.new("Attachment", LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character.PrimaryPart)
    local attachment1 = Instance.new("Attachment", model.PrimaryPart)

    beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.Color = ColorSequence.new(Color3.fromRGB(0,255,0))
    beam.FaceCamera = true
    beam.Parent = linePart

    return highlight
end

-- ===============================
-- UPDATE / REFRESH ESP + LINE
-- ===============================
local function updateESP()
    local model = getModel(modelPath)
    if model and model.PrimaryPart and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        if not currentESP then
            currentESP = createESP(model)
        else
            currentESP.Adornee = model
            -- Update beam attachments if needed
            beam.Attachment1.Position = model.PrimaryPart.Position
        end
    else
        if currentESP then
            currentESP:Destroy()
            currentESP = nil
        end
        if linePart then
            linePart:Destroy()
            linePart = nil
            beam = nil
        end
    end
end

-- ===============================
-- RUN EVERY FRAME
-- ===============================
RunService.RenderStepped:Connect(updateESP)
