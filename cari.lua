-- ===============================
-- Auto Enchant Rod GUI (Safe)
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- ===== Ambil Remote Secara Aman =====
local function safeWaitForChild(parent, childName)
    local ok, result = pcall(function()
        return parent:WaitForChild(childName, 5) -- timeout 5 detik
    end)
    return ok and result or nil
end

local Packages = safeWaitForChild(ReplicatedStorage, "Packages")
local Index = Packages and safeWaitForChild(Packages, "_Index")
local Module = Index and safeWaitForChild(Index, "sleitnick_net@0.2.0")
local NetFolder = Module and safeWaitForChild(Module, "net")

local ActivateEnchantingAltar = NetFolder and safeWaitForChild(NetFolder, "RE/ActivateEnchantingAltar")
local EquipToolFromHotbar = NetFolder and safeWaitForChild(NetFolder, "RE/EquipToolFromHotbar")

if not ActivateEnchantingAltar or not EquipToolFromHotbar then
    warn("[AutoEnchant] Remote not found! Make sure net/RE exists.")
    return
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "AutoEnchantRodGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25, 0.15)
frame.Position = UDim2.fromScale(0.375, 0.1)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Auto Enchant Rod"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.9,0,0.4,0)
toggleBtn.Position = UDim2.new(0.05,0,0.5,0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(45,150,45)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Text = "OFF"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)

-- ===== Settings =====
local enabled = false
local enchantPosition = Vector3.new(3231,-1303,1402) -- ganti sesuai posisi altar

-- ===== Toggle =====
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleBtn.Text = enabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(200,45,45) or Color3.fromRGB(45,150,45)
    StarterGui:SetCore("SendNotification", {
        Title = "Auto Enchant Rod",
        Text = enabled and "Activated" or "Deactivated",
        Duration = 3
    })
end)

-- ===== Loop Auto Enchant =====
RunService.RenderStepped:Connect(function()
    if enabled and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Cek slot 5 (misal rod ada di slot 5)
            local slot5 = LocalPlayer.PlayerGui:FindFirstChild("Backpack") 
                          and LocalPlayer.PlayerGui.Backpack:FindFirstChild("Display")
                          and LocalPlayer.PlayerGui.Backpack.Display:GetChildren()[10]

            local itemName = slot5 and slot5:FindFirstChild("Inner") 
                             and slot5.Inner:FindFirstChild("Tags") 
                             and slot5.Inner.Tags:FindFirstChild("ItemName")

            if itemName and itemName.Text:lower():find("enchant") then
                -- Teleport ke Altar
                local originalCFrame = hrp.CFrame
                hrp.CFrame = CFrame.new(enchantPosition + Vector3.new(0,5,0))
                task.wait(1)

                pcall(function()
                    EquipToolFromHotbar:FireServer(5)
                    task.wait(0.5)
                    ActivateEnchantingAltar:FireServer()
                    task.wait(7)
                end)

                -- Kembali ke posisi awal
                hrp.CFrame = originalCFrame + Vector3.new(0,3,0)
            end
        end
    end
end)
