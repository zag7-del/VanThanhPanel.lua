-- Van Thanh Panel v1.16 (13/11/2025) - Based on Aurora ENG + Van Thanh Upgrade
-- Code bởi: Van Thanh >/< | Tham khảo: egorware/aurora_but_eng.lua
-- Features: Smooth Aimbot, Silent Aim, ESP Team Toggle, Tracer + Distance, FOV %, Config

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local camera = workspace.CurrentCamera
local localPlayer = players.LocalPlayer
local HttpService = game:GetService("HttpService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- === CONFIG ===
local config = {
    aimbot = {
        Enabled = false,
        TeamCheck = true,
        SilentAim = false,
        Hitbox = "Head",
        Smoothing = 0.15,
        FOV = 150,
        FOVVisible = true,
        FOVSizePct = 100
    },
    esp = {
        Enabled = false,
        TeamESP = false,
        Box = true,
        Name = true,
        Distance = true,
        Tracer = true,
        HealthBar = true
    }
}

-- === FOV CIRCLE ===
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Transparency = 0.8
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Radius = config.aimbot.FOV * (config.aimbot.FOVSizePct / 100)
fovCircle.Visible = config.aimbot.FOVVisible

-- === ESP STORAGE ===
local ESP = {}

-- === GET BEST TARGET (Aurora-style) ===
local function GetBestTarget()
    local closest = nil
    local closestDist = config.aimbot.FOV
    local origin = camera.CFrame.Position

    for _, player in pairs(players:GetPlayers()) do
        if player == localPlayer then continue end
        if config.aimbot.TeamCheck and player.Team == localPlayer.Team then continue end

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then continue end
        if char.Humanoid.Health <= 0 then continue end

        local part = char:FindFirstChild(config.aimbot.Hitbox) or char.HumanoidRootPart
        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - userInputService:GetMouseLocation()).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = {Player = player, Part = part, Screen = screenPos}
        end
    end
    return closest
end

-- === AIMBOT LOOP (Smooth + Silent) ===
runService.Heartbeat:Connect(function()
    if not config.aimbot.Enabled then return end
    local target = GetBestTarget()
    if not target then return end

    local targetPos = target.Part.Position

    if config.aimbot.SilentAim then
        -- Silent: Không di chuyển camera, chỉ bắn trúng
        local mousePos = userInputService:GetMouseLocation()
        local direction = (targetPos - camera.CFrame.Position).Unit
        local lookAt = camera.CFrame.Position + direction * 1000
        camera.CFrame = CFrame.new(camera.CFrame.Position, lookAt)
    else
        -- Smooth aim: Tâm di chuyển theo địch
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), config.aimbot.Smoothing)
    end
end)

-- === ESP CREATE ===
local function CreateESP(player)
    if ESP[player] then return end

    local esp = {}
    esp.Box = Drawing.new("Square")
    esp.Box.Thickness = 2; esp.Box.Filled = false; esp.Box.Color = Color3.fromRGB(255, 0, 0); esp.Box.Transparency = 1

    esp.Name = Drawing.new("Text")
    esp.Name.Size = 14; esp.Name.Font = 2; esp.Name.Color = Color3.fromRGB(255, 255, 255); esp.Name.Outline = true; esp.Name.Center = true

    esp.Distance = Drawing.new("Text")
    esp.Distance.Size = 13; esp.Distance.Font = 2; esp.Distance.Color = Color3.fromRGB(0, 255, 255); esp.Distance.Outline = true

    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Thickness = 1; esp.Tracer.Color = Color3.fromRGB(255, 255, 255); esp.Tracer.Transparency = 0.7

    esp.HealthBar = Drawing.new("Line")
    esp.HealthBar.Thickness = 3

    esp.HealthBG = Drawing.new("Line")
    esp.HealthBG.Thickness = 3; esp.HealthBG.Color = Color3.fromRGB(0, 0, 0); esp.HealthBG.Transparency = 0.5

    ESP[player] = esp
end

