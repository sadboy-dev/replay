-- ===============================
-- Model & Tool Controller GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")

-- ===============================
-- SETTINGS
-- ===============================
local trackedObjects = {} -- {model = Instance, esp = {dot,line}}
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "ESP_Models"

-- ===============================
-- GUI
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "ModelToolController"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25,0.6)
frame.Position = UDim2.fromScale(0.7,0.2)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Model & Tool Controller"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(1,-10,1,-40)
listFrame.Position = UDim2.new(0,5,0,35)
listFrame.BackgroundTransparency = 1
listFrame.ScrollBarThickness = 4
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", listFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,6)

-- ===============================
-- FUNCTION TO CREATE LIST BUTTONS
-- ===============================
local function addObjectButton(obj)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = obj.Name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = listFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    
    btn.MouseButton1Click:Connect(function()
        if trackedObjects[obj] then
            -- Remove ESP
            for _,v in pairs(trackedObjects[obj].esp) do
                if v then v:Destroy() end
            end
            trackedObjects[obj] = nil
        else
            -- Add ESP
            local dot = Instance.new("Part")
            dot.Anchored = true
            dot.CanCollide = false
            dot.Size = Vector3.new(0.4,0.4,0.4)
            dot.Shape = Enum.PartType.Ball
            dot.BrickColor = BrickColor.new("Bright red")
            dot.Material = Enum.Material.Neon
            dot.Parent = espFolder

            local line = Instance.new("Part")
            line.Anchored = true
            line.CanCollide = false
            line.Size = Vector3.new(0.2,0.2,0.2)
            line.BrickColor = BrickColor.new("Bright yellow")
            line.Material = Enum.Material.Neon
            line.Parent = espFolder

            trackedObjects[obj] = {model=obj, esp={dot,line}}
        end
    end)
end

-- ===============================
-- POPULATE LIST FROM ReplicatedStorage
-- ===============================
for _, folder in pairs(ReplicatedStorage:GetDescendants()) do
    if folder:IsA("Model") or folder:IsA("Tool") then
        addObjectButton(folder)
    end
end

-- ===============================
-- UPDATE ESP EVERY FRAME
-- ===============================
RunService.RenderStepped:Connect(function()
    for obj,data in pairs(trackedObjects) do
        if obj.Parent then
            local root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if root then
                -- Dot position
                data.esp[1].CFrame = root.CFrame

                -- Line to player
                local line = data.esp[2]
                local plrPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
                if plrPos then
                    local dist = root.Position - plrPos
                    line.Size = Vector3.new(0.2,0.2,dist.Magnitude)
                    line.CFrame = CFrame.new(plrPos,root.Position) * CFrame.new(0,0,-dist.Magnitude/2)
                end
            end
        end
    end
end)

StarterGui:SetCore("SendNotification",{
    Title = "Model & Tool Controller",
    Text = "Click objects to track/untrack ESP",
    Duration = 5
})
