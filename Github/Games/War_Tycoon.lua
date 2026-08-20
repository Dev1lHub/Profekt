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
    ["Silend Aim Method"] = "Raycast",
    ["Silend aim methode"] = "Raycast",
    ["Show Silend Aim Fov"] = false,
    ["Silend aim fov size"] = 100,
    ["Silend aim Distance"] = 500,
    ["Silend Wall Check"] = false,
    ["Silend Body Part"] = "Head",
    ["Silend Aim FOV Color"] = Color3.fromRGB(255, 255, 255),

    -- Movement Flags
    ["Enable Speed_Toggle"] = false,
    ["Speed Amound"] = 16,
    ["Enable JumpHight_Toggle"] = false,
    ["Jumphight Amound"] = 50,
    ["Enable Fly_Toggle"] = false,
    ["Fly Speed Amound"] = 50,
    ["Enable Vehicle Fly_Toggle"] = false,
    ["Vehicle Fly Speed"] = 75,
    ["Enable Vehicle Noclip_Toggle"] = false,
    ["Enable Infinity Jump"] = false,
    ["Enable No Jump Delay"] = false,
    ["Enable Air Strafe"] = false,
    ["Enable Noclip_Toggle"] = false,
    ["Click TP_Toggle"] = false,
    ["Freecam TP_Toggle"] = false,
    ["Freecam Speed Amound"] = 50,
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
Sub_ESPGen:AddToggle("Show Vehicle health", false, function(v) Actions.ESP_VehicleHealth(v) end)
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
Sub_MoveGen:AddSlider("Speed Amound", 0, 130, 16, function(v) Actions.Move_SpeedAmount(v) end)
Sub_MoveGen:AddToggleWithKey("Enable JumpHight", false, Enum.KeyCode.None, function(v) Actions.Move_Jump(v) end)
Sub_MoveGen:AddSlider("JumpHight Amound", 0, 150, 50, function(v) Actions.Move_JumpAmount(v) end)
Sub_MoveGen:AddToggleWithKey("Enable Fly", false, Enum.KeyCode.None, function(v) Actions.Move_Fly(v) end)
Sub_MoveGen:AddSlider("Fly Speed Amound", 0, 300, 50, function(v) Actions.Move_FlyAmount(v) end)
Sub_MoveGen:AddToggleWithKey("Enable Vehicle Fly", false, Enum.KeyCode.None, function(v) Actions.Move_VehFly(v) end)
Sub_MoveGen:AddSlider("Vehicle Fly Speed Amound", 0, 1000, 75, function(v) Actions.Move_VehFlyAmount(v) end)
Sub_MoveGen:AddToggle("Vehicle Noclip", false, function(v) Actions.Move_VehNoclip(v) end)
Sub_MoveGen:AddToggle("Infinity jump", false, function(v) Actions.Move_InfJump(v) end)
Sub_MoveGen:AddToggle("No Jump Delay", false, function(v) Actions.Move_NoJumpDelay(v) end)
Sub_MoveGen:AddToggle("Air Strafe", false, function(v) Actions.Move_AirStrafe(v) end)
Sub_MoveGen:AddToggle("Noclip", false, function(v) Actions.Move_Noclip(v) end)
Sub_MoveGen:AddToggleWithKey("Click TP", false, Enum.KeyCode.None, function(v) Actions.Move_ClickTP(v) end)
Sub_MoveGen:AddToggleWithKey("Freecam TP", false, Enum.KeyCode.None, function(v) Actions.Move_FreecamTP(v) end)
Sub_MoveGen:AddSlider("Freecam Speed Amound", 0, 500, 50, function(v) Actions.Move_FreecamSpeed(v) end)


-- ========================================================
-- 4. ESP & HIGHLIGHT BACKEND IMPLEMENTATION
-- ========================================================



-- ------------------------------------------
-- TAB 4: FARMING
-- ------------------------------------------
local Tab4 = MyWindow:AddTab("Farming")
local Sub_FarmGen = Tab4:AddSubTab("generel")
Sub_FarmGen:AddToggle("Enable Auto Upgrade Base", false, function(v) Actions.AutoUpgradeBase(v) end)


-- ==========================================
-- 3. FUNKTIONEN & LOGIK (CALLBACKS)
-- ==========================================

-- Anti-AFK (Verhindert den Kick bei Inaktivität)
-- Anti-AFK (Verhindert den Kick bei Inaktivität)
if not getgenv().AntiAfkConnected then
    getgenv().AntiAfkConnected = true
    task.spawn(function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            pcall(function()
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end)
    end)
