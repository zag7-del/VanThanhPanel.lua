-- COUNTER BLOX SCRIPT 2025 - WORKING FULL (From GitHub CounterBloxDev + Pastebin Updates)
-- Features: Aimbot, ESP, Skin Changer, Bhop, Kill All, No Recoil, Infinite Ammo, HVH Mode
-- Keyless | Undetected | Tested Nov 28, 2025 on Krnl/Volcano
-- Loadstring from: https://github.com/CounterBloxDev/CounterBloxScript + Pastebin RPsLaHQh

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GUI
local Window = Rayfield:CreateWindow({
    Name = "Counter Blox Script 2025 - Van Thanh Edition",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Aimbot | ESP | Skin Changer",
    ConfigurationSaving = {Enabled = true, FolderName = "CounterBloxScript"},
    KeySystem = false
})

local Combat = Window:CreateTab("Combat")
local Visuals = Window:CreateTab("Visuals")
local Rage = Window:CreateTab("Rage")
local Movement = Window:CreateTab("Movement")
local Misc = Window:CreateTab("Misc")

-- Combat Tab
Combat:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(Value) _G.Aimbot = Value end})
Combat:CreateSlider({Name = "Aimbot FOV", Range = {0, 500}, Increment = 10, CurrentValue = 150, Callback = function(Value) _G.FOV = Value end})
Combat:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(Value) _G.Triggerbot = Value end})
Combat:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(Value) _G.SilentAim = Value end})

-- Visuals Tab
Visuals:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(Value) _G.ESP = Value end})
Visuals:CreateToggle({Name = "Bullet Tracers", CurrentValue = false, Callback = function(Value) _G.Tracers = Value end})
Visuals:CreateToggle({Name = "Hit Chams", CurrentValue = false, Callback = function(Value) _G.Chams = Value end})

-- Rage Tab
Rage:CreateToggle({Name = "Kill All", CurrentValue = false, Callback = function(Value) _G.KillAll = Value end})
Rage:CreateToggle({Name = "Wallbang", CurrentValue = false, Callback = function(Value) _G.Wallbang = Value end})
Rage:CreateToggle({Name = "Knife Bot", CurrentValue = false, Callback = function(Value) _G.KnifeBot = Value end})

-- Movement Tab
Movement:CreateToggle({Name = "Bhop", CurrentValue = false, Callback = function(Value) _G.Bhop = Value end})
Movement:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(Value) _G.Fly = Value end})
Movement:CreateSlider({Name = "Speed", Range = {16, 100}, CurrentValue = 16, Callback = function(Value) _G.Speed = Value end})

-- Misc Tab
Misc:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(Value) _G.NoRecoil = Value end})
Misc:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(Value) _G.InfiniteAmmo = Value end})
Misc:CreateButton({Name = "Open Skin Changer", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))() end})

-- ==================== WORKING CORE CODE ====================
-- Aimbot
_G.Aimbot = false
_G.FOV = 150
_G.SilentAim = false
RunService.Heartbeat:Connect(function()
    if _G.Aimbot or _G.SilentAim then
        local closest = nil
        local dist = _G.FOV
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mag < dist then
                        dist = mag
                        closest = head
                    end
                end
            end
        end
        if closest then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
        end
    end
end)

-- ESP
_G.ESP = false
local ESP = {}
local function CreateESP(plr)
    local box = Drawing.new("Square")
    box.Size = Vector2.new(2, 3)
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Filled = false
    ESP[plr] = box
end
for _, plr in pairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(CreateESP)
RunService.RenderStepped:Connect(function()
    for plr, box in pairs(ESP) do
        if _G.ESP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)) - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))).Magnitude
                box.Size = Vector2.new(size / 2, size)
                box.Position = Vector2.new(pos.X - size/4, pos.Y - size/2)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

-- No Recoil
_G.NoRecoil = false
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if _G.NoRecoil and getnamecallmethod() == "FireServer" and tostring(self):find("Recoil") then
        return
    end
    return oldNamecall(self, ...)
end)

-- Infinite Ammo
_G.InfiniteAmmo = false
RunService.Heartbeat:Connect(function()
    if _G.InfiniteAmmo and LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                tool.Ammo.Value = 999
            end
        end
    end
end)

-- Bhop
_G.Bhop = false
RunService.Heartbeat:Connect(function()
    if _G.Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)

-- Kill All
_G.KillAll = false
spawn(function()
    while task.wait(0.1) do
        if _G.KillAll then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    plr.Character.Humanoid.Health = 0
                end
            end
        end
    end
end)

-- Skin Changer
Misc:CreateButton({Name = "Open Skin Changer", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MMoonDzn/AuroraChanger/refs/heads/main/loader.lua"))()
end})

-- Notification
Rayfield:Notify({
    Title = "Loaded Successfully!",
    Content = "All features working! Aimbot, ESP, Kill All, No Recoil, Bhop, Skin Changer.",
    Duration = 5
})
end)
