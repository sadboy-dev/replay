-- ===============================
-- Remote Executor & Logger GUI
-- ===============================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ===============================
-- Folder Remotes
-- ===============================
-- Ganti path ini sesuai game
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")

-- ===============================
-- GUI Setup
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteExecutorLoggerGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.4, 0.6)
frame.Position = UDim2.fromScale(0.3, 0.2)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Remote Executor & Logger"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Scroll frame for remotes
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-20,0.6,-35)
scroll.Position = UDim2.new(0,10,0,35)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,6)

-- TextBox for arguments
local argBox = Instance.new("TextBox", frame)
argBox.Size = UDim2.new(1,-20,0,30)
argBox.Position = UDim2.new(0,10,0,scroll.AbsolutePosition.Y + scroll.AbsoluteSize.Y + 10)
argBox.PlaceholderText = "Masukkan argumen (pisahkan koma ,) opsional"
argBox.Text = ""
argBox.TextColor3 = Color3.new(1,1,1)
argBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", argBox).CornerRadius = UDim.new(0,6)
argBox.ClearTextOnFocus = false

-- Log box
local logBox = Instance.new("TextBox", frame)
logBox.Size = UDim2.new(1,-20,0.3,-40)
logBox.Position = UDim2.new(0,10,1,-(0.3*frame.AbsoluteSize.Y)-10)
logBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
logBox.TextColor3 = Color3.new(1,1,1)
logBox.Text = "=== LOG ===\n"
logBox.MultiLine = true
logBox.ClearTextOnFocus = false
logBox.TextWrapped = true
logBox.TextEditable = false
Instance.new("UICorner", logBox).CornerRadius = UDim.new(0,6)

-- ===============================
-- Helper function: print to log
-- ===============================
local function log(msg)
    logBox.Text = logBox.Text .. "\n" .. msg
    logBox.CursorPosition = #logBox.Text + 1
end

-- ===============================
-- Create Buttons for each Remote
-- ===============================
for _, remote in ipairs(RemotesFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,0,0,36)
        btn.Text = remote.Name.." ["..remote.ClassName.."]"
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        -- Eksekusi remote
        btn.MouseButton1Click:Connect(function()
            local args = {}
            if argBox.Text ~= "" then
                for a in string.gmatch(argBox.Text,"[^,]+") do
                    a = a:match("^%s*(.-)%s*$") -- trim spasi
                    local num = tonumber(a)
                    if num then
                        table.insert(args,num)
                    else
                        table.insert(args,a)
                    end
                end
            end

            local success, err = pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                else
                    local result = remote:InvokeServer(unpack(args))
                    log("[Invoke Result] "..remote.Name.." -> "..tostring(result))
                end
            end)

            if success then
                log("[Fired] "..remote.Name.." args: "..table.concat(args,", "))
            else
                log("[Error] "..remote.Name.." err: "..tostring(err))
            end
        end)
    end
end

-- ===============================
-- Auto log setiap RemoteEvent/RemoteFunction yang terpanggil
-- ===============================
for _, remote in ipairs(RemotesFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") then
        -- Hook FireServer
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            log("[Hook Event] "..remote.Name.." called with args: "..table.concat(args,", "))
            return oldFire(self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
        -- Hook InvokeServer
        local oldInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            log("[Hook Function] "..remote.Name.." called with args: "..table.concat(args,", "))
            return oldInvoke(self, ...)
        end
    end
end
