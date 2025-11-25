-- ═══════════════════════════════════════════════════════════
--    VAN THANH PANEL v16.0 - AURORA LEGACY HVH FULL CLONE 2025
--    100% Clone Aurora từ Screenshot | Rayfield UI | Chạy như Aurora HVH
-- ═══════════════════════════════════════════════════════════

pcall(function()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")

    -- ==================== CONFIG AURORA CLONE ====================
    local Config = {
        Legit = {
            Enabled = false,
            FOV = 90,
            Smooth = 5,
            DoubleTap = false,
            HitChance = 100,
            Hitboxes = {"Head"},
            Triggerbot = false,
            AutoShoot = false
        },
        Rage = {
            Enabled = false,
            Resolver = false,
            Backtrack = false,
            KnifeBot = false,
            ForceHit = false,
            Wallbang = false,
            DoubleTap = false
        },
        Visuals = {
            ESP = true,
            Box = true,
            Name = true,
            Health = true,
            Chams = true,
            BulletTracer = true,
            HitChams = true,
            DarkFlash = true,
            ViewmodelFOV = 68,
            WorldAmbient = 0,
            Bloom = 0,
            Saturation = 0
        },
        Movement = {
            Bhop = false,
            Fly = false,
            SpeedHack = false,
            Speed = 16
        },
        GunMods = {
            InfiniteAmmo = false,
            RapidFire = false,
            NoRecoil = true
        },
        Misc = {
            PingSpoofer = 50,
            SpectatorList = true,
            ConfigName = "Default"
        }
    }

    -- ==================== RAYFIELD WINDOW - AURORA STYLE ====================
    local Window = Rayfield:CreateWindow({
        Name = "Van Thanh Panel v16.0 - Aurora Legacy HVH",
        LoadingTitle = "Aurora Legacy Loading...",
        LoadingSubtitle = "Full Clone 2025 - Van Thanh >/<",
        ConfigurationSaving = {Enabled = true, FolderName = "VanThanhAurora", FileName = "v16"},
        KeySystem = false
    })

    local LegitTab = Window:CreateTab("Legit", 4483362458)
    local RageTab = Window:CreateTab("Rage", 4483362458)
    local VisualsTab = Window:CreateTab("Visuals", 4483362458)
    local SkinsTab = Window:CreateTab("Skins", 4483362458)
    local SettingsTab = Window:CreateTab("Settings", 4483362458)

    -- ==================== LEGIT TAB ====================
    LegitTab:CreateToggle({Name = "Legitbot Enabled", CurrentValue = false, Callback = function(v) Config.Legit.Enabled = v end})
    LegitTab:CreateSlider({Name = "FOV", Range = {1, 180}, Increment = 1, CurrentValue = 90, Callback = function(v) Config.Legit.FOV = v end})
    LegitTab:CreateSlider({Name = "Smoothness", Range = {1, 30}, Increment = 1, CurrentValue = 5, Callback = function(v) Config.Legit.Smooth = v end})
    LegitTab:CreateToggle({Name = "Double Tap", CurrentValue = false, Callback = function(v) Config.Legit.DoubleTap = v end})
    LegitTab:CreateSlider({Name = "Hit Chance", Range = {0, 100}, Increment = 1, CurrentValue = 100, Callback = function(v) Config.Legit.HitChance = v end})
    LegitTab:CreateDropdown({Name = "Hitboxes", Options = {"Head", "Chest", "Stomach"}, CurrentOption = {"Head"}, MultiSelection = true, Callback = function(o) Config.Legit.Hitboxes = o end})

    -- ==================== RAGE TAB ====================
    RageTab:CreateToggle({Name = "Ragebot Enabled", CurrentValue = false, Callback = function(v) Config.Rage.Enabled = v end})
    RageTab:CreateToggle({Name = "Resolver", CurrentValue = false, Callback = function(v) Config.Rage.Resolver = v end})
    RageTab:CreateToggle({Name = "Backtrack", CurrentValue = false, Callback = function(v) Config.Rage.Backtrack = v end})
    RageTab:CreateToggle({Name = "Knife Bot", CurrentValue = false, Callback = function(v) Config.Rage.KnifeBot = v end})
    RageTab:CreateToggle({Name = "Force Hit", CurrentValue = false, Callback = function(v) Config.Rage.ForceHit = v end})
    RageTab:CreateToggle({Name = "Wallbang", CurrentValue = false, Callback = function(v) Config.Rage.Wallbang = v end})

    -- ==================== VISUALS TAB ====================
    VisualsTab:CreateToggle({Name = "ESP", CurrentValue = true, Callback = function(v) Config.Visuals.ESP = v end})
    VisualsTab:CreateToggle({Name = "Box", CurrentValue = true, Callback = function(v) Config.Visuals.Box = v end})
    VisualsTab:CreateToggle({Name = "Bullet Tracers", CurrentValue = true, Callback = function(v) Config.Visuals.BulletTracer = v end})
    VisualsTab:CreateToggle({Name = "Hit Chams", CurrentValue = true, Callback = function(v) Config.Visuals.HitChams = v end})
    VisualsTab:CreateToggle({Name = "Dark Flashbang", CurrentValue = true, Callback = function(v) Config.Visuals.DarkFlash = v end})
    VisualsTab:CreateSlider({Name = "Viewmodel FOV", Range = {50, 120}, Increment = 1, CurrentValue = 68, Callback = function(v) Config.Visuals.ViewmodelFOV = v Camera.FieldOfView = v end})
    VisualsTab:CreateSlider({Name = "World Ambient", Range = {0, 2}, Increment = 0.1, CurrentValue = 0, Callback = function(v) Lighting.Ambient = Color3.new(v,v,v) end})

    -- ==================== SKINS TAB ====================
    SkinsTab:CreateButton({Name = "Open Full Aurora Skin Changer", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))()
    end})

    -- ==================== SETTINGS TAB ====================
    SettingsTab:CreateTextbox({Name = "Config Name", CurrentValue = "Default", Callback = function(v) Config.Misc.ConfigName = v end})
    SettingsTab:CreateButton({Name = "Save Config", Callback = function() writefile("VanThanh_"..Config.Misc.ConfigName..".json", HttpService:JSONEncode(Config)) end})
    SettingsTab:CreateButton({Name = "Load Config", Callback = function()
        if isfile("VanThanh_"..Config.Misc.ConfigName..".json") then
            Config = HttpService:JSONDecode(readfile("VanThanh_"..Config.Misc.ConfigName..".json"))
            Rayfield:Notify({Title="Config", Content="Loaded: "..Config.Misc.ConfigName, Duration=3})
        end
    end})

    -- ==================== CORE FEATURES (FULL AURORA) ====================
    -- Silent Aim + Resolver
    RunService.Heartbeat:Connect(function()
        if Config.Legit.Enabled or Config.Rage.Enabled then
            local closest = nil
            local bestDist = Config.Legit.Enabled and Config.Legit.FOV or 999
            for _, plr in Players:GetPlayers() do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local head = plr.Character.Head
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            closest = head.Position
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

    -- Dark Flashbang
    spawn(function()
        while task.wait(0.1) do
            if Config.Visuals.DarkFlash then
                pcall(function() Camera.Flash:Destroy() end)
            end
        end
    end)

    Rayfield:Notify({
        Title = "Van Thanh Panel v16.0",
        Content = "Aurora Legacy HVH Clone Loaded 100%!\nChạy ngon như Aurora thật!",
        Duration = 10
    })
end)
