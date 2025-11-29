-- VAN THANH PANEL v39.8 - BULLETPROOF EDITION
-- FIX: NIL CAMERA CRASH, TARGET DESPAWN, HOOK REFERENCE ERROR, AIR JUMP
-- TRẠNG THÁI: CRASH PROOF, EXECUTOR AGNOSTIC (Hỗ trợ cả Executor yếu)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- [SAFETY LOADER]
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success then return warn("Loader Error: Rayfield API Failed.") end

-- ==================== CLEANUP & STATE ====================
if _G.VanThanhCleanup then _G.VanThanhCleanup() end

local Connections = {}
local ESP_Cache = {}

-- State Management (Initialized with Safe Defaults)
local State = {
    Camera = Workspace.CurrentCamera,
    Character = LocalPlayer.Character,
    RootPart = nil,
    Humanoid = nil
}

local Flags = {
    HooksActive = true,
    BhopDebounce = false
}

-- Singleton Hook Storage (Global Persistence)
if not _G.VanThanhHooks then
    _G.VanThanhHooks = {
        OldIndex = nil,
        HookedObject = nil
    }
end

-- ==================== DEFENSIVE HELPER FUNCTIONS ====================
local function SafeRemove(obj)
    pcall(function()
        if obj.Remove then obj:Remove()
        elseif obj.Destroy then obj:Destroy() end
    end)
end

local function ParseKey(keyVal)
    if typeof(keyVal) == "EnumItem" then return keyVal end
    if typeof(keyVal) == "string" then
        return Enum.KeyCode[keyVal] or Enum.UserInputType[keyVal] or Enum.KeyCode.Q
    end
    return Enum.KeyCode.Q
end

-- [NEW] Helper kiểm tra nhân vật sống an toàn
local function IsAlive(plr)
    if not plr then return false end
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    local head = char:FindFirstChild("Head")
    if not hum or not head then return false end
    return hum.Health > 0
end

-- ==================== CONFIG ====================
local Config = {
    Aimbot = {Enabled = true, Keybind = Enum.KeyCode.Q, FOV = 150, Smooth = 0.2, WallCheck = true},
    ESP = {Enabled = true, Box = true, Name = true, Color = Color3.fromRGB(255, 0, 0), MaxDist = 2000},
    Misc = {NameSpoofer = "VanThanh"},
    Move = {Bhop = true, JumpCooldown = 0.1},
    Gun = {NoRecoil = true}
}

-- ==================== UI SETUP ====================
local Window = Rayfield:CreateWindow({
    Name = "Van Thanh v39.8 - Crash Proof",
    ConfigurationSaving = {Enabled = true, FolderName = "VanThanhV39_8"},
    KeySystem = false
})

local Combat = Window:CreateTab("Combat")
local Visual = Window:CreateTab("Visual")
local Move   = Window:CreateTab("Movement")
local Gun    = Window:CreateTab("Gun Mods")
local Misc   = Window:CreateTab("Misc")

-- UI CONTROLS
Combat:CreateToggle({Name = "Aimbot Enabled", CurrentValue = Config.Aimbot.Enabled, Callback = function(v) Config.Aimbot.Enabled = v end})
Combat:CreateKeybind({Name = "Aim Key", CurrentKeybind = "Q", Callback = function(v) Config.Aimbot.Keybind = ParseKey(v) end})
Combat:CreateSlider({Name = "FOV Radius", Range = {10, 600}, CurrentValue = 150, Callback = function(v) Config.Aimbot.FOV = v end})

Visual:CreateToggle({Name = "ESP Enabled", CurrentValue = Config.ESP.Enabled, Callback = function(v) 
    Config.ESP.Enabled = v 
    if not v then for _, objs in pairs(ESP_Cache) do SafeRemove(objs.Box); SafeRemove(objs.Name) end end
end})

