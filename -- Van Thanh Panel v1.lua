-- Van Thanh Panel v1.18 (24/11/2025) - No Recoil Toggle + Keybinds
-- Code bởi: Van Thanh >/< | Dựa Aurora ENG + Van Thanh Fix
-- Features: Keybinds, Hold Mouse1 to Aim, Only Enemy, Silent Aim, ESP Team Toggle, Config

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
        Enabled = true,
        HoldToAim = true,        -- Chỉ aim khi giữ chuột trái
        SilentAim = false,       -- Bắn trúng dù tâm không nhích
        Hitbox = "Head",
        Smoothing = 0.15,
        FOV = 150,
        FOVVisible = true,
        FOVSizePct = 100,
        Keybind = Enum.KeyCode.R -- KEYBIND MỚI
    },
    esp = {
        Enabled = true,
        TeamESP = false,         -- Bật để thấy đồng đội
        Box = true,
        Name = true,
        Distance = true,
        Tracer = true,
        HealthBar = true,
        Keybind = Enum.KeyCode.T -- KEYBIND MỚI
    },
    misc = { -- THÊM CONFIG CHO MISC
        NoRecoil = false,
        NoRecoilKeybind = Enum.KeyCode.F -- KEYBIND MỚI
    },
    menu = { -- CONFIG CHO MENU
        Keybind = Enum.KeyCode.RightShift
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

-- === INPUT & STATE ===
local mouseDown = false
userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDown = true
    end
    
    -- KEYBINDS LOGIC
    if input.UserInputType == Enum.UserInputType.Keyboard then
        -- Menu Toggle
        if input.KeyCode == config.menu.Keybind then
            Rayfield:Toggle()
        end

        -- Aimbot Toggle
        if input.KeyCode == config.aimbot.Keybind then
            config.aimbot.Enabled = not config.aimbot.Enabled
            -- Cập nhật GUI (nếu Rayfield hỗ trợ)
            -- (Rayfield không hỗ trợ cập nhật toggle từ ngoài, cần chỉnh sửa trong Rayfield nếu muốn)
            Rayfield:Notify({Title = "Aimbot Keybind", Content = "Aimbot: " .. (config.aimbot.Enabled and "ON" or "OFF"), Duration = 1})
        end
        
        -- ESP Toggle
        if input.KeyCode == config.esp.Keybind then
            config.esp.Enabled = not config.esp.Enabled
            Rayfield:Notify({Title = "ESP Keybind", Content = "ESP: " .. (config.esp.Enabled and "ON" or "OFF"), Duration = 1})
        end

        -- No Recoil Toggle
        if input.KeyCode == config.misc.NoRecoilKeybind then
            config.misc.NoRecoil = not config.misc.NoRecoil
            if config.misc.NoRecoil and localPlayer.Character then
                CheckAndApplyRecoil(localPlayer.Character)
            end
            Rayfield:Notify({Title = "No Recoil Keybind", Content = "No Recoil: " .. (config.misc.NoRecoil and "ON" or "OFF"), Duration = 1})
        end
    end
end)
userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDown = false
    end
end)

