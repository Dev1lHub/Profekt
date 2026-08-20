-- ==========================================
-- 1. VORBEREITUNG & SETUP DER NEUEN GUI
-- ==========================================

local gui_link = "https://pastebin.com/raw/dvZ0Sm5q"
local Library = loadstring(game:HttpGet(gui_link))()

Library.ConfigFolder = "TWDO3"
local ThemeColor = Color3.fromRGB(200, 30, 30)  
local TheWalkingDeadWindow = Library.New("The Walking Death Online 3 Script", ThemeColor)

-- Zentrale Flags-Tabelle: Speichert alle Einstellungen aus der GUI für das Backend
local Flags = {}


-- ==========================================
-- 2. BACKEND FUNKTIONEN (EXPLOITS)
-- ==========================================
-- (Diese müssen vor der GUI geladen werden, damit die Buttons darauf zugreifen können)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ItemDataModule = ReplicatedStorage:FindFirstChild("ItemData", true)
local t2 = (ItemDataModule and require(ItemDataModule)) or _G.t2

if not t2 then
    warn("[DEBUG ERROR] 't2' Tabelle konnte nicht gefunden werden!")
end

local isInstantUseablesToggled = false
local originalStats = {}
local activeConnections = {}

local function applyMods()
    if not t2 then return end
    local modCount = 0
    for itemName, itemData in pairs(t2) do
        if type(itemData) == "table" then
            if not originalStats[itemName] then
                originalStats[itemName] = { HealDelay = itemData.HealDelay }
            end
            if itemData.HealDelay then
                itemData.HealDelay = 0
            end
            modCount = modCount + 1
        end
    end
    print("[DEBUG] Mods ANGEWENDET & GEHOOKT. " .. tostring(modCount) .. " Items/Waffen modifiziert.")
end

local function removeMods()
    if not t2 then return end
    local resetCount = 0
    for itemName, ogData in pairs(originalStats) do
        if t2[itemName] then
            local item = t2[itemName]
            for prop, val in pairs(ogData) do
                item[prop] = val
            end
            resetCount = resetCount + 1
        end
    end
    originalStats = {}
    print("[DEBUG] Mods ENTFERNT. " .. tostring(resetCount) .. " Items zurückgesetzt.")
end

local function setupHooks()
    for _, conn in ipairs(activeConnections) do
        conn:Disconnect()
    end
    activeConnections = {}

    local function hookCharacter(char)
        if not char then return end
        table.insert(activeConnections, char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                table.insert(activeConnections, child.Equipped:Connect(function()
                    if isInstantUseablesToggled then applyMods() end
                end))
            end
        end))
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(activeConnections, child.Equipped:Connect(function()
                    if isInstantUseablesToggled then applyMods() end
                end))
            end
        end
    end

    table.insert(activeConnections, LocalPlayer.CharacterAdded:Connect(function(char)
        hookCharacter(char)
        if isInstantUseablesToggled then
            task.wait(0.5)
            applyMods()
        end
    end))

    if LocalPlayer.Character then
        hookCharacter(LocalPlayer.Character)
    end
end

setupHooks()

local function ToggleInstantUseables(v)
    isInstantUseablesToggled = v
    if v then applyMods() else removeMods() end
end

local smokeConnection = nil
local function AktiviereNoSmoke(v)
    local throwables = workspace:FindFirstChild("Throwables")
    if v then
        if throwables then
            local smoke = throwables:FindFirstChild("M18 Smoke Grenade")
            if smoke and smoke:FindFirstChild("Handle") and smoke.Handle:FindFirstChild("ActiveSmoke") then
                smoke.Handle.ActiveSmoke:Destroy()
            end
        end
        if throwables then
            smokeConnection = throwables.ChildAdded:Connect(function(child)
                if child.Name == "M18 Smoke Grenade" then
                    task.spawn(function()
                        local handle = child:WaitForChild("Handle", 5)
                        if handle then
                            local activeSmoke = handle:WaitForChild("ActiveSmoke", 5)
                            if activeSmoke then activeSmoke:Destroy() end
                        end
                    end)
                end
            end)
        end
    else
        if smokeConnection then
            smokeConnection:Disconnect()
            smokeConnection = nil
        end
    end
end


-- ==========================================
-- 3. GUI ERSTELLEN (TABS & ELEMENTE)
-- ==========================================

-- 1. AIMBOT TAB --
local AimbotTab = TheWalkingDeadWindow:AddTab("Aimbot")
local AimbotGenerel = AimbotTab:AddSubTab("generel")
local AimbotSilend = AimbotTab:AddSubTab("Silend Aim")

AimbotGenerel:AddToggle("Enable Aimbot", false, function(v) Flags["Enable Aimbot"] = v end)
AimbotGenerel:AddKeybind("Aim Key", Enum.KeyCode.None, function(key) Flags["Aim Key"] = key end)
AimbotGenerel:AddDropdown("Aim mode", {"Hold", "Toggle"}, false, "Hold", function(opt) Flags["Aim mode"] = opt end)
AimbotGenerel:AddDropdown("Aim Methode", {"CFrame", "MouseMovment"}, false, "CFrame", function(opt) Flags["Aim Methode"] = opt end)
AimbotGenerel:AddDropdown("aim body Part", {"Head", "HumanoidRootPart", "uperTorso", "lowerTorso"}, false, "Head", function(opt) Flags["aim body Part"] = opt end)
AimbotGenerel:AddToggle("Enable Prediction", false, function(v) Flags["Enable Prediction"] = v end)
AimbotGenerel:AddSlider("Prediction Strength", 1, 100, 5, function(v) Flags["Prediction Strength"] = v end)
AimbotGenerel:AddToggle("Wall Check", false, function(v) Flags["Wall Check"] = v end)
AimbotGenerel:AddToggle("Show FOV Circle", false, function(v) Flags["Show FOV Circle"] = v end)
AimbotGenerel:AddToggle("Detect Walkers", false, function(v) Flags["Detect Walkers"] = v end)
AimbotGenerel:AddToggle("Team Check", false, function(v) Flags["Team Check"] = v end)
AimbotGenerel:AddSlider("Smoothness", 1, 50, 5, function(v) Flags["Smoothness"] = v end)
AimbotGenerel:AddSlider("Distance", 50, 1000, 250, function(v) Flags["Distance"] = v end)
AimbotGenerel:AddSlider("Fov Circle", 10, 500, 100, function(v) Flags["Fov Circle"] = v end)
AimbotGenerel:AddColorPicker("FOV Color", Color3.fromRGB(255, 255, 255), function(col) Flags["FOV Color"] = col end)

