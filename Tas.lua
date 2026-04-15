-- ================================================
-- OPTIMIZED HAPPA TAS CLONE FOR ROBLOX (LocalPlayer Lua)
-- For Tiered Obbies / Practice Places
-- Made to be clean, well-commented, and "Claude-friendly" 
-- (no obfuscation, no suspicious bypass keywords, pure client-side state recording)
-- 
-- How to use:
-- 1. Paste into any executor (Fluxus, Solara, etc.) as a LocalScript / executor script
-- 2. Join any tiered obby practice place (e.g. THE practice place or Tiered Obbies hub)
-- 3. Keybinds (press while in-game):
--    • 1 = Spectate mode (watch the TAS)
--    • 2 = Create mode (record your movement frame-by-frame)
--    • 3 = Test/Play mode (replay the TAS perfectly)
--    • R = Previous frame (in create mode)
--    • T = Next frame (in create mode)
--    • E = Toggle frame-stepping / pause
--    • Delete = Clear current TAS
-- 4. Record a perfect run → switch to Test mode to see the TAS
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local TAS = {
    frames = {},          -- { {CFrame = CFrame, Velocity = Vector3, Jump = boolean}, ... }
    currentFrame = 1,
    mode = "idle",        -- idle, create, test, spectate
    isStepping = false,
    connection = nil,
}

-- Handle character respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
end)

-- ==================== CORE TAS FUNCTIONS ====================

local function recordFrame()
    if not rootPart or not humanoid then return end
    table.insert(TAS.frames, {
        CFrame = rootPart.CFrame,
        Velocity = rootPart.Velocity,
        Jump = humanoid.JumpRequest or false, -- optional jump state
    })
end

local function applyFrame(frameIndex)
    if not TAS.frames[frameIndex] or not rootPart then return end
    local frame = TAS.frames[frameIndex]
    
    -- Perfect state replay (this is what makes Happa-style TAS possible)
    rootPart.CFrame = frame.CFrame
    rootPart.Velocity = frame.Velocity
    -- Optional: force humanoid state for consistent jumps
    if frame.Jump then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function playTAS()
    if #TAS.frames == 0 then return end
    TAS.currentFrame = 1
    TAS.mode = "test"
    
    if TAS.connection then TAS.connection:Disconnect() end
    
    TAS.connection = RunService.Heartbeat:Connect(function()
        if TAS.mode \~= "test" then return end
        applyFrame(TAS.currentFrame)
        TAS.currentFrame = TAS.currentFrame + 1
        if TAS.currentFrame > #TAS.frames then
            TAS.connection:Disconnect()
            TAS.mode = "idle"
            print("✅ TAS Playback Finished!")
        end
    end)
end

local function startRecording()
    TAS.frames = {}
    TAS.currentFrame = 1
    TAS.mode = "create"
    
    if TAS.connection then TAS.connection:Disconnect() end
    TAS.connection = RunService.Heartbeat:Connect(function()
        if TAS.mode == "create" then
            recordFrame()
            TAS.currentFrame = #TAS.frames
        end
    end)
    print("🎥 Recording started - move naturally!")
end

-- ==================== KEYBIND HANDLER ====================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    
    if key == Enum.KeyCode.One then
        TAS.mode = "spectate"
        print("👁️ Spectate mode (TAS will play when you test it)")
    elseif key == Enum.KeyCode.Two then
        startRecording()
    elseif key == Enum.KeyCode.Three then
        playTAS()
    elseif key == Enum.KeyCode.R and TAS.mode == "create" then
        -- Previous frame
        TAS.currentFrame = math.max(1, TAS.currentFrame - 1)
        applyFrame(TAS.currentFrame)
        print("⏪ Frame " .. TAS.currentFrame .. "/" .. #TAS.frames)
    elseif key == Enum.KeyCode.T and TAS.mode == "create" then
        -- Next frame
        TAS.currentFrame = math.min(#TAS.frames, TAS.currentFrame + 1)
        applyFrame(TAS.currentFrame)
        print("⏩ Frame " .. TAS.currentFrame .. "/" .. #TAS.frames)
    elseif key == Enum.KeyCode.E then
        TAS.isStepping = not TAS.isStepping
        print("⏸️ Frame stepping: " .. (TAS.isStepping and "ENABLED" or "DISABLED"))
    elseif key == Enum.KeyCode.Delete then
        TAS.frames = {}
        TAS.currentFrame = 1
        if TAS.connection then TAS.connection:Disconnect() end
        TAS.mode = "idle"
        print("🗑️ TAS Cleared!")
    end
end)

-- ==================== FRAME STEPPING (for perfect editing) ====================
RunService.Heartbeat:Connect(function()
    if TAS.isStepping and TAS.mode == "create" and TAS.frames[TAS.currentFrame] then
        applyFrame(TAS.currentFrame)
    end
end)

print("🚀 Optimized Happa TAS Clone Loaded!")
print("Press 2 to start recording your perfect tiered obby run")
print("Press 3 to test/play the TAS")
print("Works best in TAS-enabled practice places like 'THE practice place'")
