-- ===============================
-- Fish Model/Tool Cloner GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Fungsi aman untuk menunggu folder tanpa infinite yield
local function safeWaitFolder(parent, name, timeout)
    timeout = timeout or 5
    local folder
    local success, err = pcall(function()
        folder = parent:WaitForChild(name, timeout)
    end)
    if success then return folder end
    return nil
end

-- Target folder
local fishFolder = safeWaitFolder(
    safeWaitFolder(
        safeWaitFolder(
            safeWaitFolder(ReplicatedStorage, "Modules"), "ModelDownloader"), "Collection"), "Fish")

if not fishFolder then
    warn("Folder Fish tidak ditemukan, script dihentikan.")
    return
end

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "FishClonerGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25, 0.6)
frame.Position = UDim2.fromScale(0.7, 0.2)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Fish Model/Tool Cloner"
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
-- Fungsi rekursif untuk ambil semua model di folder
-- ===============================
local function getAllModelsAndTools(folder)
    local items = {}
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") or item:IsA("Tool") then
            table.insert(items, item)
        elseif item:IsA("Folder") then
            local subItems = getAllModelsAndTools(item)
            for _, sub in ipairs(subItems) do
                table.insert(items, sub)
            end
        end
    end
    return items
end

local allItems = getAllModelsAndTools(fishFolder)

-- ===============================
-- Buat tombol untuk setiap model/tool
-- ===============================
for _, item in ipairs(allItems) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,0,0,36)
    btn.Text = item.Name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        local clone = item:Clone()

        if clone:IsA("Tool") then
            -- Clone langsung ke Backpack
            clone.Parent = LocalPlayer.Backpack
            print("Tool "..clone.Name.." berhasil diclone ke Backpack")
        else
            -- Model → set PrimaryPart otomatis
            if not clone.PrimaryPart then
                local primary = clone:FindFirstChildWhichIsA("BasePart") or clone:FindFirstChild("HumanoidRootPart")
                if primary then
                    clone.PrimaryPart = primary
                else
                    warn("Model "..clone.Name.." tidak punya BasePart, skip clone")
                    return
                end
            end
            -- Spawn di workspace
            clone.Parent = Workspace
            clone:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame + Vector3.new(5,0,0))
            print("Model "..clone.Name.." berhasil diclone ke Workspace")
        end
    end)
end
