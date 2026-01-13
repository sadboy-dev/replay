-- ===============================
-- Inventory Fish Cloner GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local InventoryGUI = PlayerGui:WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("ScrollingFrame")
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Workspace = game:GetService("Workspace")

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "FishClonerGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

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
title.Text = "Fish Cloner"
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
-- Function to populate fish items
-- ===============================
local function populateFishGUI()
    -- Clear old buttons
    scroll:ClearAllChildren()
    for _, slot in ipairs(InventoryGUI:GetChildren()) do
        if slot:IsA("Frame") and slot:FindFirstChild("Inner") then
            local itemFrame = slot.Inner
            local tags = itemFrame:FindFirstChild("Tags")
            local itemName = itemFrame:FindFirstChild("NameLabel") and itemFrame.NameLabel.Text or "Unknown"
            local itemId = tags and tags:FindFirstChild("ItemId") and tags.ItemId.Value or "?"
            local rarity = tags and tags:FindFirstChild("Rarity") and tags.Rarity.Value or "?"
            local itemType = tags and tags:FindFirstChild("Type") and tags.Type.Value or "Unknown"

            -- Only fish
            if itemType:lower() == "fish" then
                local btn = Instance.new("TextButton", scroll)
                btn.Size = UDim2.new(1,0,0,36)
                btn.Text = string.format("%s | ID: %s | Rarity: %s", itemName, itemId, rarity)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextColor3 = Color3.new(1,1,1)
                btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

                -- Click to clone
                btn.MouseButton1Click:Connect(function()
                    local clone = itemFrame:Clone()
                    if clone then
                        clone.Parent = Backpack
                        print("Cloned fish:", itemName, "ID:", itemId, "Rarity:", rarity)
                    else
                        warn("Failed to clone:", itemName)
                    end
                end)
            end
        end
    end
end

-- Initial populate
populateFishGUI()

-- Optional: auto-refresh every few seconds
task.spawn(function()
    while task.wait(5) do
        populateFishGUI()
    end
end)
