-- ===============================
-- GUI Inventory Fish Viewer
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ===============================
-- Ambil data fish dari ReplicatedStorage
-- ===============================
local GlobalFav = {
    FishIdToName = {},
    FishNameToId = {},
    FishIdToTier = {},
    FishNames = {}
}

for _, item in pairs(ReplicatedStorage:WaitForChild("Items"):GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        local id = data.Data.Id
        local name = data.Data.Name
        local tier = data.Data.Tier
        GlobalFav.FishIdToName[id] = name
        GlobalFav.FishNameToId[name] = id
        GlobalFav.FishIdToTier[id] = tier
        table.insert(GlobalFav.FishNames, name)
    end
end

table.sort(GlobalFav.FishNames)

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "FishViewerGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.3, 0.6)
frame.Position = UDim2.fromScale(0.05, 0.2)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "All Fish Viewer"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Scrolling Frame untuk list fish
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-20,1,-40)
scroll.Position = UDim2.new(0,10,0,35)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,4)

-- ===============================
-- Tambahkan tombol untuk setiap fish
-- ===============================
for _, fishName in ipairs(GlobalFav.FishNames) do
    local fishId = GlobalFav.FishNameToId[fishName]
    local tier = GlobalFav.FishIdToTier[fishId]

    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = string.format("%s | ID: %s | Tier: %s", fishName, tostring(fishId), tostring(tier))
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    -- Saat klik tombol (untuk sekarang hanya print info)
    btn.MouseButton1Click:Connect(function()
        print("Clicked fish:")
        print("Name:", fishName)
        print("ID:", fishId)
        print("Tier:", tier)
    end)
end
