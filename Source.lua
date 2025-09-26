-- Source.lua (Delta/mobile-friendly)
-- Full black overlay + attempt to teleport to a Private Server (with debug)
-- Target: Steal Brainrot private server (info supplied by user)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- ====== CONFIG (already filled) ======
local PLACE_ID = 109983668079237
local PRIVATE_SERVER_CODE = "5b9835461333ac4f90ab22e415b96229"

local PRE_DISPLAY_TIME = 0.1       -- seconds to show pre-teleport black screen
local POST_FREEZE_TIME = 3         -- seconds to freeze after spawn in destination (if script runs there)

-- ====== UTILITIES ======
local function create_fullscreen_black(parent, name)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name or "BlackOverlay"
    -- full coverage on modern clients
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.AnchorPoint = Vector2.new(0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    return screenGui, frame
end

local function safeFreezeCharacter(character)
    if not character then return nil end
    local backup = {}
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
    if humanoid then
        backup.WalkSpeed = humanoid.WalkSpeed
        -- store JumpPower or JumpHeight if present
        if humanoid.JumpPower ~= nil then
            backup.JumpPower = humanoid.JumpPower
            humanoid.JumpPower = 0
        elseif humanoid.JumpHeight ~= nil then
            backup.JumpPower = humanoid.JumpHeight
            humanoid.JumpHeight = 0
        end
        -- platform stand
        backup.PlatformStand = humanoid.PlatformStand
        humanoid.PlatformStand = true
        humanoid.WalkSpeed = 0
    end
    if root and root:IsA("BasePart") then
        backup.Anchored = root.Anchored
        root.Anchored = true
    end
    return backup
end

local function safeUnfreezeCharacter(character, backup)
    if not character or not backup then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
    if humanoid then
        if backup.WalkSpeed ~= nil then
            pcall(function() humanoid.WalkSpeed = backup.WalkSpeed end)
        end
        if backup.JumpPower ~= nil then
            pcall(function()
                if humanoid.JumpPower ~= nil then
                    humanoid.JumpPower = backup.JumpPower
                else
                    humanoid.JumpHeight = backup.JumpPower
                end
            end)
        end
        if backup.PlatformStand ~= nil then
            pcall(function() humanoid.PlatformStand = backup.PlatformStand end)
        end
    end
    if root and root:IsA("BasePart") and backup.Anchored ~= nil then
        pcall(function() root.Anchored = backup.Anchored end)
    end
end

-- ====== MAIN ======
local player = Players.LocalPlayer
if not player then
    warn("[Source.lua] LocalPlayer not found. This script must be run client-side.")
    return
end

local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")

-- create pre-teleport full black overlay
local preGui, _ = create_fullscreen_black(playerGui, "PreTeleportOverlay")

-- freeze current character (best-effort)
local preBackup
if player.Character then
    preBackup = safeFreezeCharacter(player.Character)
else
    local chr = player.CharacterAdded:Wait()
    preBackup = safeFreezeCharacter(chr)
end

-- wait PRE_DISPLAY_TIME (use heartbeat loop for responsiveness)
if PRE_DISPLAY_TIME > 0 then
    local t0 = tick()
    while tick() - t0 < PRE_DISPLAY_TIME do
        RunService.Heartbeat:Wait()
    end
end

-- attempt teleport (pcall to catch errors)
local ok, err = pcall(function()
    TeleportService:TeleportToPrivateServer(PLACE_ID, PRIVATE_SERVER_CODE, {player})
end)

if not ok then
    warn("[Source.lua] Teleport failed: " .. tostring(err))
    -- cleanup: remove overlay and unfreeze
    if preGui and preGui.Parent then
        preGui:Destroy()
    end
    if player.Character and preBackup then
        safeUnfreezeCharacter(player.Character, preBackup)
    end
    return
end

-- If teleport succeeded, Roblox usually takes over and this script stops.
-- Some executors reinject the same script into the new session; handle post-teleport GUI if that happens.

local function postTeleportProcedure(character)
    -- create post overlay
    local postGui, _ = create_fullscreen_black(playerGui, "PostTeleportOverlay")
    -- freeze new character
    local backup = safeFreezeCharacter(character)
    -- hold for POST_FREEZE_TIME
    local t0 = tick()
    while tick() - t0 < POST_FREEZE_TIME do
        RunService.Heartbeat:Wait()
    end
    -- cleanup
    if postGui and postGui.Parent then
        postGui:Destroy()
    end
    safeUnfreezeCharacter(character, backup)
end

-- when character spawns, run post behavior (this helps if the script persists after teleport)
player.CharacterAdded:Connect(function(char)
    -- ensure character has parts
    char:WaitForChild("HumanoidRootPart", 5)
    postTeleportProcedure(char)
end)

-- also attempt to run immediately if character exists (handles reinjected runs)
if player.Character then
    -- remove pre overlay if still present (we teleported)
    if preGui and preGui.Parent then
        preGui:Destroy()
    end
    -- small delay then run post (best-effort)
    delay(0.1, function()
        if player.Character then
            postTeleportProcedure(player.Character)
        end
    end)
end