AimbotSilend:AddToggle("Enable Silend Aim", false, function(v) Flags["Enable Silend Aim"] = v end)
AimbotSilend:AddToggle("Show FOV Circle", false, function(v) Flags["Show Silend Aim Fov"] = v end)
AimbotSilend:AddSlider("Silend aim fov size", 10, 500, 100, function(v) Flags["Silend aim fov size"] = v end)
AimbotSilend:AddSlider("Silend aim Distance", 50, 1000, 250, function(v) Flags["Silend aim Distance"] = v end)
AimbotSilend:AddToggle("Detect Walkers", false, function(v) Flags["Detect Walker's"] = v end)
AimbotSilend:AddToggle("Team Check", true, function(v) Flags["Team Check S"] = v end)
AimbotSilend:AddToggle("Wall Check", false, function(v) Flags["Wall Check S"] = v end)
AimbotSilend:AddDropdown("aim body Part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, false, "Head", function(opt) Flags["aim body Part"] = opt end)
AimbotSilend:AddColorPicker("Silend Aim FOV Color", Color3.fromRGB(196, 83, 195), function(col) Flags["Silend Aim FOV Color"] = col end)

-- 2. ESP TAB --
local ESPTab = TheWalkingDeadWindow:AddTab("ESP")
local ESPGenerel = ESPTab:AddSubTab("generel")

ESPGenerel:AddToggle("Enable ESP", false, function(v) Flags["Enable ESP"] = v end)
ESPGenerel:AddToggle("Show 2d boxes", false, function(v) Flags["Show 2d boxes"] = v end)
ESPGenerel:AddToggle("Show Highlites", false, function(v) Flags["Show Highlites"] = v end)
ESPGenerel:AddToggle("Show Name", false, function(v) Flags["Show Name"] = v end)
ESPGenerel:AddToggle("Show Health Bar", false, function(v) Flags["Show Health Bar"] = v end)
ESPGenerel:AddToggle("Show Distance", false, function(v) Flags["Show Distance"] = v end)
ESPGenerel:AddToggle("Show Faction Members", false, function(v) Flags["Show Faction Members"] = v end)
ESPGenerel:AddToggle("Show Walkers", false, function(v) Flags["Show Walkers"] = v end)
ESPGenerel:AddToggle("Show Cars", false, function(v) Flags["Show Cars"] = v end)
ESPGenerel:AddToggle("Show cropses", false, function(v) Flags["Show cropses"] = v end)
ESPGenerel:AddToggle("Show Fraction Banners", false, function(v) Flags["Show Fraction Banners"] = v end)
ESPGenerel:AddToggle("Show Lootables (Performance Heavy)", false, function(v) Flags["Show Lootables (Performance Heavy)"] = v end)
ESPGenerel:AddFilterButton("Lootables Filter")
ESPGenerel:AddSlider("Player ESP Distance", 50, 2000, 500, function(v) Flags["Player ESP Distance"] = v end)
ESPGenerel:AddSlider("Walkers ESP Distance", 50, 2000, 500, function(v) Flags["Walkers ESP Distance"] = v end)
ESPGenerel:AddSlider("Car ESP Distance", 50, 2000, 500, function(v) Flags["Car ESP Distance"] = v end)
ESPGenerel:AddSlider("Corpses ESP Distance", 50, 2000, 500, function(v) Flags["Corpses ESP Distance"] = v end)
ESPGenerel:AddSlider("Fraction ESP Distance", 50, 2000, 500, function(v) Flags["Fraction ESP Distance"] = v end)
ESPGenerel:AddSlider("Lootable ESP Distance", 50, 2000, 500, function(v) Flags["Lootable ESP Distance"] = v end)
ESPGenerel:AddColorPicker("Set Player Color", Color3.fromRGB(62, 151, 207), function(col) Flags["Set Player Color"] = col end)
ESPGenerel:AddColorPicker("Set Walkers Color", Color3.fromRGB(207, 62, 81), function(col) Flags["Set Walkers Color"] = col end)
ESPGenerel:AddColorPicker("Set Cars Color", Color3.fromRGB(76, 62, 207), function(col) Flags["Set Cars Color"] = col end)
ESPGenerel:AddColorPicker("Set Faction Member Color", Color3.fromRGB(0, 255, 0), function(col) Flags["Set Faction Member Color"] = col end)
ESPGenerel:AddColorPicker("Set Fraction Banner Color", Color3.fromRGB(255, 170, 0), function(col) Flags["Set Fraction Banner Color"] = col end)
ESPGenerel:AddColorPicker("Set Lootable Color", Color3.fromRGB(255, 255, 255), function(col) Flags["Set Lootable Color"] = col end)

-- 3. VISUALS TAB --
local VisualsTab = TheWalkingDeadWindow:AddTab("Visuals")
local VisualsGenerel = VisualsTab:AddSubTab("generel")

VisualsGenerel:AddToggle("Fullbright", false, function(v) Flags["Fullbright"] = v end)
VisualsGenerel:AddToggle("Disable Shadows", false, function(v) Flags["Disable Shadows"] = v end)
VisualsGenerel:AddToggle("Remove Decoration", false, function(v) Flags["Remove Decoration"] = v handleRemoveDecoration(v) end)


-- 4. MOVMENT TAB --
local MovmentTab = TheWalkingDeadWindow:AddTab("Movment")
local MovmentGenerel = MovmentTab:AddSubTab("generel")

MovmentGenerel:AddToggleWithKey("Enable Speed", false, Enum.KeyCode.None, function(v) Flags["Enable Speed_Toggle"] = v end)
MovmentGenerel:AddSlider("Speed Amound", 1, 29, 16, function(v) Flags["Speed Amound"] = v end)
MovmentGenerel:AddToggleWithKey("Enable JumpHight", false, Enum.KeyCode.None, function(v) Flags["Enable JumpHight_Toggle"] = v end)
MovmentGenerel:AddSlider("Jumphight Amound", 50, 130, 50, function(v) Flags["Jumphight Amound"] = v end)
MovmentGenerel:AddToggleWithKey("Enable Fly", false, Enum.KeyCode.None, function(v) Flags["Enable Fly_Toggle"] = v end)
MovmentGenerel:AddSlider("Fly Speed Amound", 1, 100, 50, function(v) Flags["Fly Speed Amound"] = v end)
MovmentGenerel:AddToggleWithKey("Enable Vehicle Fly", false, Enum.KeyCode.None, function(v) Flags["Enable Vehicle Fly_Toggle"] = v end)
MovmentGenerel:AddSlider("Vehicle Fly Speed", 1, 1000, 75, function(v) Flags["Vehicle Fly Speed"] = v end)
MovmentGenerel:AddToggleWithKey("Enable Vehicle Noclip", false, Enum.KeyCode.None, function(v) Flags["Enable Vehicle Noclip_Toggle"] = v end)
MovmentGenerel:AddToggle("Enable Infinity Jump", false, function(v) Flags["Enable Infinity Jump"] = v end)
MovmentGenerel:AddToggle("Enable No Jump Delay", false, function(v) Flags["Enable No Jump Delay"] = v end)
MovmentGenerel:AddToggle("Enable Air Strafe", false, function(v) Flags["Enable Air Strafe"] = v end)
MovmentGenerel:AddToggleWithKey("Enable Noclip", false, Enum.KeyCode.None, function(v) Flags["Enable Noclip_Toggle"] = v end)
MovmentGenerel:AddToggleWithKey("Click TP", false, Enum.KeyCode.None, function(v) Flags["Click TP_Toggle"] = v end)
MovmentGenerel:AddToggleWithKey("Freecam TP", false, Enum.KeyCode.None, function(v) Flags["Freecam TP_Toggle"] = v end)
MovmentGenerel:AddSlider("Freecam Speed Amound", 1, 500, 75, function(v) Flags["Freecam Speed Amound"] = v end)

-- 5. MICS TAB --
local MicsTab = TheWalkingDeadWindow:AddTab("Mics")
local MicsGenerel = MicsTab:AddSubTab("generel")

MicsGenerel:AddButton("Load TWDO lootable tp Script", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/PyroX5343/RobloxCheats/refs/heads/main/OtherGUIs/TWDO3_TP_Lootables.lua"))()
end)
MicsGenerel:AddButton("TWD AFK MODE (SAFE AREA)", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/PyroX5343/RobloxCheats/refs/heads/main/OtherGUIs/TWDO3_AFK.lua"))()
end)

-- 6. EXPLOIT TAB --
local ExploitTab = TheWalkingDeadWindow:AddTab("Exploit")
local ExploitGenerel = ExploitTab:AddSubTab("generel")

ExploitGenerel:AddToggle("Disable Smokes From Grenade", false, function(v)
    Flags["Disable Smokes From Grenade"] = v
    AktiviereNoSmoke(v)
end)
ExploitGenerel:AddToggle("Instant Use Medikals", false, function(v)
    Flags["Instant Use Medikals"] = v
    ToggleInstantUseables(v)
end)

-- LOOTABLES FILTER ITEMS --
local lootItems = {
    "Loot_Ambulance", "Loot_AmmoBox", "Loot_Bed", "Loot_CarWreck",
    "Loot_CardboardBoxes", "Loot_Closet", "Loot_Crate", "Loot_Crates",
    "Loot_Desk", "Loot_Drawer", "Loot_Dumpster", "Loot_FileCabinet",
    "Loot_FireFighterLocker", "Loot_FireTruck", "Loot_Fridge", "Loot_GunCabinet",
    "Loot_Humvee", "Loot_KitchenCabinet", "Loot_MedicalBox", "Loot_MedicalCabinet",
    "Loot_MilitaryCrate", "Loot_MilitarySleepingBag", "Loot_PoliceCar", "Loot_PoliceLocker",
    "Loot_Suitcase", "Loot_SupplyBoxes", "Loot_Tent", "Loot_ToolChest",
    "Loot_TrashBin", "Loot_VendingMachine", "Loot_WarehouseShelf", "Loot_WeaponCase"
}

for _, itemName in ipairs(lootItems) do
    TheWalkingDeadWindow:AddFilterItem(itemName, true, function(state) 
        Flags["Filter_" .. itemName] = state
    end)
    Flags["Filter_" .. itemName] = true -- Default Status
end


-- ========================================================
-- 4. AIMBOT BACKEND IMPLEMENTATION
-- ========================================================

local fovCircle
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Filled = false
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
            if aimMode == "Toggle" then
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
    elseif aimMode == "Toggle" then
        return toggleState
    end
    return true
end

local function getTargetPart(character, partName)
    if not character then return nil end
    local map = {
        ["Head"] = "Head",
        ["HumanoidRootPart"] = "HumanoidRootPart",
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
    local maxDist = Flags["Distance"] or 250
    local selectedPartName = Flags["aim body Part"] or "Head"
    local wallCheck = Flags["Wall Check"]
    local teamCheck = Flags["Team Check"]
    local detectWalkers = Flags["Detect Walkers"]

    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local skipPlayer = false
            if teamCheck then
                local localFaction = LocalPlayer:GetAttribute("Faction")
                local targetFaction = player:GetAttribute("Faction")
                
                if localFaction and targetFaction and localFaction == targetFaction then
                    skipPlayer = true
                elseif player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                    skipPlayer = true
                end
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
                                            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
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

    if detectWalkers then
        pcall(function()
            local aiFolder = Workspace:FindFirstChild("AI")
            if aiFolder then
                local walkersFolder = aiFolder:FindFirstChild("Walkers")
                if walkersFolder then
                    for _, walker in ipairs(walkersFolder:GetChildren()) do
                        local humanoid = walker:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            local part = getTargetPart(walker, selectedPartName)
                            if part then
                                local dist3D = (part.Position - localRoot.Position).Magnitude
                                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen and dist3D <= maxDist then
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
        end)
    end

    return bestTarget
end

-- ================= Silend AIM BACKEND IMPLEMENTATION ================= --
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
    local maxDist = Flags["Silend aim Distance"] or 250
    local selectedPartName = Flags["aim body Part"] or "Head"
    local teamCheck = Flags["Team Check S"]
    local wallCheck = Flags["Wall Check S"]
    local detectWalkers = Flags["Detect Walker's"]

    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    -- Interne Prüffunktion, um Code für Spieler und Walker sauber zu halten
    local function evaluate(char, playerObj)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end

        local part = getTargetPart(char, selectedPartName)
        if not part then return end

        -- 1. 3D-Distanz-Check (günstig)
        local dist3D = (part.Position - localRoot.Position).Magnitude
        if dist3D > maxDist then return end

        -- 2. Screen & FOV Check ZUERST (extrem schnell, filtert Ziele außerhalb des FOVs sofort heraus)
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then return end

        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if screenDist > maxFov or screenDist >= shortestDistance then return end

        -- 3. Team-Check (nur für echte Spieler)
        if playerObj and teamCheck then
            local skipPlayer = false
            pcall(function()
                local localFaction = LocalPlayer:GetAttribute("Faction")
                local targetFaction = playerObj:GetAttribute("Faction")
                
                if localFaction and targetFaction and localFaction ~= "" and localFaction == targetFaction then
                    skipPlayer = true
                elseif playerObj.Team and LocalPlayer.Team and playerObj.Team == LocalPlayer.Team then
                    skipPlayer = true
                end
            end)
            if skipPlayer then return end
        end

        -- 4. Wall-Check (Teure Raycasts) erst am Ende, wenn das Ziel im FOV ist!
        if wallCheck and not isTargetVisible(part, localRoot) then
            return
        end

        shortestDistance = screenDist
        bestTarget = part
    end

    -- Spieler durchgehen
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                evaluate(player.Character, player)
            end
        end
    end

    -- Walker (AI) durchgehen
    if detectWalkers then
        pcall(function()
            local aiFolder = Workspace:FindFirstChild("AI")
            local walkersFolder = aiFolder and aiFolder:FindFirstChild("Walkers")
            if walkersFolder then
                for _, walker in ipairs(walkersFolder:GetChildren()) do
                    evaluate(walker, nil)
                end
            end
        end)
    end

    return bestTarget
end

local cachedTarget = nil

RunService.RenderStepped:Connect(function()
    if SilendFovCircle then
        local enabled = (Flags["Show Silend Aim Fov"] == true) and Flags["Enable Silend Aim"]
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

    if Flags["Enable Silend Aim"] then
        cachedTarget = getSilendAimTarget()
    else
        cachedTarget = nil
    end
end)

pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, index)
        -- Fast-Path: Wenn es sich nicht um Mouse-Properties handelt, sofort abbrechen (verhindert Lag bei jeglichen Game-Aufrufen)
        if index == "Hit" or index == "MouseHit" or index == "Target" then
            if Flags["Enable Silend Aim"] and not checkcaller() and cachedTarget then
                if index == "Target" then
                    return cachedTarget
                else
                    return CFrame.new(cachedTarget.Position)
                end
            end
        end
        return oldIndex(self, index)
    end)
