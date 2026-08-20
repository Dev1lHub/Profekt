local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Altes GUI automatisch löschen, falls es bereits existiert
local existingGui = playerGui:FindFirstChild("LootTeleporterProGui")
if existingGui then
	existingGui:Destroy()
end

local MAX_DISTANCE_LIMIT = 3000
local CURRENT_DISTANCE = 500
local currentTab = "Loot" -- "Loot", "Corpses", "Deaths" oder "Locations"

local deathRecords = {} 

local CUSTOM_LOCATIONS = {
	{ name = "Bunker outside", pos = Vector3.new(5929, 262, -5716) },
	{ name = "Bunker room 1", pos = Vector3.new(5942, 101, -5698) },
	{ name = "Bunker room 2", pos = Vector3.new(5829, 97, -5868) },
	{ name = "PD outside", pos = Vector3.new(4867, 146, -1144) },
	{ name = "PD inside", pos = Vector3.new(4870, 124, -1151) },
	{ name = "Outpost outside", pos = Vector3.new(-1803, 314, 931) },
	{ name = "Outpost inside", pos = Vector3.new(-1812, 293, 918) },
	{ name = "Prison outside", pos = Vector3.new(5462, 169, -3017) },
	{ name = "Prison inside", pos = Vector3.new(5459, 140, -3023) },
	{ name = "Bigspot outside", pos = Vector3.new(1844, 273, 1521) },
	{ name = "Bigspot inside", pos = Vector3.new(1922, 260, 1542) },
	{ name = "P Storage Farmhouse", pos = Vector3.new(3104, 137, 5634) },
}
 
local DEFAULT_FILTER_SETTINGS = {
	["Loot_Ambulance"] = false,
	["Loot_AmmoBox"] = true,
	["Loot_Bed"] = false,
	["Loot_CarWreck"] = false,
	["Loot_CardboardBoxes"] = false,
	["Loot_Closet"] = false,
	["Loot_Crate"] = false,
	["Loot_Crates"] = false,
	["Loot_Desk"] = false,
	["Loot_Drawer"] = false,
	["Loot_Dumpster"] = false,
	["Loot_FileCabinet"] = false,
	["Loot_FireFighterLocker"] = false,
	["Loot_FireTruck"] = false,
	["Loot_Fridge"] = false,
	["Loot_GunCabinet"] = true,
	["Loot_Humvee"] = false,
	["Loot_KitchenCabinet"] = false,
	["Loot_MedicalBox"] = false,
	["Loot_MedicalCabinet"] = false,
	["Loot_MilitaryCrate"] = true,
	["Loot_MilitarySleepingBag"] = false,
	["Loot_PoliceCar"] = false,
	["Loot_PoliceLocker"] = false,
	["Loot_Suitcase"] = false,
	["Loot_SupplyBoxes"] = false,
	["Loot_Tent"] = false,
	["Loot_ToolChest"] = false,
	["Loot_TrashBin"] = false,
	["Loot_VendingMachine"] = false,
	["Loot_WarehouseShelf"] = false,
	["Loot_WeaponCase"] = true,
}

local filterSettings = table.clone(DEFAULT_FILTER_SETTINGS)

local originalCFrame = nil 
local activeItem = nil 
local originalItemCFrame = nil 

local realCharacter = nil
local fakeCharacter = nil

local cooldownEndTime = 0

local Colors = {
	Background = Color3.fromRGB(15, 15, 15),      
	Panel = Color3.fromRGB(25, 25, 25),           
	PanelHover = Color3.fromRGB(40, 40, 40),      
	Accent = Color3.fromRGB(210, 40, 40),        
	AccentHover = Color3.fromRGB(240, 50, 50),    
	Success = Color3.fromRGB(120, 120, 120),     
	SuccessHover = Color3.fromRGB(150, 150, 150),
	Warning = Color3.fromRGB(180, 130, 30),       
	WarningHover = Color3.fromRGB(210, 150, 40),
	Danger = Color3.fromRGB(180, 40, 40),         
	Text = Color3.fromRGB(240, 240, 240),         
	TextMuted = Color3.fromRGB(140, 140, 140),    
	Border = Color3.fromRGB(60, 60, 60)           
}
local GlobalFont = Enum.Font.GothamBold

local function applyTween(uiElement, properties, duration, easingStyle, easingDirection)
	local tween = TweenService:Create(uiElement, TweenInfo.new(duration or 0.15, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out), properties)
	tween:Play()
	return tween
end

local function createHoverEffect(button, defaultColor, hoverColor)
	button.MouseEnter:Connect(function() if button.AutoButtonColor then applyTween(button, {BackgroundColor3 = hoverColor}, 0.1) end end)
	button.MouseLeave:Connect(function() if button.AutoButtonColor then applyTween(button, {BackgroundColor3 = defaultColor}, 0.1) end end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LootTeleporterProGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 390, 0, 500)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Colors.Background
