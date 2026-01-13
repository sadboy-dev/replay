-- ===============================
-- Pirate Chest / PlacePressureItem GUI (Input2 Optional + Log)
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "PlacePressureItemGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.35, 0.5)
frame.Position = UDim2.fromScale(0.32, 0.25)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Execute Remote"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Input 1
local input1Box = Instance.new("TextBox", frame)
input1Box.Size = UDim2.new(0.9, 0, 0, 30)
input1Box.Position = UDim2.new(0.05, 0, 0, 40)
input1Box.PlaceholderText = "Remote Name (Input1)"
input1Box.Text = ""
input1Box.ClearTextOnFocus = false
input1Box.BackgroundColor3 = Color3.fromRGB(40,40,40)
input1Box.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", input1Box).CornerRadius = UDim.new(0,6)

-- Input 2 (Opsional)
local input2Box = Instance.new("TextBox", frame)
input2Box.Size = UDim2.new(0.9, 0, 0, 30)
input2Box.Position = UDim2.new(0.05, 0, 0, 80)
input2Box.PlaceholderText = "Argument / Value (Input2, optional)"
input2Box.Text = ""
input2Box.ClearTextOnFocus = false
input2Box.BackgroundColor3 = Color3.fromRGB(40,40,40)
input2Box.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", input2Box).CornerRadius = UDim.new(0,6)

-- Execute Button
local executeBtn = Instance.new("TextButton", frame)
executeBtn.Size = UDim2.new(0.9,0,0,35)
executeBtn.Position = UDim2.new(0.05,0,0,125)
executeBtn.Text = "Execute"
executeBtn.Font = Enum.Font.GothamBold
executeBtn.TextSize = 16
executeBtn.BackgroundColor3 = Color3.fromRGB(45, 150, 45)
executeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", executeBtn).CornerRadius = UDim.new(0,8)

-- Log Box
local logBox = Instance.new("TextBox", frame)
logBox.Size = UDim2.new(0.9,0,0,150)
logBox.Position = UDim2.new(0.05,0,0,170)
logBox.MultiLine = true
logBox.ClearTextOnFocus = false
logBox.TextWrapped = true
logBox.TextEditable = false
logBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
logBox.TextColor3 = Color3.new(1,1,1)
logBox.Text = "=== Remote Log ===\n"
Instance.new("UICorner", logBox).CornerRadius = UDim.new(0,6)

-- Helper function untuk menambah log
local function addLog(msg)
    logBox.Text = logBox.Text .. msg .. "\n"
    logBox.CursorPosition = #logBox.Text+1
end

-- ===============================
-- Button Logic
-- ===============================
executeBtn.MouseButton1Click:Connect(function()
    local input1 = input1Box.Text
    local input2 = input2Box.Text

    if input1 == "" then
        addLog("[ERROR] Input1 (Remote Name) is required!")
        StarterGui:SetCore("SendNotification", {
            Title = "Execute Remote",
            Text = "Input1 is required!",
            Duration = 3
        })
        return
    end

    -- Tunggu net folder
    local success, NetFolder = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
    end)
    if not success then
        addLog("[ERROR] Net folder not found!")
        return
    end

    -- Ambil remote
    local remote = NetFolder:FindFirstChild(input1)
    if remote and remote:IsA("RemoteEvent") then
        local fired = false
        local status, err = pcall(function()
            if input2 == "" then
                remote:FireServer()
            else
                local n = tonumber(input2)
                if n then
                    remote:FireServer(n)
                else
                    remote:FireServer(input2)
                end
            end
            fired = true
        end)
        if fired then
            addLog("[SUCCESS] "..input1.." fired"..(input2 ~= "" and " with argument: "..input2 or ""))
        else
            addLog("[ERROR] Failed to fire "..input1.." | "..(err or "unknown error"))
        end
    else
        addLog("[ERROR] Remote "..input1.." not found!")
    end
end)