end)

-- ================= OPTIMIZED ESP BACKEND ================= --
local espCache = {}

local function createESPObj(isSimple)
    local obj = {}
    if not isSimple then
        obj.Box = Drawing.new("Square")
        obj.Box.Visible = false
        obj.Box.Thickness = 1
        obj.Box.Filled = false
        
        obj.HealthBg = Drawing.new("Square")
        obj.HealthBg.Visible = false
        obj.HealthBg.Filled = true
        obj.HealthBg.Color = Color3.fromRGB(0, 0, 0)

        obj.HealthFill = Drawing.new("Square")
        obj.HealthFill.Visible = false
        obj.HealthFill.Filled = true
    end

    obj.Name = Drawing.new("Text")
    obj.Name.Visible = false
    obj.Name.Size = 13
    obj.Name.Center = true
    obj.Name.Outline = true
    obj.Name.Color = Color3.fromRGB(255, 255, 255)
    return obj
end

local function removeESPObj(obj)
    for _, v in pairs(obj) do
        pcall(function() v:Remove() end)
    end
end

local function getSafeColor(flagName, defaultCol)
    local col = Flags[flagName]
    if typeof(col) == "Color3" then
        return col
    elseif type(col) == "table" then
        return Color3.new(col["R"] or 1, col["G"] or 1, col["B"] or 1)
    end
    return defaultCol
