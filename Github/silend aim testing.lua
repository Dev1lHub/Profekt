-- ==========================================
-- 1. VORBEREITUNG & SETUP
-- ==========================================

local gui_link = "https://raw.githubusercontent.com/PyroX5343/RobloxCheats/refs/heads/main/Gui_Libary/GUI_Libary.lua"
local Library = loadstring(game:HttpGet(gui_link))()

local Actions = {}
local Flags = {
    ["Enable Aimbot"] = false,
    ["Aim Key"] = Enum.KeyCode.None,
    ["Aim mode"] = "Hold",
    ["Aim Methode"] = "CFrame",
    ["aim body Part"] = "Head",
    ["Enable Prediction"] = false,
    ["Prediction Strength"] = 25,
    ["Wall Check"] = false,
    ["Show Fov Circle"] = false,
    ["Smoothness"] = 0,
    ["Distance"] = 500,
    ["Fov Circle"] = 100,
    ["Fov Color"] = Color3.fromRGB(255, 255, 255),

    ["Enable Silend Aim"] = false,
    ["Silend Aim Method"] = "FindPartOnRay",
    ["Silend aim methode"] = "FindPartOnRay",
    ["Show Silend Aim Fov"] = false,
    ["Silend aim fov size"] = 100,
    ["Silend aim Distance"] = 500,
    ["Silend Wall Check"] = false,
    ["Silend Body Part"] = "Head",
    ["Silend Aim FOV Color"] = Color3.fromRGB(255, 255, 255),
}

local toggleActive = false
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- ==========================================
-- 2. GUI ERSTELLEN (MENÜS & ELEMENTE)
-- ==========================================

local ConfigFolderName = "War_Tycoon"
Library.ConfigFolder = ConfigFolderName

local ThemeColor = Color3.fromRGB(222, 163, 62) 
local MyWindow = Library.New("War Tycoon", ThemeColor)

-- ------------------------------------------
-- TAB 1: COMBAT
-- ------------------------------------------
local Tab1 = MyWindow:AddTab("Combat")

-- Subtab 1: Aimbot
local Sub_Aimbot = Tab1:AddSubTab("Aimbot")
Sub_Aimbot:AddToggle("Enable Aimbot", false, function(v) Actions.EnableAimbot(v) end)
Sub_Aimbot:AddKeybind("Aim key", Enum.KeyCode.None, function(key) Actions.AimKey(key) end)
Sub_Aimbot:AddDropdown("Aim Mode", {"Hold", "Toggel"}, false, "Hold", function(opt) Actions.AimMode(opt) end)
Sub_Aimbot:AddDropdown("Aim Methode", {"CFrame", "MouseMovment"}, false, "CFrame", function(opt) Actions.AimMethod(opt) end)
Sub_Aimbot:AddDropdown("Aim body Part", {"Head", "HumanoidRootPart", "UperTorso", "LowerTorso"}, false, "Head", function(opt) Actions.AimBodyPart(opt) end)
Sub_Aimbot:AddToggle("Enable Prediction", false, function(v) Actions.EnablePrediction(v) end)
Sub_Aimbot:AddSlider("Prediction Strength", 0, 100, 25, function(v) Actions.PredictionStrength(v) end)
Sub_Aimbot:AddToggle("Wall Check", false, function(v) Actions.WallCheck(v) end)
Sub_Aimbot:AddToggle("Show Fov Circle", false, function(v) Actions.ShowFovCircle(v) end)
Sub_Aimbot:AddSlider("Smoothness", 0, 100, 0, function(v) Actions.Smoothness(v) end)
Sub_Aimbot:AddSlider("Distacne", 0, 1000, 500, function(v) Actions.Distance(v) end)
Sub_Aimbot:AddSlider("Aimbot Fov Circle", 0, 500, 100, function(v) Actions.AimbotFovCircle(v) end)
Sub_Aimbot:AddColorPicker("Fov Color", Color3.fromRGB(255, 255, 255), function(col) Actions.FovColor(col) end)

