-- ===============================
-- Inventory Cloner GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local InventoryGUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("ScrollingFrame")

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "InventoryClonerGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.3, 0.6)
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
-- Populate Inventory Items
-- ===============================
for _, slot in ipairs(InventoryGUI:GetChildren()) do
    if slot:IsA("Frame") and slot:FindFirstChild("Inner") then
        local itemFrame = slot.Inner
        local itemName = itemFrame:FindFirstChild("NameLabel") and itemFrame.NameLabel.Text or "Unknown"
        local itemId = itemFrame:FindFirstChild("Tags") and itemFrame.Tags:FindFirstChild("ItemId") and itemFrame.Tags.ItemId.Value or "?"
        local rarity = itemFrame:FindFirstChild("Tags") and itemFrame.Tags:FindFirstChild("Rarity") and itemFrame.Tags.Rarity.Value or "?"

        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,0,0,36)
        btn.Text = string.format("%s | ID: %s | Rarity: %s", itemName, itemId, rarity)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            local clone = nil
            -- Tool → Backpack
            if itemFrame:FindFirstChildOfClass("Tool") then
                clone = itemFrame:FindFirstChildOfClass("Tool"):Clone()
                clone.Parent = LocalPlayer.Backpack
            else
                -- Model → Workspace
                if itemFrame:FindFirstChildOfClass("Model") then
                    clone = itemFrame:FindFirstChildOfClass("Model"):Clone()
                    -- Set PrimaryPart jika belum ada
                    if not clone.PrimaryPart then
                        local firstPart = clone:FindFirstChildWhichIsA("BasePart") or clone:FindFirstChildWhichIsA("MeshPart")
                        if firstPart then
                            clone.PrimaryPart = firstPart
                        end
                    end
                    if clone.PrimaryPart then
                        clone:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame + Vector3.new(5,0,0))
                        clone.Parent = workspace
                    else
                        warn("Cannot clone model, no PrimaryPart:", itemName)
                    end
                end
            end
            if clone then
                print("Cloned:", itemName, "ID:", itemId, "Rarity:", rarity)
            end
        end)
    end
end