-- === ESP UPDATE ===
local function UpdateESP()
    if not config.esp.Enabled then return end

    for player, drawings in pairs(ESP) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local root = char.HumanoidRootPart
        local hum = char.Humanoid
        local head = char:FindFirstChild("Head") or root
        local isTeam = player.Team == localPlayer.Team

        -- Team ESP Toggle
        if not config.esp.TeamESP and isTeam then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local vector, onScreen = camera:WorldToViewportPoint(root.Position)
        local headY = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0)).Y
        local footY = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 5, 0)).Y
        local height = math.abs(headY - footY)
        local width = height / 2

        if onScreen and height > 10 then
            local color = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

            -- Box
            if config.esp.Box then
                drawings.Box.Size = Vector2.new(width, height)
                drawings.Box.Position = Vector2.new(vector.X - width/2, vector.Y - height/2)
                drawings.Box.Color = color
                drawings.Box.Visible = true
            else
                drawings.Box.Visible = false
            end

            -- Name
            if config.esp.Name then
                drawings.Name.Text = player.Name
                drawings.Name.Position = Vector2.new(vector.X, headY - 20)
                drawings.Name.Visible = true
            else
                drawings.Name.Visible = false
            end

            -- Distance
            if config.esp.Distance then
                local dist = (root.Position - camera.CFrame.Position).Magnitude
                drawings.Distance.Text = string.format("%.1fm", dist)
                drawings.Distance.Position = Vector2.new(vector.X, footY + 5)
                drawings.Distance.Visible = true
            else
                drawings.Distance.Visible = false
            end

            -- Tracer
            if config.esp.Tracer then
                drawings.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                drawings.Tracer.To = Vector2.new(vector.X, footY)
                drawings.Tracer.Color = color
                drawings.Tracer.Visible = true
            else
                drawings.Tracer.Visible = false
            end

            -- Health Bar
            if config.esp.HealthBar then
                local healthPct = hum.Health / hum.MaxHealth
                drawings.HealthBar.From = Vector2.new(vector.X - width/2 - 5, footY)
                drawings.HealthBar.To = Vector2.new(vector.X - width/2 - 5, footY + height * healthPct)
                drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
                drawings.HealthBar.Visible = true

                drawings.HealthBG.From = Vector2.new(vector.X - width/2 - 5, footY)
                drawings.HealthBG.To = Vector2.new(vector.X - width/2 - 5, footY + height)
                drawings.HealthBG.Visible = true
            else
                drawings.HealthBar.Visible = false
                drawings.HealthBG.Visible = false
            end
        else
            for _, d in pairs(drawings) do d.Visible = false end
        end
    end
end

-- === CONFIG SAVE/LOAD ===
local configFile = "VanThanhPanel_v16.json"
local function SaveConfig()
    if writefile then
        writefile(configFile, HttpService:JSONEncode(config))
        Rayfield:Notify({Title = "Saved!", Content = "Config đã lưu!", Duration = 2})
    else
        setclipboard(HttpService:JSONEncode(config))
        Rayfield:Notify({Title = "Copied!", Content = "Dán JSON để lưu!", Duration = 2})
    end
end

local function LoadConfig()
    if isfile and isfile(configFile) and readfile then
        local data = HttpService:JSONDecode(readfile(configFile))
        for k, v in pairs(data) do
            if config[k] then
                for sk, sv in pairs(v) do
                    if config[k][sk] ~= nil then
                        config[k][sk] = sv
                    end
                end
            end
        end
        -- Apply
        fovCircle.Radius = config.aimbot.FOV * (config.aimbot.FOVSizePct / 100)
        fovCircle.Visible = config.aimbot.FOVVisible
        Rayfield:Notify({Title = "Loaded!", Content = "Config đã tải!", Duration = 2})
    end
end

-- === GUI ===
local Window = Rayfield:CreateWindow({
    Name = "Van Thanh Panel v1.16",
    LoadingTitle = "Aurora ENG + Van Thanh",
    LoadingSubtitle = "Smooth | Silent | ESP Team Toggle",
    ConfigurationSaving = {Enabled = true, FolderName = "VanThanhPanel", FileName = "v16"}
})