-- Subtab 2: Silent Aim
local Sub_SilentAim = Tab1:AddSubTab("Silend Aim")
Sub_SilentAim:AddToggle("Enable Silend aim", false, function(v) Actions.EnableSilentAim(v) end)
Sub_SilentAim:AddDropdown("Silend aim methode", {"FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist", "FindPartOnRay", "MouseHit", "Raycast", "ScreenPointToRay", "ViewportPointToRay", "All"}, false, "FindPartOnRay", function(opt) Actions.SilentAimMethod(opt) end)
Sub_SilentAim:AddToggle("Show Fov Circle", false, function(v) Actions.SilentShowFov(v) end)
Sub_SilentAim:AddSlider("Fov Circle", 0, 500, 100, function(v) Actions.SilentFovSize(v) end)
Sub_SilentAim:AddSlider("Distance", 0, 1000, 500, function(v) Actions.SilentDistance(v) end)
Sub_SilentAim:AddToggle("Wall Check", false, function(v) Actions.SilentWallCheck(v) end)
Sub_SilentAim:AddDropdown("aim Body Part", {"Head", "HumanoidRootPart", "UperTorso", "LowerTorso"}, false, "Head", function(opt) Actions.SilentBodyPart(opt) end)
Sub_SilentAim:AddColorPicker("Fov Color", Color3.fromRGB(255, 255, 255), function(col) Actions.SilentFovColor(col) end)


-- ------------------------------------------
-- TAB 2: ESP
-- ------------------------------------------
local Tab2 = MyWindow:AddTab("ESP")
local Sub_ESPGen = Tab2:AddSubTab("generel")
Sub_ESPGen:AddToggle("Enable ESP", false, function(v) Actions.ESP_Enable(v) end)
Sub_ESPGen:AddToggle("Show 2d boxes", false, function(v) Actions.ESP_Boxes(v) end)
Sub_ESPGen:AddToggle("Show Highlites", false, function(v) Actions.ESP_Highlights(v) end)
Sub_ESPGen:AddToggle("Show Name", false, function(v) Actions.ESP_Name(v) end)
Sub_ESPGen:AddToggle("Show Health bar", false, function(v) Actions.ESP_Health(v) end)
Sub_ESPGen:AddToggle("Show Distance", false, function(v) Actions.ESP_Distance(v) end)
Sub_ESPGen:AddToggle("Show Vehicles", false, function(v) Actions.ESP_Vehicles(v) end)
Sub_ESPGen:AddSlider("Player ESP Distance", 0, 5000, 1000, function(v) Actions.ESP_PlayerDist(v) end)
Sub_ESPGen:AddSlider("Vehicle ESP Distance", 0, 5000, 1000, function(v) Actions.ESP_VehicleDist(v) end)
Sub_ESPGen:AddColorPicker("Set Player Color", Color3.fromRGB(255, 255, 255), function(col) Actions.ESP_PlayerColor(col) end)
Sub_ESPGen:AddColorPicker("Set Vehicle Color", Color3.fromRGB(255, 255, 255), function(col) Actions.ESP_VehicleColor(col) end)


-- ------------------------------------------
-- TAB 3: MOVEMENT
-- ------------------------------------------
local Tab3 = MyWindow:AddTab("Movment")
local Sub_MoveGen = Tab3:AddSubTab("generel")
Sub_MoveGen:AddToggleWithKey("Enable Speed", false, Enum.KeyCode.None, function(v) Actions.Move_Speed(v) end)
Sub_MoveGen:AddSlider("Speed Amound", 0, 100, 16, function(v) Actions.Move_SpeedAmount(v) end)
Sub_MoveGen:AddToggleWithKey("Enable JumpHight", false, Enum.KeyCode.None, function(v) Actions.Move_Jump(v) end)
Sub_MoveGen:AddSlider("JumpHight Amound", 0, 100, 50, function(v) Actions.Move_JumpAmount(v) end)
Sub_MoveGen:AddToggleWithKey("Enable Fly", false, Enum.KeyCode.None, function(v) Actions.Move_Fly(v) end)
Sub_MoveGen:AddSlider("Fly Speed Amound", 0, 100, 50, function(v) Actions.Move_FlyAmount(v) end)
Sub_MoveGen:AddToggleWithKey("Enable Vehicle Fly", false, Enum.KeyCode.None, function(v) Actions.Move_VehFly(v) end)
Sub_MoveGen:AddSlider("Vehicle Fly Speed Amound", 0, 100, 50, function(v) Actions.Move_VehFlyAmount(v) end)
Sub_MoveGen:AddToggle("Vehicle Noclip", false, function(v) Actions.Move_VehNoclip(v) end)
Sub_MoveGen:AddToggle("Infinity jump", false, function(v) Actions.Move_InfJump(v) end)
Sub_MoveGen:AddToggle("No Jump Delay", false, function(v) Actions.Move_NoJumpDelay(v) end)
Sub_MoveGen:AddToggle("Air Strafe", false, function(v) Actions.Move_AirStrafe(v) end)
Sub_MoveGen:AddToggle("Noclip", false, function(v) Actions.Move_Noclip(v) end)
Sub_MoveGen:AddToggleWithKey("Click TP", false, Enum.KeyCode.None, function(v) Actions.Move_ClickTP(v) end)
Sub_MoveGen:AddToggleWithKey("Freecam TP", false, Enum.KeyCode.None, function(v) Actions.Move_FreecamTP(v) end)
Sub_MoveGen:AddSlider("Freecam Speed Amound", 0, 100, 50, function(v) Actions.Move_FreecamSpeed(v) end)


