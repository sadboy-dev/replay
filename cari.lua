local Packages = ReplicatedStorage:FindFirstChild("Packages")
local IndexFolder = Packages and Packages:FindFirstChild("_Index")
local Sleitnick = IndexFolder and IndexFolder:FindFirstChild("sleitnick_net@0.2.0")
local REFolder = Sleitnick and Sleitnick:FindFirstChild("RE")

if not REFolder then
    warn("Folder RE tidak ditemukan! Logger tidak bisa dijalankan.")
else
    print("Folder RE ditemukan:", REFolder:GetFullName())
end
