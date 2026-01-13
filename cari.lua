-- ===============================
-- Model/Tool Cloner GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Folder target untuk clone (ubah sesuai kebutuhan)
local targetFolder = ReplicatedStorage:WaitForChild("Model") -- contoh folder

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "ClonerGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25, 0.5)
frame.Position = UDim2.fromScale(0.05, 0.2)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Model/Tool Cloner"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- ScrollFrame untuk list item
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-40)
scroll.Position = UDim2.new(0,5,0,35)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,4)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Fungsi untuk buat tombol clone
local function createCloneButton(item)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = item.Name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.Parent = scroll

    btn.MouseButton1Click:Connect(function()
        local success, cloned = pcall(function()
            return item:Clone()
        end)
        if success and cloned then
            if cloned:IsA("Tool") then
                cloned.Parent = LocalPlayer.Backpack
                StarterGui:SetCore("SendNotification", {
                    Title = "Cloner",
                    Text = "Cloned "..item.Name.." ke Backpack!",
                    Duration = 3
                })
            elseif cloned:IsA("Model") then
                -- Pastikan ada PrimaryPart agar bisa di CFrame
                local root = cloned.PrimaryPart or cloned:FindFirstChildWhichIsA("BasePart")
                if root then
                    cloned:SetPrimaryPartCFrame(CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(5,0,0)))
                end
                cloned.Parent = Workspace
                StarterGui:SetCore("SendNotification", {
                    Title = "Cloner",
                    Text = "Cloned "..item.Name.." ke Workspace!",
                    Duration = 3
                })
            else
                cloned.Parent = Workspace
                StarterGui:SetCore("SendNotification", {
                    Title = "Cloner",
                    Text = "Cloned "..item.Name.."!",
                    Duration = 3
                })
            end
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Cloner",
                Text = "Gagal clone "..item.Name,
                Duration = 3
            })
        end
    end)
end

-- Generate tombol untuk setiap item di folder
for _, item in ipairs(targetFolder:GetChildren()) do
    createCloneButton(item)
end