-- ------------------------------------------
-- TAB 4: FARMING
-- ------------------------------------------
local Tab4 = MyWindow:AddTab("Farming")
local Sub_FarmGen = Tab4:AddSubTab("generel")
Sub_FarmGen:AddToggle("Enable Auto Upgrade Base", false, function(v) Actions.AutoUpgradeBase(v) end)


-- ==========================================
-- 3. FUNKTIONEN & LOGIK (CALLBACKS)
-- ==========================================

function Actions.AutoUpgradeBase(v)
    toggleActive = v
    print("Auto Upgrade Base Toggle changed to:", v)
    
    local function setMetalCollision(state)
        pcall(function()
            local currentTeamName = "Foxtrot"
            if LocalPlayer.Team and LocalPlayer.Team.Name then
                currentTeamName = LocalPlayer.Team.Name
            elseif LocalPlayer:GetAttribute("Team") then
                currentTeamName = tostring(LocalPlayer:GetAttribute("Team"))
            end
            
            local tycoonFolder = Workspace.Tycoon.Tycoons:FindFirstChild(currentTeamName)
            if tycoonFolder then
                local metalPart = tycoonFolder.Essentials.CollectorParts.Metal
                if metalPart and metalPart:IsA("BasePart") then
                    metalPart.CanCollide = state
                end
            end
        end)
    end
    
    if toggleActive then
        setMetalCollision(false)
        
        task.spawn(function()
            while toggleActive do
                local targetPart = nil
                
                local currentTeamName = "Foxtrot"
                if LocalPlayer.Team and LocalPlayer.Team.Name then
                    currentTeamName = LocalPlayer.Team.Name
                elseif LocalPlayer:GetAttribute("Team") then
                    currentTeamName = tostring(LocalPlayer:GetAttribute("Team"))
                end
                
                local tycoonFolder = Workspace.Tycoon.Tycoons:FindFirstChild(currentTeamName)
                
                local success, err = pcall(function()
                    if tycoonFolder and tycoonFolder:FindFirstChild("UnpurchasedButtons") then
                        local unpurchasedFolder = tycoonFolder.UnpurchasedButtons
                        for _, descendant in ipairs(unpurchasedFolder:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                local col = descendant.Color
                                local isGreen = (math.abs(col.R - 0) < 0.05) and (math.abs(col.G - 1) < 0.05) and (math.abs(col.B - 0) < 0.05)
                                local isNeon = (descendant.Material == Enum.Material.Neon) or (descendant.Name == "Neon")
                                
                                if isGreen and isNeon then
                                    targetPart = descendant
                                    break
                                end
                            end
                        end
                    end
                end)
                
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if targetPart and hrp then
                    hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
                    local startTime = tick()
                    while toggleActive and targetPart and targetPart.Parent and targetPart:IsDescendantOf(Workspace) do
                        if tick() - startTime >= 1.0 then
                            if hrp and targetPart and targetPart.Parent then
                                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
                            end
                            startTime = tick()
                        end
                        task.wait(0.2)
                    end
                else
                    local fallbackPos = CFrame.new(3070, 70, -1731) + Vector3.new(0, 10, 0)
                    pcall(function()
                        if tycoonFolder then
                            local collectorPart = tycoonFolder.Essentials.CollectorParts.Collector
                            if collectorPart and collectorPart:IsA("BasePart") then
                                fallbackPos = collectorPart.CFrame + Vector3.new(0, 10, 0)
                            end
                        end
                    end)
                    
                    if hrp then
                        hrp.CFrame = fallbackPos
                    end
                    task.wait(5)
                end
                
                task.wait(0.2)
            end
            setMetalCollision(true)
        end)
    else
        setMetalCollision(true)
    end
end

-- Aimbot Action Setters
function Actions.EnableAimbot(v) Flags["Enable Aimbot"] = v end
function Actions.AimKey(key) Flags["Aim Key"] = key end
function Actions.AimMode(opt) Flags["Aim mode"] = opt end
function Actions.AimMethod(opt) Flags["Aim Methode"] = opt end
function Actions.AimBodyPart(opt) Flags["aim body Part"] = opt end
function Actions.EnablePrediction(v) Flags["Enable Prediction"] = v end
function Actions.PredictionStrength(v) Flags["Prediction Strength"] = v end
function Actions.WallCheck(v) Flags["Wall Check"] = v end
function Actions.ShowFovCircle(v) Flags["Show Fov Circle"] = v end
function Actions.Smoothness(v) Flags["Smoothness"] = v end
function Actions.Distance(v) Flags["Distance"] = v end
function Actions.AimbotFovCircle(v) Flags["Fov Circle"] = v end
function Actions.FovColor(col) Flags["Fov Color"] = col end

-- Silent Aim Action Setters
function Actions.EnableSilentAim(v) Flags["Enable Silend Aim"] = v end
function Actions.SilentAimMethod(opt) 
    Flags["Silend Aim Method"] = opt 
    Flags["Silend aim methode"] = opt 
end
function Actions.SilentShowFov(v) Flags["Show Silend Aim Fov"] = v end
function Actions.SilentFovSize(v) Flags["Silend aim fov size"] = v end
function Actions.SilentDistance(v) Flags["Silend aim Distance"] = v end
function Actions.SilentWallCheck(v) Flags["Silend Wall Check"] = v end
function Actions.SilentBodyPart(opt) Flags["Silend Body Part"] = opt end
function Actions.SilentFovColor(col) Flags["Silend Aim FOV Color"] = col end

-- Dummy-Funktionen für ESP (Platzhalter)
function Actions.ESP_Enable(v) end
function Actions.ESP_Boxes(v) end
function Actions.ESP_Highlights(v) end
function Actions.ESP_Name(v) end
function Actions.ESP_Health(v) end
function Actions.ESP_Distance(v) end
function Actions.ESP_Vehicles(v) end
function Actions.ESP_PlayerDist(v) end
function Actions.ESP_VehicleDist(v) end
function Actions.ESP_PlayerColor(col) end
function Actions.ESP_VehicleColor(col) end

-- Dummy-Funktionen für Movement (Platzhalter)
function Actions.Move_Speed(v) end
function Actions.Move_SpeedAmount(v) end
function Actions.Move_Jump(v) end
function Actions.Move_JumpAmount(v) end
function Actions.Move_Fly(v) end
function Actions.Move_FlyAmount(v) end
function Actions.Move_VehFly(v) end
function Actions.Move_VehFlyAmount(v) end
function Actions.Move_VehNoclip(v) end
function Actions.Move_InfJump(v) end
function Actions.Move_NoJumpDelay(v) end
function Actions.Move_AirStrafe(v) end
function Actions.Move_Noclip(v) end
function Actions.Move_ClickTP(v) end
function Actions.Move_FreecamTP(v) end
function Actions.Move_FreecamSpeed(v) end


-- ========================================================
-- 4. AIMBOT & SILENT AIM BACKEND IMPLEMENTATION
-- ========================================================

local aimbotFovCircle
pcall(function()
    aimbotFovCircle = Drawing.new("Circle")
    aimbotFovCircle.Visible = false
    aimbotFovCircle.Thickness = 1
    aimbotFovCircle.NumSides = 64
    aimbotFovCircle.Filled = false
end)

local aimKeyHeld = false
local toggleState = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    local aimKey = Flags["Aim Key"]
    if typeof(aimKey) == "string" then
        pcall(function()
            local enumItem = Enum.KeyCode:FromName(aimKey)
            if not enumItem then
                enumItem = Enum.UserInputType:FromName(aimKey)
            end
            if enumItem then
                aimKey = enumItem
                Flags["Aim Key"] = enumItem
            end
        end)
    end
    if aimKey and aimKey ~= Enum.KeyCode.None then
        if (input.KeyCode == aimKey) or (input.UserInputType == aimKey) then
            aimKeyHeld = true
            local aimMode = Flags["Aim mode"]
            if aimMode == "Toggel" or aimMode == "Toggle" then
                toggleState = not toggleState
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local aimKey = Flags["Aim Key"]
    if typeof(aimKey) == "string" then
        pcall(function()
            local enumItem = Enum.KeyCode:FromName(aimKey)
            if not enumItem then
                enumItem = Enum.UserInputType:FromName(aimKey)
            end
            if enumItem then
                aimKey = enumItem
                Flags["Aim Key"] = enumItem
            end
        end)
    end
    if aimKey and aimKey ~= Enum.KeyCode.None then
        if (input.KeyCode == aimKey) or (input.UserInputType == aimKey) then
            aimKeyHeld = false
        end
    end
end)