-- === GET BEST ENEMY (ONLY) ===
local function GetBestEnemy()
    if not config.aimbot.Enabled or (config.aimbot.HoldToAim and not mouseDown) then return nil end

    local closest = nil
    local closestDist = config.aimbot.FOV
    local origin = camera.CFrame.Position
    local mousePos = userInputService:GetMouseLocation() -- Lấy ở ngoài vòng lặp

    for _, player in pairs(players:GetPlayers()) do
        if player == localPlayer then continue end
        if player.Team == localPlayer.Team then continue end  -- CHỈ ĐỊCH

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then continue end
        if char.Humanoid.Health <= 0 then continue end

        local part = nil
        local hitboxToAim = config.aimbot.Hitbox

        if hitboxToAim == "Head" then
            part = char:FindFirstChild("Head") or char.HumanoidRootPart
        elseif hitboxToAim == "Body" then
            part = char:FindFirstChild("Torso") or char.HumanoidRootPart
        elseif hitboxToAim == "Nearest" then
            local bestPart = nil
            local smallestDist = math.huge
            
            -- Danh sách các bộ phận có thể là hitbox
            local potentialParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}
            
            for _, partName in ipairs(potentialParts) do
                local currentPart = char:FindFirstChild(partName)
                if currentPart and currentPart:IsA("BasePart") then
                    local screenPos, onScreen = camera:WorldToViewportPoint(currentPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < smallestDist then
                            smallestDist = dist
                            bestPart = currentPart
                        end
                    end
                end
            end
            part = bestPart
        end

        if not part then continue end -- Bỏ qua nếu không tìm thấy bộ phận hợp lệ
        
        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = {Player = player, Part = part, Screen = screenPos}
        end
    end
    return closest
end

-- === AIMBOT LOOP (Hold + Silent) ===
runService.Heartbeat:Connect(function()
    local target = GetBestEnemy()
    if not target then return end

    local targetPos = target.Part.Position

    if config.aimbot.SilentAim then
        -- Silent: Bắn trúng, tâm không nhích
        local direction = (targetPos - camera.CFrame.Position).Unit
        local lookAt = camera.CFrame.Position + direction * 1000
        camera.CFrame = CFrame.new(camera.CFrame.Position, lookAt)
    else
        -- Smooth aim: Tâm di chuyển mượt khi giữ chuột
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), config.aimbot.Smoothing)
    end
end)

-- === NO RECOIL LOGIC (VĨNH VIỄN) ===
local function ApplyNoRecoil(tool)
    if config.misc.NoRecoil and tool and tool:IsA("Tool") and tool:FindFirstChild("Recoil") then
        tool.Recoil.Value = 0
    end
end

local function CheckAndApplyRecoil(char)
    if not char then return end

    -- Áp dụng cho các vũ khí đã có trong Backpack và tay
    local backpack = localPlayer:FindFirstChild("Backpack")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            ApplyNoRecoil(tool)
        end
    end
    
    if humanoid and humanoid.EquippedTool then
        ApplyNoRecoil(humanoid.EquippedTool)
    end
    
    -- Lắng nghe khi nhặt/chuyển vũ khí
    local function connectTool(tool)
        ApplyNoRecoil(tool)
        tool.ChildAdded:Connect(function(child)
            if child.Name == "Recoil" then
                ApplyNoRecoil(tool)
            end
        end)
    end

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            connectTool(child)
        end
    end)
    
    if backpack then
        backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                connectTool(child)
            end
        end)
    end
end

localPlayer.CharacterAdded:Connect(CheckAndApplyRecoil)
-- Chạy lần đầu nếu Character đã tồn tại
if localPlayer.Character then
    CheckAndApplyRecoil(localPlayer.Character)
end

-- === ESP CREATE & UPDATE ===
local ESP = {}
local function CreateESP(player)
    if ESP[player] then return end

    local esp = {}
    esp.Box = Drawing.new("Square")
    esp.Box.Thickness = 2; esp.Box.Filled = false; esp.Box.Transparency = 1

    esp.Name = Drawing.new("Text")
    esp.Name.Size = 14; esp.Name.Font = 2; esp.Name.Outline = true; esp.Name.Center = true

    esp.Distance = Drawing.new("Text")
    esp.Distance.Size = 13; esp.Distance.Font = 2; esp.Distance.Outline = true

    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Thickness = 1; esp.Tracer.Transparency = 0.7

    esp.HealthBar = Drawing.new("Line")
    esp.HealthBar.Thickness = 3

    esp.HealthBG = Drawing.new("Line")
    esp.HealthBG.Thickness = 3; esp.HealthBG.Transparency = 0.5

    ESP[player] = esp
end

