-- ===============================
-- Inventory + Clone Fish GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Fungsi aman untuk waitForChild dengan timeout
local function waitForChildSafe(parent, childName, timeout)
    local startTime = tick()
    while not parent:FindFirstChild(childName) and tick() - startTime < (timeout or 5) do
        task.wait(0.1)
    end
    return parent:FindFirstChild(childName)
end

-- Ambil inventory GUI dengan aman
local InventoryGUI = waitForChildSafe(LocalPlayer:WaitForChild("PlayerGui"), "Inventory", 5)
if not InventoryGUI then
    warn("Inventory GUI not found!")
    return
end

local MainInventory = waitForChildSafe(InventoryGUI, "Main", 5)
if not MainInventory then
    warn("Inventory Main frame not found!")
    return
end

-- ===============================
-- GUI Setup
-- ===============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InventoryCloneGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromScale(0.25, 0.5)
Frame.Position = UDim2.fromScale(0.7, 0.25)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Inventory Clone"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-20,1,-50)
Scroll.Position = UDim2.new(0,10,0,45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Frame

local Layout = Instance.new("UIListLayout", Scroll)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0,6)

-- ===============================
-- Function: Clone Item
-- ===============================
local function cloneItem(item)
    if item:IsA("Tool") then
        -- clone ke backpack
        local clone = item:Clone()
        clone.Parent = LocalPlayer.Backpack
        print("Cloned Tool:", clone.Name)
    elseif item:IsA("Model") then
        -- clone model ke workspace di depan player
        local clone = item:Clone()
        local char = LocalPlayer.Character
        if char and char.PrimaryPart then
            local offset = Vector3.new(5,0,0)
            clone.Parent = workspace
            -- set primary part kalau belum ada
            if not clone.PrimaryPart then
                for _, part in ipairs(clone:GetDescendants()) do
                    if part:IsA("BasePart") then
                        clone.PrimaryPart = part
                        break
                    end
                end
            end
            if clone.PrimaryPart then
                clone:SetPrimaryPartCFrame(char.PrimaryPart.CFrame + offset)
                print("Cloned Model:", clone.Name)
            else
                warn("Model has no BasePart to set as PrimaryPart:", clone.Name)
            end
        end
    else
        warn("Unsupported item type:", item.ClassName)
    end
end

-- ===============================
-- Populate GUI with Inventory
-- ===============================
local function refreshInventory()
    -- hapus semua button dulu
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- loop inventory tools/items
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,36)
        btn.Text = item.Name .. " | " .. item.ClassName
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        btn.Parent = Scroll

        btn.MouseButton1Click:Connect(function()
            cloneItem(item)
        end)
    end
end

refreshInventory()

-- ===============================
-- Auto Refresh Inventory
-- ===============================
LocalPlayer.Backpack.ChildAdded:Connect(refreshInventory)
LocalPlayer.Backpack.ChildRemoved:Connect(refreshInventory)
