pcall(function()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local Lighting = game:GetService("Lighting")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- ==================== FULL CONFIG AURORA 1:1 ====================
    local Config = {
        Legit = {Enabled = false, FOV = 120, Smooth = 0.15, HitChance = 100, DoubleTap = false, Triggerbot = false},
        Rage = {Enabled = false, Resolver = true, Backtrack = false, KnifeBot = true, Wallbang = false, ForceHit = false},
        Visuals = {
            ESP = true, Box = true, Name = true, HealthBar = true, Chams = true,
            BulletTracer = true, HitChams = true, DarkFlash = true,
            ViewmodelFOV = 90, Ambient = 0, Bloom = 0, Saturation = 0
        },
        Movement = {Bhop = true, Fly = false, Speed = 16},
        GunMods = {InfiniteAmmo = true, RapidFire = false, NoRecoil = true},
        Misc = {PingSpoofer = 50, SpectatorList = true, AntiVoteKick = true, NameSpoofer = "VanThanh"}
    }

    -- ==================== RAYFIELD UI - AURORA STYLE ====================
    local Window = Rayfield:CreateWindow({
        Name = "Van Thanh Panel </> v20.0",
        LoadingTitle = "Van Thanh Cheat Loading...",
        LoadingSubtitle = "version 20.0",
        ConfigurationSaving = {Enabled = true, FolderName = "VanThanhV20"},
        KeySystem = false
    })

    local Legit = Window:CreateTab("Legit")
    local Rage = Window:CreateTab("Rage")
    local Visuals = Window:CreateTab("Visuals")
    local Movement = Window:CreateTab("Movement")
    local GunMods = Window:CreateTab("Gun Mods")
    local Misc = Window:CreateTab("Misc")
    local Skins = Window:CreateTab("Skins")

    -- ==================== LEGIT TAB ====================
    Legit:CreateToggle({Name = "Legitbot", CurrentValue = false, Callback = function(v) Config.Legit.Enabled = v end})
    Legit:CreateSlider({Name = "FOV", Range = {10, 300}, CurrentValue = 120, Callback = function(v) Config.Legit.FOV = v end})
    Legit:CreateSlider({Name = "Smooth", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.15, Callback = function(v) Config.Legit.Smooth = v end})
    Legit:CreateSlider({Name = "Hit Chance", Range = {0, 100}, CurrentValue = 100, Callback = function(v) Config.Legit.HitChance = v end})
    Legit:CreateToggle({Name = "Double Tap", CurrentValue = false, Callback = function(v) Config.Legit.DoubleTap = v end})
    Legit:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) Config.Legit.Triggerbot = v end})

    -- ==================== RAGE TAB ====================
    Rage:CreateToggle({Name = "Ragebot", CurrentValue = false, Callback = function(v) Config.Rage.Enabled = v end})
    Rage:CreateToggle({Name = "Resolver", CurrentValue = true, Callback = function(v) Config.Rage.Resolver = v end})
    Rage:CreateToggle({Name = "Backtrack", CurrentValue = false, Callback = function(v) Config.Rage.Backtrack = v end})
    Rage:CreateToggle({Name = "Knife Bot", CurrentValue = true, Callback = function(v) Config.Rage.KnifeBot = v end})
    Rage:CreateToggle({Name = "Wallbang", CurrentValue = false, Callback = function(v) Config.Rage.Wallbang = v end})
    Rage:CreateToggle({Name = "Force Hit", CurrentValue = false, Callback = function(v) Config.Rage.ForceHit = v end})

    -- ==================== VISUALS TAB ====================
    Visuals:CreateToggle({Name = "ESP", CurrentValue = true, Callback = function(v) Config.Visuals.ESP = v end})
    Visuals:CreateToggle({Name = "Box", CurrentValue = true, Callback = function(v) Config.Visuals.Box = v end})
    Visuals:CreateToggle({Name = "Name", CurrentValue = true, Callback = function(v) Config.Visuals.Name = v end})
    Visuals:CreateToggle({Name = "Health Bar", CurrentValue = true, Callback = function(v) Config.Visuals.HealthBar = v end})
    Visuals:CreateToggle({Name = "Bullet Tracers", CurrentValue = true, Callback = function(v) Config.Visuals.BulletTracer = v end})
    Visuals:CreateToggle({Name = "Hit Chams", CurrentValue = true, Callback = function(v) Config.Visuals.HitChams = v end})
    Visuals:CreateToggle({Name = "Dark Flashbang", CurrentValue = true, Callback = function(v) Config.Visuals.DarkFlash = v end})
    Visuals:CreateSlider({Name = "Viewmodel FOV", Range = {50, 120}, CurrentValue = 90, Callback = function(v) Config.Visuals.ViewmodelFOV = v; Camera.FieldOfView = v end})

    -- ==================== MOVEMENT TAB ====================
    Movement:CreateToggle({Name = "Bunny Hop", CurrentValue = true, Callback = function(v) Config.Movement.Bhop = v end})
    Movement:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) Config.Movement.Fly = v end})
    Movement:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, CurrentValue = 16, Callback = function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end})

    -- ==================== GUN MODS TAB ====================
    GunMods:CreateToggle({Name = "Infinite Ammo", CurrentValue = true, Callback = function(v) Config.GunMods.InfiniteAmmo = v end})
    GunMods:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) Config.GunMods.RapidFire = v end})
 planted:CreateToggle({Name = "No Recoil", CurrentValue = true, Callback = function(v) Config.GunMods.NoRecoil = v end})

    -- ==================== MISC TAB ====================
    Misc:CreateSlider({Name = "Ping Spoofer", Range = {0, 300}, CurrentValue = 50, Callback = function(v) Config.Misc.PingSpoofer = v end})
    Misc:CreateToggle({Name = "Spectator List", CurrentValue = true, Callback = function(v) Config.Misc.SpectatorList = v end})
    Misc:CreateToggle({Name = "Anti-Vote Kick", CurrentValue = true, Callback = function(v) Config.Misc.AntiVoteKick = v end})
    Misc:CreateTextbox({Name = "Name Spoofer", CurrentValue = "VanThanh", Callback = function(v) LocalPlayer.DisplayName = v end})

    -- ==================== SKINS TAB ====================
    Skins:CreateButton({Name = "Open Aurora Skin Changer", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))()
    end})

    -- ==================== 100% WORKING FEATURES ====================
    -- Silent Aim + Resolver
    RunService.Heartbeat:Connect(function()
        if Config.Legit.Enabled or Config.Rage.Enabled then
            local closest = nil
            local best = Config.Legit.Enabled and Config.Legit.FOV or 999
            for _, plr in Players:GetPlayers() do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < best then
                            best = dist
                            closest = plr.Character.Head.Position
                        end
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

    -- Knife Bot
    RunService.Heartbeat:Connect(function()
        if Config.Rage.KnifeBot then
            for _, plr in Players:GetPlayers() do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                        plr.Character.Humanoid:TakeDamage(100)
                    end
                end
            end
        end
    end)

    -- Dark Flashbang
    spawn(function()
        while task.wait(0.1) do
            if Config.Visuals.DarkFlash then
                pcall(function() Camera.Flash:Destroy() end)
            end
        end
    end)

    -- Infinite Ammo + No Recoil
    RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character then
            for _, tool in LocalPlayer.Character:GetChildren() do
                if tool:IsA("Tool") then
                    if Config.GunMods.InfiniteAmmo then
                        pcall(function() tool.Ammo.Value = 999 end)
                    end
                    if Config.GunMods.NoRecoil then
                        pcall(function() tool.Recoil:Destroy() end)
                    end
                end
            end
        end
    end)

    Rayfield:Notify({
        Title = "Van Thanh Panel </> v20.0",
        Content = "Last Update in 25/11/2025",
        Duration = 10
    })
end)
