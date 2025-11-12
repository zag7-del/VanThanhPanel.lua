-- Van Thanh Panel v1.0
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
    HeadPriority = 50
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


local function GetClosestPlayer()
    UpdatePartRatios()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local origin = camera.CFrame.Position
    
    local ratios = aimbot.TargetPart == "Random" and aimbot.PartRatios or {}
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
           player.Character:FindFirstChild("Humanoid") and (not aimbot.TeamCheck or player.Team ~= localPlayer.Team) then
            
            local parts = {
                Head = player.Character:FindFirstChild("Head"),
                Torso = player.Character:FindFirstChild("UpperTorso"),
                LeftHand = player.Character:FindFirstChild("LeftHand"),
                RightHand = player.Character:FindFirstChild("RightHand")
            }
            
            local selectedPart = nil
            if aimbot.TargetPart ~= "Random" then
                selectedPart = parts[aimbot.TargetPart]
            else
                local rand = math.random(1, 100)
                local cumulative = 0
                for partName, ratio in pairs(ratios) do
                    cumulative += ratio
                    if rand <= cumulative and parts[partName] then
                        selectedPart = parts[partName]
                        break
                    end
                end
            end
            if not selectedPart then selectedPart = player.Character.HumanoidRootPart end
            
            local distance = (selectedPart.Position - origin).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = {Player = player, Part = selectedPart}
            end
        end
    end
    return closestPlayer
end


runService.Heartbeat:Connect(function()
    if aimbot.Enabled then
        local target = GetClosestPlayer()
        if target and target.Part then
            local targetPos = target.Part.Position
            if aimbot.EnableFOV then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                if dist > aimbot.FOVRadius then return end
            end
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), aimbot.Smoothing)
        end
    end
end)


local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local espGroup = {}
    local box = Drawing.new("Square")
    box.Thickness = 2; box.Filled = false; box.Color = Color3.fromRGB(255, 0, 0); box.Transparency = 1
    
    local nameText = Drawing.new("Text")
    nameText.Size = 16; nameText.Font = 2; nameText.Color = Color3.fromRGB(255, 255, 255); nameText.Outline = true; nameText.Center = true
    
    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 3; healthBar.Color = Color3.fromRGB(0, 255, 0)
    
    local healthBarBG = Drawing.new("Line")
    healthBarBG.Thickness = 3; healthBarBG.Color = Color3.fromRGB(0, 0, 0); healthBarBG.Transparency = 0.5
    
    espGroup.box = box; espGroup.name = nameText; espGroup.healthBar = healthBar; espGroup.healthBarBG = healthBarBG
    
    ESPObjects[player] = espGroup
end


local function UpdateESP()
    if not esp.Enabled then return end
    for player, group in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local root = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid
            local vector, onScreen = camera:WorldToViewportPoint(root.Position)
            local headPos = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
            local footPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 5, 0))
            local height = math.abs(headPos.Y - footPos.Y)
            local width = height / 2
            
            if onScreen then
                group.box.Size = Vector2.new(width, height)
                group.box.Position = Vector2.new(vector.X - width/2, vector.Y - height/2)
                group.box.Visible = true
                
                group.name.Text = player.Name
                group.name.Position = Vector2.new(vector.X, headPos.Y - 20)
                group.name.Visible = true
                
                local healthPercent = hum.Health / hum.MaxHealth
                group.healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                group.healthBar.From = Vector2.new(vector.X - width/2 - 5, footPos.Y)
                group.healthBar.To = Vector2.new(vector.X - width/2 - 5, footPos.Y + (height * healthPercent))
                group.healthBar.Visible = true
                
                group.healthBarBG.From = Vector2.new(vector.X - width/2 - 5, footPos.Y)
                group.healthBarBG.To = Vector2.new(vector.X - width/2 - 5, footPos.Y + height)
                group.healthBarBG.Visible = true
            else
                for _, obj in pairs(group) do obj.Visible = false end
            end
        else
            for _, obj in pairs(group) do obj.Visible = false end
        end
    end
end

local function ToggleShadows(remove)
    for _, v in pairs(lighting:GetDescendants()) do
        if v:IsA("PostEffect") or v.Name:find("Shadow") then v.Enabled = not remove end
    end
end


local configFile = "VanThanhPanel/Config.json"
local function SaveConfig()
    local config = {
        aimbot = aimbot,
        esp = esp
    }
    if writefile then
        writefile(configFile, HttpService:JSONEncode(config))
        Rayfield:Notify({Title = "Saved!", Content = "Config lưu file!", Duration = 3})
    else
        setclipboard(HttpService:JSONEncode(config))
        Rayfield:Notify({Title = "Saved Clipboard!", Content = "Paste lưu JSON!", Duration = 3})
    end
end

