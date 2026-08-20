local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local success, parent = pcall(function()
    return CoreGui
end)
if not success or not parent then
    parent = PlayerGui
end

if parent:FindFirstChild("SketchGUILibrary") then
    parent.SketchGUILibrary:Destroy()
end

local Library = {}
Library.Version = "v2.1.7"
Library.ThemeColor = Library.ThemeColor
Library.Flags = {}
Library.SettingsFileName = "config1"
Library.ConfigFolder = ""
Library.ElementUpdaters = {}
local BaseFolderName = "PyroXGUI"

local function GetConfigDisplayName()
    local name = Library.SettingsFileName
    if name == "" then
        name = "config1"
    end
    return string.gsub(name, "%.json$", "")
end

local function GetFilePath()
    -- Hauptordner prüfen/erstellen
    if makefolder and not isfolder(BaseFolderName) then
        pcall(function() makefolder(BaseFolderName) end)
    end
    
    -- Unterordner prüfen/erstellen, falls angegeben
    local currentFolder = BaseFolderName
    if Library.ConfigFolder and Library.ConfigFolder ~= "" then
        currentFolder = BaseFolderName .. "/" .. Library.ConfigFolder
        if makefolder and not isfolder(currentFolder) then
            pcall(function() makefolder(currentFolder) end)
        end
    end
    
    local name = Library.SettingsFileName
    if name == "" then
        name = "config1"
    end
    if not string.match(name, "%.json$") then
        name = name .. ".json"
    end
    return currentFolder .. "/" .. name
end

local function GetEnumFromValue(val)
    if typeof(val) == "EnumItem" then
        return val
    elseif type(val) == "table" and val.Enum and val.Name then
        local success, res = pcall(function()
            return Enum[val.Enum][val.Name]
        end)
        if success then return res end
    elseif type(val) == "string" then
        if val == "None" then
            return Enum.KeyCode.None
        end
        local success, res = pcall(function()
            return Enum.KeyCode[val]
        end)
        if success and res then return res end
        
        for _, item in ipairs(Enum.UserInputType:GetEnumItems()) do
            if item.Name == val then
                return item
            end
        end
    end
    return Enum.KeyCode.None
end