local Combat = Window:CreateTab("Combat", 4483362458)
local Visuals = Window:CreateTab("Visuals", 4483362458)
local Misc = Window:CreateTab("Misc", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)
local Credits = Window:CreateTab("Credits", 4483362458)

-- === COMBAT ===
Combat:CreateToggle({Name = "Aimbot", Callback = function(v) config.aimbot.Enabled = v end})
Combat:CreateToggle({Name = "Silent Aim", Callback = function(v) config.aimbot.SilentAim = v end})
Combat:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) config.aimbot.TeamCheck = v end})
Combat:CreateDropdown({Name = "Hitbox", Options = {"Head", "Body", "Nearest"}, CurrentOption = {"Head"}, Callback = function(o) config.aimbot.Hitbox = o[1] end})
Combat:CreateSlider({Name = "Smoothing", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.15, Callback = function(v) config.aimbot.Smoothing = v end})
Combat:CreateSlider({Name = "FOV", Range = {50, 500}, Increment = 10, CurrentValue = 150, Callback = function(v) config.aimbot.FOV = v; fovCircle.Radius = v * (config.aimbot.FOVSizePct / 100) end})
Combat:CreateToggle({Name = "FOV Circle", CurrentValue = true, Callback = function(v) config.aimbot.FOVVisible = v; fovCircle.Visible = v end})
Combat:CreateSlider({Name = "FOV Size %", Range = {50, 200}, Increment = 5, CurrentValue = 100, Callback = function(v) config.aimbot.FOVSizePct = v; fovCircle.Radius = config.aimbot.FOV * (v / 100) end})

-- === VISUALS ===
Visuals:CreateToggle({Name = "ESP", Callback = function(v) config.esp.Enabled = v end})
Visuals:CreateToggle({Name = "ESP Đồng Đội", CurrentValue = false, Callback = function(v) config.esp.TeamESP = v end})
Visuals:CreateToggle({Name = "Box", CurrentValue = true, Callback = function(v) config.esp.Box = v end})
Visuals:CreateToggle({Name = "Name", CurrentValue = true, Callback = function(v) config.esp.Name = v end})
Visuals:CreateToggle({Name = "Distance", CurrentValue = true, Callback = function(v) config.esp.Distance = v end})
Visuals:CreateToggle({Name = "Tracer", CurrentValue = true, Callback = function(v) config.esp.Tracer = v end})
Visuals:CreateToggle({Name = "Health Bar", CurrentValue = true, Callback = function(v) config.esp.HealthBar = v end})

-- === MISC ===
Misc:CreateButton({Name = "No Recoil", Callback = function() 
    for _, w in pairs(replicatedStorage.Weapons:GetChildren()) do 
        if w:FindFirstChild("Recoil") then w.Recoil.Value = 0 end 
    end 
end})

-- === CONFIG ===
ConfigTab:CreateButton({Name = "Save Config", Callback = SaveConfig})
ConfigTab:CreateButton({Name = "Load Config", Callback = LoadConfig})

-- === CREDITS ===
Credits:CreateLabel("Code bởi: Van Thanh >/<")
Credits:CreateLabel("Dựa trên: egorware/aurora_but_eng.lua")
Credits:CreateLabel("Zalo: 0392236290 | Discord: vthanh20th7")

-- === LOOPS ===
runService.RenderStepped:Connect(UpdateESP)
runService.RenderStepped:Connect(function()
    if config.aimbot.FOVVisible then
        fovCircle.Position = userInputService:GetMouseLocation()
    end
end)

players.PlayerAdded:Connect(function(p)
    if config.esp.Enabled and p ~= localPlayer then
        CreateESP(p)
    end
end)

players.PlayerRemoving:Connect(function(p)
    if ESP[p] then
        for _, d in pairs(ESP[p]) do d:Remove() end
        ESP[p] = nil
    end
end)

-- Auto create ESP
for _, p in pairs(players:GetPlayers()) do
    if p ~= localPlayer then CreateESP(p) end
end

print("Van Thanh Panel v1.16 Loaded – Aurora ENG Base + Full Upgrade!")
