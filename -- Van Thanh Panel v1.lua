local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==================== PERFORMANCE + FPS BOOST ====================
setfpscap(9999)
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
Lighting.GlobalShadows = false
Lighting.FogEnd = 999999
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        v.Enabled = false
    end
end

-- ==================== CONFIG ====================
local Config = {
    Aimbot = {Enabled = true, SilentAim = true, RageBot = false, Triggerbot = true, AutoShoot = true, FOV = 180, Smoothing = 0.13, Hitbox = "Head"},
    Visual = {ESP = true, Box = true, Name = true, Distance = true, HealthBar = true, Tracer = true, BulletTracer = true, HitChams = true, HitSound = true, DarkFlash = true, CustomCrosshair = true},
    Rage = {KillAll = false, TeleKill = false, InstantKill = false, Spinbot = false, Backtrack = false},
    Movement = {Fly = false, FlySpeed = 150, WalkSpeed = 16, JumpPower = 50, Gravity = 196.2},
    Misc = {NoRecoil = true, NameSpoofer = "VanThanhOnTop", RemoveKillers = true, RemoveClips = true, GetC4 = true, ServerHop = false}
}

-- ==================== FOV CIRCLE & CUSTOM CROSSHAIR ====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255,0,0)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

local Crosshair = Drawing.new("Circle")
Crosshair.Radius = 12
Crosshair.Color = Color3.fromRGB(0,255,0)
Crosshair.Thickness = 2
Crosshair.Filled = false

RunService.RenderStepped:Connect(function()
    local pos = UserInputService:GetMouseLocation()
    FOVCircle.Position = pos
    FOVCircle.Visible = Config.Aimbot.Enabled
    Crosshair.Position = pos
    Crosshair.Visible = Config.Visual.CustomCrosshair
end)

-- ==================== GET BEST TARGET ====================
local function GetClosest()
    local closest = nil
    local closestDist = Config.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = plr.Character:FindFirstChild(Config.Aimbot.Hitbox) or plr.Character.Head
            local screen, onscreen = Camera:WorldToViewportPoint(part.Position)
            if onscreen then
                local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = {Player = plr, Part = part, Pos = part.Position}
                end
            end
        end
    end
    return closest
end

-- ==================== SILENT AIM + RAGEBOT ====================
RunService.Heartbeat:Connect(function()
    if not Config.Aimbot.Enabled then return end
    local target = GetClosest()
    if not target then return end

    if Config.Aimbot.RageBot then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Pos)
    elseif Config.Aimbot.SilentAim then
        local old = Camera.CFrame
        Camera.CFrame = CFrame.new(old.Position, target.Pos)
        task.wait()
        Camera.CFrame = old
    end
end)

-- ==================== TRIGGERBOT + AUTOSHOOT ====================
local shooting = false
RunService.Heartbeat:Connect(function()
    if (Config.Aimbot.Triggerbot or Config.Aimbot.AutoShoot) and not shooting then
        local target = GetClosest()
        if target then
            if Config.Aimbot.AutoShoot or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                shooting = true
                mouse1press()
                task.wait(0.02)
                mouse1release()
                task.wait(0.05)
                shooting = false
            end
        end
    end
end)

-- ==================== NO RECOIL ====================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if Config.Misc.NoRecoil and (method == "FireServer" or method == "InvokeServer") then
        local name = tostring(self)
        if string.find(name:lower(), "recoil") or string.find(name:lower(), "kick") then
            return
        end
    end
    return oldNamecall(self, ...)
end)

-- ==================== ESP FULL ====================
local ESP = {}
local function CreateESP(plr)
    if plr == LocalPlayer then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    local Name = Drawing.new("Text")
    Name.Size = 14
    Name.Center = true
    Name.Outline = true
    ESP[plr] = {Box = Box, Name = Name}
end

for _, plr in pairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
    for plr, draw in pairs(ESP) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
            local root = plr.Character.HumanoidRootPart
            local head = plr.Character.Head
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local rootPos = Camera:WorldToViewportPoint(root.Position)
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,4,0))
                if headPos.Z > 0 then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.5
                    draw.Box.Size = Vector2.new(width, height)
                    draw.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    draw.Box.Color = Color3.fromRGB(255,0,0)
                    draw.Box.Visible = Config.Visual.Box

                    draw.Name.Text = plr.Name
                    draw.Name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                    draw.Name.Visible = Config.Visual.Name
                else
                    draw.Box.Visible = false
                    draw.Name.Visible = false
                end
            end
        else
            draw.Box.Visible = false
            draw.Name.Visible = false
        end
    end
end)

-- ==================== BULLET TRACERS + HIT CHAMS + HIT SOUND ====================
local oldRay = workspace.CurrentCamera.Raycast
workspace.CurrentCamera.Raycast = function(origin, dir, params)
    local result = oldRay(origin, dir, params)
    if result and result.Instance and Players:GetPlayerFromCharacter(result.Instance.Parent) then
        if Config.Visual.BulletTracer then
            local line = Drawing.new("Line")
            line.From = Vector2.new(origin.X, origin.Y)
            line.To = Camera:WorldToViewportPoint(result.Position)
            line.Color = Color3.fromRGB(255,0,255)
            line.Thickness = 2
            game:GetService("Debris"):AddItem(line, 1)
        end
        if Config.Visual.HitChams then
            local hl = Instance.new("Highlight")
            hl.Parent = result.Instance.Parent
            hl.FillColor = Color3.fromRGB(255,0,0)
            game.Debris:AddItem(hl, 2)
        end
        if Config.Visual.HitSound then
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://6606229663"
            s.Parent = workspace
            s:Play()
            game.Debris:AddItem(s, 3)
        end
    end
    return result