end

-- Anti-AFK (Verhindert den Kick bei Inaktivität)
if not getgenv().AntiAfkConnected then
    getgenv().AntiAfkConnected = true
    task.spawn(function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            pcall(function()
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end)
    end)
end

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
        
        -- Haupt-Loop
        task.spawn(function()
            while toggleActive do
                -- Rebirth Check & ConfirmButton Trigger
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        local ui = playerGui:FindFirstChild("UI")
                        local container = ui and ui:FindFirstChild("Container")
                        local hud = container and container:FindFirstChild("HUD")
                        local menu = hud and hud:FindFirstChild("Menu")
                        local innerHud = menu and menu:FindFirstChild("HUD")
                        local rebirths = innerHud and innerHud:FindFirstChild("Rebirths")
                        
                        -- Prüfen ob das Rebirths-Fenster bzw. Menü sichtbar ist
                        if rebirths and rebirths.Visible then
                            local rebirthMenu = rebirths:FindFirstChild("RebirthMenu")
                            local background = rebirthMenu and rebirthMenu:FindFirstChild("Background")
                            local body = background and background:FindFirstChild("Body")
                            local options = body and body:FindFirstChild("Options")
                            local confirmButton = options and options:FindFirstChild("ConfirmButton")
                            
                            if confirmButton then
                                -- Button über Executor-Funktionen auslösen
                                if firesignal then
                                    firesignal(confirmButton.MouseButton1Click)
                                    firesignal(confirmButton.Activated)
                                elseif getconnections then
                                    for _, conn in ipairs(getconnections(confirmButton.MouseButton1Click)) do
                                        conn:Fire()
                                    end
                                    for _, conn in ipairs(getconnections(confirmButton.Activated)) do
                                        conn:Fire()
                                    end
                                end
                            end
                        end
                    end
                end)

                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                local currentTeamName = "Foxtrot"
                if LocalPlayer.Team and LocalPlayer.Team.Name then
                    currentTeamName = LocalPlayer.Team.Name
                elseif LocalPlayer:GetAttribute("Team") then
                    currentTeamName = tostring(LocalPlayer:GetAttribute("Team"))
                end
                
                local tycoonFolder = Workspace.Tycoon.Tycoons:FindFirstChild(currentTeamName)
                
                -- Fallback-Position (Collector) ermitteln
                local fallbackPos = CFrame.new(3070, 70, -1731) + Vector3.new(0, 10, 0)
                pcall(function()
                    if tycoonFolder then
                        local collectorPart = tycoonFolder.Essentials.CollectorParts.Collector
                        if collectorPart and collectorPart:IsA("BasePart") then
                            fallbackPos = collectorPart.CFrame + Vector3.new(0, 10, 0)
                        end
                    end
                end)

                -- Aktuelle Rebirths des Spielers auslesen
                local playerRebirths = 0
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                if leaderstats then
                    local rebirthsVal = leaderstats:FindFirstChild("Rebirths")
                    if rebirthsVal then
                        playerRebirths = tonumber(rebirthsVal.Value) or 0
                    end
                end
                
                -- SCHRITT 1: ZUERST nach kaufbaren Buttons suchen (Grün, Blau [4, 175, 235] oder Rebirth-Gelb)
                local targetPart = nil
                pcall(function()
                    if tycoonFolder and tycoonFolder:FindFirstChild("UnpurchasedButtons") then
                        local unpurchasedFolder = tycoonFolder.UnpurchasedButtons
                        for _, descendant in ipairs(unpurchasedFolder:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                local col = descendant.Color
                                local isGreen = (math.abs(col.R - 0) < 0.05) and (math.abs(col.G - 1) < 0.05) and (math.abs(col.B - 0) < 0.05)
                                local isBlue = (math.abs(col.R - (4/255)) < 0.05) and (math.abs(col.G - (175/255)) < 0.05) and (math.abs(col.B - (235/255)) < 0.05)
                                local isYellow = (math.abs(col.R - 1) < 0.05) and (math.abs(col.G - 1) < 0.05) and (math.abs(col.B - 0) < 0.05)
                                local isNeon = (descendant.Material == Enum.Material.Neon) or (descendant.Name == "Neon")
                                
                                if isNeon then
                                    if isGreen or isBlue then
                                        targetPart = descendant
                                        break
                                    elseif isYellow then
                                        local canBuy = false
                                        local ui = descendant:FindFirstChild("UI")
                                        if ui then
                                            local billboard = ui:FindFirstChild("BillboardGui")
                                            if billboard then
                                                local frame = billboard:FindFirstChild("Frame")
                                                if frame then
                                                    local priceLabel = frame:FindFirstChild("Price")
                                                    if priceLabel and priceLabel:IsA("TextLabel") then
                                                        local priceText = priceLabel.Text
                                                        if string.find(string.lower(priceText), "rebirth") then
                                                            local requiredRebirths = tonumber(string.match(priceText, "(%d+)")) or 0
                                                            if playerRebirths >= requiredRebirths then
                                                                canBuy = true
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        
                                        if canBuy then
                                            targetPart = descendant
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                
                -- SCHRITT 2: Wenn ein Button gefunden wurde, sofort dorthin teleportieren!
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
                    -- SCHRITT 3: Wenn KEIN Button bereit ist, prüfen ob "Oil 2" fehlt -> Oil 1 ProximityPrompt einmalig ausführen
                    local oilHandled = false
                    pcall(function()
                        if tycoonFolder then
                            local purchasedObjects = tycoonFolder:FindFirstChild("PurchasedObjects")
                            if purchasedObjects and not purchasedObjects:FindFirstChild("Oil 2") then
                                local oil1 = purchasedObjects:FindFirstChild("Oil 1")
                                if oil1 then
                                    local cb1 = oil1:FindFirstChild("CB1")
                                    if cb1 then
                                        local prompt = cb1:FindFirstChild("DefaultExtractor")
                                        if prompt and prompt:IsA("ProximityPrompt") then
                                            local promptPart = prompt.Parent
                                            if promptPart and promptPart:IsA("BasePart") and hrp then
                                                hrp.CFrame = promptPart.CFrame + Vector3.new(0, 3, 0)
                                                task.wait(0.2)
                                                fireproximityprompt(prompt)
                                                task.wait(0.2)
                                                hrp.CFrame = fallbackPos
                                                oilHandled = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    
                    -- Wenn kein Oil getriggert wurde, einfach am Collector bleiben
                    if not oilHandled and hrp then
                        hrp.CFrame = fallbackPos
                    end
                    
                    task.wait(0.5)
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
function Actions.SilentShowFov(v) Flags["Show Silend Aim Fov"] = v end
function Actions.SilentFovSize(v) Flags["Silend aim fov size"] = v end
function Actions.SilentDistance(v) Flags["Silend aim Distance"] = v end
function Actions.SilentWallCheck(v) Flags["Silend Wall Check"] = v end
function Actions.SilentBodyPart(opt) Flags["Silend Body Part"] = opt end
function Actions.SilentFovColor(col) Flags["Silend Aim FOV Color"] = col end

-- Movement Action Setters (Linked to Backend Flags)
function Actions.Move_Speed(v) Flags["Enable Speed_Toggle"] = v end
function Actions.Move_SpeedAmount(v) Flags["Speed Amound"] = v end
function Actions.Move_Jump(v) Flags["Enable JumpHight_Toggle"] = v end
function Actions.Move_JumpAmount(v) Flags["Jumphight Amound"] = v end
function Actions.Move_Fly(v) Flags["Enable Fly_Toggle"] = v end
function Actions.Move_FlyAmount(v) Flags["Fly Speed Amound"] = v end
function Actions.Move_VehFly(v) Flags["Enable Vehicle Fly_Toggle"] = v end
function Actions.Move_VehFlyAmount(v) Flags["Vehicle Fly Speed"] = v end
function Actions.Move_VehNoclip(v) Flags["Enable Vehicle Noclip_Toggle"] = v end
function Actions.Move_InfJump(v) Flags["Enable Infinity Jump"] = v end
function Actions.Move_NoJumpDelay(v) Flags["Enable No Jump Delay"] = v end
function Actions.Move_AirStrafe(v) Flags["Enable Air Strafe"] = v end
function Actions.Move_Noclip(v) Flags["Enable Noclip_Toggle"] = v end
function Actions.Move_ClickTP(v) Flags["Click TP_Toggle"] = v end
function Actions.Move_FreecamTP(v) Flags["Freecam TP_Toggle"] = v end
function Actions.Move_FreecamSpeed(v) Flags["Freecam Speed Amound"] = v end

-- ESP Action Setters
function Actions.ESP_Enable(v) Flags["Enable ESP"] = v end
function Actions.ESP_Boxes(v) Flags["Show 2d boxes"] = v end
function Actions.ESP_Highlights(v) Flags["Show Highlites"] = v end
function Actions.ESP_Name(v) Flags["Show Name"] = v end
function Actions.ESP_Health(v) Flags["Show Health bar"] = v end
function Actions.ESP_Distance(v) Flags["Show Distance"] = v end
function Actions.ESP_Vehicles(v) Flags["Show Vehicles"] = v end
function Actions.ESP_VehicleHealth(v) Flags["Show Vehicle Health"] = v end
function Actions.ESP_PlayerDist(v) Flags["Player ESP Distance"] = v end
function Actions.ESP_VehicleDist(v) Flags["Vehicle ESP Distance"] = v end
function Actions.ESP_PlayerColor(col) Flags["Set Player Color"] = col end
function Actions.ESP_VehicleColor(col) Flags["Set Vehicle Color"] = col end


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
local cachedAimbotTarget = nil

RunService.RenderStepped:Connect(function()
    if isAimbotActive() then
        cachedAimbotTarget = getClosestTarget()
    else
        cachedAimbotTarget = nil
    end

    if Flags["Enable Silend Aim"] then
        cachedTarget = getSilendAimTarget()
    else
        cachedTarget = nil
    end

    if aimbotFovCircle then
        local enabled = Flags["Show Fov Circle"] and Flags["Enable Aimbot"]
        aimbotFovCircle.Visible = enabled
        if enabled then
            aimbotFovCircle.Radius = Flags["Fov Circle"] or 100
            aimbotFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            if cachedAimbotTarget then
                aimbotFovCircle.Color = Color3.fromRGB(212, 80, 80)
            else
                aimbotFovCircle.Color = Flags["Fov Color"] or Color3.fromRGB(255, 255, 255)
            end
        end
    end

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

    if isAimbotActive() then
        local targetPart = cachedAimbotTarget
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
end)

-- ========================================================
-- SILENT AIM HOOK (Workspace:Raycast)
-- ========================================================
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if Flags["Enable Silend Aim"] and not checkcaller() then
            if (method == "Raycast" or method == "raycast") and cachedTarget then
                local hitPos = cachedTarget.Position
                local origin = args[1]
                if typeof(origin) == "Vector3" and typeof(args[2]) == "Vector3" then
                    args[2] = (hitPos - origin).Unit * args[2].Magnitude
                    return oldNamecall(self, unpack(args))
                end
            end
        end

        return oldNamecall(self, ...)
    end)
end)

-- ========================================================
-- 5. ESP & HIGHLIGHT BACKEND IMPLEMENTATION
-- ========================================================

local espCache = {
    Players = {},
    Vehicles = {}
}

local function createDrawing(type, properties)
    local success, obj = pcall(function()
        local d = Drawing.new(type)
        for k, v in pairs(properties) do
            d[k] = v
        end
        return d
    end)
    if success then return obj end
    return nil
end

local function getPlayerEspObjects(player)
    if not espCache.Players[player] then
        espCache.Players[player] = {
            Box = createDrawing("Square", {Visible = false, Filled = false, Thickness = 1}),
            HealthBg = createDrawing("Square", {Visible = false, Filled = true, Color = Color3.fromRGB(0, 0, 0)}),
            HealthFill = createDrawing("Square", {Visible = false, Filled = true, Color = Color3.fromRGB(0, 255, 0)}),
            NameTag = createDrawing("Text", {Visible = false, Size = 16, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255)}),
            Highlight = nil
        }
    end
    return espCache.Players[player]