local function ShowPopup(message)
    local notifGui = parent:FindFirstChild("PyroXGUI_Notification")
    if not notifGui then
        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "PyroXGUI_Notification"
        notifGui.ResetOnSpawn = false
        notifGui.Parent = parent
    end

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 40)
    NotifFrame.Position = UDim2.new(1, 20, 1, -60)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    NotifFrame.BorderColor3 = Library.ThemeColor
    NotifFrame.BorderSizePixel = 1
    NotifFrame.BackgroundTransparency = 0.25
    NotifFrame.ZIndex = 9999
    NotifFrame.Parent = notifGui

    local NotifLabel = Instance.new("TextLabel")
    NotifLabel.Size = UDim2.new(1, -10, 1, 0)
    NotifLabel.Position = UDim2.new(0, 5, 0, 0)
    NotifLabel.BackgroundTransparency = 1
    NotifLabel.Font = Enum.Font.SourceSansBold
    NotifLabel.Text = message
    NotifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifLabel.TextSize = 14
    NotifLabel.TextXAlignment = Enum.TextXAlignment.Center
    NotifLabel.ZIndex = 10000
    NotifLabel.Parent = NotifFrame

    for _, child in ipairs(notifGui:GetChildren()) do
        if child:IsA("Frame") and child ~= NotifFrame then
            TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -260, 1, child.Position.Y.Offset - 45)
            }):Play()
        end
    end

    local tweenInfoIn = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(NotifFrame, tweenInfoIn, {Position = UDim2.new(1, -260, 1, -60)}):Play()

    task.spawn(function()
        task.wait(3)
        local tweenInfoOut = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local slideOut = TweenService:Create(NotifFrame, tweenInfoOut, {Position = UDim2.new(1, 20, 1, NotifFrame.Position.Y.Offset)})
        slideOut:Play()
        slideOut.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

function Library.SaveSettings()
    if writefile then
        local success, encoded = pcall(function()
            local exportTable = {}
            for k, v in pairs(Library.Flags) do
                if typeof(v) == "Color3" then
                    exportTable[k] = {R = v.R, G = v.G, B = v.B}
                elseif typeof(v) == "EnumItem" then
                    -- Fix: tostring() splitten, da v.EnumType.Name einen Fehler auslöst
                    local split = tostring(v):split(".")
                    exportTable[k] = {Enum = split[2], Name = split[3]}
                else
                    exportTable[k] = v
                end
            end
            return HttpService:JSONEncode(exportTable)
        end)
        if success then
            local path = GetFilePath()
            pcall(function()
                writefile(path, encoded)
            end)
            ShowPopup('saved "' .. GetConfigDisplayName() .. '"')
        end
    end
end

function Library.LoadSettings()
    local path = GetFilePath()
    if readfile and isfile and isfile(path) then
        local success, decoded = pcall(function()
            local content = readfile(path)
            return HttpService:JSONDecode(content)
        end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if type(v) == "table" and v.Enum and v.Name then
                    pcall(function()
                        Library.Flags[k] = Enum[v.Enum][v.Name]
                    end)
                else
                    Library.Flags[k] = v
                end
            end
            for _, updateFunc in pairs(Library.ElementUpdaters) do
                pcall(updateFunc)
            end
            ShowPopup('loaded "' .. GetConfigDisplayName() .. '"')
        end
    end
end

function Library.New(titleText, customThemeColor)
    if customThemeColor then
        Library.ThemeColor = customThemeColor
    end
    
    local Window = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SketchGUILibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent

    -- MainFrame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 750, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    MainFrame.BackgroundTransparency = 0.25
    MainFrame.Visible = false
    MainFrame.ZIndex = 2
    MainFrame.Parent = ScreenGui

    local DimOverlay = Instance.new("TextButton")
    DimOverlay.Name = "DimOverlay"
    DimOverlay.Size = UDim2.new(1, 0, 1, 0)
    DimOverlay.Position = UDim2.new(0, 0, 0, 0)
    DimOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DimOverlay.BackgroundTransparency = 0.6
    DimOverlay.AutoButtonColor = false
    DimOverlay.Text = ""
    DimOverlay.Visible = false
    DimOverlay.ZIndex = 50
    DimOverlay.Parent = MainFrame

    local openPopups = {}
    local function CloseAllPopups()
        for _, closeFunc in ipairs(openPopups) do
            pcall(closeFunc)
        end
        DimOverlay.Visible = false
    end

    DimOverlay.MouseButton1Click:Connect(function()
        CloseAllPopups()
    end)

    -- Right Filter-Panel
    local FilterPanel = Instance.new("Frame")
    FilterPanel.Name = "FilterPanel"
    FilterPanel.Size = UDim2.new(0, 200, 0, 480)
    FilterPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    FilterPanel.BorderColor3 = Color3.fromRGB(50, 50, 50)
    FilterPanel.BackgroundTransparency = 0.25
    FilterPanel.Visible = false
    FilterPanel.ZIndex = 3
    FilterPanel.Parent = ScreenGui

    -- Color Picker Panel
    local ColorPickerPanel = Instance.new("Frame")
    ColorPickerPanel.Name = "ColorPickerPanel"
    ColorPickerPanel.Size = UDim2.new(0, 200, 0, 160)
    ColorPickerPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    ColorPickerPanel.BorderColor3 = Color3.fromRGB(50, 50, 50)
    ColorPickerPanel.BackgroundTransparency = 0.25
    ColorPickerPanel.Visible = false
    ColorPickerPanel.ZIndex = 3
    ColorPickerPanel.Parent = ScreenGui

    local function UpdatePanelPositions()
        local absPos = MainFrame.AbsolutePosition
        local absSize = MainFrame.AbsoluteSize
        FilterPanel.Position = UDim2.new(0, absPos.X + absSize.X + 8, 0, absPos.Y)
        ColorPickerPanel.Position = UDim2.new(0, absPos.X + absSize.X + 8, 0, absPos.Y + 180)
    end

    MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePanelPositions)
    task.spawn(function()
        task.wait(0.05)
        UpdatePanelPositions()
    end)

    -- Title Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderColor3 = Color3.fromRGB(50, 50, 50)
    TopBar.ZIndex = 3
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = titleText or "GUI Library"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TopBar

    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Size = UDim2.new(0, 80, 1, 0)
    VersionLabel.Position = UDim2.new(1, -90, 0, 0)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Font = Enum.Font.SourceSansBold
    VersionLabel.Text = Library.Version
    VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    VersionLabel.TextSize = 14
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
    VersionLabel.ZIndex = 3
    VersionLabel.Parent = TopBar

    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            UpdatePanelPositions()
        end
    end)

    local SideTabScroll = Instance.new("ScrollingFrame")
    SideTabScroll.Name = "SideTabScroll"
    SideTabScroll.Size = UDim2.new(0, 140, 1, -85)
    SideTabScroll.Position = UDim2.new(0, 5, 0, 40)
    SideTabScroll.BackgroundTransparency = 1
    SideTabScroll.BorderSizePixel = 0
    SideTabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SideTabScroll.ScrollBarThickness = 4
    SideTabScroll.ZIndex = 3
    SideTabScroll.Parent = MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SideLayout.Padding = UDim.new(0, 5)
    SideLayout.Parent = SideTabScroll

    SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SideTabScroll.CanvasSize = UDim2.new(0, 0, 0, SideLayout.AbsoluteContentSize.Y + 10)
    end)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -155, 1, -45)
    ContentContainer.Position = UDim2.new(0, 150, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 3
    ContentContainer.Parent = MainFrame

    local SettingsButton = Instance.new("TextButton")
    SettingsButton.Size = UDim2.new(0, 140, 0, 35)
    SettingsButton.Position = UDim2.new(0, 5, 1, -40)
    SettingsButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SettingsButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
    SettingsButton.Font = Enum.Font.SourceSansBold
    SettingsButton.Text = "Settings"
    SettingsButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    SettingsButton.TextSize = 14
    SettingsButton.ZIndex = 3
    SettingsButton.Parent = MainFrame

    local SettingsPanel = Instance.new("Frame")
    SettingsPanel.Name = "SettingsPanel"
    SettingsPanel.Size = UDim2.new(1, -10, 1, -40)
    SettingsPanel.Position = UDim2.new(0, 5, 0, 35)
    SettingsPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SettingsPanel.BorderColor3 = Color3.fromRGB(50, 50, 50)
    SettingsPanel.BackgroundTransparency = 0.1
    SettingsPanel.Visible = false
    SettingsPanel.ZIndex = 10
    SettingsPanel.Parent = ContentContainer

    local SettTitle = Instance.new("TextLabel")
    SettTitle.Size = UDim2.new(1, -20, 0, 30)
    SettTitle.Position = UDim2.new(0, 10, 0, 10)
    SettTitle.BackgroundTransparency = 1
    SettTitle.Font = Enum.Font.SourceSansBold
    SettTitle.Text = "Configuration Settings"
    SettTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettTitle.TextSize = 16
    SettTitle.TextXAlignment = Enum.TextXAlignment.Left
    SettTitle.ZIndex = 11
    SettTitle.Parent = SettingsPanel

    local SettNameBox = Instance.new("TextBox")
    SettNameBox.Size = UDim2.new(1, -20, 0, 32)
    SettNameBox.Position = UDim2.new(0, 10, 0, 50)
    SettNameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SettNameBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
    SettNameBox.Font = Enum.Font.SourceSans
    SettNameBox.Text = Library.SettingsFileName
    SettNameBox.PlaceholderText = "Settings File Name..."
    SettNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettNameBox.TextSize = 14
    SettNameBox.ZIndex = 11
    SettNameBox.Parent = SettingsPanel

    SettNameBox.FocusLost:Connect(function()
        if SettNameBox.Text ~= "" then
            Library.SettingsFileName = SettNameBox.Text
        end
    end)

    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Size = UDim2.new(0.5, -15, 0, 35)
    LoadBtn.Position = UDim2.new(0, 10, 0, 95)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    LoadBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    LoadBtn.Font = Enum.Font.SourceSansBold
    LoadBtn.Text = "Load"
    LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadBtn.TextSize = 14
    LoadBtn.ZIndex = 11
    LoadBtn.Parent = SettingsPanel

    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Size = UDim2.new(0.5, -15, 0, 35)
    SaveBtn.Position = UDim2.new(0.5, 5, 0, 95)
    SaveBtn.BackgroundColor3 = Library.ThemeColor
    SaveBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    SaveBtn.Font = Enum.Font.SourceSansBold
    SaveBtn.Text = "Save"
    SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveBtn.TextSize = 14
    SaveBtn.ZIndex = 11
    SaveBtn.Parent = SettingsPanel

    LoadBtn.MouseButton1Click:Connect(function()
        Library.LoadSettings()
    end)

    SaveBtn.MouseButton1Click:Connect(function()
        Library.SaveSettings()
    end)

    local menuKeyFlag = "MenuToggleKey"
    if Library.Flags[menuKeyFlag] == nil then
        Library.Flags[menuKeyFlag] = Enum.KeyCode.RightShift
    end

    local MenuKeyLabel = Instance.new("TextLabel")
    MenuKeyLabel.Size = UDim2.new(1, -20, 0, 20)
    MenuKeyLabel.Position = UDim2.new(0, 10, 0, 140)
    MenuKeyLabel.BackgroundTransparency = 1
    MenuKeyLabel.Font = Enum.Font.SourceSansBold
    MenuKeyLabel.Text = "Menu Toggle Key"
    MenuKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MenuKeyLabel.TextSize = 14
    MenuKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    MenuKeyLabel.ZIndex = 11
    MenuKeyLabel.Parent = SettingsPanel

    local MenuKeyButton = Instance.new("TextButton")
    MenuKeyButton.Size = UDim2.new(1, -20, 0, 32)
    MenuKeyButton.Position = UDim2.new(0, 10, 0, 165)
    MenuKeyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MenuKeyButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
    MenuKeyButton.Font = Enum.Font.SourceSans
    local currentMenuKey = Library.Flags[menuKeyFlag]
    MenuKeyButton.Text = (typeof(currentMenuKey) == "EnumItem" and currentMenuKey ~= Enum.KeyCode.None) and currentMenuKey.Name or "RightShift"
    MenuKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MenuKeyButton.TextSize = 14
    MenuKeyButton.ZIndex = 11
    MenuKeyButton.Parent = SettingsPanel

    local bindingMenuKey = false
    MenuKeyButton.MouseButton1Click:Connect(function()
        bindingMenuKey = true
        MenuKeyButton.Text = "Press any key..."
    end)

    local menuOpen = false
    local function ToggleMainMenu(isOpen)
        menuOpen = isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if menuOpen then
            ScreenGui.Enabled = true
            MainFrame.Size = UDim2.new(0, 700, 0, 440)
            MainFrame.BackgroundTransparency = 1
            TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 750, 0, 480), BackgroundTransparency = 0.25}):Play()
            if DimOverlay.Visible then
                TweenService:Create(DimOverlay, tweenInfo, {BackgroundTransparency = 0.6}):Play()
            end
        else
            CloseAllPopups()
            local tw1 = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 700, 0, 440), BackgroundTransparency = 1})
            local tw2 = TweenService:Create(DimOverlay, tweenInfo, {BackgroundTransparency = 1})
            tw1:Play()
            tw2:Play()
            tw1.Completed:Connect(function()
                if not menuOpen then
                    ScreenGui.Enabled = false
                    MainFrame.Size = UDim2.new(0, 750, 0, 480)
                    MainFrame.BackgroundTransparency = 0.25
                end
            end)

            local currentKey = Library.Flags[menuKeyFlag]
            local keyName = (typeof(currentKey) == "EnumItem" and currentKey ~= Enum.KeyCode.None) and currentKey.Name or "RightShift"
            ShowPopup("GUI closed! Press [" .. keyName .. "] to reopen.")
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if bindingMenuKey then
            local validKey = false
            local keyName = ""
            local keyValue = nil

            if input.UserInputType == Enum.UserInputType.Keyboard then
                validKey = true
                keyName = input.KeyCode.Name
                keyValue = input.KeyCode
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                validKey = true
                keyName = input.UserInputType.Name
                keyValue = input.UserInputType
            end

            if validKey then
                Library.Flags[menuKeyFlag] = keyValue
                MenuKeyButton.Text = keyName
                bindingMenuKey = false
            end
        elseif not gameProcessed then
            local targetKey = Library.Flags[menuKeyFlag]
            if typeof(targetKey) == "string" then
                pcall(function()
                    targetKey = Enum.KeyCode[targetKey] or Enum.UserInputType[targetKey] or Enum.KeyCode.RightShift
                end)
            end
            if targetKey then
                if (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == targetKey) or (input.UserInputType == targetKey) then
                    ToggleMainMenu(not menuOpen)
                end
            end
        end
    end)

    table.insert(Library.ElementUpdaters, function()
        local val = Library.Flags[menuKeyFlag]
        if val ~= nil then
            if typeof(val) == "string" then
                pcall(function()
                    Library.Flags[menuKeyFlag] = Enum.KeyCode[val] or Enum.UserInputType[val] or Enum.KeyCode.RightShift
                end)
            end
            local currentKey = Library.Flags[menuKeyFlag]
            MenuKeyButton.Text = (typeof(currentKey) == "EnumItem" and currentKey ~= Enum.KeyCode.None) and currentKey.Name or "RightShift"
        end
    end)

    local sideTabs = {}
    local firstSideTab = true

    SettingsButton.MouseButton1Click:Connect(function()
        CloseAllPopups()
        for _, t in pairs(sideTabs) do
            t.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            t.HeaderBar.Visible = false
            for _, sub in pairs(t.SubTabs) do
                sub.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                sub.Container.Visible = false
            end
        end
        SettingsPanel.Visible = not SettingsPanel.Visible
    end)

    local FilterTitle = Instance.new("TextLabel")
    FilterTitle.Size = UDim2.new(1, 0, 0, 30)
    FilterTitle.Position = UDim2.new(0, 10, 0, 0)
    FilterTitle.BackgroundTransparency = 1
    FilterTitle.Font = Enum.Font.SourceSansBold
    FilterTitle.Text = "LOOT FILTER"
    FilterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FilterTitle.TextSize = 14
    FilterTitle.TextXAlignment = Enum.TextXAlignment.Left
    FilterTitle.ZIndex = 4
    FilterTitle.Parent = FilterPanel

    local FilterScroll = Instance.new("ScrollingFrame")
    FilterScroll.Size = UDim2.new(1, -10, 1, -35)
    FilterScroll.Position = UDim2.new(0, 5, 0, 30)
    FilterScroll.BackgroundTransparency = 1
    FilterScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    FilterScroll.ScrollBarThickness = 4
    FilterScroll.ZIndex = 4
    FilterScroll.Parent = FilterPanel

    local FilterListLayout = Instance.new("UIListLayout")
    FilterListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    FilterListLayout.Padding = UDim.new(0, 5)
    FilterListLayout.Parent = FilterScroll

    FilterListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        FilterScroll.CanvasSize = UDim2.new(0, 0, 0, FilterListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Animierted Filter Panel
    local filterOpen = false
    local function CloseFilter()
        if not filterOpen then return end
        filterOpen = false
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tw = TweenService:Create(FilterPanel, tweenInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 180, 0, 460)})
        tw:Play()
        tw.Completed:Wait()
        FilterPanel.Visible = false
        FilterPanel.BackgroundTransparency = 0.25
        FilterPanel.Size = UDim2.new(0, 200, 0, 480)
    end
    table.insert(openPopups, CloseFilter)

    local function ToggleFilterPanel()
        local targetState = not filterOpen
        CloseAllPopups()
        if targetState then
            filterOpen = true
            FilterPanel.Visible = true
            FilterPanel.BackgroundTransparency = 1
            FilterPanel.Size = UDim2.new(0, 180, 0, 460)
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(FilterPanel, tweenInfo, {BackgroundTransparency = 0.25, Size = UDim2.new(0, 200, 0, 480)}):Play()
        else
            CloseFilter()
        end
    end

    function Window:AddTab(tabName)
        local TabObj = {}
        local t_first_sub = nil
        local isThisFirstTab = firstSideTab

        local SideButton = Instance.new("TextButton")
        SideButton.Size = UDim2.new(1, -10, 0, 30)
        SideButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        SideButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
        SideButton.Font = Enum.Font.SourceSans
        SideButton.Text = tabName
        SideButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        SideButton.TextSize = 14
        SideButton.ZIndex = 3
        SideButton.Parent = SideTabScroll

        local SubTabHeaderBar = Instance.new("ScrollingFrame")
        SubTabHeaderBar.Name = tabName .. "_SubBar"
        SubTabHeaderBar.Size = UDim2.new(1, -10, 0, 25)
        SubTabHeaderBar.Position = UDim2.new(0, 5, 0, 5)
        SubTabHeaderBar.BackgroundTransparency = 1
        SubTabHeaderBar.CanvasSize = UDim2.new(0, 0, 0, 0)
        SubTabHeaderBar.ScrollBarThickness = 0
        SubTabHeaderBar.Visible = false
        SubTabHeaderBar.ZIndex = 3
        SubTabHeaderBar.Parent = ContentContainer

        local SubHeaderLayout = Instance.new("UIListLayout")
        SubHeaderLayout.FillDirection = Enum.FillDirection.Horizontal
        SubHeaderLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubHeaderLayout.Padding = UDim.new(0, 5)
        SubHeaderLayout.Parent = SubTabHeaderBar

        SubHeaderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SubTabHeaderBar.CanvasSize = UDim2.new(0, SubHeaderLayout.AbsoluteContentSize.X + 10, 0, 0)
        end)

        if firstSideTab then
            SideButton.BackgroundColor3 = Library.ThemeColor
            SubTabHeaderBar.Visible = true
        end

        SideButton.MouseButton1Click:Connect(function()
            CloseAllPopups()
            SettingsPanel.Visible = false
            for _, t in pairs(sideTabs) do
                t.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                t.HeaderBar.Visible = false
                for _, sub in pairs(t.SubTabs) do
                    sub.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    sub.Container.Visible = false
                end
            end
            
            SideButton.BackgroundColor3 = Library.ThemeColor
            SubTabHeaderBar.Visible = true
            if t_first_sub then
                t_first_sub.Button.BackgroundColor3 = Library.ThemeColor
                if t_first_sub.Container then
                    t_first_sub.Container.Visible = true
                end
            end
        end)

        TabObj.Button = SideButton
        TabObj.HeaderBar = SubTabHeaderBar
        TabObj.SubTabs = {}

        function TabObj:AddSubTab(subTabName)
            local SubObj = {}

            local SubButton = Instance.new("TextButton")
            SubButton.Size = UDim2.new(0, 95, 0, 25)
            SubButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SubButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
            SubButton.Font = Enum.Font.SourceSans
            SubButton.Text = subTabName
            SubButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            SubButton.TextSize = 13
            SubButton.ZIndex = 3
            SubButton.Parent = SubTabHeaderBar

            local ElementScroll = Instance.new("ScrollingFrame")
            ElementScroll.Size = UDim2.new(1, -10, 1, -35)
            ElementScroll.Position = UDim2.new(0, 5, 0, 35)
            ElementScroll.BackgroundTransparency = 1
            ElementScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ElementScroll.ScrollBarThickness = 4
            ElementScroll.Visible = false
            ElementScroll.ZIndex = 3
            ElementScroll.Parent = ContentContainer

            local ElementLayout = Instance.new("UIListLayout")
            ElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementLayout.Padding = UDim.new(0, 5)
            ElementLayout.Parent = ElementScroll

            ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ElementScroll.CanvasSize = UDim2.new(0, 0, 0, ElementLayout.AbsoluteContentSize.Y + 10)
            end)

            SubButton.MouseButton1Click:Connect(function()
                CloseAllPopups()
                for _, s in pairs(TabObj.SubTabs) do
                    s.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    s.Container.Visible = false
                end
                SubButton.BackgroundColor3 = Library.ThemeColor
                ElementScroll.Visible = true
            end)

            SubObj.Button = SubButton
            SubObj.Container = ElementScroll
            table.insert(TabObj.SubTabs, SubObj)

            if not t_first_sub then
                t_first_sub = SubObj
                if isThisFirstTab then
                    SubButton.BackgroundColor3 = Library.ThemeColor
                    ElementScroll.Visible = true
                end
            end

            -- 1. Toggle Button
            function SubObj:AddToggle(text, default, callback)
                local flag = tabName .. "_" .. subTabName .. "_" .. text
                if type(Library.Flags[flag]) ~= "boolean" then
                    Library.Flags[flag] = (default ~= nil) and default or false
                end

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, -5, 0, 30)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                ToggleFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                ToggleFrame.ZIndex = 3
                ToggleFrame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -55, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = ToggleFrame

                local Switch = Instance.new("TextButton")
                Switch.Size = UDim2.new(0, 40, 0, 18)
                Switch.Position = UDim2.new(1, -45, 0.5, -9)
                Switch.BackgroundColor3 = Library.Flags[flag] and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
                Switch.BorderColor3 = Color3.fromRGB(60, 60, 60)
                Switch.Text = Library.Flags[flag] and "ON" or "OFF"
                Switch.Font = Enum.Font.SourceSansBold
                Switch.TextColor3 = Color3.fromRGB(255, 255, 255)
                Switch.TextSize = 11
                Switch.ZIndex = 3
                Switch.Parent = ToggleFrame

                Switch.MouseButton1Click:Connect(function()
                    Library.Flags[flag] = not Library.Flags[flag]
                    Switch.BackgroundColor3 = Library.Flags[flag] and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
                    Switch.Text = Library.Flags[flag] and "ON" or "OFF"
                    if callback then callback(Library.Flags[flag]) end
                end)

                table.insert(Library.ElementUpdaters, function()
                    local val = Library.Flags[flag]
                    if val ~= nil then
                        Switch.BackgroundColor3 = val and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
                        Switch.Text = val and "ON" or "OFF"
                        if callback then callback(val) end
                    end
                end)
            end

            -- 2. Slider
            function SubObj:AddSlider(text, min, max, default, callback)
                local flag = tabName .. "_" .. subTabName .. "_" .. text
                if type(Library.Flags[flag]) ~= "number" then
                    Library.Flags[flag] = default or min
                end

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, -5, 0, 45)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                SliderFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                SliderFrame.ZIndex = 3
                SliderFrame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -10, 0, 20)
                Label.Position = UDim2.new(0, 10, 0, 2)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text .. ": " .. tostring(Library.Flags[flag])
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = SliderFrame

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, -20, 0, 6)
                SliderBar.Position = UDim2.new(0, 10, 0, 28)
                SliderBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                SliderBar.BorderColor3 = Color3.fromRGB(60, 60, 60)
                SliderBar.ZIndex = 3
                SliderBar.Parent = SliderFrame

                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new((Library.Flags[flag] - min) / (max - min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Library.ThemeColor
                SliderFill.BorderSizePixel = 0
                SliderFill.ZIndex = 3
                SliderFill.Parent = SliderBar

                local draggingSlider = false
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + ((max - min) * pos))
                    Library.Flags[flag] = val
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(val)
                    if callback then callback(val) end
                end

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        updateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)

                table.insert(Library.ElementUpdaters, function()
                    local val = Library.Flags[flag]
                    if val ~= nil then
                        local pos = math.clamp((val - min) / (max - min), 0, 1)
                        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                        Label.Text = text .. ": " .. tostring(val)
                        if callback then callback(val) end
                    end
                end)
            end

            -- 3. Keybind
            function SubObj:AddKeybind(text, defaultKey, callback)
                local flag = tabName .. "_" .. subTabName .. "_" .. text
                if Library.Flags[flag] == nil then
                    Library.Flags[flag] = defaultKey or Enum.KeyCode.None
                end

                local KeyFrame = Instance.new("Frame")
                KeyFrame.Size = UDim2.new(1, -5, 0, 30)
                KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                KeyFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                KeyFrame.ZIndex = 3
                KeyFrame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -120, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = KeyFrame

                local ResetButton = Instance.new("TextButton")
                ResetButton.Size = UDim2.new(0, 45, 0, 22)
                ResetButton.Position = UDim2.new(1, -120, 0.5, -11)
                ResetButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                ResetButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
                ResetButton.Font = Enum.Font.SourceSans
                ResetButton.Text = "Reset"
                ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                ResetButton.TextSize = 11
                ResetButton.ZIndex = 3
                ResetButton.Parent = KeyFrame

                local KeyButton = Instance.new("TextButton")
                KeyButton.Size = UDim2.new(0, 70, 0, 22)
                KeyButton.Position = UDim2.new(1, -70, 0.5, -11)
                KeyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                KeyButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
                KeyButton.Font = Enum.Font.SourceSans
                KeyButton.Text = (typeof(Library.Flags[flag]) == "EnumItem" and Library.Flags[flag] ~= Enum.KeyCode.None) and Library.Flags[flag].Name or "None"
                KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeyButton.TextSize = 12
                KeyButton.ZIndex = 3
                KeyButton.Parent = KeyFrame

                local binding = false
                KeyButton.MouseButton1Click:Connect(function()
                    binding = true
                    KeyButton.Text = "..."
                end)

                ResetButton.MouseButton1Click:Connect(function()
                    binding = false
                    Library.Flags[flag] = Enum.KeyCode.None
                    KeyButton.Text = "None"
                    if callback then callback(Enum.KeyCode.None) end
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if binding then
                        local validKey = false
                        local keyName = ""
                        local keyValue = nil

                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            validKey = true
                            keyName = input.KeyCode.Name
                            keyValue = input.KeyCode
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            validKey = true
                            keyName = input.UserInputType.Name
                            keyValue = input.UserInputType
                        end

                        if validKey then
                            Library.Flags[flag] = keyValue
                            KeyButton.Text = keyName
                            binding = false
                            if callback then callback(keyValue) end
                        end
                    elseif not gameProcessed and Library.Flags[flag] ~= Enum.KeyCode.None then
                        if (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Library.Flags[flag]) or (input.UserInputType == Library.Flags[flag]) then
                            if callback then callback(Library.Flags[flag]) end
                        end
                    end
                end)

                table.insert(Library.ElementUpdaters, function()
                    local val = Library.Flags[flag]
                    if val ~= nil then
                        if typeof(val) == "string" then
                            pcall(function()
                                if val == "None" then
                                    Library.Flags[flag] = Enum.KeyCode.None
                                else
                                    Library.Flags[flag] = Enum.KeyCode[val] or Enum.UserInputType[val] or Enum.KeyCode.None
                                end
                            end)
                        end
                        local currentKey = Library.Flags[flag]
                        KeyButton.Text = (typeof(currentKey) == "EnumItem" and currentKey ~= Enum.KeyCode.None) and currentKey.Name or "None"
                        if callback and typeof(currentKey) == "EnumItem" then callback(currentKey) end
                    end
                end)
            end

            -- 4. Dropdown (Animiert)
            function SubObj:AddDropdown(text, options, multiSelect, default, callback)
                local flag = tabName .. "_" .. subTabName .. "_" .. text
                if Library.Flags[flag] == nil or type(Library.Flags[flag]) ~= (multiSelect and "table" or "string") then
                    if multiSelect then
                        Library.Flags[flag] = default or {}
                    else
                        Library.Flags[flag] = default or options[1]
                    end
                end

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, -5, 0, 30)
                DropFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                DropFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                DropFrame.ZIndex = 3
                DropFrame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -110, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = DropFrame

                local DropButton = Instance.new("TextButton")
                DropButton.Size = UDim2.new(0, 95, 0, 22)
                DropButton.Position = UDim2.new(1, -100, 0.5, -11)
                DropButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                DropButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
                DropButton.Font = Enum.Font.SourceSans
                DropButton.TextTruncate = Enum.TextTruncate.AtEnd
                
                local updateButtonText
                local targetHeight = math.clamp(#options * 30 + 10, 30, 180)
                local ListFrame = Instance.new("ScrollingFrame")
                ListFrame.Size = UDim2.new(0, 200, 0, targetHeight)
                ListFrame.Position = UDim2.new(0.5, -100, 0.5, -90)
                ListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                ListFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                ListFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)
                ListFrame.ScrollBarThickness = 4
                ListFrame.Visible = false
                ListFrame.ZIndex = 60
                ListFrame.Parent = MainFrame

                local dropdownOpen = false
                local function CloseDropdown()
                    if not dropdownOpen then return end
                    dropdownOpen = false
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tw = TweenService:Create(ListFrame, tweenInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 180, 0, 0)})
                    tw:Play()
                    tw.Completed:Wait()
                    ListFrame.Visible = false
                    ListFrame.BackgroundTransparency = 0
                    ListFrame.Size = UDim2.new(0, 200, 0, targetHeight)
                end
                table.insert(openPopups, CloseDropdown)

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = ListFrame

                local optButtons = {}
                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, -5, 0, 28)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    OptBtn.BorderColor3 = Color3.fromRGB(50, 50, 50)
                    OptBtn.Font = Enum.Font.SourceSans
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    OptBtn.TextSize = 13
                    OptBtn.ZIndex = 61
                    OptBtn.Parent = ListFrame

                    OptBtn.MouseButton1Click:Connect(function()
                        if multiSelect then
                            Library.Flags[flag][opt] = not Library.Flags[flag][opt]
                            OptBtn.BackgroundColor3 = Library.Flags[flag][opt] and Library.ThemeColor or Color3.fromRGB(30, 30, 30)
                        else
                            Library.Flags[flag] = opt
                            CloseAllPopups()
                        end
                        updateButtonText()
                        if callback then callback(Library.Flags[flag]) end
                    end)
                    optButtons[opt] = OptBtn
                end

                updateButtonText = function()
                    if multiSelect then
                        local active = {}
                        for k, v in pairs(Library.Flags[flag]) do
                            if v then table.insert(active, k) end
                            if optButtons[k] then
                                optButtons[k].BackgroundColor3 = v and Library.ThemeColor or Color3.fromRGB(30, 30, 30)
                            end
                        end
                        DropButton.Text = (#active > 0) and table.concat(active, ", ") or "Select..."
                    else
                        DropButton.Text = tostring(Library.Flags[flag])
                    end
                end
                updateButtonText()

                DropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropButton.TextSize = 12
                DropButton.ZIndex = 3
                DropButton.Parent = DropFrame

                DropButton.MouseButton1Click:Connect(function()
                    local targetState = not dropdownOpen
                    CloseAllPopups()
                    if targetState then
                        dropdownOpen = true
                        ListFrame.Visible = true
                        ListFrame.BackgroundTransparency = 1
                        ListFrame.Size = UDim2.new(0, 180, 0, 0)
                        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        TweenService:Create(ListFrame, tweenInfo, {BackgroundTransparency = 0, Size = UDim2.new(0, 200, 0, targetHeight)}):Play()
                        DimOverlay.Visible = true
                        DimOverlay.BackgroundTransparency = 1
                        TweenService:Create(DimOverlay, tweenInfo, {BackgroundTransparency = 0.6}):Play()
                    else
                        CloseDropdown()
                    end
                end)

                table.insert(Library.ElementUpdaters, function()
                    if Library.Flags[flag] ~= nil then
                        updateButtonText()
                        if callback then callback(Library.Flags[flag]) end
                    end
                end)
            end

            -- 5. Filter Button
            function SubObj:AddFilterButton(text)
                local FilterBtnFrame = Instance.new("Frame")
                FilterBtnFrame.Size = UDim2.new(1, -5, 0, 30)
                FilterBtnFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                FilterBtnFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                FilterBtnFrame.ZIndex = 3
                FilterBtnFrame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -110, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = FilterBtnFrame

                local OpenBtn = Instance.new("TextButton")
                OpenBtn.Size = UDim2.new(0, 95, 0, 22)
                OpenBtn.Position = UDim2.new(1, -100, 0.5, -11)
                OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                OpenBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
                OpenBtn.Font = Enum.Font.SourceSans
                OpenBtn.Text = "Open Filter"
                OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                OpenBtn.TextSize = 13
                OpenBtn.ZIndex = 3
                OpenBtn.Parent = FilterBtnFrame

                OpenBtn.MouseButton1Click:Connect(function()
                    ToggleFilterPanel()
                end)
            end

            -- 6. Color Picker (Animiert)
            function SubObj:AddColorPicker(text, defaultColor, callback)
                local flag = tabName .. "_" .. subTabName .. "_" .. text
                if Library.Flags[flag] == nil or typeof(Library.Flags[flag]) == "boolean" or type(Library.Flags[flag]) == "number" or type(Library.Flags[flag]) == "string" then
                    Library.Flags[flag] = defaultColor or Color3.fromRGB(255, 255, 255)
                end

                local ColorFrame = Instance.new("Frame")
                ColorFrame.Size = UDim2.new(1, -5, 0, 30)
                ColorFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                ColorFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                ColorFrame.ZIndex = 3
                ColorFrame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -110, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = ColorFrame

                local ColorDisplay = Instance.new("TextButton")
                ColorDisplay.Size = UDim2.new(0, 95, 0, 22)
                ColorDisplay.Position = UDim2.new(1, -100, 0.5, -11)
                
                local curCol = Library.Flags[flag]
                if type(curCol) == "table" then
                    curCol = Color3.new(curCol["R"] or 1, curCol["G"] or 1, curCol["B"] or 1)
                    Library.Flags[flag] = curCol
                end
                ColorDisplay.BackgroundColor3 = curCol
                
                ColorDisplay.BorderColor3 = Color3.fromRGB(60, 60, 60)
                ColorDisplay.Font = Enum.Font.SourceSans
                ColorDisplay.Text = "Set Color"
                ColorDisplay.TextColor3 = Color3.fromRGB(0, 0, 0)
                ColorDisplay.TextSize = 13
                ColorDisplay.ZIndex = 3
                ColorDisplay.Parent = ColorFrame

                local colorPickerOpen = false
                local function CloseColorPicker()
                    if not colorPickerOpen then return end
                    colorPickerOpen = false
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tw = TweenService:Create(ColorPickerPanel, tweenInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 180, 0, 140)})
                    tw:Play()
                    tw.Completed:Wait()
                    ColorPickerPanel.Visible = false
                    ColorPickerPanel.BackgroundTransparency = 0.25
                    ColorPickerPanel.Size = UDim2.new(0, 200, 0, 160)
                end
                table.insert(openPopups, CloseColorPicker)

                ColorDisplay.MouseButton1Click:Connect(function()
                    local targetState = not colorPickerOpen
                    CloseAllPopups()
                    if targetState then
                        colorPickerOpen = true
                        
                        for _, v in pairs(ColorPickerPanel:GetChildren()) do
                            v:Destroy()
                        end
                        
                        local cpTitle = Instance.new("TextLabel")
                        cpTitle.Size = UDim2.new(1, 0, 0, 25)
                        cpTitle.Position = UDim2.new(0, 10, 0, 0)
                        cpTitle.BackgroundTransparency = 1
                        cpTitle.Font = Enum.Font.SourceSansBold
                        cpTitle.Text = text .. " RGB"
                        cpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                        cpTitle.TextSize = 13
                        cpTitle.TextXAlignment = Enum.TextXAlignment.Left
                        cpTitle.ZIndex = 4
                        cpTitle.Parent = ColorPickerPanel
                        
                        local c = Library.Flags[flag]
                        if type(c) == "table" then c = Color3.new(c["R"] or 1, c["G"] or 1, c["B"] or 1) end
                        local red, green, blue = math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)

                        local function makeColorSlider(name, yPos, initialVal, updateFunc)
                            local sLbl = Instance.new("TextLabel")
                            sLbl.Size = UDim2.new(1, -20, 0, 15)
                            sLbl.Position = UDim2.new(0, 10, 0, yPos)
                            sLbl.BackgroundTransparency = 1
                            sLbl.Font = Enum.Font.SourceSans
                            sLbl.Text = name .. ": " .. tostring(initialVal)
                            sLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
                            sLbl.TextSize = 12
                            sLbl.TextXAlignment = Enum.TextXAlignment.Left
                            sLbl.ZIndex = 4
                            sLbl.Parent = ColorPickerPanel

                            local sBar = Instance.new("Frame")
                            sBar.Size = UDim2.new(1, -20, 0, 6)
                            sBar.Position = UDim2.new(0, 10, 0, yPos + 16)
                            sBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                            sBar.BorderColor3 = Color3.fromRGB(60, 60, 60)
                            sBar.ZIndex = 4
                            sBar.Parent = ColorPickerPanel

                            local sFill = Instance.new("Frame")
                            sFill.Size = UDim2.new(initialVal / 255, 0, 1, 0)
                            sFill.BackgroundColor3 = Library.ThemeColor
                            sFill.BorderSizePixel = 0
                            sFill.ZIndex = 4
                            sFill.Parent = sBar

                            local draggingVal = false
                            sBar.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingVal = true end
                            end)
                            UserInputService.InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingVal = false end
                            end)
                            UserInputService.InputChanged:Connect(function(input)
                                if draggingVal and input.UserInputType == Enum.UserInputType.MouseMovement then
                                    local pos = math.clamp((input.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
                                    local val = math.floor(pos * 255)
                                    sFill.Size = UDim2.new(pos, 0, 1, 0)
                                    sLbl.Text = name .. ": " .. tostring(val)
                                    updateFunc(val)
                                end
                            end)
                        end
                        
                        makeColorSlider("Red", 30, red, function(v)
                            red = v
                            local newCol = Color3.fromRGB(red, green, blue)
                            Library.Flags[flag] = newCol
                            ColorDisplay.BackgroundColor3 = newCol
                            if callback then callback(newCol) end
                        end)
                        makeColorSlider("Green", 70, green, function(v)
                            green = v
                            local newCol = Color3.fromRGB(red, green, blue)
                            Library.Flags[flag] = newCol
                            ColorDisplay.BackgroundColor3 = newCol
                            if callback then callback(newCol) end
                        end)
                        makeColorSlider("Blue", 110, blue, function(v)
                            blue = v
                            local newCol = Color3.fromRGB(red, green, blue)
                            Library.Flags[flag] = newCol
                            ColorDisplay.BackgroundColor3 = newCol
                            if callback then callback(newCol) end
                        end)

                        ColorPickerPanel.Visible = true
                        ColorPickerPanel.BackgroundTransparency = 1
                        ColorPickerPanel.Size = UDim2.new(0, 180, 0, 140)
                        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        TweenService:Create(ColorPickerPanel, tweenInfo, {BackgroundTransparency = 0.25, Size = UDim2.new(0, 200, 0, 160)}):Play()
                    else
                        CloseColorPicker()
                    end
                end)

                table.insert(Library.ElementUpdaters, function()
                    local col = Library.Flags[flag]
                    if type(col) == "table" then
                        col = Color3.new(col["R"] or 1, col["G"] or 1, col["B"] or 1)
                        Library.Flags[flag] = col
                    end
                    if typeof(col) == "Color3" then
                        ColorDisplay.BackgroundColor3 = col
                        if callback then callback(col) end
                    end
                end)
            end

            -- 7. Toggle Button with Keybind
            function SubObj:AddToggleWithKey(text, defaultToggle, defaultKey, callback)
                local flagToggle = tabName .. "_" .. subTabName .. "_" .. text .. "_Toggle"
                local flagKey = tabName .. "_" .. subTabName .. "_" .. text .. "_Key"
                if type(Library.Flags[flagToggle]) ~= "boolean" then
                    Library.Flags[flagToggle] = (defaultToggle ~= nil) and defaultToggle or false
                end
                if Library.Flags[flagKey] == nil then
                    Library.Flags[flagKey] = defaultKey or Enum.KeyCode.None
                end

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -5, 0, 30)
                Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                Frame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                Frame.ZIndex = 3
                Frame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -170, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = Frame

                local ResetBtn = Instance.new("TextButton")
                ResetBtn.Size = UDim2.new(0, 40, 0, 20)
                ResetBtn.Position = UDim2.new(1, -165, 0.5, -10)
                ResetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                ResetBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
                ResetBtn.Font = Enum.Font.SourceSans
                ResetBtn.Text = "Reset"
                ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                ResetBtn.TextSize = 11
                ResetBtn.ZIndex = 3
                ResetBtn.Parent = Frame

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.new(0, 65, 0, 20)
                KeyBtn.Position = UDim2.new(1, -120, 0.5, -10)
                KeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                KeyBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
                KeyBtn.Font = Enum.Font.SourceSans
                KeyBtn.Text = (typeof(Library.Flags[flagKey]) == "EnumItem" and Library.Flags[flagKey] ~= Enum.KeyCode.None) and Library.Flags[flagKey].Name or "None"
                KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeyBtn.TextSize = 12
                KeyBtn.ZIndex = 3
                KeyBtn.Parent = Frame

                local Switch = Instance.new("TextButton")
                Switch.Size = UDim2.new(0, 40, 0, 18)
                Switch.Position = UDim2.new(1, -50, 0.5, -9)
                Switch.BackgroundColor3 = Library.Flags[flagToggle] and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
                Switch.BorderColor3 = Color3.fromRGB(60, 60, 60)
                Switch.Text = Library.Flags[flagToggle] and "ON" or "OFF"
                Switch.Font = Enum.Font.SourceSansBold
                Switch.TextColor3 = Color3.fromRGB(255, 255, 255)
                Switch.TextSize = 11
                Switch.ZIndex = 3
                Switch.Parent = Frame

                local function toggleAction()
                    Library.Flags[flagToggle] = not Library.Flags[flagToggle]
                    Switch.BackgroundColor3 = Library.Flags[flagToggle] and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
                    Switch.Text = Library.Flags[flagToggle] and "ON" or "OFF"
                    ShowPopup(text .. " is now " .. (Library.Flags[flagToggle] and "ON" or "OFF"))
                    if callback then callback(Library.Flags[flagToggle]) end
                end

                Switch.MouseButton1Click:Connect(toggleAction)

                local binding = false
                KeyBtn.MouseButton1Click:Connect(function()
                    binding = true
                    KeyBtn.Text = "..."
                end)

                ResetBtn.MouseButton1Click:Connect(function()
                    binding = false
                    Library.Flags[flagKey] = Enum.KeyCode.None
                    KeyBtn.Text = "None"
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if binding then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Library.Flags[flagKey] = input.KeyCode
                            KeyBtn.Text = input.KeyCode.Name
                            binding = false
                        end
                    elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and Library.Flags[flagKey] ~= Enum.KeyCode.None and input.KeyCode == Library.Flags[flagKey] then
                        toggleAction()
                    end
                end)

                table.insert(Library.ElementUpdaters, function()
                    local tVal = Library.Flags[flagToggle]
                    local kVal = Library.Flags[flagKey]
                    if type(kVal) == "string" then
                        pcall(function()
                            if kVal == "None" then
                                Library.Flags[flagKey] = Enum.KeyCode.None
                            else
                                Library.Flags[flagKey] = Enum.KeyCode[kVal] or Enum.KeyCode.None
                            end
                        end)
                        kVal = Library.Flags[flagKey]
                    end
                    if tVal ~= nil then
                        Switch.BackgroundColor3 = tVal and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
                        Switch.Text = tVal and "ON" or "OFF"
                        if callback then callback(tVal) end
                    end
                    if kVal ~= nil and typeof(kVal) == "EnumItem" then
                        KeyBtn.Text = (kVal ~= Enum.KeyCode.None) and kVal.Name or "None"
                    end
                end)
            end

            -- 8. Text Field
            function SubObj:AddTextBox(text, placeholder, callback)
                local flag = tabName .. "_" .. subTabName .. "_" .. text
                if type(Library.Flags[flag]) ~= "string" then
                    Library.Flags[flag] = ""
                end

                local TextFrame = Instance.new("Frame")
                TextFrame.Size = UDim2.new(1, -5, 0, 30)
                TextFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                TextFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                TextFrame.ZIndex = 3
                TextFrame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -135, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = TextFrame

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(0, 120, 0, 22)
                Box.Position = UDim2.new(1, -125, 0.5, -11)
                Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Box.BorderColor3 = Color3.fromRGB(60, 60, 60)
                Box.Font = Enum.Font.SourceSans
                Box.PlaceholderText = placeholder or "Enter Text..."
                Box.Text = tostring(Library.Flags[flag])
                Box.TextColor3 = Color3.fromRGB(255, 255, 255)
                Box.TextSize = 12
                Box.ZIndex = 3
                Box.Parent = TextFrame

                Box.FocusLost:Connect(function(enterPressed)
                    Library.Flags[flag] = Box.Text
                    if callback then callback(Box.Text, enterPressed) end
                end)

                table.insert(Library.ElementUpdaters, function()
                    local val = Library.Flags[flag]
                    if val ~= nil then
                        Box.Text = tostring(val)
                        if callback then callback(tostring(val), false) end
                    end
                end)
            end

            -- 9. Simple Button
            function SubObj:AddButton(text, callback)
                local BtnFrame = Instance.new("Frame")
                BtnFrame.Size = UDim2.new(1, -5, 0, 30)
                BtnFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                BtnFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                BtnFrame.ZIndex = 3
                BtnFrame.Parent = ElementScroll

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -110, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.SourceSans
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 3
                Label.Parent = BtnFrame

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(0, 95, 0, 22)
                Button.Position = UDim2.new(1, -100, 0.5, -11)
                Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Button.BorderColor3 = Color3.fromRGB(60, 60, 60)
                Button.Font = Enum.Font.SourceSans
                Button.Text = "Click"
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.TextSize = 12
                Button.ZIndex = 3
                Button.Parent = BtnFrame

                Button.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end

            return SubObj
        end

        table.insert(sideTabs, TabObj)
        firstSideTab = false
        return TabObj
    end

    function Window:AddFilterItem(itemName, default, callback)
        local flag = "Filter_" .. itemName
        if Library.Flags[flag] == nil then
            Library.Flags[flag] = (default ~= nil) and default or false
        end

        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, -5, 0, 30)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ItemFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
        ItemFrame.ZIndex = 4
        ItemFrame.Parent = FilterScroll

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -55, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.SourceSans
        Label.Text = itemName
        Label.TextColor3 = Color3.fromRGB(240, 240, 240)
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 4
        Label.Parent = ItemFrame

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 40, 0, 18)
        Switch.Position = UDim2.new(1, -45, 0.5, -9)
        Switch.BackgroundColor3 = Library.Flags[flag] and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
        Switch.BorderColor3 = Color3.fromRGB(60, 60, 60)
        Switch.Text = Library.Flags[flag] and "ON" or "OFF"
        Switch.Font = Enum.Font.SourceSansBold
        Switch.TextColor3 = Color3.fromRGB(255, 255, 255)
        Switch.TextSize = 11
        Switch.ZIndex = 4
        Switch.Parent = ItemFrame

                Switch.MouseButton1Click:Connect(function()
                    Library.Flags[flag] = not Library.Flags[flag]
                    Switch.BackgroundColor3 = Library.Flags[flag] and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
                    Switch.Text = Library.Flags[flag] and "ON" or "OFF"
                    ShowPopup(itemName .. " is now " .. (Library.Flags[flag] and "ON" or "OFF"))
                    
                    if callback then callback(Library.Flags[flag]) end
                end)

        table.insert(Library.ElementUpdaters, function()
            local val = Library.Flags[flag]
            if val ~= nil then
                Switch.BackgroundColor3 = val and Library.ThemeColor or Color3.fromRGB(35, 35, 35)
                Switch.Text = val and "ON" or "OFF"
                if callback then callback(val) end
            end
        end)
    end

    Library.LoadSettings()
    
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Size = UDim2.new(0, 350, 0, 150)
    LoadingFrame.Position = UDim2.new(0.5, -175, 0.5, -75)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    LoadingFrame.BorderColor3 = Library.ThemeColor
    LoadingFrame.BorderSizePixel = 1
    LoadingFrame.BackgroundTransparency = 0.25
    LoadingFrame.ZIndex = 9999
    LoadingFrame.Parent = ScreenGui

    local TitleLabelLoad = Instance.new("TextLabel")
    TitleLabelLoad.Size = UDim2.new(1, 0, 0, 30)
    TitleLabelLoad.Position = UDim2.new(0, 0, 0, 20)
    TitleLabelLoad.BackgroundTransparency = 1
    TitleLabelLoad.Font = Enum.Font.SourceSansBold
    TitleLabelLoad.Text = (titleText or "GUI Library")
    TitleLabelLoad.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabelLoad.TextSize = 18
    TitleLabelLoad.ZIndex = 10000
    TitleLabelLoad.Parent = LoadingFrame

    local SubTextLoad = Instance.new("TextLabel")
    SubTextLoad.Size = UDim2.new(1, 0, 0, 30)
    SubTextLoad.Position = UDim2.new(0, 0, 0, 60)
    SubTextLoad.BackgroundTransparency = 1
    SubTextLoad.Font = Enum.Font.SourceSans
    SubTextLoad.Text = "Loading Interface..."
    SubTextLoad.TextColor3 = Color3.fromRGB(200, 200, 200)
    SubTextLoad.TextSize = 15
    SubTextLoad.ZIndex = 10000
    SubTextLoad.Parent = LoadingFrame

    local BarBG = Instance.new("Frame")
    BarBG.Size = UDim2.new(1, -60, 0, 4) -- Dünner Ladebalken wie auf Skizze
    BarBG.Position = UDim2.new(0, 30, 0, 110)
    BarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBG.BorderColor3 = Color3.fromRGB(10, 10, 10)
    BarBG.BorderSizePixel = 1
    BarBG.ZIndex = 10000
    BarBG.Parent = LoadingFrame

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Library.ThemeColor -- Anpassung an das Farbthema
    BarFill.BorderSizePixel = 0
    BarFill.ZIndex = 10001
    BarFill.Parent = BarBG

    task.spawn(function()
        local loadTween = TweenService:Create(BarFill, TweenInfo.new(2, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
        loadTween:Play()
        loadTween.Completed:Wait()
        
        SubTextLoad.Text = "Finished!"
        task.wait(0.5)
        
        -- Fade Out
        TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        TweenService:Create(TitleLabelLoad, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
        TweenService:Create(SubTextLoad, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
        TweenService:Create(BarBG, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        
        task.wait(0.5)
        LoadingFrame:Destroy()
        
        MainFrame.Visible = true
        ToggleMainMenu(true) 
    end)
    return Window
end
return Library