local function UpdateESP()
    if not config.esp.Enabled then
        for _, drawings in pairs(ESP) do
            for _, d in pairs(drawings) do d.Visible = false end
        end
        return
    end

    for player, drawings in pairs(ESP) do
        local char = player.Character
        
        -- Lấy các part cần thiết
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        local head = char and char:FindFirstChild("Head") 

        if not root or not hum or hum.Health <= 0 then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local isTeam = player.Team == localPlayer.Team
        if not config.esp.TeamESP and isTeam then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local vector, onScreen = camera:WorldToViewportPoint(root.Position)
        
        -- Cải tiến tính toán chiều cao ESP
        local headY = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)).Y 
        local footY = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y
        local height = math.abs(headY - footY)
        local width = height / 2

        local color = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

        if onScreen and height > 10 then
            -- Box
            drawings.Box.Visible = config.esp.Box
            if config.esp.Box then
                drawings.Box.Size = Vector2.new(width, height)
                drawings.Box.Position = Vector2.new(vector.X - width/2, vector.Y - height/2)
                drawings.Box.Color = color
            end

            -- Name
            drawings.Name.Visible = config.esp.Name
            if config.esp.Name then
                drawings.Name.Text = player.Name
                drawings.Name.Position = Vector2.new(vector.X, headY - 20)
            end

            -- Distance
            drawings.Distance.Visible = config.esp.Distance
            if config.esp.Distance then
                local dist = (root.Position - camera.CFrame.Position).Magnitude
                drawings.Distance.Text = string.format("%.1fm", dist)
                drawings.Distance.Position = Vector2.new(vector.X, footY + 5)
            end

            -- Tracer
            drawings.Tracer.Visible = config.esp.Tracer
            if config.esp.Tracer then
                drawings.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                drawings.Tracer.To = Vector2.new(vector.X, footY)
                drawings.Tracer.Color = color
            end

            -- Health
            drawings.HealthBar.Visible = config.esp.HealthBar
            drawings.HealthBG.Visible = config.esp.HealthBar
            if config.esp.HealthBar then
                local hp = hum.Health / hum.MaxHealth
                drawings.HealthBar.From = Vector2.new(vector.X - width/2 - 5, footY)
                drawings.HealthBar.To = Vector2.new(vector.X - width/2 - 5, footY + height * hp)
                drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)

                drawings.HealthBG.From = Vector2.new(vector.X - width/2 - 5, footY)
                drawings.HealthBG.To = Vector2.new(vector.X - width/2 - 5, footY + height)
            end
        else
            for _, d in pairs(drawings) do d.Visible = false end
        end
    end
end

-- === CONFIG SAVE/LOAD ===
local configFile = "VanThanhPanel_v18.json" -- Cập nhật tên file
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
                    if config[k][sk] ~= nil then config[k][sk] = sv end
                end
            end
        end
        
        -- Cập nhật No Recoil ngay sau khi Load
        if config.misc.NoRecoil and localPlayer.Character then
            CheckAndApplyRecoil(localPlayer.Character)
        end
        
        fovCircle.Radius = config.aimbot.FOV * (config.aimbot.FOVSizePct / 100)
        fovCircle.Visible = config.aimbot.FOVVisible
        Rayfield:Notify({Title = "Loaded!", Content = "Config đã tải!", Duration = 2})
    end
end

-- === GUI ===
local Window = Rayfield:CreateWindow({
    Name = "Van Thanh Panel v1.18",
    LoadingTitle = "Hold-To-Aim | No Recoil",
    LoadingSubtitle = "Van Thanh >/<",
    ConfigurationSaving = {Enabled = true, FolderName = "VanThanhPanel", FileName = "v18"}
})

local Combat = Window:CreateTab("Combat", 4483362458)
local Visuals = Window:CreateTab("Visuals", 4483362458)
local Misc = Window:CreateTab("Misc", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)
local Credits = Window:CreateTab("Credits", 4483362458)