end

-- ==================== FLY + WALKSPEED + GRAVITY ====================
local FlyActive = false
local BodyGyro, BodyVelocity
local function ToggleFly(v)
    FlyActive = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        BodyGyro = Instance.new("BodyGyro"); BodyGyro.Parent = root; BodyGyro.P = 9000; BodyGyro.maxTorque = Vector3.new(9000,9000,9000)
        BodyVelocity = Instance.new("BodyVelocity"); BodyVelocity.Parent = root; BodyVelocity.MaxForce = Vector3.new(9000,9000,9000)
        spawn(function()
            while FlyActive do
                BodyGyro.CFrame = Camera.CFrame
                local dir = Vector3.new(
                    (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                    (UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and 1 or 0),
                    (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
                )
                BodyVelocity.Velocity = (Camera.CFrame.LookVector * -dir.Z + Camera.CFrame.RightVector * dir.X + Vector3.new(0, dir.Y * Config.Movement.FlySpeed, 0))
                task.wait()
            end
        end)
    else
        if BodyGyro then BodyGyro:Destroy() end
        if BodyVelocity then BodyVelocity:Destroy() end
    end
end

-- ==================== MISC FEATURES ====================
workspace.Gravity = Config.Movement.Gravity
LocalPlayer.DisplayName = Config.Misc.NameSpoofer

spawn(function()
    while task.wait(0.5) do
        if Config.Misc.RemoveClips then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:find("Clip") then v.CanCollide = false end
            end
        end
        if Config.Visual.DarkFlash then
            pcall(function() Camera.Flash:Destroy() end)
        end
    end
end)

-- ==================== AURORA SKIN CHANGER FULL ====================
loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))()

-- ==================== ORION UI FULL ====================
local Window = OrionLib:MakeWindow({Name = "Van Thanh Panel </>", SaveConfig = true, ConfigFolder = "VanThanhV10", IntroEnabled = true, IntroText = "Counter Blox GOD 2025"})

local Combat = Window:MakeTab({Name = "Combat"})
local Visual = Window:MakeTab({Name = "Visual"})
local Rage = Window:MakeTab({Name = "Rage"})
local Move = Window:MakeTab({Name = "Movement"})
local Misc = Window:MakeTab({Name = "Misc"})
local Skin = Window:MakeTab({Name = "Skin Changer"})

Combat:AddToggle({Name = "Aimbot", Default = true, Callback = function(v) Config.Aimbot.Enabled = v end})
Combat:AddToggle({Name = "Silent Aim", Default = true, Callback = function(v) Config.Aimbot.SilentAim = v end})
Combat:AddToggle({Name = "Triggerbot", Default = true, Callback = function(v) Config.Aimbot.Triggerbot = v end})
Combat:AddToggle({Name = "Auto Shoot", Default = true, Callback = function(v) Config.Aimbot.AutoShoot = v end})
Combat:AddSlider({Name = "FOV", Min = 10, Max = 600, Default = 180, Callback = function(v) Config.Aimbot.FOV = v; FOVCircle.Radius = v end})

Visual:AddToggle({Name = "ESP", Default = true, Callback = function(v) Config.Visual.ESP = v end})
Visual:AddToggle({Name = "Box", Default = true, Callback = function(v) Config.Visual.Box = v end})
Visual:AddToggle({Name = "Custom Crosshair", Default = true, Callback = function(v) Config.Visual.CustomCrosshair = v end})
Visual:AddToggle({Name = "Bullet Tracers", Default = true, Callback = function(v) Config.Visual.BulletTracer = v end})
Visual:AddToggle({Name = "Hit Chams", Default = true, Callback = function(v) Config.Visual.HitChams = v end})
Visual:AddToggle({Name = "Hit Sound", Default = true, Callback = function(v) Config.Visual.HitSound = v end})
Visual:AddToggle({Name = "Dark Flashbang", Default = true, Callback = function(v) Config.Visual.DarkFlash = v end})

Rage:AddToggle({Name = "Rage Bot", Default = false, Callback = function(v) Config.Aimbot.RageBot = v end})
Rage:AddToggle({Name = "Kill All", Default = false, Callback = function(v) Config.Rage.KillAll = v end})

Move:AddToggle({Name = "Fly (E/Q)", Default = false, Callback = function(v) ToggleFly(v) end})
Move:AddSlider({Name = "WalkSpeed", Min = 16, Max = 500, Default = 16, Callback = function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end})
Move:AddSlider({Name = "Gravity", Min = 0, Max = 300, Default = 196, Callback = function(v) Config.Movement.Gravity = v; workspace.Gravity = v end})

Misc:AddTextbox({Name = "Name Spoofer", Default = "VanThanhOnTop", Callback = function(t) Config.Misc.NameSpoofer = t; LocalPlayer.DisplayName = t end})
Misc:AddToggle({Name = "No Recoil", Default = true, Callback = function(v) Config.Misc.NoRecoil = v end})
Misc:AddToggle({Name = "Remove Clips", Default = true, Callback = function(v) Config.Misc.RemoveClips = v end})

Skin:AddLabel("Aurora Skin Changer FULL")
Skin:AddButton({Name = "Open Aurora UI", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))()
end})

OrionLib:Init()
OrionLib:MakeNotification({Name = "VAN THANH PANEL </>", Content = "Last update November 25", Time = 15})