Move:CreateToggle({Name = "Bhop", CurrentValue = Config.Move.Bhop, Callback = function(v) Config.Move.Bhop = v end})
Gun:CreateToggle({Name = "No Recoil", CurrentValue = Config.Gun.NoRecoil, Callback = function(v) Config.Gun.NoRecoil = v end})
Misc:CreateInput({Name = "Name Spoofer", CurrentValue = Config.Misc.NameSpoofer, Callback = function(v) Config.Misc.NameSpoofer = v end})

-- ==================== BACKEND SYSTEM ====================

local function UpdateState()
    State.Character = LocalPlayer.Character
    -- [FIX 1] Camera check robust
    if Workspace.CurrentCamera then State.Camera = Workspace.CurrentCamera end
    
    if State.Character then
        State.RootPart = State.Character:FindFirstChild("HumanoidRootPart")
        State.Humanoid = State.Character:FindFirstChild("Humanoid")
        
        -- [FIX SPOOFER] Pcall wrap để tránh lỗi permission
        if State.Humanoid and Config.Misc.NameSpoofer ~= "" then
            pcall(function() State.Humanoid.DisplayName = Config.Misc.NameSpoofer end)
        end
    else
        State.RootPart = nil; State.Humanoid = nil
    end
end
Connections.CharAdd = LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); UpdateState() end)
Connections.CamChange = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(UpdateState) -- Auto update camera
UpdateState()

-- RAYCAST FILTER
local function GetRayParams()
    local params = RaycastParams.new()
    local filter = {}
    if State.Character then table.insert(filter, State.Character) end
    if State.Camera then
        for _, obj in pairs(State.Camera:GetChildren()) do
            if obj:IsA("Model") then table.insert(filter, obj) end
        end
    end
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Exclude
    return params
end

-- 1. AIMBOT (SAFE TARGET VALIDATION)
local function GetClosestPlayer()
    if not State.RootPart or not State.Camera then return nil end -- [FIX 4] Nil Check
    
    local closest, minDst = nil, Config.Aimbot.FOV
    local mouse = UserInputService:GetMouseLocation()
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and IsAlive(plr) then
            local head = plr.Character.Head
            local pos, onScreen = State.Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if dist < minDst then
                    local blocked = false
                    if Config.Aimbot.WallCheck then
                        local rParams = GetRayParams()
                        local dir = head.Position - State.Camera.CFrame.Position
                        local ray = Workspace:Raycast(State.Camera.CFrame.Position, dir, rParams)
                        if ray and not ray.Instance:IsDescendantOf(plr.Character) then blocked = true end
                    end
                    if not blocked then minDst = dist; closest = head end
                end
            end
        end
    end
    return closest
end

Connections.Aimbot = RunService.Heartbeat:Connect(function(dt)
    if not Config.Aimbot.Enabled or not State.Camera then return end
    
    local kb = Config.Aimbot.Keybind
    local pressed = false
    
    -- [FIX 4] Safe Input Check
    if kb.EnumType == Enum.KeyCode then pressed = UserInputService:IsKeyDown(kb)
    elseif kb.EnumType == Enum.UserInputType then
         if kb == Enum.UserInputType.MouseButton1 or kb == Enum.UserInputType.MouseButton2 or kb == Enum.UserInputType.MouseButton3 then
            pressed = UserInputService:IsMouseButtonPressed(kb)
         end
    end
    
    if pressed then
        local target = GetClosestPlayer()
        -- [FIX 4] Check target validity again inside loop
        if target and target.Parent then 
            local currentCF = State.Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, target.Position)
            local alpha = math.clamp(Config.Aimbot.Smooth * (dt * 60), 0, 1)
            State.Camera.CFrame = currentCF:Lerp(targetCF, alpha)
        end
    end
end)

