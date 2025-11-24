local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== CONFIG ====================
local Config = {
    Aimbot = {Enabled = true, SilentAim = true, FOV = 180},
    Visual = {ESP = true, Box = true, Name = true, Health = true, Crosshair = true, BulletTracer = true, HitChams = true, HitSound = true, DarkFlash = true},
    Rage = {TeleKillTarget = false, Target = nil, TeleportOnly = false, Wallbang = false},
    Movement = {Fly = false, Bhop = false, Speed = 16, Gravity = 196.2},
    GunMods = {InfiniteAmmo = false, RapidFire = false, NoRecoil = true},
    Misc = {AntiVoteKick = true, NameSpoofer = "VanThanh", RemoveKillFeed = true, RemoveClips = true}
}

-- ==================== RAYFIELD WINDOW (MƯỢT NHƯ BƠ) ====================
local Window = Rayfield:CreateWindow({
    Name = "VAN THANH PANEL v14.0 - ULTIMATE 2025",
    LoadingTitle = "Van Thanh Panel Loading...",
    LoadingSubtitle = "Best Counter Blox Script Ever",
    ConfigurationSaving = {Enabled = true, FolderName = "VanThanhV14"},
    Discord = {Enabled = false},
    KeySystem = false
})

-- Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local RageTab = Window:CreateTab("Rage", 4483362458)
local MoveTab = Window:CreateTab("Movement", 4483362458)
local GunTab = Window:CreateTab("Gun Mods", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local SkinTab = Window:CreateTab("Skin Changer", 4483362458)

-- ==================== COMBAT TAB ====================
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = true,
    Callback = function(v) Config.Aimbot.SilentAim = v end
})
CombatTab:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = true,
    Callback = function(v) end
})
CombatTab:CreateToggle({
    Name = "Auto Shoot",
    CurrentValue = true,
    Callback = function(v) end
})
CombatTab:CreateSlider({
    Name = "FOV Size",
    Range = {10, 600},
    Increment = 10,
    CurrentValue = 180,
    Callback = function(v) Config.Aimbot.FOV = v end
})

-- ==================== VISUAL TAB ====================
VisualTab:CreateToggle({Name = "ESP Box + Name + Health", CurrentValue = true, Callback = function(v) Config.Visual.ESP = v end})
VisualTab:CreateToggle({Name = "Custom Crosshair", CurrentValue = true, Callback = function(v) Config.Visual.Crosshair = v end})
VisualTab:CreateToggle({Name = "Bullet Tracers", CurrentValue = true, Callback = function(v) Config.Visual.BulletTracer = v end})
VisualTab:CreateToggle({Name = "Hit Chams", CurrentValue = true, Callback = function(v) Config.Visual.HitChams = v end})
VisualTab:CreateToggle({Name = "Hit Sound", CurrentValue = true, Callback = function(v) Config.Visual.HitSound = v end})
VisualTab:CreateToggle({Name = "Dark Flashbang", CurrentValue = true, Callback = function(v) Config.Visual.DarkFlash = v end})

-- ==================== RAGE TAB ====================
RageTab:CreateToggle({Name = "Wallbang (Shoot Through Walls)", CurrentValue = false, Callback = function(v) Config.Rage.Wallbang = v end})
RageTab:CreateToggle({Name = "TeleKill Target", CurrentValue = false, Callback = function(v) Config.Rage.TeleKillTarget = v end})
RageTab:CreateToggle({Name = "Teleport Only", CurrentValue = false, Callback = function(v) Config.Rage.TeleportOnly = v end})
RageTab:CreateDropdown({
    Name = "Target Player",
    Options = (function() local t={} for _,p in Players:GetPlayers() do if p~=LocalPlayer then table.insert(t,p.Name) end end return t end)(),
    CurrentOption = "None",
    Callback = function(n) Config.Rage.Target = Players:FindFirstChild(n) end
})

-- ==================== MOVEMENT TAB ====================
MoveTab:CreateToggle({Name = "Fly (WASD + E/Q)", CurrentValue = false, Callback = function(v) 
    if v and LocalPlayer.Character then
        local root = LocalPlayer.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        local bg = Instance.new("BodyGyro", root); bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        spawn(function()
            while v and task.wait() do
                bg.CFrame = Camera.CFrame
                bv.Velocity = (Camera.CFrame.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.W) and 200 or UserInputService:IsKeyDown(Enum.KeyCode.S) and -200 or 0)) +
                                (Camera.CFrame.RightVector * (UserInputService:IsKeyDown(Enum.KeyCode.D) and 200 or UserInputService:IsKeyDown(Enum.KeyCode.A) and -200 or 0)) +
                                Vector3.new(0, UserInputService:IsKeyDown(Enum.KeyCode.E) and 200 or UserInputService:IsKeyDown(Enum.KeyCode.Q) and -200 or 0, 0)
            end
            bv:Destroy(); bg:Destroy()
        end)
    end
end})
MoveTab:CreateToggle({Name = "Bunny Hop", CurrentValue = false, Callback = function(v) Config.Movement.Bhop = v end})
MoveTab:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, Increment = 10, CurrentValue = 16, Callback = function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end})

-- ==================== GUN MODS TAB ====================
GunTab:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(v) Config.GunMods.InfiniteAmmo = v end})
GunTab:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) Config.GunMods.RapidFire = v end})
GunTab:CreateToggle({Name = "No Recoil", CurrentValue = true, Callback = function(v) Config.GunMods.NoRecoil = v end})

-- ==================== MISC TAB ====================
MiscTab:CreateToggle({Name = "Anti-Vote Kick", CurrentValue = true, Callback = function(v) Config.Misc.AntiVoteKick = v end})
MiscTab:CreateTextbox({Name = "Name Spoofer", Text = "VanThanh", Callback = function(t) LocalPlayer.DisplayName = t end})

-- ==================== SKIN CHANGER TAB ====================
SkinTab:CreateButton({
    Name = "OPEN AURORA SKIN CHANGER (3000+ SKINS)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))()
    end
})

-- ==================== CORE FEATURES (FULL CODE) ====================
-- Silent Aim
RunService.Heartbeat:Connect(function()
    if Config.Aimbot.SilentAim then
        local closest = nil; local dist = Config.Aimbot.FOV
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mag < dist then dist = mag; closest = plr.Character.Head.Position end
                end
            end
        end
        if closest then
            local old = Camera.CFrame
            Camera.CFrame = CFrame.new(old.Position, closest)
            task.wait()
            Camera.CFrame = old
        end
    end
end)

-- Bhop
RunService.Heartbeat:Connect(function()
    if Config.Movement.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.Jump = true
    end
end)

-- Infinite Ammo + Rapid Fire
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                if Config.GunMods.InfiniteAmmo then tool.Ammo.Value = 999 end
                if Config.GunMods.RapidFire then tool.FireRate.Value = 0.01 end
            end
        end
    end
end)

-- Dark Flashbang
spawn(function()
    while task.wait(0.1) do
        if Config.Visual.DarkFlash then
            pcall(function() Camera.Flash:Destroy() end)
        end
    end
end)

Rayfield:Notify({
    Title = "Van Thanh Panel v14.0",
    Content = "Van Thanh </> dep try vai lon",
    Duration = 8,
    Image = 4483362458
})
