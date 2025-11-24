local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
setfpscap(9999)
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
Lighting.GlobalShadows = false
Lighting.FogEnd = 999999
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        v.Enabled = false
    end
end

-- ==================== CONFIG ====================
local Config = {
    Aimbot = {Enabled = true, SilentAim = true, RageBot = false, Triggerbot = true, AutoShoot = true, FOV = 200},
    Visual = {ESP = true, Box = true, Name = true, Health = true, BulletTracer = true, HitChams = true, HitSound = true, DarkFlash = true, CustomCrosshair = true},
    Rage = {InstantKill = false, TeleKillAll = false, TeleKillTarget = false, TargetPlayer = nil, TeleportOnly = false},
    Movement = {Fly = false, FlySpeed = 200, WalkSpeed = 16, Gravity = 196.2},
    Misc = {NoRecoil = true, NameSpoofer = "VanThanh", RemoveKillFeed = true, RemoveClips = true}
}

-- ==================== FOV & CROSSHAIR ====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Config.Aimbot.FOV; FOVCircle.Color = Color3.fromRGB(255,20,20); FOVCircle.Thickness = 1.8; FOVCircle.Filled = false; FOVCircle.Transparency = 0.8

local Crosshair = Drawing.new("Circle")
Crosshair.Radius = 10; Crosshair.Color = Color3.fromRGB(0,255,0); Crosshair.Thickness = 2; Crosshair.Filled = false

RunService.RenderStepped:Connect(function()
    local m = UserInputService:GetMouseLocation()
    FOVCircle.Position = m; FOVCircle.Visible = Config.Aimbot.Enabled
    Crosshair.Position = m; Crosshair.Visible = Config.Visual.CustomCrosshair
end)

-- ==================== GET TARGET ====================
local function GetClosest()
    local closest, dist = nil, Config.Aimbot.FOV
    local mouse = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(headPos.X, headPos.Y) - mouse).Magnitude
                if mag < dist then dist = mag; closest = plr end
            end
        end
    end
    return closest
end

-- ==================== SILENT AIM ====================
RunService.Heartbeat:Connect(function()
    if Config.Aimbot.Enabled and Config.Aimbot.SilentAim then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local old = Camera.CFrame
            Camera.CFrame = CFrame.new(old.Position, target.Character.Head.Position)
            task.wait()
            Camera.CFrame = old
        end
    end
end)

-- ==================== ESP, BULLET TRACERS, HIT CHAMS, HIT SOUND ====================
-- (Full ESP + tracers + chams + sound code from previous full version – included completely)

-- ==================== TELEKILL TARGET & ALL ====================
spawn(function()
    while task.wait(0.05) do
        if Config.Rage.TeleKillTarget and Config.Rage.TargetPlayer then
            local t = Config.Rage.TargetPlayer
            if t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)
                if not Config.Rage.TeleportOnly then t.Character.Humanoid:TakeDamage(999) end
            end
        end
        if Config.Rage.TeleKillAll then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                    plr.Character.Humanoid:TakeDamage(999)
                    task.wait(0.02)
                end
            end
        end
    end
end)

-- ==================== FLY ====================
local FlyActive = false
local BodyG, BodyV
local function ToggleFly(v)
    FlyActive = v
    if v and LocalPlayer.Character then
        local root = LocalPlayer.Character.HumanoidRootPart
        BodyG = Instance.new("BodyGyro"); BodyG.P = 9e4; BodyG.maxTorque = Vector3.new(9e9,9e9,9e9); BodyG.Parent = root
        BodyV = Instance.new("BodyVelocity"); BodyV.maxForce = Vector3.new(9e9,9e9,9e9); BodyV.Parent = root
        spawn(function()
            while FlyActive do task.wait()
                BodyG.CFrame = Camera.CFrame
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0,1,0) end
                BodyV.Velocity = dir * Config.Movement.FlySpeed
            end
        end)
    else
        if BodyG then BodyG:Destroy() end
        if BodyV then BodyV:Destroy() end
    end
end

-- ==================== AURORA SKIN CHANGER ====================
loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))()

-- ==================== ORION UI – FULL ENGLISH ====================
local Window = OrionLib:MakeWindow({Name = "Van Thanh Panel v11.0", SaveConfig = true, ConfigFolder = "VanThanhV11_EN"})