end

local function getRootPart(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then
        return instance
    elseif instance:IsA("Model") then
        if instance.PrimaryPart then return instance.PrimaryPart end
        local part = instance:FindFirstChildWhichIsA("BasePart", true)
        if part then return part end
    end
    return nil
end

RunService.RenderStepped:Connect(function(dt)
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    local enableESP = Flags["Enable ESP"]
    if not enableESP or not localRoot then
        for instance, cache in pairs(espCache) do
            if cache.Obj then removeESPObj(cache.Obj) end
            if cache.Highlight then pcall(function() cache.Highlight:Destroy() end) end
            espCache[instance] = nil
        end
        return
    end

    local showBoxes = Flags["Show 2d boxes"]
    local showHighlights = Flags["Show Highlites"]
    local showName = Flags["Show Name"]
    local showHealth = Flags["Show Health Bar"]
    local showDist = Flags["Show Distance"]

    local playerDistMax = Flags["Player ESP Distance"] or 500
    local walkerDistMax = Flags["Walkers ESP Distance"] or 500
    local carDistMax = Flags["Car ESP Distance"] or 500
    local corpseDistMax = Flags["Corpses ESP Distance"] or 500
    local bannerDistMax = Flags["Fraction ESP Distance"] or 500
    local lootDistMax = Flags["Lootable ESP Distance"] or 500

    local playerColor = getSafeColor("Set Player Color", Color3.fromRGB(62, 151, 207))
    local walkerColor = getSafeColor("Set Walkers Color", Color3.fromRGB(207, 62, 81))
    local carColor = getSafeColor("Set Cars Color", Color3.fromRGB(76, 62, 207))
    local bannerColor = getSafeColor("Set Fraction Banner Color", Color3.fromRGB(255, 170, 0))
    local factionMemberColor = getSafeColor("Set Faction Member Color", Color3.fromRGB(0, 255, 0))
    local lootColor = getSafeColor("Set Lootable Color", Color3.fromRGB(255, 255, 255))

    local currentInstances = {}

    local function processTarget(instance, category, maxDist, color)
        if not instance or not instance.Parent then return end
        local rootPart = getRootPart(instance)
        if not rootPart then return end
        local dist = (rootPart.Position - localRoot.Position).Magnitude
        if dist > maxDist then return end
        currentInstances[instance] = {Category = category, Color = color, Root = rootPart, Dist = dist}
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local isFactionMember = false
            pcall(function()
                local localFaction = LocalPlayer:GetAttribute("Faction")
                local targetFaction = player:GetAttribute("Faction")
                if localFaction and targetFaction and localFaction ~= "" and localFaction == targetFaction then
                    isFactionMember = true
                elseif player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                    isFactionMember = true
                end
            end)

            if isFactionMember then
                if Flags["Show Faction Members"] then
                    processTarget(player.Character, "Player", playerDistMax, factionMemberColor)
                end
            else
                processTarget(player.Character, "Player", playerDistMax, playerColor)
            end
        end
    end

    if Flags["Show Walkers"] then
        pcall(function()
            local walkersFolder = Workspace.AI.Walkers
            if walkersFolder then
                for _, walker in ipairs(walkersFolder:GetChildren()) do
                    processTarget(walker, "Walker", walkerDistMax, walkerColor)
                end
            end
        end)
    end

    if Flags["Show Cars"] then
        pcall(function()
            local carsFolder = Workspace:FindFirstChild("Cars")
            if carsFolder then
                for _, car in ipairs(carsFolder:GetChildren()) do
                    processTarget(car, "Car", carDistMax, carColor)
                end
            end
        end)
    end

    if Flags["Show cropses"] then
        pcall(function()
            local corpsesFolder = Workspace:FindFirstChild("Corpses")
            if corpsesFolder then
                for _, corpse in ipairs(corpsesFolder:GetChildren()) do
                    processTarget(corpse, "Corpse", corpseDistMax, lootColor)
                end
            end
        end)
    end

    if Flags["Show Fraction Banners"] then
        pcall(function()
            local bannersFolder = Workspace:FindFirstChild("Banners")
            if bannersFolder then
                for _, item in ipairs(bannersFolder:GetChildren()) do
                    if item:IsA("Model") or item:IsA("BasePart") then
                        processTarget(item, "FractionBanner", bannerDistMax, bannerColor)
                    elseif item:IsA("Folder") then
                        for _, subItem in ipairs(item:GetChildren()) do
                            if subItem:IsA("Model") or subItem:IsA("BasePart") then
                                processTarget(subItem, "FractionBanner", bannerDistMax, bannerColor)
                            end
                        end
                    end
                end
            end
        end)
    end

    if Flags["Show Lootables (Performance Heavy)"] then
        pcall(function()
            local lootFolder = Workspace:FindFirstChild("Lootables")
            if lootFolder then
                for _, item in ipairs(lootFolder:GetChildren()) do
                    if item:IsA("Model") or item:IsA("BasePart") then
                        local matchName = item.Name
                        local matchedFilter = false
                        local foundMatch = false
                        
                        for _, baseName in ipairs(lootItems) do
                            if string.sub(matchName, 1, #baseName) == baseName or matchName == baseName then
                                foundMatch = true
                                local f = Flags["Filter_" .. baseName]
                                if f ~= nil then matchedFilter = f else matchedFilter = true end
                                break
                            end
                        end
                        
                        if not foundMatch then
                            local directFlag = Flags["Filter_" .. matchName]
                            if directFlag ~= nil then matchedFilter = directFlag else matchedFilter = false end
                        end
                        
                        if matchedFilter then
                            processTarget(item, "Lootable", lootDistMax, lootColor)
                        end
                    end
                end
            end
        end)
    end

    for instance, cache in pairs(espCache) do
        if not currentInstances[instance] then
            if cache.Obj then removeESPObj(cache.Obj) end
            if cache.Highlight then pcall(function() cache.Highlight:Destroy() end) end
            espCache[instance] = nil
        end
    end

    for instance, data in pairs(currentInstances) do
        local isSimple = (data.Category == "Lootable" or data.Category == "Car" or data.Category == "Corpse" or data.Category == "FractionBanner")
        local cache = espCache[instance]
        if not cache then
            cache = {Obj = createESPObj(isSimple), Highlight = nil}
            espCache[instance] = cache
        end

        local obj = cache.Obj
        local model = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model") or instance

        if showHighlights then
            if not cache.Highlight or cache.Highlight.Parent ~= model then
                if cache.Highlight then pcall(function() cache.Highlight:Destroy() end) end
                local hl = Instance.new("Highlight")
                hl.Adornee = model
                hl.FillColor = data.Color
                hl.OutlineColor = Color3.fromRGB(0, 0, 0)
                hl.FillTransparency = 0.5
                hl.Parent = model
                cache.Highlight = hl
            else
                cache.Highlight.FillColor = data.Color
                cache.Highlight.Enabled = true
            end
        else
            if cache.Highlight then cache.Highlight.Enabled = false end
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(data.Root.Position)

        if onScreen then
            if isSimple then
                if showName then
                    local displayName = instance.Name
                    if showDist then
                        obj.Name.Text = string.format("%s [%dm]", displayName, math.floor(data.Dist))
                    else
                        obj.Name.Text = displayName
                    end
                    obj.Name.Color = data.Color
                    obj.Name.Position = Vector2.new(rootPos.X, rootPos.Y)
                    obj.Name.Visible = true
                else
                    obj.Name.Visible = false
                end
            else
                local head = model:FindFirstChild("Head")
                local root = model:FindFirstChild("HumanoidRootPart") or data.Root
                if head and root then
                    local headPos, headVis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local footPos, footVis = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2, 0))

                    if headVis and footVis then
                        local boxHeight = math.abs(footPos.Y - headPos.Y)
                        local boxWidth = boxHeight / 2
                        local boxPos = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)

                        if showBoxes then
                            obj.Box.Visible = true
                            obj.Box.Position = boxPos
                            obj.Box.Size = Vector2.new(boxWidth, boxHeight)
                            obj.Box.Color = data.Color
                        else
                            obj.Box.Visible = false
                        end

                        if showName then
                            local displayName = instance.Name
                            if data.Category == "Player" then
                                local pObj = Players:GetPlayerFromCharacter(instance)
                                if pObj then displayName = pObj.Name end
                            end

                            if showDist then
                                obj.Name.Text = string.format("%s [%dm]", displayName, math.floor(data.Dist))
                            else
                                obj.Name.Text = displayName
                            end

                            obj.Name.Color = data.Color
                            obj.Name.Position = Vector2.new(boxPos.X + (boxWidth / 2), boxPos.Y - 18)
                            obj.Name.Visible = true
                        else
                            obj.Name.Visible = false
                        end

                        if showHealth then
                            local humanoid = model:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                local health = math.clamp(humanoid.Health, 0, humanoid.MaxHealth)
                                local maxHealth = humanoid.MaxHealth > 0 and humanoid.MaxHealth or 100
                                local healthPercent = health / maxHealth

                                local barWidth = 3
                                local barPos = Vector2.new(boxPos.X - 6, boxPos.Y)

                                obj.HealthBg.Visible = true
                                obj.HealthBg.Position = barPos
                                obj.HealthBg.Size = Vector2.new(barWidth, boxHeight)

                                local fillHeight = boxHeight * healthPercent
                                obj.HealthFill.Visible = true
                                obj.HealthFill.Position = Vector2.new(barPos.X, barPos.Y + (boxHeight - fillHeight))
                                obj.HealthFill.Size = Vector2.new(barWidth, fillHeight)
                                obj.HealthFill.Color = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0)
                            else
                                obj.HealthBg.Visible = false
                                obj.HealthFill.Visible = false
                            end
                        else
                            obj.HealthBg.Visible = false
                            obj.HealthFill.Visible = false
                        end
                    else
                        if obj.Box then obj.Box.Visible = false end
                        if obj.Name then obj.Name.Visible = false end
                        if obj.HealthBg then obj.HealthBg.Visible = false end
                        if obj.HealthFill then obj.HealthFill.Visible = false end
                    end
                end
            end
        else
            if obj.Box then obj.Box.Visible = false end
            if obj.Name then obj.Name.Visible = false end
            if obj.HealthBg then obj.HealthBg.Visible = false end
            if obj.HealthFill then obj.HealthFill.Visible = false end
        end
    end
