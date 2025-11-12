--Van Thanh Panel v1.0--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local replicatedStorage = game:GetService("ReplicatedStorage")
local camera = workspace.CurrentCamera
local weapons = replicatedStorage:WaitForChild("Weapons")
local localPlayer = players.LocalPlayer
local HttpService = game:GetService("HttpService")


local aimbot = {
    Enabled = false,
    TargetPart = "Head",
    TeamCheck = false,
    Smoothing = 0.1,
    EnableFOV = false,
    FOVRadius = 150,
    HeadPriority = 50,
    CircleSizePct = 100
}


local function UpdatePartRatios()
    local headPct = aimbot.HeadPriority
    local remaining = 100 - headPct
    aimbot.PartRatios = {
        Head = headPct,
        Torso = math.floor(remaining * 0.6),
        LeftHand = math.floor(remaining * 0.2),
        RightHand = remaining * 0.2
    }
end


local esp = {Enabled = false}


local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 2
fovCircle.Radius = aimbot.FOVRadius * (aimbot.CircleSizePct / 100)
fovCircle.Transparency = 0.8
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Filled = false


local ESPObjects = {}


local function GetValidPart(player, partName)
    local char = player.Character
    if not char then return nil end

    local part = nil
    if partName == "Head" then
        part = char:FindFirstChild("Head")
    elseif partName == "Torso" then
        part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    elseif partName == "LeftHand" then
        part = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
    elseif partName == "RightHand" then
        part = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    end

    if part and part:IsA("BasePart") and part.Position then
        return part
    end
    return nil
end


local function GetClosestPlayer()
    UpdatePartRatios()
    local closest = nil
    local shortestDist = math.huge
    local origin = camera.CFrame.Position

    for _, player in pairs(players:GetPlayers()) do
        if player == localPlayer then continue end
        local char = player.Character
        if not char then continue end
        if not char:FindFirstChild("HumanoidRootPart") then continue end
        if not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then continue end
        if aimbot.TeamCheck and player.Team == localPlayer.Team then continue end

        local parts = {
            Head = GetValidPart(player, "Head"),
            Torso = GetValidPart(player, "Torso"),
            LeftHand = GetValidPart(player, "LeftHand"),
            RightHand = GetValidPart(player, "RightHand")
        }

        local selectedPart = nil
        if aimbot.TargetPart ~= "Random" then
            selectedPart = parts[aimbot.TargetPart]
        else
            local rand = math.random(1, 100)
            local cum = 0
            for name, ratio in pairs(aimbot.PartRatios) do
                if parts[name] then
                    cum = cum + ratio
                    if rand <= cum then
                        selectedPart = parts[name]
                        break
                    end
                end
            end
        end

        if not selectedPart then
            selectedPart = char.HumanoidRootPart
        end

        if selectedPart and selectedPart.Position then
            local dist = (selectedPart.Position - origin).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = {Player = player, Part = selectedPart}
            end
        end
    end
    return closest
end


runService.Heartbeat:Connect(function()
    if not aimbot.Enabled then return end
    local target = GetClosestPlayer()
    if not target or not target.Part or not target.Part.Position then return end

    local targetPos = target.Part.Position
    if aimbot.EnableFOV then
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
        if not onScreen then return end
        local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > aimbot.FOVRadius then return end
    end

    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), aimbot.Smoothing)
end)


local function CreateESP(player)
    if ESPObjects[player] then return end

    local group = {}
    local box = Drawing.new("Square")
    box.Thickness = 2; box.Filled = false; box.Color = Color3.fromRGB(255, 0, 0); box.Transparency = 1

    local name = Drawing.new("Text")
    name.Size = 16; name.Font = 2; name.Color = Color3.fromRGB(255, 255, 255); name.Outline = true; name.Center = true

    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 3; healthBar.Color = Color3.fromRGB(0, 255, 0)

    local healthBG = Drawing.new("Line")
    healthBG.Thickness = 3; healthBG.Color = Color3.fromRGB(0, 0, 0); healthBG.Transparency = 0.5

    group.box = box; group.name = name; group.healthBar = healthBar; group.healthBG = healthBG
    ESPObjects[player] = group
end


local function UpdateESP()
    if not esp.Enabled then return end

    for player, group in pairs(ESPObjects) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            for _, obj in pairs(group) do obj.Visible = false end
            continue
        end

        local root = char.HumanoidRootPart
        local hum = char.Humanoid
        local head = GetValidPart(player, "Head") or root
        local vector, onScreen = camera:WorldToViewportPoint(root.Position)
        local headY = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0)).Y
        local footY = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 5, 0)).Y
        local height = math.abs(headY - footY)
        local width = height / 2

        if onScreen and height > 10 then
            
            group.box.Size = Vector2.new(width, height)
            group.box.Position = Vector2.new(vector.X - width/2, vector.Y - height/2)
            group.box.Visible = true

            
            group.name.Text = player.Name
            group.name.Position = Vector2.new(vector.X, headY - 20)
            group.name.Visible = true

            
            local healthPct = hum.Health / hum.MaxHealth
            group.healthBar.From = Vector2.new(vector.X - width/2 - 5, footY)
            group.healthBar.To = Vector2.new(vector.X - width/2 - 5, footY + height * healthPct)
            group.healthBar.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
            group.healthBar.Visible = true

            group.healthBG.From = Vector2.new(vector.X - width/2 - 5, footY)
            group.healthBG.To = Vector2.new(vector.X - width/2 - 5, footY + height)
            group.healthBG.Visible = true
        else
            for _, obj in pairs(group) do obj.Visible = false end
        end
    end