frame.BackgroundTransparency = 0.2 
frame.BorderSizePixel = 0
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 0) 
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Colors.Border
frameStroke.Thickness = 1
frameStroke.Transparency = 0.1

local uiScale = Instance.new("UIScale", frame)
uiScale.Scale = 1

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "TELEPORT SYSTEM"
title.TextColor3 = Colors.Text
title.TextSize = 16
title.Font = GlobalFont
title.RichText = true
title.TextXAlignment = Enum.TextXAlignment.Center
title.Position = UDim2.new(0, 0, 0, 5)
title.Active = true

local hintLabel = Instance.new("TextLabel", frame)
hintLabel.Size = UDim2.new(1, 0, 0, 25)
hintLabel.Position = UDim2.new(0, 0, 1, 8)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "[ K ] Press to show/hide the menu."
hintLabel.TextColor3 = Colors.TextMuted
hintLabel.TextSize = 12
hintLabel.Font = Enum.Font.GothamMedium

local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local tabLootBtn = Instance.new("TextButton", frame)
tabLootBtn.Size = UDim2.new(0.22, 0, 0, 32)
tabLootBtn.Position = UDim2.new(0.03, 0, 0, 45)
tabLootBtn.BackgroundColor3 = Colors.Accent
tabLootBtn.Text = "LOOT"
tabLootBtn.TextColor3 = Colors.Text
tabLootBtn.TextSize = 12
tabLootBtn.Font = GlobalFont
Instance.new("UICorner", tabLootBtn).CornerRadius = UDim.new(0, 0)

local tabCorpsesBtn = Instance.new("TextButton", frame)
tabCorpsesBtn.Size = UDim2.new(0.22, 0, 0, 32)
tabCorpsesBtn.Position = UDim2.new(0.27, 0, 0, 45)
tabCorpsesBtn.BackgroundColor3 = Colors.Panel
tabCorpsesBtn.Text = "CROPSES"
tabCorpsesBtn.TextColor3 = Colors.Text
tabCorpsesBtn.TextSize = 12
tabCorpsesBtn.Font = GlobalFont
Instance.new("UICorner", tabCorpsesBtn).CornerRadius = UDim.new(0, 0)

local tabDeathsBtn = Instance.new("TextButton", frame)
tabDeathsBtn.Size = UDim2.new(0.22, 0, 0, 32)
tabDeathsBtn.Position = UDim2.new(0.51, 0, 0, 45)
tabDeathsBtn.BackgroundColor3 = Colors.Panel
tabDeathsBtn.Text = "DEADTHS"
tabDeathsBtn.TextColor3 = Colors.Text
tabDeathsBtn.TextSize = 12
tabDeathsBtn.Font = GlobalFont
Instance.new("UICorner", tabDeathsBtn).CornerRadius = UDim.new(0, 0)

local tabLocationsBtn = Instance.new("TextButton", frame)
tabLocationsBtn.Size = UDim2.new(0.22, 0, 0, 32)
tabLocationsBtn.Position = UDim2.new(0.75, 0, 0, 45)
tabLocationsBtn.BackgroundColor3 = Colors.Panel
tabLocationsBtn.Text = "LOCATION"
tabLocationsBtn.TextColor3 = Colors.Text
tabLocationsBtn.TextSize = 12
tabLocationsBtn.Font = GlobalFont
Instance.new("UICorner", tabLocationsBtn).CornerRadius = UDim.new(0, 0)

local sliderContainer = Instance.new("Frame", frame)
sliderContainer.Size = UDim2.new(0.93, 0, 0, 40)
sliderContainer.Position = UDim2.new(0.035, 0, 0, 85)
sliderContainer.BackgroundTransparency = 1

local sliderLabel = Instance.new("TextLabel", sliderContainer)
sliderLabel.Size = UDim2.new(1, 0, 0, 18)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "SEARCH RADIUS: " .. CURRENT_DISTANCE .. "M"
sliderLabel.TextColor3 = Colors.TextMuted
sliderLabel.TextSize = 12
sliderLabel.Font = GlobalFont
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local sliderTrack = Instance.new("Frame", sliderContainer)
sliderTrack.Size = UDim2.new(1, 0, 0, 6)
sliderTrack.Position = UDim2.new(0, 0, 0, 24)
sliderTrack.BackgroundColor3 = Colors.Panel
sliderTrack.Active = true
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(0, 0)
local trackStroke = Instance.new("UIStroke", sliderTrack)
trackStroke.Color = Colors.Border
trackStroke.Thickness = 1