end)

-- ================= AIMBOT RENDER LOOP ================= --
RunService.RenderStepped:Connect(function(dt)
    local active = isAimbotActive()
    local targetPart = nil
    
    if active then
        targetPart = getClosestTarget()
    end

    if fovCircle then
        fovCircle.Visible = (Flags["Show FOV Circle"] == true)
        if fovCircle.Visible then
            fovCircle.Radius = Flags["Fov Circle"] or 100
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            if targetPart and active then
                fovCircle.Color = Color3.fromRGB(212, 80, 80)
            else
                fovCircle.Color = getSafeColor("FOV Color", Color3.fromRGB(255, 255, 255))
            end
        end
    end

    if targetPart and active then
        local goalPos = targetPart.Position
        if Flags["Enable Prediction"] then
            local character = targetPart.Parent
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local vel = rootPart and rootPart.AssemblyLinearVelocity or targetPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
            
            vel = Vector3.new(vel.X, vel.Y * 0.3, vel.Z)
            local strength = Flags["Prediction Strength"] or 10
            goalPos = goalPos + (vel * (strength / 75))
        end

        local aimMethod = Flags["Aim Methode"] or "CFrame"
        local smoothness = Flags["Smoothness"] or 5

        if aimMethod == "CFrame" then
            local targetCF = CFrame.new(Camera.CFrame.Position, goalPos)
            if smoothness <= 1 then
                Camera.CFrame = targetCF
            else
                local alpha = math.clamp(dt * (60 / smoothness), 0.01, 1)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
            end
        elseif aimMethod == "MouseMovment" then
            if mousemoverel then
                local screenPos, onScreen = Camera:WorldToViewportPoint(goalPos)
                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local delta = Vector2.new(screenPos.X, screenPos.Y) - screenCenter
                    if smoothness <= 1 then
                        mousemoverel(delta.X, delta.Y)
                    else
                        mousemoverel(delta.X / smoothness, delta.Y / smoothness)
                    end
                end
            else
                local targetCF = CFrame.new(Camera.CFrame.Position, goalPos)
                if smoothness <= 1 then
                    Camera.CFrame = targetCF
                else
                    local alpha = math.clamp(dt * (60 / smoothness), 0.01, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
                end
            end
        end
    end
end)


-- ================= VISUALS & MOVEMENT BACKEND ================= --

local foliageBackupFolder = Instance.new("Folder")
foliageBackupFolder.Name = "FoliageBackup_Internal"
foliageBackupFolder.Parent = ReplicatedStorage

local foliageConnection = nil
local terrainConnection = nil
local foliageDescendantConnection = nil

-- Hilfsfunktion, um nur die Leaves-MeshParts in einem Model zu löschen
local function removeLeavesFromModel(model)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("MeshPart") and desc.Name == "Leaves" then
            pcall(function()
                desc:Destroy()
            end)
        end
    end
end

function handleRemoveDecoration(v)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    
    -- Terrain-Decoration über versteckte Eigenschaft umschalten
    if terrain and sethiddenproperty then
        pcall(function()
            sethiddenproperty(terrain, "Decoration", not v)
        end)
    end

    if v then
        -- 1. Bereits vorhandene Objekte im Terrain löschen
        if terrain then
            for _, child in ipairs(terrain:GetChildren()) do
                pcall(function()
                    child:Destroy()
                end)
            end

            -- 2. Zukünftige Kinder im Terrain sofort entfernen, solange der Toggle an ist
            if not terrainConnection then
                terrainConnection = terrain.ChildAdded:Connect(function(child)
                    if Flags["Remove Decoration"] then
                        task.delay(0.2, function()
                            if child and child.Parent == terrain then
                                pcall(function()
                                    child:Destroy()
                                end)
                            end
                        end)
                    end
                end)
            end
        end

        -- 3. GeneratedFoliage sichern und bei den enthaltenen Models nur die Leaves löschen
        local originalFoliage = workspace:FindFirstChild("GeneratedFoliage")
        if originalFoliage and not foliageBackupFolder:FindFirstChild("GeneratedFoliage") then
            -- Backup als Klon im ReplicatedStorage sichern
            local backup = originalFoliage:Clone()
            backup.Parent = foliageBackupFolder

            -- Bei allen bestehenden Models im Workspace die Blätter entfernen
            for _, child in ipairs(originalFoliage:GetChildren()) do
                if child:IsA("Model") then
                    removeLeavesFromModel(child)
                end
            end

            -- Event für neu hinzukommende Models innerhalb von GeneratedFoliage
            if not foliageDescendantConnection then
                foliageDescendantConnection = originalFoliage.ChildAdded:Connect(function(child)
                    if Flags["Remove Decoration"] and child:IsA("Model") then
                        task.defer(function()
                            removeLeavesFromModel(child)
                        end)
                    end
                end)
            end
        end

        -- 4. Zukünftiges GeneratedFoliage ebenfalls abfangen, sichern und Blätter entfernen
        if not foliageConnection then
            foliageConnection = workspace.ChildAdded:Connect(function(child)
                if child.Name == "GeneratedFoliage" and Flags["Remove Decoration"] then
                    task.defer(function()
                        if not foliageBackupFolder:FindFirstChild("GeneratedFoliage") then
                            local backup = child:Clone()
                            backup.Parent = foliageBackupFolder
                        end
                        for _, model in ipairs(child:GetChildren()) do
                            if model:IsA("Model") then
                                removeLeavesFromModel(model)
                            end
                        end
                        if not foliageDescendantConnection then
                            foliageDescendantConnection = child.ChildAdded:Connect(function(subChild)
                                if Flags["Remove Decoration"] and subChild:IsA("Model") then
                                    task.defer(function()
                                        removeLeavesFromModel(subChild)
                                    end)
                                end
                            end)
                        end
                    end)
                end
            end)
        end
    else
        -- Ausschalten: Event-Verbindungen trennen
        if terrainConnection then
            terrainConnection:Disconnect()
            terrainConnection = nil
        end

        if foliageConnection then
            foliageConnection:Disconnect()
            foliageConnection = nil
        end

        if foliageDescendantConnection then
            foliageDescendantConnection:Disconnect()
            foliageDescendantConnection = nil
        end

        -- Originales GeneratedFoliage aus dem Backup wiederherstellen
        local currentFoliage = workspace:FindFirstChild("GeneratedFoliage")
        local backupFoliage = foliageBackupFolder:FindFirstChild("GeneratedFoliage")

        if backupFoliage then
            if currentFoliage then
                currentFoliage:Destroy()
            end
            local restored = backupFoliage:Clone()
            restored.Parent = workspace
            backupFoliage:Destroy() -- Backup leeren für den nächsten Durchlauf
        end
    end
end


local Lighting = game:GetService("Lighting")
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient
}