end


local function ToggleShadows(remove)
    for _, v in pairs(lighting:GetDescendants()) do
        if v:IsA("PostEffect") or string.find(v.Name, "Shadow") then
            v.Enabled = not remove
        end
    end
end


local configFile = "VanThanhPanel_Config.json"
local function SaveConfig()
    local config = {aimbot = aimbot, esp = esp}
    if writefile then
        writefile(configFile, HttpService:JSONEncode(config))
        Rayfield:Notify({Title = "Saved!", Content = "Config lưu file!", Duration = 2})
    else
        setclipboard(HttpService:JSONEncode(config))
        Rayfield:Notify({Title = "Copied!", Content = "Dán JSON để lưu!", Duration = 2})
    end
end

local function LoadConfig()
    if isfile and isfile(configFile) and readfile then
        local data = HttpService:JSONDecode(readfile(configFile))
        for k, v in pairs(data.aimbot) do aimbot[k] = v end
        esp.Enabled = data.esp.Enabled or false
        fovCircle.Radius = aimbot.FOVRadius * (aimbot.CircleSizePct / 100)
        Rayfield:Notify({Title = "Loaded!", Content = "Config OK!", Duration = 2})
    end
end


local Window = Rayfield:CreateWindow({
    Name = "Van Thanh Panel v1.15",
    LoadingTitle = "Đang Load...",
    LoadingSubtitle = "Code By Van Thanh >/<",
    ConfigurationSaving = {Enabled = true, FolderName = "VanThanhPanel", FileName = "Config"}
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)
local CreditsTab = Window:CreateTab("Credits", 4483362458)


CombatTab:CreateToggle({Name = "Aimbot", Callback = function(v) aimbot.Enabled = v end})
CombatTab:CreateDropdown({Name = "Target", Options = {"Head", "Torso", "LeftHand", "RightHand", "Random"}, CurrentOption = {"Head"}, Callback = function(o) aimbot.TargetPart = o[1] end})
CombatTab:CreateSlider({Name = "Head Priority %", Range = {0,100}, Increment = 5, CurrentValue = 50, Callback = function(v) aimbot.HeadPriority = v end})
CombatTab:CreateToggle({Name = "Team Check", Callback = function(v) aimbot.TeamCheck = v end})
CombatTab:CreateSlider({Name = "Smoothing", Range = {0,1}, Increment = 0.05, CurrentValue = 0.1, Callback = function(v) aimbot.Smoothing = v end})


VisualsTab:CreateToggle({Name = "ESP", Callback = function(v) 
    esp.Enabled = v
    if v then
        for _, p in pairs(players:GetPlayers()) do
            if p ~= localPlayer then CreateESP(p) end
        end
    else
        for _, g in pairs(ESPObjects) do for _, o in pairs(g) do o:Remove() end end
        ESPObjects = {}
    end
end})
VisualsTab:CreateToggle({Name = "FOV Circle", Callback = function(v) aimbot.EnableFOV = v; fovCircle.Visible = v end})
VisualsTab:CreateSlider({Name = "Game FOV %", Range = {50,200}, Increment = 5, CurrentValue = 100, Callback = function(v) camera.FieldOfView = 70 * (v/100) end})
VisualsTab:CreateSlider({Name = "Circle Size %", Range = {50,200}, Increment = 5, CurrentValue = 100, Callback = function(v) aimbot.CircleSizePct = v; fovCircle.Radius = aimbot.FOVRadius * (v/100) end})

-- Misc
MiscTab:CreateButton({Name = "No Recoil", Callback = function() for _, w in pairs(weapons:GetChildren()) do if w:FindFirstChild("Recoil") then w.Recoil.Value = 0 end end end})
MiscTab:CreateButton({Name = "Inf Ammo", Callback = function() spawn(function() while wait(0.1) do for _, w in pairs(weapons:GetChildren()) do if w:FindFirstChild("Ammo") then w.Ammo.Value = 999 end end end end) end})
MiscTab:CreateToggle({Name = "Remove Shadows", Callback = function(v) ToggleShadows(v) end})


ConfigTab:CreateButton({Name = "Save Config", Callback = SaveConfig})
ConfigTab:CreateButton({Name = "Load Config", Callback = LoadConfig})


CreditsTab:CreateLabel("Code bởi: Van Thanh >/<")
CreditsTab:CreateLabel("v1.15 - Fixed All Spawn Errors")
CreditsTab:CreateLabel("Zalo: 0392236290")


runService.RenderStepped:Connect(UpdateESP)
runService.RenderStepped:Connect(function()
    if aimbot.EnableFOV and fovCircle.Visible then
        fovCircle.Position = userInputService:GetMouseLocation()
    end
end)

players.PlayerAdded:Connect(function(p) if esp.Enabled and p ~= localPlayer then CreateESP(p) end end)
players.PlayerRemoving:Connect(function(p) if ESPObjects[p] then for _, o in pairs(ESPObjects[p]) do o:Remove() end; ESPObjects[p] = nil end end)

print("Van Thanh Panel v1.0! | Wish you a fun and relaxing game. Thank you very much!")
