-- VAN THANH PANEL v21 - GỌN NHẸ SIÊU NHANH (2025)
-- Chỉ có: Silent Aim + ESP + FOV Circle
-- Chạy ngon trên mọi executor (Volcano/Krnl/Delta)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local Aimbot = {Enabled = true, FOV = 150}
local ESP = {Enabled = true}
local FOVCircle = Drawing.new("Circle")

FOVCircle.Radius = Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255,0,0)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

-- FOV Circle
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Aimbot.Enabled
end)

-- ESP + Aimbot
RunService.Heartbeat:Connect(function()
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            -- ESP (Box đỏ)
            if ESP.Enabled and onScreen then
                local box = Drawing.new("Square")
                box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                box.Color = Color3.fromRGB(255,0,0)
                box.Thickness = 2
                box.Filled = false
                box.Transparency = 1
                RunService.RenderStepped:Wait()
                box:Remove()
            end
            
            -- Silent Aim
            if Aimbot.Enabled and onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < Aimbot.FOV then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                end
            end
        end
    end
end)

print("Van Thanh Panel v21 - Aimbot + ESP + FOV Loaded!")
game.StarterGui:SetCore("SendNotification", {Title="Van Thanh v21", Text="Aimbot + ESP + FOV đang chạy!", Duration=5})