local function isAimbotActive()
    if not Flags["Enable Aimbot"] then return false end
    local aimMode = Flags["Aim mode"]
    if aimMode == "Hold" then
        return aimKeyHeld
    elseif aimMode == "Toggel" or aimMode == "Toggle" then
        return toggleState
    end
    return true
end

local function getTargetPart(character, partName)
    if not character then return nil end
    local map = {
        ["Head"] = "Head",
        ["HumanoidRootPart"] = "HumanoidRootPart",
        ["UperTorso"] = "UpperTorso",
        ["LowerTorso"] = "LowerTorso",
        ["uperTorso"] = "UpperTorso",
        ["lowerTorso"] = "LowerTorso"
    }
    local realName = map[partName] or partName
    local part = character:FindFirstChild(realName)
    if not part then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("BasePart") and string.lower(child.Name) == string.lower(realName) then
                return child
            end
        end
        part = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    end
    return part
end

local function getClosestTarget()
    local bestTarget = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local maxFov = Flags["Fov Circle"] or 100
    local maxDist = Flags["Distance"] or 500
    local selectedPartName = Flags["aim body Part"] or "Head"
    local wallCheck = Flags["Wall Check"]

    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local skipPlayer = false
            if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                skipPlayer = true
            end
            
            if not skipPlayer then
                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local part = getTargetPart(char, selectedPartName)
                        if part then
                            local dist3D = (part.Position - localRoot.Position).Magnitude
                            if dist3D <= maxDist then
                                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
                                    local screenDist = (screenPos2D - screenCenter).Magnitude
                                    if screenDist <= maxFov and screenDist < shortestDistance then
                                        local passWall = true
                                        if wallCheck then
                                            local rayParams = RaycastParams.new()
                                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                            rayParams.FilterDescendantsInstances = {localChar, char}
                                            local rayResult = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
                                            if rayResult then
                                                passWall = false
                                            end
                                        end
                                        if passWall then
                                            shortestDistance = screenDist
                                            bestTarget = part
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- ================= Silent AIM BACKEND IMPLEMENTATION ================= --
local function isTargetVisible(targetPart, localRoot)
    if not targetPart or not localRoot then return false end
    local origin = localRoot.Position
    local direction = targetPart.Position - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if not result then
        return true
    else
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
    end
    return false