local sliderFill = Instance.new("Frame", sliderTrack)
local initialPercentage = CURRENT_DISTANCE / MAX_DISTANCE_LIMIT
sliderFill.Size = UDim2.new(initialPercentage, 0, 1, 0)
sliderFill.BackgroundColor3 = Colors.Accent
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 0)

local sliderDragging = false
sliderTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = true end
end)
UserInputService.InputChanged:Connect(function(input)
	if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local relativeX = math.clamp(input.Position.X - sliderTrack.AbsolutePosition.X, 0, sliderTrack.AbsoluteSize.X)
		local percentage = relativeX / sliderTrack.AbsoluteSize.X
		CURRENT_DISTANCE = math.floor(percentage * MAX_DISTANCE_LIMIT)
		applyTween(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
		sliderLabel.Text = "SEARCH RADIUS: " .. CURRENT_DISTANCE .. "M"
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = false end
end)

local refreshBtn = Instance.new("TextButton", frame)
refreshBtn.Size = UDim2.new(0.29, 0, 0, 36)
refreshBtn.Position = UDim2.new(0.035, 0, 0, 135)
refreshBtn.BackgroundColor3 = Colors.Panel
refreshBtn.Text = "RELOAD"
refreshBtn.TextColor3 = Colors.Text
refreshBtn.TextSize = 12
refreshBtn.Font = GlobalFont
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 0)
Instance.new("UIStroke", refreshBtn).Color = Colors.Border
createHoverEffect(refreshBtn, Colors.Panel, Colors.PanelHover)

local globalReturnBtn = Instance.new("TextButton", frame)
globalReturnBtn.Size = UDim2.new(0.29, 0, 0, 36)
globalReturnBtn.Position = UDim2.new(0.355, 0, 0, 135)
globalReturnBtn.BackgroundColor3 = Colors.Panel
globalReturnBtn.Text = "NO TARGET"
globalReturnBtn.TextColor3 = Colors.TextMuted
globalReturnBtn.TextSize = 11
globalReturnBtn.Font = GlobalFont
globalReturnBtn.AutoButtonColor = false
Instance.new("UICorner", globalReturnBtn).CornerRadius = UDim.new(0, 0)
local returnStroke = Instance.new("UIStroke", globalReturnBtn)
returnStroke.Color = Colors.Border
createHoverEffect(globalReturnBtn, Colors.Warning, Colors.WarningHover)

local filterOpenBtn = Instance.new("TextButton", frame)
filterOpenBtn.Size = UDim2.new(0.29, 0, 0, 36)
filterOpenBtn.Position = UDim2.new(0.675, 0, 0, 135)
filterOpenBtn.BackgroundColor3 = Colors.Panel
filterOpenBtn.Text = "FILTER"
filterOpenBtn.TextColor3 = Colors.Text
filterOpenBtn.TextSize = 12
filterOpenBtn.Font = GlobalFont
Instance.new("UICorner", filterOpenBtn).CornerRadius = UDim.new(0, 0)
Instance.new("UIStroke", filterOpenBtn).Color = Colors.Border
createHoverEffect(filterOpenBtn, Colors.Panel, Colors.PanelHover)

local scrollingFrame = Instance.new("ScrollingFrame", frame)
scrollingFrame.Size = UDim2.new(0.93, 0, 0, 310)
scrollingFrame.Position = UDim2.new(0.035, 0, 0, 180)
scrollingFrame.BackgroundColor3 = Colors.Background
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 2
scrollingFrame.ScrollBarImageColor3 = Colors.Border

local uiListLayout = Instance.new("UIListLayout", scrollingFrame)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 4)

local filterFrame = Instance.new("Frame", frame)
filterFrame.Size = UDim2.new(0, 0, 0, 500)
filterFrame.Position = UDim2.new(1, 15, 0.5, -250) 
filterFrame.BackgroundColor3 = Colors.Background
filterFrame.BackgroundTransparency = 0.2
filterFrame.BorderSizePixel = 0
filterFrame.ClipsDescendants = true
Instance.new("UICorner", filterFrame).CornerRadius = UDim.new(0, 0)
local filterStroke = Instance.new("UIStroke", filterFrame)
filterStroke.Color = Colors.Border
filterStroke.Thickness = 1
filterStroke.Transparency = 1 

local filterTitle = Instance.new("TextLabel", filterFrame)
filterTitle.Size = UDim2.new(1, 0, 0, 45)
filterTitle.BackgroundTransparency = 1
filterTitle.Text = "LOOT FILTER"
filterTitle.TextColor3 = Colors.Text
filterTitle.TextSize = 16
filterTitle.Font = GlobalFont
filterTitle.TextXAlignment = Enum.TextXAlignment.Center
filterTitle.Position = UDim2.new(0, 0, 0, 5)

