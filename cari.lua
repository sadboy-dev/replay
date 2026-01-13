-- ===============================
-- Inventory GUI Cloner (From GUI)
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "InventoryClonerGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.35, 0.55)
frame.Position = UDim2.fromScale(0.32, 0.22)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
-- Function to clone items
-- ===============================
local function cloneItem(item)
    if not item then return end
    local clone = item:Clone()
    if clone:IsA("Tool") then
        clone.Parent = LocalPlayer.Backpack
    elseif clone:IsA("Model") then
        if not clone.PrimaryPart then
            clone.PrimaryPart = clone:FindFirstChildWhichIsA("BasePart")
        end
        if clone.PrimaryPart and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            clone:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame + Vector3.new(5,0,0))
        end
        clone.Parent = Workspace
    end
end

-- ===============================
-- List Inventory Items from GUI
-- ===============================
local function listInventory()
    scroll:ClearAllChildren()

    local invGUI = LocalPlayer.PlayerGui:FindFirstChild("Inventory")
    if not invGUI then return end

    local mainFrame = invGUI:FindFirstChild("Main")
    if not mainFrame then return end

    local itemsFolder = mainFrame:FindFirstChild("Items") or mainFrame:FindFirstChildWhichIsA("Frame")
    if not itemsFolder then return end

    for _, slot in ipairs(itemsFolder:GetChildren()) do
        if slot:IsA("Frame") then
            local inner = slot:FindFirstChild("Inner")
            if inner then
                local itemClone = inner:FindFirstChildWhichIsA("Model") or inner:FindFirstChildWhichIsA("Tool")
                if itemClone then
                    local btn = Instance.new("TextButton", scroll)
                    btn.Size = UDim2.new(1,0,0,36)
                    btn.Text = itemClone.Name.." ["..itemClone.ClassName.."]"
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 14
                    btn.TextColor3 = Color3.new(1,1,1)
                    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

                    btn.MouseButton1Click:Connect(function()
                        cloneItem(itemClone)
                    end)
                end
            end
        end
    end
end

-- ===============================
-- Button Refresh All
-- ===============================
local refreshBtn = Instance.new("TextButton", frame)
refreshBtn.Size = UDim2.new(0.4,0,0,30)
refreshBtn.Position = UDim2.new(0.3,0,1,-35)
refreshBtn.Text = "Refresh Inventory"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 14
refreshBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
refreshBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,6)

refreshBtn.MouseButton1Click:Connect(function()
    listInventory()
end)

-- ===============================
-- Initial Populate
-- ===============================
listInventory()
