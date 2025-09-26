-- Combined Teleport + GUI script
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- Replace these with your actual Place ID and private server code
local PLACE_ID = 109983668079237
local PRIVATE_SERVER_CODE = "4f6239506ffe73459353586bfcb5b652"

local IMAGE_ID = "YOUR_IMAGE_ID" -- replace with your Roblox decal ID

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Pre-teleport GUI =====
local preGui = Instance.new("ScreenGui")
preGui.Name = "PreTeleportOverlay"
preGui.ResetOnSpawn = false
preGui.Parent = playerGui

local preFrame = Instance.new("Frame")
preFrame.Size = UDim2.new(1,0,1,0)
preFrame.Position = UDim2.new(0,0,0,0)
preFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
preFrame.BackgroundTransparency = 0.3
preFrame.Parent = preGui

local preImage = Instance.new("ImageLabel")
preImage.Size = UDim2.new(0,300,0,300)
preImage.Position = UDim2.new(0.5,-150,0.5,-150)
preImage.AnchorPoint = Vector2.new(0.5,0.5)
preImage.BackgroundTransparency = 1
preImage.Image = IMAGE_ID
preImage.Parent = preFrame

local preText = Instance.new("TextLabel")
preText.Size = UDim2.new(1,0,0,50)
preText.Position = UDim2.new(0,0,0.8,0)
preText.BackgroundTransparency = 1
preText.Text = "Teleporting you to the private server..."
preText.TextScaled = true
preText.TextColor3 = Color3.fromRGB(255,255,255)
preText.Font = Enum.Font.SourceSansBold
preText.Parent = preFrame

-- Short delay so player sees it
wait(1)

-- ===== Teleport =====
TeleportService:TeleportToPrivateServer(PLACE_ID, PRIVATE_SERVER_CODE, {player})

-- ===== Post-teleport GUI =====
-- This part will run after the player joins your private server
local function showPostGui()
    local postGui = Instance.new("ScreenGui")
    postGui.Name = "PostTeleportOverlay"
    postGui.ResetOnSpawn = false
    postGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.Position = UDim2.new(0,0,0,0)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.BackgroundTransparency = 0.3
    frame.Parent = postGui

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(0,300,0,300)
    image.Position = UDim2.new(0.5,-150,0.5,-150)
    image.AnchorPoint = Vector2.new(0.5,0.5)
    image.BackgroundTransparency = 1
    image.Image = IMAGE_ID
    image.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,0,50)
    text.Position = UDim2.new(0,0,0.8,0)
    text.BackgroundTransparency = 1
    text.Text = "Welcome to the private server..."
    text.TextScaled = true
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Font = Enum.Font.SourceSansBold
    text.Parent = frame

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

-- Listen for character spawn to apply post-GUI
player.CharacterAdded:Connect(function()
    showPostGui()
end)