local filterScrolling = Instance.new("ScrollingFrame", filterFrame)
filterScrolling.Size = UDim2.new(0.9, 0, 0, 430)
filterScrolling.Position = UDim2.new(0.05, 0, 0, 55)
filterScrolling.BackgroundColor3 = Colors.Background
filterScrolling.BackgroundTransparency = 1
filterScrolling.BorderSizePixel = 0
filterScrolling.ScrollBarThickness = 2
filterScrolling.ScrollBarImageColor3 = Colors.Border

local filterListLayout = Instance.new("UIListLayout", filterScrolling)
filterListLayout.SortOrder = Enum.SortOrder.LayoutOrder
filterListLayout.Padding = UDim.new(0, 4)

local filterOpen = false
filterOpenBtn.MouseButton1Click:Connect(function()
	filterOpen = not filterOpen
	if filterOpen then
		applyTween(filterFrame, {Size = UDim2.new(0, 320, 0, 500)}, 0.4, Enum.EasingStyle.Quint)
		applyTween(filterStroke, {Transparency = 0.1}, 0.3)
		applyTween(filterOpenBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
	else
		applyTween(filterFrame, {Size = UDim2.new(0, 0, 0, 500)}, 0.4, Enum.EasingStyle.Quint)
		applyTween(filterStroke, {Transparency = 1}, 0.3)
		applyTween(filterOpenBtn, {BackgroundColor3 = Colors.Panel}, 0.2)
	end
end)

local function buildFilterMenu()
	local sortedNames = {}
	for name, _ in pairs(DEFAULT_FILTER_SETTINGS) do table.insert(sortedNames, name) end
	table.sort(sortedNames)

	for _, name in ipairs(sortedNames) do
		local row = Instance.new("Frame", filterScrolling)
		row.Size = UDim2.new(1, -10, 0, 35)
		row.BackgroundColor3 = Colors.Panel
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 0)
		Instance.new("UIStroke", row).Color = Colors.Border

		local nameLabel = Instance.new("TextLabel", row)
		nameLabel.Size = UDim2.new(0.65, 0, 1, 0)
		nameLabel.Position = UDim2.new(0.05, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = name
		nameLabel.TextColor3 = Colors.Text
		nameLabel.TextSize = 12
		nameLabel.Font = GlobalFont
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left

		local toggleBtn = Instance.new("TextButton", row)
		toggleBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
		toggleBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
		toggleBtn.TextSize = 11
		toggleBtn.Font = GlobalFont
		Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 0)
		Instance.new("UIStroke", toggleBtn).Color = Colors.Border

		local function updateToggle()
			if filterSettings[name] then
				toggleBtn.Text = "ON"
				applyTween(toggleBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
			else
				toggleBtn.Text = "OFF"
				applyTween(toggleBtn, {BackgroundColor3 = Colors.Panel}, 0.2)
			end
		end
		updateToggle()

		toggleBtn.MouseButton1Click:Connect(function()
			filterSettings[name] = not filterSettings[name]
			updateToggle()
		end)
	end
	filterScrolling.CanvasSize = UDim2.new(0, 0, 0, #sortedNames * 39)
end
buildFilterMenu()

local function disableBlink()
	if activeItem and originalItemCFrame then
		if activeItem:IsA("Model") then
			activeItem:PivotTo(originalItemCFrame)
		elseif activeItem:IsA("BasePart") then
			activeItem.CFrame = originalItemCFrame
		end
	end
	if realCharacter then
		local realRoot = realCharacter:FindFirstChild("HumanoidRootPart")
		if realRoot then
			realRoot.Anchored = false
			if originalCFrame then
				realRoot.CFrame = originalCFrame
			end
		end
		player.Character = realCharacter
		local humanoid = realCharacter:FindFirstChild("Humanoid")
		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end
	if fakeCharacter then
		fakeCharacter:Destroy()
		fakeCharacter = nil
	end
	realCharacter = nil
	activeItem = nil
	originalItemCFrame = nil
	originalCFrame = nil
end

local function enableBlink(item, itemOrigCFrame)
	if activeItem ~= nil then return end
	local character = player.Character
	if realCharacter then 
		character = realCharacter 
	end
	if not character then return end
	
	realCharacter = character
	realCharacter.Archivable = true 
	
	local realRoot = realCharacter:FindFirstChild("HumanoidRootPart")
	if not realRoot then return end
	if not originalCFrame then
		originalCFrame = realRoot.CFrame
	end
	if fakeCharacter then
		fakeCharacter:Destroy()
		fakeCharacter = nil
	end
	fakeCharacter = realCharacter:Clone()
	fakeCharacter:PivotTo(originalCFrame)
	
	local fakeRoot = fakeCharacter:FindFirstChild("HumanoidRootPart")
	if fakeRoot then
		fakeRoot.Anchored = false
	end
	
	for _, desc in ipairs(fakeCharacter:GetDescendants()) do
		if desc:IsA("LocalScript") or desc:IsA("Script") then
			desc.Enabled = true
		end
	end
	
	fakeCharacter.Parent = workspace
	
	player.Character = fakeCharacter
	local fakeHumanoid = fakeCharacter:FindFirstChild("Humanoid")
	if fakeHumanoid then
		workspace.CurrentCamera.CameraSubject = fakeHumanoid
	end

	task.wait(0.1) 
	
	realRoot.CFrame = itemOrigCFrame + Vector3.new(0, -10, 0)
	task.wait(0.15)
	realRoot.Anchored = true

	local offsetCFrame = originalCFrame * CFrame.new(0, 1, -4)
	if item:IsA("Model") then
		item:PivotTo(offsetCFrame)
	elseif item:IsA("BasePart") then
		item.CFrame = offsetCFrame
	end

	activeItem = item
	originalItemCFrame = itemOrigCFrame
end

local function applyVisualCooldown(btn, defaultText, defaultColor, preserveHover)
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = Colors.Panel
	btn.TextColor3 = Colors.Warning

	task.spawn(function()
		while os.clock() < cooldownEndTime do
			if not btn.Parent then break end
			local remaining = math.max(0, cooldownEndTime - os.clock())
			btn.Text = string.format("%.1fs", remaining)
			task.wait(0.1)
		end
		
		if btn.Parent then
			btn.Text = defaultText
			btn.BackgroundColor3 = defaultColor
			btn.TextColor3 = Colors.Text
			if preserveHover then btn.AutoButtonColor = true end
		end
	end)
end

local updateLootList

local function updateGlobalReturnBtnState()
	local targetText, targetColor, targetHover
	
	if originalCFrame then
		targetText = "BACK"
		targetColor = Colors.Warning
		targetHover = true
		globalReturnBtn.TextColor3 = Colors.Text
		returnStroke.Color = Colors.Warning
	else
		targetText = "NO TARGET"
		targetColor = Colors.Panel
		targetHover = false
		globalReturnBtn.TextColor3 = Colors.TextMuted
		returnStroke.Color = Colors.Border
	end
	
	globalReturnBtn.Text = targetText
	globalReturnBtn.BackgroundColor3 = targetColor
	globalReturnBtn.AutoButtonColor = targetHover
	
	if os.clock() < cooldownEndTime then
		applyVisualCooldown(globalReturnBtn, targetText, targetColor, targetHover)
	end
end

globalReturnBtn.MouseButton1Click:Connect(function()
	if os.clock() < cooldownEndTime then return end
	
	if originalCFrame then
		cooldownEndTime = os.clock() + 3.0
		disableBlink()
		updateGlobalReturnBtnState()
		updateLootList()
	end
end)

local function switchTab(tabName)
	if activeItem ~= nil then return end

	currentTab = tabName
	applyTween(tabLootBtn, {BackgroundColor3 = Colors.Panel}, 0.2)
	applyTween(tabCorpsesBtn, {BackgroundColor3 = Colors.Panel}, 0.2)
	applyTween(tabDeathsBtn, {BackgroundColor3 = Colors.Panel}, 0.2)
	applyTween(tabLocationsBtn, {BackgroundColor3 = Colors.Panel}, 0.2)

	if currentTab == "Loot" then
		applyTween(tabLootBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
		sliderContainer.Visible = true
		filterOpenBtn.Visible = true
	elseif currentTab == "Corpses" then
		applyTween(tabCorpsesBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
		sliderContainer.Visible = false
		filterOpenBtn.Visible = false
		if filterOpen then
			filterOpen = false
			applyTween(filterFrame, {Size = UDim2.new(0, 0, 0, 500)}, 0.4, Enum.EasingStyle.Quint)
			applyTween(filterStroke, {Transparency = 1}, 0.3)
			applyTween(filterOpenBtn, {BackgroundColor3 = Colors.Panel}, 0.2)
		end
	elseif currentTab == "Deaths" then
		applyTween(tabDeathsBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
		sliderContainer.Visible = false
		filterOpenBtn.Visible = false
		if filterOpen then
			filterOpen = false
			applyTween(filterFrame, {Size = UDim2.new(0, 0, 0, 500)}, 0.4, Enum.EasingStyle.Quint)
			applyTween(filterStroke, {Transparency = 1}, 0.3)
			applyTween(filterOpenBtn, {BackgroundColor3 = Colors.Panel}, 0.2)
		end
	else 
		applyTween(tabLocationsBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
		sliderContainer.Visible = false
		filterOpenBtn.Visible = false
		if filterOpen then
			filterOpen = false
			applyTween(filterFrame, {Size = UDim2.new(0, 0, 0, 500)}, 0.4, Enum.EasingStyle.Quint)
			applyTween(filterStroke, {Transparency = 1}, 0.3)
			applyTween(filterOpenBtn, {BackgroundColor3 = Colors.Panel}, 0.2)
		end
	end
	updateLootList()
end

tabLootBtn.MouseButton1Click:Connect(function() switchTab("Loot") end)
tabCorpsesBtn.MouseButton1Click:Connect(function() switchTab("Corpses") end)
tabDeathsBtn.MouseButton1Click:Connect(function() switchTab("Deaths") end)
tabLocationsBtn.MouseButton1Click:Connect(function() switchTab("Locations") end)

local function setupHealthTracker()
	task.spawn(function()
		local userGUI = playerGui:WaitForChild("UserGUI", 30)
		local frameUI = userGUI and userGUI:WaitForChild("Frame", 30)
		if not frameUI then return end
		
		local isProcessing = false
		
		frameUI:GetPropertyChangedSignal("Visible"):Connect(function()
			if isProcessing then return end
			
			if frameUI.Visible == false then
				isProcessing = true
				
				local targetPos = nil
				if fakeCharacter and fakeCharacter:FindFirstChild("HumanoidRootPart") then
					targetPos = fakeCharacter.HumanoidRootPart.Position
				elseif player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					targetPos = player.Character.HumanoidRootPart.Position
				end
				
				if targetPos then
					table.insert(deathRecords, {
						pos = targetPos,
						time = os.time()
					})
					if currentTab == "Deaths" then updateLootList() end
				end
				
				task.wait(1) 
				isProcessing = false
			end
		end)
	end)
end

setupHealthTracker()

local menuVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end 
	if input.KeyCode == Enum.KeyCode.K then
		menuVisible = not menuVisible
		if menuVisible then
			frame.Visible = true
			applyTween(uiScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else
			local tween = applyTween(uiScale, {Scale = 0}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			tween.Completed:Connect(function()
				if not menuVisible then frame.Visible = false end
			end)
		end
	end
end)

local function getLootCFrame(item)
	if item:IsA("Model") then return item:GetPivot()
	elseif item:IsA("BasePart") then return item.CFrame end
end

function updateLootList()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local itemsToDisplay = {}

	if currentTab == "Loot" then
		local lootablesFolder = Workspace:FindFirstChild("Lootables")
		if lootablesFolder then
			local allChildren = lootablesFolder:GetChildren()
			for i = 1, #allChildren do
				local item = allChildren[i]
				if DEFAULT_FILTER_SETTINGS[item.Name] ~= nil and filterSettings[item.Name] then
					local cf = getLootCFrame(item)
					if cf then
						local dist = (hrp.Position - cf.Position).Magnitude
						if dist <= CURRENT_DISTANCE then
							table.insert(itemsToDisplay, {item = item, distance = dist})
						end
					end
				end
			end
		end

		table.sort(itemsToDisplay, function(a, b) return a.distance < b.distance end)

		for i = 1, #itemsToDisplay do
			local data = itemsToDisplay[i]
			local itemFrame = Instance.new("Frame", scrollingFrame)
			itemFrame.Size = UDim2.new(1, -10, 0, 38)
			itemFrame.BackgroundColor3 = Colors.Panel
			Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 0)
			Instance.new("UIStroke", itemFrame).Color = Colors.Border

			local label = Instance.new("TextLabel", itemFrame)
			label.Size = UDim2.new(0.65, 0, 1, 0)
			label.Position = UDim2.new(0.05, 0, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Colors.Text
			label.TextSize = 12
			label.Font = GlobalFont
			label.TextXAlignment = Enum.TextXAlignment.Left

			local tpBtn = Instance.new("TextButton", itemFrame)
			tpBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
			tpBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
			tpBtn.TextSize = 11
			tpBtn.Font = GlobalFont
			Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 0)
			Instance.new("UIStroke", tpBtn).Color = Colors.Border

			local displayName = data.item.Name
			local targetText, targetColor, targetHover

			if activeItem == data.item then
				targetText = "BACK"
				targetColor = Colors.Warning
				targetHover = true
				label.Text = string.format("%s [Here]", displayName)
				createHoverEffect(tpBtn, Colors.Warning, Colors.WarningHover)
			else
				targetText = "GO"
				if activeItem ~= nil then
					targetColor = Colors.Panel
					targetHover = false
					tpBtn.TextColor3 = Colors.TextMuted
				else
					targetColor = Colors.Success
					targetHover = true
					tpBtn.TextColor3 = Colors.Text
					createHoverEffect(tpBtn, Colors.Success, Colors.SuccessHover)
				end
				label.Text = string.format("%s (%dm)", displayName, math.floor(data.distance))
			end

			tpBtn.Text = targetText
			tpBtn.BackgroundColor3 = targetColor
			tpBtn.AutoButtonColor = targetHover

			if os.clock() < cooldownEndTime then
				applyVisualCooldown(tpBtn, targetText, targetColor, targetHover)
			end

			tpBtn.MouseButton1Click:Connect(function()
				if os.clock() < cooldownEndTime then return end
				
				if activeItem == data.item then
					cooldownEndTime = os.clock() + 3.0
					disableBlink()
				else
					if activeItem == nil then
						local currentCF = getLootCFrame(data.item)
						if currentCF then
							cooldownEndTime = os.clock() + 3.0
							enableBlink(data.item, currentCF)
						end
					end
				end
				updateGlobalReturnBtnState()
				updateLootList()
			end)
		end
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #itemsToDisplay * 42)

	elseif currentTab == "Corpses" then
		local corpsesFolder = Workspace:FindFirstChild("Corpses")
		if corpsesFolder then
			local allCorpses = corpsesFolder:GetChildren()
			for i = 1, #allCorpses do
				local item = allCorpses[i]
				local cf = getLootCFrame(item)
				if cf then
					local dist = (hrp.Position - cf.Position).Magnitude
					table.insert(itemsToDisplay, {item = item, distance = dist})
				end
			end
		end

		table.sort(itemsToDisplay, function(a, b) return a.distance < b.distance end)

		for i = 1, #itemsToDisplay do
			local data = itemsToDisplay[i]
			local itemFrame = Instance.new("Frame", scrollingFrame)
			itemFrame.Size = UDim2.new(1, -10, 0, 38)
			itemFrame.BackgroundColor3 = Colors.Panel
			Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 0)
			Instance.new("UIStroke", itemFrame).Color = Colors.Border

			local label = Instance.new("TextLabel", itemFrame)
			label.Size = UDim2.new(0.65, 0, 1, 0)
			label.Position = UDim2.new(0.05, 0, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Colors.Danger
			label.TextSize = 12
			label.Font = GlobalFont
			label.TextXAlignment = Enum.TextXAlignment.Left

			local tpBtn = Instance.new("TextButton", itemFrame)
			tpBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
			tpBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
			tpBtn.TextSize = 11
			tpBtn.Font = GlobalFont
			Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 0)
			Instance.new("UIStroke", tpBtn).Color = Colors.Border

			local displayName = "Leiche: " .. data.item.Name
			local targetText, targetColor, targetHover

			if activeItem == data.item then
				targetText = "BACK"
				targetColor = Colors.Warning
				targetHover = true
				label.Text = string.format("%s [Hier]", displayName)
				createHoverEffect(tpBtn, Colors.Warning, Colors.WarningHover)
			else
				targetText = "GO"
				if activeItem ~= nil then
					targetColor = Colors.Panel
					targetHover = false
					tpBtn.TextColor3 = Colors.TextMuted
				else
					targetColor = Colors.Success
					targetHover = true
					tpBtn.TextColor3 = Colors.Text
					createHoverEffect(tpBtn, Colors.Success, Colors.SuccessHover)
				end
				label.Text = string.format("%s (%dm)", displayName, math.floor(data.distance))
			end

			tpBtn.Text = targetText
			tpBtn.BackgroundColor3 = targetColor
			tpBtn.AutoButtonColor = targetHover

			if os.clock() < cooldownEndTime then
				applyVisualCooldown(tpBtn, targetText, targetColor, targetHover)
			end

			tpBtn.MouseButton1Click:Connect(function()
				if os.clock() < cooldownEndTime then return end 
				
				if activeItem == data.item then
					cooldownEndTime = os.clock() + 3.0
					disableBlink()
				else
					if activeItem == nil then
						local currentCF = getLootCFrame(data.item)
						if currentCF then
							cooldownEndTime = os.clock() + 3.0
							enableBlink(data.item, currentCF)
						end
					end
				end
				updateGlobalReturnBtnState()
				updateLootList()
			end)
		end
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #itemsToDisplay * 42)

	elseif currentTab == "Deaths" then
		local deathsToDisplay = {}
		for i = 1, #deathRecords do
			local record = deathRecords[i]
			local dist = (hrp.Position - record.pos).Magnitude
			table.insert(deathsToDisplay, {record = record, distance = dist})
		end

		table.sort(deathsToDisplay, function(a, b) return a.record.time > b.record.time end)

		for i = 1, #deathsToDisplay do
			local data = deathsToDisplay[i]
			local record = data.record
			local dist = data.distance

			local itemFrame = Instance.new("Frame", scrollingFrame)
			itemFrame.Size = UDim2.new(1, -10, 0, 44)
			itemFrame.BackgroundColor3 = Colors.Panel
			Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 0)
			Instance.new("UIStroke", itemFrame).Color = Colors.Border

			local label = Instance.new("TextLabel", itemFrame)
			label.Size = UDim2.new(0.65, 0, 1, 0)
			label.Position = UDim2.new(0.05, 0, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Colors.Danger
			label.TextSize = 11
			label.Font = GlobalFont
			label.TextXAlignment = Enum.TextXAlignment.Left

			local connection
			connection = RunService.RenderStepped:Connect(function()
				if not itemFrame.Parent then
					if connection then connection:Disconnect() end
					return
				end
				local currentHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local currentDist = currentHRP and (currentHRP.Position - record.pos).Magnitude or dist
				local diff = os.time() - record.time
				local timeStr = ""
				if diff < 60 then
					timeStr = diff .. "s"
				elseif diff < 3600 then
					timeStr = math.floor(diff / 60) .. "m " .. (diff % 60) .. "s"
				else
					timeStr = math.floor(diff / 3600) .. "h"
				end
				label.Text = string.format("Todesort (vor %s)\nDistanz: %dm", timeStr, math.floor(currentDist))
			end)

			local tpBtn = Instance.new("TextButton", itemFrame)
			tpBtn.Size = UDim2.new(0.25, 0, 0.65, 0)
			tpBtn.Position = UDim2.new(0.7, 0, 0.175, 0)
			tpBtn.TextSize = 11
			tpBtn.Font = GlobalFont
			tpBtn.Text = "GO"
			tpBtn.BackgroundColor3 = Colors.Success
			Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 0)
			Instance.new("UIStroke", tpBtn).Color = Colors.Border
			createHoverEffect(tpBtn, Colors.Success, Colors.SuccessHover)

			if os.clock() < cooldownEndTime then
				applyVisualCooldown(tpBtn, "GO", Colors.Success, true)
			end

			tpBtn.MouseButton1Click:Connect(function()
				if os.clock() < cooldownEndTime then return end
				cooldownEndTime = os.clock() + 3.0
				
				if connection then connection:Disconnect() end
				disableBlink()
				
				local realHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if realHRP then
					realHRP.CFrame = CFrame.new(record.pos + Vector3.new(0, 3, 0))
				end
				updateGlobalReturnBtnState()
				updateLootList()
			end)
		end
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #deathsToDisplay * 48)

	else
		local locationItems = {}
		for _, locData in ipairs(CUSTOM_LOCATIONS) do
			local dist = (hrp.Position - locData.pos).Magnitude
			table.insert(locationItems, {name = locData.name, pos = locData.pos, distance = dist})
		end

		for i = 1, #locationItems do
			local data = locationItems[i]
			local itemFrame = Instance.new("Frame", scrollingFrame)
			itemFrame.Size = UDim2.new(1, -10, 0, 38)
			itemFrame.BackgroundColor3 = Colors.Panel
			Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 0)
			Instance.new("UIStroke", itemFrame).Color = Colors.Border

			local label = Instance.new("TextLabel", itemFrame)
			label.Size = UDim2.new(0.65, 0, 1, 0)
			label.Position = UDim2.new(0.05, 0, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Colors.Text
			label.TextSize = 12
			label.Font = GlobalFont
			label.TextXAlignment = Enum.TextXAlignment.Left

			local tpBtn = Instance.new("TextButton", itemFrame)
			tpBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
			tpBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
			tpBtn.TextSize, tpBtn.Font = 11, GlobalFont
			Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 0)
			Instance.new("UIStroke", tpBtn).Color = Colors.Border

			tpBtn.Text = "TELEPORT"
			tpBtn.BackgroundColor3 = Colors.Success
			label.Text = data.name .. string.format(" (%dm)", math.floor(data.distance))
			createHoverEffect(tpBtn, Colors.Success, Colors.SuccessHover)

			if os.clock() < cooldownEndTime then
				applyVisualCooldown(tpBtn, "TELEPORT", Colors.Success, true)
			end

			tpBtn.MouseButton1Click:Connect(function()
				if os.clock() < cooldownEndTime then return end
				cooldownEndTime = os.clock() + 3.0
				
				disableBlink()
				
				local realHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if realHRP then
					realHRP.CFrame = CFrame.new(data.pos + Vector3.new(0, 3, 0))
				end
				updateGlobalReturnBtnState()
				updateLootList()
			end)
		end
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #locationItems * 42)
	end
end

refreshBtn.MouseButton1Click:Connect(updateLootList)