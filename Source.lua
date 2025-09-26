-- Final Black Overlay + Teleport Script
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- Your game/place info
local PLACE_ID = 109983668079237
local PRIVATE_SERVER_CODE = "4f6239506ffe73459353586bfcb5b652"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Pre-Teleport Black Overlay =====
local preGui = Instance.new("ScreenGui")
preGui.Name = "PreTeleportOverlay"
preGui.ResetOnSpawn = false
preGui.Parent = playerGui

local preFrame = Instance.new("Frame")
preFrame.Size = UDim2.new(1,0,1,0)
preFrame.Position = UDim2.new(0,0,0,0)
preFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
preFrame.BackgroundTransparency = 0 -- fully black
preFrame.Parent = preGui

-- Short delay (0.1s)
wait(0.1)

-- ===== Teleport =====
local success, err = pcall(function()
    TeleportService:TeleportToPrivateServer(PLACE_ID, PRIVATE_SERVER_CODE, {player})
end)

if not success then
    warn("Teleport failed: "..tostring(err))
end

-- ===== Post-Teleport Black Overlay =====
local function showPostGui()
    local postGui = Instance.new("ScreenGui")
    postGui.Name = "PostTeleportOverlay"
    postGui.ResetOnSpawn = false
    postGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.Position = UDim2.new(0,0,0,0)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.BackgroundTransparency = 0 -- fully black
    frame.Parent = postGui

    -- Freeze player for 3 seconds
    local character = player.Character or player.CharacterAdded:Wait()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    wait(3)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
end

-- Show post-GUI when character spawns
player.CharacterAdded:Connect(function()
    showPostGui()
end)
