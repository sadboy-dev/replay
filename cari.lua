-- ===============================
-- Inventory Item Cloner GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- Folder Model/Tool
local CollectionFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ModelDownloader"):WaitForChild("Collection")

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "InventoryClonerGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.3, 0.5)
frame.Position = UDim2.fromScale(0.35, 0.2)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Inventory Cloner"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local refreshBtn = Instance.new("TextButton", frame)
refreshBtn.Size = UDim2.new(0.9,0,0,30)
refreshBtn.Position = UDim2.new(0.05,0,0,45)
refreshBtn.Text = "Refresh Inventory"
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.TextSize = 14
refreshBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
refreshBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,6)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-20,1,-80)
scroll.Position = UDim2.new(0,10,0,80)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,6)

-- ===============================
-- Function to populate GUI
-- ===============================
local function refreshInventory()
    -- Bersihkan dulu
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local inventory = LocalPlayer:FindFirstChild("Backpack")
    if not inventory then return end

    for _, item in ipairs(inventory:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Model") then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1,0,0,36)
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

            -- Nama, ID, Rarity
            local name = item.Name
            local id = item:GetAttribute("ItemId") or "UnknownID"
            local rarity = item:GetAttribute("Rarity") or "Unknown"

            btn.Text = string.format("%s | %s | %s", name, id, rarity)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextColor3 = Color3.new(1,1,1)

            btn.MouseButton1Click:Connect(function()
                local clone = item:Clone()
                if clone:IsA("Tool") then
                    clone.Parent = LocalPlayer.Backpack
                else
                    -- Set PrimaryPart jika belum ada
                    if not clone.PrimaryPart then
                        local primary = clone:FindFirstChildWhichIsA("BasePart") or clone:FindFirstChildWhichIsA("MeshPart")
                        if primary then clone.PrimaryPart = primary end
                    end
                    if clone.PrimaryPart then
                        clone.Parent = Workspace
                        clone:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame + Vector3.new(5,0,0))
                    else
                        warn("Cannot clone model, no PrimaryPart found: "..clone.Name)
                    end
                end
            end)
        end
    end
end

refreshBtn.MouseButton1Click:Connect(refreshInventory)

-- Auto refresh saat GUI dibuka
refreshInventory()