end

local function getVehicleEspObjects(model)
    if not espCache.Vehicles[model] then
        espCache.Vehicles[model] = {
            NameTag = createDrawing("Text", {Visible = false, Size = 16, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255)}),
            Highlight = nil
        }
    end
    return espCache.Vehicles[model]
end

Players.PlayerRemoving:Connect(function(player)
    if espCache.Players[player] then
        for _, obj in pairs(espCache.Players[player]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            elseif typeof(obj) == "userdata" then
                pcall(function() obj:Remove() end)
            end
        end
        espCache.Players[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    local espEnabled = Flags["Enable ESP"]
    local showBoxes = Flags["Show 2d boxes"]
    local showHighlights = Flags["Show Highlites"]
    local showName = Flags["Show Name"]
    local showHealth = Flags["Show Health bar"]
    local showDistance = Flags["Show Distance"]
    local showVehicles = Flags["Show Vehicles"]
    local showVehicleHealth = Flags["Show Vehicle Health"]
    
    local playerDistLimit = Flags["Player ESP Distance"] or 1000
    local vehicleDistLimit = Flags["Vehicle ESP Distance"] or 1000
    local playerColor = Flags["Set Player Color"] or Color3.fromRGB(255, 255, 255)
    local vehicleColor = Flags["Set Vehicle Color"] or Color3.fromRGB(255, 255, 255)

    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    -- ==========================================
    -- 1. SPIELER ESP
    -- ==========================================
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local objects = getPlayerEspObjects(player)
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            local shouldRender = false
            local dist = math.huge

            if espEnabled and char and hrp and localRoot and humanoid and humanoid.Health > 0 then
                dist = (hrp.Position - localRoot.Position).Magnitude
                if dist <= playerDistLimit then
                    shouldRender = true
                end
            end

            -- Highlights für Spieler
            if showHighlights and shouldRender then
                if not objects.Highlight or not objects.Highlight.Parent then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = char
                    hl.Parent = char
                    objects.Highlight = hl
                end
                objects.Highlight.FillColor = playerColor
                objects.Highlight.OutlineColor = playerColor
                objects.Highlight.Enabled = true
            else
                if objects.Highlight then
                    objects.Highlight.Enabled = false
                end
            end

            if shouldRender then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local topWorld = hrp.Position + Vector3.new(0, 3, 0)
                local bottomWorld = hrp.Position - Vector3.new(0, 3.5, 0)
                local topScreen, topOnScreen = Camera:WorldToViewportPoint(topWorld)
                local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomWorld)

                if topOnScreen or bottomOnScreen or onScreen then
                    local boxHeight = math.abs(topScreen.Y - bottomScreen.Y)
                    local boxWidth = boxHeight / 2
                    local boxPos = Vector2.new(screenPos.X - boxWidth / 2, topScreen.Y)

                    -- 2D Boxen (nur Spieler)
                    if showBoxes then
                        objects.Box.Visible = true
                        objects.Box.Size = Vector2.new(boxWidth, boxHeight)
                        objects.Box.Position = boxPos
                        objects.Box.Color = playerColor
                    else
                        objects.Box.Visible = false
                    end

                    -- Health Bar (nur Spieler)
                    if showHealth then
                        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barHeight = boxHeight * healthPercent
                        
                        objects.HealthBg.Visible = true
                        objects.HealthBg.Size = Vector2.new(4, boxHeight)
                        objects.HealthBg.Position = Vector2.new(boxPos.X - 6, boxPos.Y)

                        objects.HealthFill.Visible = true
                        objects.HealthFill.Size = Vector2.new(2, barHeight)
                        objects.HealthFill.Position = Vector2.new(boxPos.X - 5, boxPos.Y + (boxHeight - barHeight))
                        objects.HealthFill.Color = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0)
                    else
                        objects.HealthBg.Visible = false
                        objects.HealthFill.Visible = false
                    end

                    -- Name & Distance
                    if showName then
                        local displayText = player.Name
                        if showDistance then
                            displayText = string.format("%s [%d studs]", player.Name, math.floor(dist))
                        end
                        objects.NameTag.Visible = true
                        objects.NameTag.Text = displayText
                        objects.NameTag.Position = Vector2.new(screenPos.X, boxPos.Y - 20)
                        objects.NameTag.Color = playerColor
                    else
                        objects.NameTag.Visible = false
                    end
                else
                    objects.Box.Visible = false
                    objects.HealthBg.Visible = false
                    objects.HealthFill.Visible = false
                    objects.NameTag.Visible = false
                end
            else
                objects.Box.Visible = false
                objects.HealthBg.Visible = false
                objects.HealthFill.Visible = false
                objects.NameTag.Visible = false
            end
        end
    end

    -- ==========================================
    -- 2. VEHICLE ESP
    -- ==========================================
    local activeVehicleModels = {}
    if espEnabled and showVehicles then
        local gameSystems = Workspace:FindFirstChild("Game Systems")
        if gameSystems then
            local folders = {"Helicopter Workspace", "Plane Workspace", "Vehicle Workspace", "Boat Workspace", "Tank Workspace", "Drone Workspace", "Submarine Workspace", "RC Workspace"}
            for _, folderName in ipairs(folders) do
                local folder = gameSystems:FindFirstChild(folderName)
                if folder then
                    for _, model in ipairs(folder:GetChildren()) do
                        if model:IsA("Model") then
                            table.insert(activeVehicleModels, model)
                        end
                    end
                end
            end
        end
    end

    -- Cleanup für entfernte Vehicles
    for model, objects in pairs(espCache.Vehicles) do
        local found = false
        for _, vm in ipairs(activeVehicleModels) do
            if vm == model then found = true break end
        end
        if not found then
            if objects.Highlight then objects.Highlight:Destroy() end
            pcall(function() objects.NameTag:Remove() end)
            espCache.Vehicles[model] = nil
        end
    end

    -- Render Vehicles
    for _, model in ipairs(activeVehicleModels) do
        local objects = getVehicleEspObjects(model)
        local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        
        local shouldRender = false
        local dist = math.huge

        if primaryPart and localRoot then
            dist = (primaryPart.Position - localRoot.Position).Magnitude
            if dist <= vehicleDistLimit then
                shouldRender = true
            end
        end

        -- Highlights für Vehicles
        if showHighlights and shouldRender then
            if not objects.Highlight or not objects.Highlight.Parent then
                local hl = Instance.new("Highlight")
                hl.Adornee = model
                hl.Parent = model
                objects.Highlight = hl
            end
            objects.Highlight.FillColor = vehicleColor
            objects.Highlight.OutlineColor = vehicleColor
            objects.Highlight.Enabled = true
        else
            if objects.Highlight then
                objects.Highlight.Enabled = false
            end
        end

        -- Name, Health & Distance für Vehicles
        if shouldRender and showName and primaryPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(primaryPart.Position)
            if onScreen then
                local displayText = model.Name
                
                -- Vehicle Health auslesen
                if showVehicleHealth then
                    local healthObj = model:FindFirstChild("Health")
                    if healthObj and (healthObj:IsA("IntValue") or healthObj:IsA("NumberValue")) then
                        local maxHealthObj = model:FindFirstChild("MaxHealth")
                        if maxHealthObj and (maxHealthObj:IsA("IntValue") or maxHealthObj:IsA("NumberValue")) then
                            displayText = displayText .. string.format(" [HP: %d/%d]", math.floor(healthObj.Value), math.floor(maxHealthObj.Value))
                        else
                            displayText = displayText .. string.format(" [HP: %d]", math.floor(healthObj.Value))
                        end
                    end
                end
                
                -- Distance anfügen
                if showDistance then
                    displayText = displayText .. string.format(" [%d studs]", math.floor(dist))
                end

                objects.NameTag.Visible = true
                objects.NameTag.Text = displayText
                objects.NameTag.Position = Vector2.new(screenPos.X, screenPos.Y - 15)
                objects.NameTag.Color = vehicleColor
            else
                objects.NameTag.Visible = false
            end
        else
            objects.NameTag.Visible = false
        end
    end
end)