-- === COMBAT ===
Combat:CreateToggle({Name = "Aimbot (Keybind: " .. config.aimbot.Keybind.Name .. ")", CurrentValue = config.aimbot.Enabled, Callback = function(v) config.aimbot.Enabled = v end})
Combat:CreateToggle({Name = "Silent Aim", CurrentValue = config.aimbot.SilentAim, Callback = function(v) config.aimbot.SilentAim = v end})
Combat:CreateDropdown({Name = "Hitbox", Options = {"Head", "Body", "Nearest"}, CurrentOption = {config.aimbot.Hitbox}, Callback = function(o) config.aimbot.Hitbox = o[1] end})
Combat:CreateSlider({Name = "Smoothing", Range = {0.01, 1}, Increment = 0.01, CurrentValue = config.aimbot.Smoothing, Callback = function(v) config.aimbot.Smoothing = v end})
Combat:CreateSlider({Name = "FOV", Range = {50, 500}, Increment = 10, CurrentValue = config.aimbot.FOV, Callback = function(v) config.aimbot.FOV = v; fovCircle.Radius = v * (config.aimbot.FOVSizePct / 100) end})
Combat:CreateToggle({Name = "FOV Circle", CurrentValue = config.aimbot.FOVVisible, Callback = function(v) config.aimbot.FOVVisible = v; fovCircle.Visible = v end})
Combat:CreateSlider({Name = "FOV Size %", Range = {50, 200}, Increment = 5, CurrentValue = config.aimbot.FOVSizePct, Callback = function(v) config.aimbot.FOVSizePct = v; fovCircle.Radius = config.aimbot.FOV * (v / 100) end})

-- === VISUALS ===
Visuals:CreateToggle({Name = "ESP (Keybind: " .. config.esp.Keybind.Name .. ")", CurrentValue = config.esp.Enabled, Callback = function(v) config.esp.Enabled = v end})
Visuals:CreateToggle({Name = "ESP Đồng Đội", CurrentValue = config.esp.TeamESP, Callback = function(v) config.esp.TeamESP = v end})
Visuals:CreateToggle({Name = "Box", CurrentValue = config.esp.Box, Callback = function(v) config.esp.Box = v end})
Visuals:CreateToggle({Name = "Name", CurrentValue = config.esp.Name, Callback = function(v) config.esp.Name = v end})
Visuals:CreateToggle({Name = "Distance", CurrentValue = config.esp.Distance, Callback = function(v) config.esp.Distance = v end})
Visuals:CreateToggle({Name = "Tracer", CurrentValue = config.esp.Tracer, Callback = function(v) config.esp.Tracer = v end})
Visuals:CreateToggle({Name = "Health Bar", CurrentValue = config.esp.HealthBar, Callback = function(v) config.esp.HealthBar = v end})

-- === MISC ===
Misc:CreateToggle({
    Name = "No Recoil (Keybind: " .. config.misc.NoRecoilKeybind.Name .. ")", 
    CurrentValue = config.misc.NoRecoil, 
    Callback = function(v) 
        config.misc.NoRecoil = v
        if v and localPlayer.Character then
            CheckAndApplyRecoil(localPlayer.Character)
        end
    end
})

-- Nút cũ đã bị xóa. Có thể thêm lại nút để áp dụng ngay 1 lần nếu cần.

-- === CONFIG ===
ConfigTab:CreateButton({Name = "Save Config", Callback = SaveConfig})
ConfigTab:CreateButton({Name = "Load Config", Callback = LoadConfig})
ConfigTab:CreateLabel("Menu Keybind: " .. config.menu.Keybind.Name) -- Hiển thị Keybind Menu

-- === CREDITS ===
Credits:CreateLabel("Code bởi: Van Thanh >/<")
Credits:CreateLabel("v1.18 - Keybinds + No Recoil Toggle")
Credits:CreateLabel("Zalo: 0392236290")

-- === LOOPS ===
runService.RenderStepped:Connect(UpdateESP)
runService.RenderStepped:Connect(function()
    if config.aimbot.FOVVisible then
        fovCircle.Position = userInputService:GetMouseLocation()
    end
end)

-- Auto ESP
for _, p in pairs(players:GetPlayers()) do
    if p ~= localPlayer then CreateESP(p) end
end

players.PlayerAdded:Connect(function(p)
    if p ~= localPlayer then CreateESP(p) end
end)

players.PlayerRemoving:Connect(function(p)
    if ESP[p] then
        for _, d in pairs(ESP[p]) do d:Remove() end
        ESP[p] = nil
    end
end)

print("Van Thanh Panel v1.18 Loaded – Hold LMB to Aim, Keybinds: R, T, F!")

-- Load config khi script được tải
LoadConfig()
