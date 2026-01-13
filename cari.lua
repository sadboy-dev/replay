-- ===============================
-- Safe Model/Tool Cloner GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Folder target (gunakan folder bebas, jangan _Index/Packages)
local folder = ReplicatedStorage:FindFirstChild("Models")
if not folder then
    warn("Folder 'Models' tidak ditemukan di ReplicatedStorage!")
    return
end

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "SafeModelClonerGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25, 0.5)
frame.Position = UDim2.fromScale(0.7, 0.25)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Safe Model/Tool Cloner"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-20,1,-50)
scroll.Position = UDim2.new(0,10,0,45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,6)

-- ===============================
-- Create Button for each Model/Tool
-- ===============================
for _, item in ipairs(folder:GetChildren()) do
    if item:IsA("Model") or item:IsA("Tool") then
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,0,0,36)
        btn.Text = item.Name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            local success, clone = pcall(function()
                return item:Clone()
            end)

            if not success or not clone then
                warn("Gagal clone "..item.Name)
                return
            end

            -- Set PrimaryPart otomatis kalau model
            if clone:IsA("Model") and not clone.PrimaryPart then
                local firstPart = clone:FindFirstChildWhichIsA("BasePart")
                if firstPart then
                    clone.PrimaryPart = firstPart
                else
                    warn(clone.Name.." tidak punya part untuk PrimaryPart!")
                    return
                end
            end

            -- Spawn ke tempat aman
            if clone:IsA("Tool") then
                -- Tools bisa langsung ke Backpack
                pcall(function()
                    clone.Parent = LocalPlayer:WaitForChild("Backpack")
                end)
            else
                -- Model ke Workspace, offset sedikit dari karakter
                if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                    local charCFrame = LocalPlayer.Character.PrimaryPart.CFrame
                    pcall(function()
                        clone.Parent = Workspace
                        clone:SetPrimaryPartCFrame(charCFrame + Vector3.new(5,0,0))
                    end)
                else
                    warn("Tidak dapat menentukan posisi karakter!")
                    clone.Parent = Workspace -- fallback
                end
            end
        end)
    end
end