-- ========================================================
-- 6. MOVEMENT BACKEND IMPLEMENTATION (Flüssig & Gefixt)
-- ========================================================

local originalWalkSpeed = 16
local lastSpeedState = false
local originalJumpPower = 50
local originalJumpHeight = 7.2
local lastJumpState = false

local flyBV, flyBG
local lastFlyState = false

-- Vehicle Fly Variablen
local vehicleFlyBodyGyro, vehicleFlyBodyVelocity = nil, nil

local freecamCF = nil
local lastFreecamState = false
local freecamYaw, freecamPitch = 0, 0
local originalMouseBehavior = Enum.MouseBehavior.Default

RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        -- Speed Logik
        local speedEnabled = Flags["Enable Speed_Toggle"]
        local speedAmount = Flags["Speed Amound"] or 16
        if speedEnabled then
            if not lastSpeedState then
                originalWalkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or 16
                lastSpeedState = true
            end
            humanoid.WalkSpeed = speedAmount
        else
            if lastSpeedState then
                humanoid.WalkSpeed = originalWalkSpeed
                lastSpeedState = false
            end
        end

        -- JumpHeight Logik
        local jumpEnabled = Flags["Enable JumpHight_Toggle"]
        local jumpAmount = Flags["Jumphight Amound"] or 50
        if jumpEnabled then
            if not lastJumpState then
                originalJumpPower = humanoid.JumpPower
                originalJumpHeight = humanoid.JumpHeight
                lastJumpState = true
            end
            humanoid.UseJumpPower = true
            humanoid.JumpPower = jumpAmount
        else
            if lastJumpState then
                humanoid.JumpPower = originalJumpPower
                humanoid.JumpHeight = originalJumpHeight
                lastJumpState = false
            end
        end

        -- Fly Logik
        local flyEnabled = Flags["Enable Fly_Toggle"]
        local flySpeed = Flags["Fly Speed Amound"] or 50
        if flyEnabled then
            humanoid.PlatformStand = true
            
            if not flyBV or not flyBV.Parent then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBV.Velocity = Vector3.zero
                flyBV.Parent = rootPart
            end
            if not flyBG or not flyBG.Parent then
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBG.CFrame = Camera.CFrame
                flyBG.Parent = rootPart
            end

            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            flyBV.Velocity = moveDir * (flySpeed * 1.5)
            flyBG.CFrame = Camera.CFrame
            lastFlyState = true
        else
            if flyBV then flyBV:Destroy() flyBV = nil end
            if flyBG then flyBG:Destroy() flyBG = nil end
            if lastFlyState then
                humanoid.PlatformStand = false
                lastFlyState = false
            end
        end

        -- Vehicle Fly Logik (NEU HINZUGEFÜGT)
        local vehFlyEnabled = Flags["Enable Vehicle Fly_Toggle"]
        local vehFlySpeed = Flags["Vehicle Fly Speed"] or 75

        if vehFlyEnabled and humanoid.SeatPart then
            Camera.CameraSubject = humanoid

            local seat = humanoid.SeatPart
            local vehicleModel = seat.Parent
            local vehicleRoot = vehicleModel:IsA("Model") and (vehicleModel.PrimaryPart or vehicleModel:FindFirstChild("HumanoidRootPart") or seat) or seat

            if vehicleRoot and vehicleRoot:IsA("BasePart") then
                if not vehicleFlyBodyVelocity or vehicleFlyBodyVelocity.Parent ~= vehicleRoot then
                    if vehicleFlyBodyVelocity then vehicleFlyBodyVelocity:Destroy() end
                    if vehicleFlyBodyGyro then vehicleFlyBodyGyro:Destroy() end

                    vehicleFlyBodyVelocity = Instance.new("BodyVelocity")
                    vehicleFlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    vehicleFlyBodyVelocity.Velocity = Vector3.zero
                    vehicleFlyBodyVelocity.Parent = vehicleRoot

                    vehicleFlyBodyGyro = Instance.new("BodyGyro")
                    vehicleFlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    vehicleFlyBodyGyro.CFrame = Camera.CFrame * CFrame.Angles(math.rad(180), math.rad(90), 0)
                    vehicleFlyBodyGyro.Parent = vehicleRoot
                end

                local moveDir = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                vehicleFlyBodyVelocity.Velocity = moveDir * (vehFlySpeed * 1.5)
                vehicleFlyBodyGyro.CFrame = Camera.CFrame * CFrame.Angles(math.rad(180), math.rad(90), 0)
            end
        else
            if vehicleFlyBodyVelocity then vehicleFlyBodyVelocity:Destroy() vehicleFlyBodyVelocity = nil end
            if vehicleFlyBodyGyro then vehicleFlyBodyGyro:Destroy() vehicleFlyBodyGyro = nil end
        end

        -- Freecam Logik
        local freecamEnabled = Flags["Freecam TP_Toggle"]
        local freecamSpeed = Flags["Freecam Speed Amound"] or 50

        if freecamEnabled then
            if not lastFreecamState then
                freecamCF = Camera.CFrame
                local rx, ry, _ = freecamCF:ToOrientation()
                freecamYaw, freecamPitch = ry, rx
                rootPart.Anchored = true
                humanoid.PlatformStand = true
                originalMouseBehavior = UserInputService.MouseBehavior
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                lastFreecamState = true
            end
            
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

            local mouseDelta = UserInputService:GetMouseDelta()
            local sensitivity = 0.003
            freecamYaw = freecamYaw - mouseDelta.X * sensitivity
            freecamPitch = math.clamp(freecamPitch - mouseDelta.Y * sensitivity, -math.rad(89), math.rad(89))

            Camera.CameraType = Enum.CameraType.Scriptable
            local rotCF = CFrame.fromOrientation(0, freecamYaw, 0) * CFrame.fromOrientation(freecamPitch, 0, 0)
            local camMove = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then camMove = camMove + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then camMove = camMove + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then camMove = camMove + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then camMove = camMove + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then camMove = camMove + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then camMove = camMove + Vector3.new(0, -1, 0) end
            
            local speedMultiplier = (freecamSpeed / 25) 
            local moveVector = (rotCF:VectorToWorldSpace(camMove)) * speedMultiplier
            
            freecamCF = freecamCF + moveVector
            Camera.CFrame = CFrame.new(freecamCF.Position) * rotCF
            freecamCF = Camera.CFrame
        else
            if lastFreecamState then
                Camera.CameraType = Enum.CameraType.Custom
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                if rootPart then
                    rootPart.Anchored = false
                    rootPart.CFrame = freecamCF
                end
                humanoid.PlatformStand = false
                lastFreecamState = false
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Flags["Enable Noclip_Toggle"] then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not Flags["Enable Infinity Jump"] then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end

    local jumpPower = humanoid.JumpPower
    if not humanoid.UseJumpPower then jumpPower = math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight) end
    if not jumpPower or jumpPower == 0 then jumpPower = 44 end
    local currentVel = rootPart.AssemblyLinearVelocity
    if currentVel.X ~= currentVel.X or currentVel.Y ~= currentVel.Y or currentVel.Z ~= currentVel.Z then return end
    rootPart.AssemblyLinearVelocity = Vector3.new(currentVel.X, jumpPower, currentVel.Z)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and Flags["Click TP_Toggle"] then
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local mousePos = UserInputService:GetMouseLocation()
                local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                raycastParams.FilterDescendantsInstances = {char}
                
                local rayResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
                if rayResult then
                    hrp.CFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0))
                end
            end
        end
    end