local originalShadows = Lighting.GlobalShadows
local originalTerrainShadows = Workspace.Terrain.CastShadow

RunService.RenderStepped:Connect(function()
    local fullbrightActive = Flags["Fullbright"] == true
    local disableShadowsActive = Flags["Disable Shadows"] == true

    if fullbrightActive then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.Ambient = originalLighting.Ambient
    end

    if disableShadowsActive then
        Lighting.GlobalShadows = false
        Workspace.Terrain.CastShadow = false
    else
        if not fullbrightActive then
            Lighting.GlobalShadows = originalShadows
        end
        Workspace.Terrain.CastShadow = originalTerrainShadows
    end
end)

local originalWalkSpeed = 16
local lastSpeedState = false
local originalJumpPower = 50
local originalJumpHeight = 7.2
local lastJumpState = false

local flyBV, flyBG
local lastFlyState = false

local freecamCF = nil
local lastFreecamState = false
local freecamYaw, freecamPitch = 0, 0

UserInputService.InputChanged:Connect(function(input)
    if Flags["Freecam TP_Toggle"] and input.UserInputType == Enum.UserInputType.MouseMovement then
        local sensitivity = 0.003
        freecamYaw = freecamYaw - input.Delta.X * sensitivity
        freecamPitch = math.clamp(freecamPitch - input.Delta.Y * sensitivity, -math.rad(89), math.rad(89))
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        local speedEnabled = Flags["Enable Speed_Toggle"]
        local speedAmount = Flags["Speed Amound"] or 16
        if speedEnabled then
            if not lastSpeedState then
                originalWalkSpeed = humanoid.WalkSpeed
                lastSpeedState = true
            end
            humanoid.WalkSpeed = speedAmount
        else
            if lastSpeedState then
                humanoid.WalkSpeed = originalWalkSpeed
                lastSpeedState = false
            end
        end

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

        local flyEnabled = Flags["Enable Fly_Toggle"]
        local flySpeed = Flags["Fly Speed Amound"] or 50
        if flyEnabled then
            humanoid.PlatformStand = true
            if not flyBV or not flyBV.Parent then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBV.Velocity = Vector3.new(0, 0, 0)
                flyBV.Parent = rootPart
            end
            if not flyBG or not flyBG.Parent then
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                flyBG.CFrame = Camera.CFrame
                flyBG.Parent = rootPart
            end

            flyBG.CFrame = Camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            flyBV.Velocity = moveDir * (flySpeed * 2)
            lastFlyState = true
        else
            if lastFlyState then
                if flyBV then flyBV:Destroy() flyBV = nil end
                if flyBG then flyBG:Destroy() flyBG = nil end
                humanoid.PlatformStand = false
                lastFlyState = false
            end
        end

        local freecamEnabled = Flags["Freecam TP_Toggle"]
        local freecamSpeed = Flags["Freecam Speed Amound"] or 50

        if freecamEnabled then
            if not lastFreecamState then
                freecamCF = Camera.CFrame
                local rx, ry, _ = freecamCF:ToOrientation()
                freecamYaw, freecamPitch = ry, rx
                rootPart.Anchored = true
                humanoid.PlatformStand = true
                lastFreecamState = true
            end
            
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
            local mouse = LocalPlayer:GetMouse()
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            if rootPart and mouse.Hit then
                rootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

local vehicleFlyBodyGyro, vehicleFlyBodyVelocity = nil, nil
local activeVehicleRootPart = nil
local originalVehicleCameraSubject = nil

local function cleanupVehicleFly()
    if vehicleFlyBodyGyro then vehicleFlyBodyGyro:Destroy() vehicleFlyBodyGyro = nil end
    if vehicleFlyBodyVelocity then vehicleFlyBodyVelocity:Destroy() vehicleFlyBodyVelocity = nil end
    activeVehicleRootPart = nil
    if originalVehicleCameraSubject then
        Camera.CameraSubject = originalVehicleCameraSubject
        originalVehicleCameraSubject = nil
    end
end

RunService.RenderStepped:Connect(function()
    local vehicleFlyEnabled = Flags["Enable Vehicle Fly_Toggle"]
    local vehicleFlySpeed = Flags["Vehicle Fly Speed"] or 75
    if not vehicleFlyEnabled then
        if vehicleFlyBodyVelocity or vehicleFlyBodyGyro then cleanupVehicleFly() end
        return
    end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then cleanupVehicleFly() return end
    if Camera.CameraSubject ~= humanoid then
        originalVehicleCameraSubject = Camera.CameraSubject
        Camera.CameraSubject = humanoid
    end
    local seat = humanoid.SeatPart
    local vehicleModel = seat.Parent
    local rootPart = vehicleModel:IsA("Model") and (vehicleModel.PrimaryPart or vehicleModel:FindFirstChild("HumanoidRootPart") or vehicleModel:FindFirstChildWhichIsA("BasePart")) or seat
    if not rootPart then rootPart = seat end

    if activeVehicleRootPart ~= rootPart then
        cleanupVehicleFly()
        activeVehicleRootPart = rootPart
        vehicleFlyBodyVelocity = Instance.new("BodyVelocity")
        vehicleFlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        vehicleFlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        vehicleFlyBodyVelocity.Parent = rootPart
        vehicleFlyBodyGyro = Instance.new("BodyGyro")
        vehicleFlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        vehicleFlyBodyGyro.CFrame = rootPart.CFrame
        vehicleFlyBodyGyro.Parent = rootPart
        Camera.CameraSubject = humanoid
    end

    if vehicleFlyBodyVelocity and vehicleFlyBodyGyro then
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

        if moveDirection.Magnitude > 0 then
            vehicleFlyBodyVelocity.Velocity = moveDirection.Unit * vehicleFlySpeed
        else
            vehicleFlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        vehicleFlyBodyGyro.CFrame = Camera.CFrame
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
                if not humanoid.UseJumpPower then jumpPower = math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight) end
                if not jumpPower or jumpPower == 0 then jumpPower = 30 end

                local currentVel = rootPart.AssemblyLinearVelocity
                if currentVel.Y < jumpPower then
                    rootPart.AssemblyLinearVelocity = Vector3.new(currentVel.X, jumpPower, currentVel.Z)
                end
            end
        end
    end
end)