local function LoadConfig()
    if readfile and isfile(configFile) then
        local configData = HttpService:JSONDecode(readfile(configFile))
        aimbot.Enabled = configData.aimbot.Enabled or false
        aimbot.TargetPart = configData.aimbot.TargetPart or "Head"
        aimbot.TeamCheck = configData.aimbot.TeamCheck or false
        aimbot.Smoothing = configData.aimbot.Smoothing or 0.1
        aimbot.EnableFOV = configData.aimbot.EnableFOV or false
        aimbot.FOVRadius = configData.aimbot.FOVRadius or 150
        aimbot.HeadPriority = configData.aimbot.HeadPriority or 50
        esp.Enabled = configData.esp.Enabled or false
        Rayfield:Notify({Title = "Loaded!", Content = "Config tải OK!", Duration = 3})
    else
        Rayfield:Notify({Title = "No Config!", Content = "Tạo config trước!", Duration = 3})
    end
end

local function ResetConfig()
    aimbot.Enabled = false
    aimbot.TargetPart = "Head"
    aimbot.TeamCheck = false
    aimbot.Smoothing = 0.1
    aimbot.EnableFOV = false
    aimbot.FOVRadius = 150
    aimbot.HeadPriority = 50
    esp.Enabled = false
    if writefile then writefile(configFile, "") end
    Rayfield:Notify({Title = "Reset!", Content = "Defaults restored!", Duration = 3})
end

local function DownloadConfig()
    local config = HttpService:JSONEncode({aimbot = aimbot, esp = esp})
    setclipboard(config)
    Rayfield:Notify({Title = "Downloaded!", Content = "JSON in clipboard - Save for reuse!", Duration = 3})
end


local Window = Rayfield:CreateWindow({
    Name = "Van Thanh Panel",
    LoadingTitle = "Đang Load...",
    LoadingSubtitle = "Best Script CB2025 Code By Van Thanh >/<",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VanThanhPanel",
        FileName = "Config"
    }
})

local CombatTab = Window:CreateTab("Combat (Aimbot)", 4483362458)
local VisualsTab = Window:CreateTab("Visuals (ESP/FOV)", 4483362458)
local SkinsTab = Window:CreateTab("Skins (Aurora Mod)", 4483362458)
local MiscTab = Window:CreateTab("Misc (Gun/Effects)", 4483362458)
local ConfigTab = Window:CreateTab("Config (Save/Load)", 4483362458)
local CreditsTab = Window:CreateTab("Credits (Info)", 4483362458)


CombatTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) aimbot.Enabled = v end})
CombatTab:CreateDropdown({
    Name = "Target Mode",
    Options = {"Head", "Torso", "LeftHand", "RightHand", "Random"},
    CurrentOption = {"Head"},
    Callback = function(option) aimbot.TargetPart = option[1] end
})
CombatTab:CreateSection("Tỉ Lệ Aim (Head Focus %)")
CombatTab:CreateSlider({
    Name = "Aim Priority % (Head Focus)",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) 
        aimbot.HeadPriority = v
        UpdatePartRatios()
        Rayfield:Notify({Title = "Updated!", Content = "Head: " .. v .. "% | Others auto", Duration = 2})
    end
})
CombatTab:CreateLabel("100% = Always Head | 0% = Even Random")
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = false, Callback = function(v) aimbot.TeamCheck = v end})
CombatTab:CreateSlider({Name = "Smoothing", Range = {0, 1}, Increment = 0.05, CurrentValue = 0.1, Callback = function(v) aimbot.Smoothing = v end})


VisualsTab:CreateToggle({Name = "ESP (Name + Health Bar)", CurrentValue = false, Callback = function(v) 
    esp.Enabled = v
    if v then 
        for _, p in pairs(players:GetPlayers()) do 
            if p ~= localPlayer then CreateESP(p) end 
        end 
    else 
        for p, g in pairs(ESPObjects) do 
            for _, o in pairs(g) do o:Remove() end 
        end 
        ESPObjects = {} 
    end 
end})
VisualsTab:CreateToggle({Name = "FOV Circle", CurrentValue = false, Callback = function(v) aimbot.EnableFOV = v; fovCircle.Visible = v end})
VisualsTab:CreateSlider({Name = "FOV Radius", Range = {50, 500}, Increment = 10, CurrentValue = 150, Callback = function(v) aimbot.FOVRadius = v; fovCircle.Radius = v end})


SkinsTab:CreateSection("Aurora Skin Changer")
local knifeOptions = {}
for _, skin in pairs(auroraSkins.Knives) do table.insert(knifeOptions, skin.Name) end
SkinsTab:CreateDropdown({Name = "Knife Skin", Options = knifeOptions, CurrentOption = {"Default"}, Callback = function(option) ApplyAuroraSkin("Knives", option[1]) end})