end

local SilendFovCircle
pcall(function()
    SilendFovCircle = Drawing.new("Circle")
    SilendFovCircle.Visible = false
    SilendFovCircle.Thickness = 1
    SilendFovCircle.NumSides = 64
    SilendFovCircle.Filled = false
    SilendFovCircle.Color = Color3.fromRGB(255, 255, 255)
end)

local function getSilendAimTarget()
    local bestTarget = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local maxFov = Flags["Silend aim fov size"] or 100
    local maxDist = Flags["Silend aim Distance"] or 500
    local selectedPartName = Flags["Silend Body Part"] or Flags["aim body Part"] or "Head"
    local wallCheck = Flags["Silend Wall Check"]

    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local skipPlayer = false
            if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                skipPlayer = true
            end
            
            if not skipPlayer then
                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local part = getTargetPart(char, selectedPartName)
                        if part then
                            local dist3D = (part.Position - localRoot.Position).Magnitude
                            if dist3D <= maxDist then
                                local passWallCheck = true
                                if wallCheck then
                                    passWallCheck = isTargetVisible(part, localRoot)
                                end

                                if passWallCheck then
                                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                                    if onScreen then
                                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                        if screenDist <= maxFov and screenDist < shortestDistance then
                                            shortestDistance = screenDist
                                            bestTarget = part
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local cachedTarget = nil