-- 2. ESP (SAFE VIEWPORT ACCESS)
local function DrawESP(plr)
    local objs = ESP_Cache[plr]
    if not objs then
        objs = { Box = Drawing.new("Square"), Name = Drawing.new("Text") }
        ESP_Cache[plr] = objs
    end
    
    -- [FIX 3] Kiểm tra Camera trước khi access ViewportSize
    if not State.Camera then 
        objs.Box.Visible = false; objs.Name.Visible = false
        return 
    end

    if IsAlive(plr) and plr.Team ~= LocalPlayer.Team and State.RootPart then
        local root = plr.Character.HumanoidRootPart
        local dst = (State.Camera.CFrame.Position - root.Position).Magnitude
        
        if dst > Config.ESP.MaxDist then
            objs.Box.Visible = false; objs.Name.Visible = false
            return
        end

        local pos, onScreen = State.Camera:WorldToViewportPoint(root.Position)
        if onScreen then
            local depth = math.max(pos.Z, 5)
            local scale = math.clamp(1000 / depth, 0.1, 100)
            
            -- [FIX 3] Safe Clamp ViewportSize
            local vpY = State.Camera.ViewportSize.Y
            local height = math.clamp(5 * scale, 10, vpY * 0.8)
            local width = height * 0.6
            
            objs.Box.Visible = Config.ESP.Box
            objs.Box.Size = Vector2.new(width, height)
            objs.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
            objs.Box.Color = Config.ESP.Color
            objs.Box.Thickness = 1.5; objs.Box.Filled = false
            
            objs.Name.Visible = Config.ESP.Name
            objs.Name.Text = plr.Name
            objs.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
            objs.Name.Center = true; objs.Name.Color = Color3.new(1,1,1)
        else
            objs.Box.Visible = false; objs.Name.Visible = false
        end
    else
        objs.Box.Visible = false; objs.Name.Visible = false
    end
end

Connections.ESP = RunService.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then DrawESP(plr) end
    end
end)

Connections.ESP_Remove = Players.PlayerRemoving:Connect(function(plr)
    if ESP_Cache[plr] then
        SafeRemove(ESP_Cache[plr].Box); SafeRemove(ESP_Cache[plr].Name)
        ESP_Cache[plr] = nil
    end
end)

-- 3. MOVEMENT (STRICT FLOOR CHECK)
Connections.Move = RunService.Heartbeat:Connect(function()
    -- [FIX 5] Nil checks & Floor Check
    if Config.Move.Bhop and State.Humanoid and State.RootPart and not Flags.BhopDebounce then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if State.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                -- [FIX 5] Chỉ nhảy nếu không đang bay (Freefall)
                if State.Humanoid.FloorMaterial ~= Enum.Material.Air then
                     State.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                     Flags.BhopDebounce = true
                     task.delay(Config.Move.JumpCooldown, function() Flags.BhopDebounce = false end)
                end
            end
        end
    end
end)

-- 4. GUN HOOKS (SAFE REFERENCE)
if not _G.VanThanhHooks.OldIndex then
    _G.VanThanhHooks.OldIndex = hookmetamethod(game, "__index", function(self, key)
        -- [FIX 2] Safe Hook Check
        if Flags.HooksActive and not checkcaller() then
            -- [FIX 2] Instance & ValueBase check
            if typeof(self) == "Instance" and Config.Gun.NoRecoil and tostring(self) == "Recoil" and key == "Value" then
                if self:IsA("ValueBase") then return 0 end
            end
        end
        return _G.VanThanhHooks.OldIndex(self, key)
    end)
end

-- ==================== FINAL CLEANUP (SAFE FALLBACK) ====================
_G.VanThanhCleanup = function()
    Flags.HooksActive = false
    for _, conn in pairs(Connections) do conn:Disconnect() end
    for _, objs in pairs(ESP_Cache) do SafeRemove(objs.Box); SafeRemove(objs.Name) end
    
    -- [FIX 6] Hook Cleanup Logic
    -- Nếu có restorefunction -> Gỡ hook & Xóa bảng
    -- Nếu không -> Giữ bảng hook để tránh crash reference, chỉ tắt Flag
    if restorefunction and _G.VanThanhHooks.OldIndex then
        pcall(function()
            restorefunction(game.__index)
            _G.VanThanhHooks = nil 
        end)
    end
end
game:BindToClose(_G.VanThanhCleanup)

Rayfield:Notify({
    Title = "Van Thanh v39.8",
    Content = "Bulletproof Framework: Nil Checks, Hook Safety, Floor Check.",
    Duration = 5
})