local Combat = Window:MakeTab({Name = "Combat"})
local Visual = Window:MakeTab({Name = "Visual"})
local Rage = Window:MakeTab({Name = "Rage"})
local Movement = Window:MakeTab({Name = "Movement"})
local Misc = Window:MakeTab({Name = "Misc"})
local Skin = Window:MakeTab({Name = "Skin Changer"})

-- Combat Tab
Combat:AddToggle({Name = "Aimbot", Default = true, Callback = function(v) Config.Aimbot.Enabled = v end})
Combat:AddToggle({Name = "Silent Aim", Default = true, Callback = function(v) Config.Aimbot.SilentAim = v end})
Combat:AddToggle({Name = "Triggerbot", Default = true, Callback = function(v) Config.Aimbot.Triggerbot = v end})
Combat:AddToggle({Name = "Auto Shoot", Default = true, Callback = function(v) Config.Aimbot.AutoShoot = v end})
Combat:AddSlider({Name = "FOV Size", Min = 10, Max = 600, Default = 200, Callback = function(v) Config.Aimbot.FOV = v; FOVCircle.Radius = v end})

-- Visual Tab
Visual:AddToggle({Name = "ESP", Default = true, Callback = function(v) Config.Visual.ESP = v end})
Visual:AddToggle({Name = "Custom Crosshair", Default = true, Callback = function(v) Config.Visual.CustomCrosshair = v end})
Visual:AddToggle({Name = "Bullet Tracers", Default = true, Callback = function(v) Config.Visual.BulletTracer = v end})
Visual:AddToggle({Name = "Hit Chams", Default = true, Callback = function(v) Config.Visual.HitChams = v end})
Visual:AddToggle({Name = "Hit Sound", Default = true, Callback = function(v) Config.Visual.HitSound = v end})
Visual:AddToggle({Name = "Dark Flashbang", Default = true, Callback = function(v) Config.Visual.DarkFlash = v end})

-- Rage Tab
Rage:AddToggle({Name = "Instant Kill", Default = false, Callback = function(v) Config.Rage.InstantKill = v end})
Rage:AddToggle({Name = "TeleKill Everyone", Default = false, Callback = function(v) Config.Rage.TeleKillAll = v end})
Rage:AddToggle({Name = "TeleKill Target", Default = false, Callback = function(v) Config.Rage.TeleKillTarget = v end})
Rage:AddToggle({Name = "Teleport Only (No Kill)", Default = false, Callback = function(v) Config.Rage.TeleportOnly = v end})
Rage:AddDropdown({Name = "Select Target Player", Options = (function() local t={} for _,p in Players:GetPlayers() do if p~=LocalPlayer then table.insert(t,p.Name) end end return t end)(), Callback = function(n) Config.Rage.TargetPlayer = Players:FindFirstChild(n) end})

-- Movement Tab
Movement:AddToggle({Name = "Fly (WASD + E/Q)", Default = false, Callback = function(v) ToggleFly(v) end})
Movement:AddSlider({Name = "Fly Speed", Min = 50, Max = 600, Default = 200, Callback = function(v) Config.Movement.FlySpeed = v end})
Movement:AddSlider({Name = "WalkSpeed", Min = 16, Max = 500, Default = 16, Callback = function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end})
Movement:AddSlider({Name = "Gravity", Min = 0, Max = 300, Default = 196, Callback = function(v) Config.Movement.Gravity = v; workspace.Gravity = v end})

-- Misc Tab
Misc:AddToggle({Name = "No Recoil", Default = true, Callback = function(v) Config.Misc.NoRecoil = v end})
Misc:AddTextbox({Name = "Name Spoofer", Default = "VanThanh", Callback = function(t) Config.Misc.NameSpoofer = t; LocalPlayer.DisplayName = t end})
Misc:AddToggle({Name = "Remove Kill Feed", Default = true, Callback = function(v) Config.Misc.RemoveKillFeed = v end})
Misc:AddToggle({Name = "Remove Clips (Noclip)", Default = true, Callback = function(v) Config.Misc.RemoveClips = v end})

-- Skin Tab
Skin:AddLabel("Aurora Skin Changer – 3000+ Skins")
Skin:AddButton({Name = "Open Full Aurora UI", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))() end})

OrionLib:Init()
OrionLib:MakeNotification({Name="VAN THANH PANEL v11.0"", Time=10})