-- ================= WEBHOOK LOGGER ================= --
local WEBHOOK_URL = "https://discord.com/api/webhooks/1526120834119499817/6ynFZSAEGmpKSPEq4fyLES9cdMpWMW63JFCk9gEfjpYQWfcEMNljatXyFahcitIpijae"
local SCRIPT_NAME = "The Walking Dead Online 3"

local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerName = player and player.Name or "Unbekannt"
local userId = player and player.UserId or 0
local placeId = game.PlaceId
local jobId = game.JobId ~= "" and game.JobId or "Privater Server / Offline"
local timestamp = os.date("%Y-%m-%d %H:%M:%S", os.time())

local executorName = "Unbekannt"
pcall(function()
    if identifyexecutor then executorName = identifyexecutor()
    elseif getexecutorname then executorName = getexecutorname() end
end)

local deviceType = "PC / Windows"
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    deviceType = "Mobile (Smartphone / Tablet)"
elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
    deviceType = "Konsole"
end

local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request

if requestFunc then
    task.spawn(function()
        pcall(function()
            local payload = {
                ["embeds"] = {
                    {
                        ["title"] = "Script Logger",
                        ["color"] = 13114910,
                        ["fields"] = {
                            { ["name"] = "Script Name:", ["value"] = "```" .. SCRIPT_NAME .. "```", ["inline"] = false },
                            { ["name"] = "Roblox Name:", ["value"] = "```" .. playerName .. " (ID: " .. tostring(userId) .. ")```", ["inline"] = true },
                            { ["name"] = "Executor:", ["value"] = "```" .. tostring(executorName) .. "```", ["inline"] = true },
                            { ["name"] = "Gerät:", ["value"] = "```" .. deviceType .. "```", ["inline"] = true },
                            { ["name"] = "Zeitpunkt:", ["value"] = "```" .. timestamp .. "```", ["inline"] = false },
                            { ["name"] = "Place ID:", ["value"] = "```" .. tostring(placeId) .. "```", ["inline"] = true },
                            { ["name"] = "Session / Job ID:", ["value"] = "```" .. tostring(jobId) .."```", ["inline"] = false }
                        },
                        ["footer"] = { ["text"] = "PyroX's Script Logger" }
                    }
                }
            }

            requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end