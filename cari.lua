-- =====================================================
-- Fish + Enchant Stone Fake Tool Cloner GUI (CLIENT ONLY)
-- =====================================================
if not game:IsLoaded() then game.Loaded:Wait() end

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- SAFE FIND PATH (NO INFINITE YIELD)
-- =====================================================
local function safePath(root, pathTable)
    local current = root
    for _, name in ipairs(pathTable) do
        current = current and current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

-- SOURCE FOLDERS
local FishFolder = safePath(ReplicatedStorage, {
    "Modules","ModelDownloader","Collection","Fish"
})

local EnchantFolder = safePath(ReplicatedStorage, {
    "Modules","ModelDownloader","Collection","Enchant Stones","Enchant Stone"
})

-- =====================================================
-- COLLECT MODELS RECURSIVE
-- =====================================================
local function collectModels(folder, list)
    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("Model") then
            table.insert(list, v)
        elseif v:IsA("Folder") then
            collectModels(v, list)
        end
    end
end

local AllModels = {}

if FishFolder then
    collectModels(FishFolder, AllModels)
end

if EnchantFolder then
    collectModels(EnchantFolder, AllModels)
end

if #AllModels == 0 then
    warn("Tidak ada model Fish / Enchant Stone ditemukan")
    return
end

-- =====================================================
-- MODEL → FAKE TOOL (STABLE)
-- =====================================================
local function ModelToFakeTool(model)
    local handle = model:FindFirstChildWhichIsA("BasePart", true)
    if not handle then
        warn("Skip model (no BasePart):", model:GetFullName())
        return
    end

    local tool = Instance.new("Tool")
    tool.Name = model.Name
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handleClone = handle:Clone()
    handleClone.Name = "Handle"
    handleClone.Anchored = false
    handleClone.CanCollide = false
    handleClone.Parent = tool

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part ~= handle then
            local p = part:Clone()
            p.Anchored = false
            p.CanCollide = false
            p.Parent = tool

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = handleClone
            weld.Part1 = p
            weld.Parent = handleClone
        end
    end

    tool.Parent = LocalPlayer.Backpack
end

-- =====================================================
-- GUI
-- =====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ModelFakeToolGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.3, 0.65)
frame.Position = UDim2.fromScale(0.67, 0.18)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,42)
title.BackgroundTransparency = 1
title.Text = "Fish + Enchant Stone → Fake Tool"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0,10,0,48)
scroll.Size = UDim2.new(1,-20,1,-58)
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

-- =====================================================
-- CREATE BUTTONS
-- =====================================================
for _, model in ipairs(AllModels) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,0,0,36)
    btn.Text = model.Name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        ModelToFakeTool(model)
    end)
end
