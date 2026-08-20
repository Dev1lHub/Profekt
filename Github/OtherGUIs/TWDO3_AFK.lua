-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI Erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportSystemGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Hauptfenster (Main Frame - Leicht transparent)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 240)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Der Rahmen
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(45, 45, 45)
uiStroke.Thickness = 2
uiStroke.Parent = mainFrame

-- Header (Überschrift - Leicht transparent)
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
header.BackgroundTransparency = 0.25
header.BorderSizePixel = 0
header.Text = "AFK SYSTEM"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.TextSize = 15
header.Font = Enum.Font.GothamBold
header.Parent = mainFrame

-- Rote Akzentlinie unter dem Header
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 3)
accentLine.Position = UDim2.new(0, 0, 0, 45)
accentLine.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
accentLine.BorderSizePixel = 0
accentLine.Parent = mainFrame

-- Slider Label (Anzeige für die Distanz)
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -40, 0, 20)
sliderLabel.Position = UDim2.new(0, 20, 0, 65)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "TELEPORT DISTANCE: 10 STUDS"
sliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
sliderLabel.TextSize = 13
sliderLabel.Font = Enum.Font.GothamMedium
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = mainFrame

-- Slider Leiste (Hintergrund)
local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1, -40, 0, 8)
sliderBar.Position = UDim2.new(0, 20, 0, 95)
sliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = mainFrame

-- Slider Füllung (Rot)
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.1, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBar

-- Unsichtbarer Button zum Greifen des Sliders
local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(1, 0, 1, 0)
sliderButton.BackgroundTransparency = 1
sliderButton.Text = ""
sliderButton.Parent = sliderBar

-- Toggle Container (Box für den Schalter)
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(1, -40, 0, 50)
toggleContainer.Position = UDim2.new(0, 20, 0, 135)
toggleContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleContainer.BorderSizePixel = 0
toggleContainer.Parent = mainFrame

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
toggleLabel.Position = UDim2.new(0, 15, 0, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "AFK MODE"
toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel.TextSize = 14
toggleLabel.Font = Enum.Font.GothamMedium
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = toggleContainer

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 80, 0, 32)
toggleBtn.Position = UDim2.new(1, -95, 0.5, -16)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = toggleContainer

----------------------------------------------------
-- DRAG & DROP LOGIK
----------------------------------------------------
local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

----------------------------------------------------
-- SLIDER FUNKTION
----------------------------------------------------
local teleportDistance = 10
local isToggled = false
local originalCFrame = nil
local sliderDragging = false

local function updateSlider(input)
    local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
    teleportDistance = math.floor(pos * 100)
    sliderLabel.Text = "TELEPORT DISTANCE: " .. teleportDistance .. " STUDS"
end

sliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- Toggle-Logik (Mit 0.3 Sekund Verzögerung vor dem Ankern)
toggleBtn.MouseButton1Click:Connect(function()
    isToggled = not isToggled
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end

    if isToggled then
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
        
        originalCFrame = rootPart.CFrame
        rootPart.CFrame = originalCFrame - Vector3.new(0, teleportDistance, 0)
        
        -- 0.3 Sekunden warten, damit der Server die neue Position verarbeiten kann, dann erst ankern
        task.spawn(function()
            task.wait(0.3)
            if isToggled and character and character.Parent then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
            end
        end)
    else
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        -- Sofortiges Entankern
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
        
        if originalCFrame then
            rootPart.CFrame = originalCFrame
        end
    end
end)