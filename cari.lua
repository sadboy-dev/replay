-- ===============================
-- Fish Cloner GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- RemoteEvent untuk menambahkan fish ke inventory
local FishCaught = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RE")
    :WaitForChild("FishCaught")

-- ===============================
-- Tier Mapping
-- ===============================
local TierMap = {
    [1] = "Biasa",
    [2] = "Tidak Biasa",
    [3] = "Langka",
    [4] = "Epik",
    [5] = "Legendaris",
    [6] = "Mitos",
    [7] = "Rahasia"
}

-- ===============================
-- Ambil semua fish dari ReplicatedStorage
-- ===============================
local FishList = {}

for _, item in pairs(ReplicatedStorage.Items:GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        table.insert(FishList, {
            Id = data.Data.Id,
            Name = data.Data.Name,
            Tier = TierMap[data.Data.Tier] or "Unknown"
        })
    end
end

-- Sort berdasarkan nama
table.sort(FishList, function(a,b) return a.Name < b.Name end)

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "FishClonerGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25, 0.5)
frame.Position = UDim2.fromScale(0.7, 0.25)
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
-- Tambahkan button untuk setiap fish
-- ===============================
for _, fish in ipairs(FishList) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,0,0,36)
    btn.Text = string.format("%s | ID: %s | Tier: %s", fish.Name, fish.Id, fish.Tier)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        print("=== Cloning Fish ===")
        print("Name:", fish.Name)
        print("ID:", fish.Id)
        print("Tier:", fish.Tier)

        -- Fire server supaya fish masuk inventory
        local success, err = pcall(function()
            FishCaught:FireServer({
                Shiny = false,
                Weight = math.random(1,10)/2,
                Id = fish.Id
            })
        end)

        if success then
            print(fish.Name .. " berhasil dikirim ke inventory!")
        else
            warn("Gagal menambahkan fish:", err)
        end
    end)
end