end)

local trackedParts = {}
RunService.Stepped:Connect(function()
    local enabled = Flags["Enable Vehicle Noclip_Toggle"]
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local isInVehicle = humanoid and humanoid.SeatPart ~= nil

    if enabled and isInVehicle then
        local seat = humanoid.SeatPart
        local vehicleModel = seat.Parent

        if vehicleModel and vehicleModel:IsA("Model") then
            for _, part in ipairs(vehicleModel:GetDescendants()) do
                if part:IsA("BasePart") then
                    if trackedParts[part] == nil then trackedParts[part] = part.CanCollide end
                    part.CanCollide = false
                end
            end
        elseif seat:IsA("BasePart") then
            if trackedParts[seat] == nil then trackedParts[seat] = seat.CanCollide end
            seat.CanCollide = false
        end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if trackedParts[part] == nil then trackedParts[part] = part.CanCollide end
                part.CanCollide = false
            end
        end

        if vehicleModel and vehicleModel:IsA("Model") then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local pChar = player.Character
                    local pHumanoid = pChar and pChar:FindFirstChildOfClass("Humanoid")
                    if pHumanoid and pHumanoid.SeatPart then
                        local pSeatParent = pHumanoid.SeatPart.Parent
                        if pSeatParent == vehicleModel or pHumanoid.SeatPart == seat then
                            for _, part in ipairs(pChar:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    if trackedParts[part] == nil then trackedParts[part] = part.CanCollide end
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        for part, originalState in pairs(trackedParts) do
            if part and part.Parent then part.CanCollide = originalState end
        end
        trackedParts = {}
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid or humanoid.Health <= 0 then return end

    if Flags["Enable Air Strafe"] then
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid.FloorMaterial == Enum.Material.Air then
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local currentVel = rootPart.AssemblyLinearVelocity
                local speed = math.max(math.sqrt(currentVel.X^2 + currentVel.Z^2), 16)
                local targetVel = moveDir * speed
                rootPart.AssemblyLinearVelocity = Vector3.new(targetVel.X, currentVel.Y, targetVel.Z)
            end
        end
    end

    if Flags["Enable No Jump Delay"] then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                local jumpPower = humanoid.JumpPower
                if not humanoid.UseJumpPower then jumpPower = math.sqrt(1 * workspace.Gravity * humanoid.JumpHeight) end
                if not jumpPower or jumpPower == 0 then jumpPower = 50 end

                local currentVel = rootPart.AssemblyLinearVelocity
                if currentVel.Y < jumpPower then
                    rootPart.AssemblyLinearVelocity = Vector3.new(currentVel.X, jumpPower, currentVel.Z)
                end
            end
        end
    end
end)