RunService.RenderStepped:Connect(function()
    -- Aimbot FOV Circle
    if aimbotFovCircle then
        local enabled = Flags["Show Fov Circle"] and Flags["Enable Aimbot"]
        aimbotFovCircle.Visible = enabled
        if enabled then
            aimbotFovCircle.Radius = Flags["Fov Circle"] or 100
            aimbotFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            aimbotFovCircle.Color = Flags["Fov Color"] or Color3.fromRGB(255, 255, 255)
        end
    end

    -- Silent Aim FOV Circle
    if SilendFovCircle then
        local enabled = Flags["Show Silend Aim Fov"] and Flags["Enable Silend Aim"]
        SilendFovCircle.Visible = enabled
        if enabled then
            SilendFovCircle.Radius = Flags["Silend aim fov size"] or 100
            SilendFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            if cachedTarget then
                SilendFovCircle.Color = Color3.fromRGB(212, 80, 80)
            else
                SilendFovCircle.Color = Flags["Silend Aim FOV Color"] or Color3.fromRGB(255, 255, 255)
            end
        end
    end

    -- Aimbot Logic Execution
    if isAimbotActive() then
        local targetPart = getClosestTarget()
        if targetPart then
            local targetPos = targetPart.Position
            
            if Flags["Enable Prediction"] then
                local hrp = targetPart.Parent and targetPart.Parent:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local predStrength = (Flags["Prediction Strength"] or 25) / 1000
                    targetPos = targetPos + (hrp.Velocity * predStrength)
                end
            end

            local aimMethod = Flags["Aim Methode"] or "CFrame"
            if aimMethod == "CFrame" then
                local smoothness = Flags["Smoothness"] or 0
                if smoothness == 0 then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                else
                    local alpha = math.clamp(1 - (smoothness / 100), 0.01, 1)
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
                end
            elseif aimMethod == "MouseMovment" then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                    local delta = targetScreenPos - screenCenter
                    local smoothness = Flags["Smoothness"] or 0
                    local divisor = math.clamp(smoothness + 1, 1, 100)
                    pcall(function()
                        mousemoverel(delta.X / divisor, delta.Y / divisor)
                    end)
                end
            end
        end
    end

    if Flags["Enable Silend Aim"] then
        cachedTarget = getSilendAimTarget()
    else
        cachedTarget = nil
    end
end)

-- ========================================================
-- ERWEITERTE SILENT AIM HOOKS (Workspace & Camera)
-- ========================================================
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if Flags["Enable Silend Aim"] and not checkcaller() then
            local aimMethod = Flags["Silend Aim Method"] or Flags["Silend aim methode"] or "FindPartOnRay"
            local useMethod = false

            if aimMethod == "All" or aimMethod == "all" then
                useMethod = true
            else
                useMethod = (method == aimMethod or string.lower(method) == string.lower(aimMethod))
            end

            if useMethod and cachedTarget then
                local hitPos = cachedTarget.Position

                -- Workspace Raycasts
                if method == "Raycast" or method == "raycast" then
                    local origin = args[1]
                    if typeof(origin) == "Vector3" and typeof(args[2]) == "Vector3" then
                        args[2] = (hitPos - origin).Unit * args[2].Magnitude
                        return oldNamecall(self, unpack(args))
                    end
                elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
                    local ray = args[1]
                    if typeof(ray) == "Ray" then
                        args[1] = Ray.new(ray.Origin, (hitPos - ray.Origin).Unit * ray.Direction.Magnitude)
                        return oldNamecall(self, unpack(args))
                    end
                
                -- Kamera Methoden (ScreenPointToRay / ViewportPointToRay)
                elseif method == "ScreenPointToRay" or method == "ViewportPointToRay" then
                    local res = oldNamecall(self, ...)
                    if typeof(res) == "Ray" then
                        local origin = res.Origin
                        local newDir = (hitPos - origin).Unit * res.Direction.Magnitude
                        return Ray.new(origin, newDir)
                    end
                end
            end
        end

        return oldNamecall(self, ...)
    end)
end)

-- ========================================================
-- INDEX HOOK FÜR MOUSE-EIGENSCHAFTEN (MouseHit, Target, UnitRay)
-- ========================================================
pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, index)
        if Flags["Enable Silend Aim"] and not checkcaller() then
            local aimMethod = Flags["Silend Aim Method"] or Flags["Silend aim methode"] or ""
            if (aimMethod == "MouseHit" or aimMethod == "All") and cachedTarget then
                if index == "Hit" then
                    return CFrame.new(cachedTarget.Position)
                elseif index == "Target" then
                    return cachedTarget
                elseif index == "UnitRay" then
                    local origin = Camera.CFrame.Position
                    return Ray.new(origin, (cachedTarget.Position - origin).Unit * 1000)
                end
            end
        end
        return oldIndex(self, index)
    end)
end)