local gloveOptions = {}
for _, skin in pairs(auroraSkins.Gloves) do table.insert(gloveOptions, skin.Name) end
SkinsTab:CreateDropdown({Name = "Glove Skin", Options = gloveOptions, CurrentOption = {"Default"}, Callback = function(option) ApplyAuroraSkin("Gloves", option[1]) end})

local weaponOptions = {}
for _, skin in pairs(auroraSkins.Weapons) do table.insert(weaponOptions, skin.Name) end
SkinsTab:CreateDropdown({Name = "Weapon Skin", Options = weaponOptions, CurrentOption = {"Default"}, Callback = function(option) ApplyAuroraSkin("Weapons", option[1]) end})

SkinsTab:CreateButton({Name = "Unlock All Aurora Skins", Callback = function() 
    for category, list in pairs(auroraSkins) do
        for _, skin in pairs(list) do
            ApplyAuroraSkin(category, skin.Name)
            wait(0.1)
        end
    end
    Rayfield:Notify({Title = "Unlocked!", Content = "All skins applied", Duration = 3})
end})


MiscTab:CreateSection("Gun Mods")
MiscTab:CreateButton({Name = "No Recoil", Callback = function() for _, w in pairs(weapons:GetChildren()) do if w:FindFirstChild("Recoil") then w.Recoil.Value = 0 end end end})
MiscTab:CreateButton({Name = "Inf Ammo", Callback = function() spawn(function() while wait(0.1) do for _, w in pairs(weapons:GetChildren()) do if w:FindFirstChild("Ammo") then w.Ammo.Value = math.huge end end end end) end})

MiscTab:CreateSection("Lighting Effects")
MiscTab:CreateToggle({Name = "Remove Shadows", CurrentValue = false, Callback = function(v) ToggleShadows(v) end})
MiscTab:CreateButton({Name = "Toggle Ambient Occlusion", Callback = function() lighting.AmbientOcclusion = not lighting.AmbientOcclusion end})
MiscTab:CreateButton({Name = "Skybox Aurora", Callback = function() lighting.Sky.SkyboxBk = "rbxassetid://600311421" end})
MiscTab:CreateSlider({Name = "Fog End", Range = {0, 100000}, Increment = 1000, CurrentValue = 100000, Callback = function(v) lighting.FogEnd = v end})
MiscTab:CreateSlider({Name = "World Time", Range = {0, 24}, Increment = 1, CurrentValue = 12, Callback = function(v) lighting.ClockTime = v end})


ConfigTab:CreateSection("Config Manager")
ConfigTab:CreateLabel("Auto-save khi chỉnh. Manual dưới để tải/lưu.")
ConfigTab:CreateButton({Name = "Save Config", Callback = SaveConfig})
ConfigTab:CreateButton({Name = "Load Config", Callback = LoadConfig})
ConfigTab:CreateButton({Name = "Download Config (Clipboard)", Callback = DownloadConfig})
ConfigTab:CreateButton({Name = "Reset Config", Callback = ResetConfig})
ConfigTab:CreateLabel("Download: Copy JSON, lưu .json để reuse sau.")


CreditsTab:CreateSection("Thông Tin Người Sáng Tạo")
CreditsTab:CreateLabel("Script được Code bởi: Van Thanh >/<")
CreditsTab:CreateLabel("Phiên bản: Van Thanh Panel v1.8 (Credits Last)")
CreditsTab:CreateLabel("Ngày cập nhật: 11/11/2025")
CreditsTab:CreateLabel("Mô tả: Tabs chức năng + Config save/load")
CreditsTab:CreateLabel("Note: Alt acc only! >/<")

CreditsTab:CreateSection("Thông Tin Liên Hệ")
CreditsTab:CreateLabel("Discord: https://discord.gg/TgBdHfVv")
CreditsTab:CreateLabel("Zalo: 0392236290 (Dv Mxh - Dư Văn Thành)")
CreditsTab:CreateLabel("Telegram: T.me/vthanhzz")
CreditsTab:CreateLabel("Vietnamese: Mua key liên hệ trên | English: Buy key above")

CreditsTab:CreateButton({
    Name = "Copy All Contacts",
    Callback = function()
        setclipboard("Discord: vthanh20th7 | Zalo: 0392236290 | Email: dvt2072012@gmail.com")
        Rayfield:Notify({Title = "Copied!", Content = "Đã copy thông tin liên hệ!", Duration = 3, Image = 4483362458})
    end
})


runService.RenderStepped:Connect(UpdateESP)
runService.RenderStepped:Connect(function()
    if aimbot.EnableFOV then
        local mouse = userInputService:GetMouseLocation()
        fovCircle.Position = mouse
    end
end)
players.PlayerRemoving:Connect(function(p) if ESPObjects[p] then for _, obj in pairs(ESPObjects[p]) do obj:Remove() end; ESPObjects[p] = nil end end)


print("Van Thanh Panel v1.0 Loaded! Wish you a fun and relaxing game. Thank you very much!>/<")
