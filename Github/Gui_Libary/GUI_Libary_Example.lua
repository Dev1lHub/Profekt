-- ==========================================
-- 1. VORBEREITUNG & SETUP
-- ==========================================

-- HIER DEN LINK ZUR RAW-DATEI DER BIBLIOTHEK EINTRAGEN
local gui_link = "https://raw.githubusercontent.com/PyroX5343/RobloxCheats/refs/heads/main/Gui_Libary/GUI_Libary.lua"
local Library = loadstring(game:HttpGet(gui_link))()
-- Die Tabelle für alle unsere Funktionen
local Actions = {}


-- ==========================================
-- 2. GUI ERSTELLEN (MENÜS & ELEMENTE)
-- ==========================================

local ConfigFolderName = "TWDO3"
Library.ConfigFolder = ConfigFolderName

local ThemeColor = Color3.fromRGB(0, 150, 255) 
local MyWindow = Library.New("Example GUI", ThemeColor)

-- Tabs erstellen
local Tab1 = MyWindow:AddTab("tab 1")
MyWindow:AddTab("tab 2")
MyWindow:AddTab("tab 3")
MyWindow:AddTab("tab 4")

-- Sub-Tabs für Tab 1 erstellen
local Sub1 = Tab1:AddSubTab("Sub Tab 1")
local Sub2 = Tab1:AddSubTab("Sub Tab 2")
local Sub3 = Tab1:AddSubTab("Sub Tab 3")
local Sub4 = Tab1:AddSubTab("Sub Tab 4")
local Sub5 = Tab1:AddSubTab("Sub Tab 5")

-- ================= SHOWCASE ALLER ELEMENTE ================= --

Sub1:AddToggle("Toggel Button", false, function(v) Actions.Toggle(v) end)
Sub1:AddSlider("Set Value", 0, 100, 25, function(v) Actions.Slider(v) end)
Sub1:AddKeybind("Set Key", Enum.KeyCode.None, function(key) Actions.Keybind(key) end)
Sub1:AddDropdown("Set Methode", {"1", "2", "3", "4"}, false, "1", function(opt) Actions.Dropdown(opt) end)
Sub1:AddFilterButton("Set Filter") 
Sub1:AddColorPicker("Set Color", Color3.fromRGB(255, 255, 255), function(col) Actions.ColorPicker(col) end)
Sub1:AddToggleWithKey("Toggel Button With Set key", false, Enum.KeyCode.None, function(v) Actions.ToggleWithKey(v) end)
Sub1:AddDropdown("Drop Down", {"Option A", "Option B", "Option C"}, true, nil, function(optTable) Actions.MultiDropdown(optTable) end)
Sub1:AddTextBox("Text Field", "Enter Text...", function(text, enterPressed) Actions.TextBox(text, enterPressed) end)
Sub1:AddButton("Simple Button", function() Actions.SimpleButton() end)
-- 10 Filter-Items per Schleife im rechten Panel generieren
for i = 1, 10 do
    MyWindow:AddFilterItem("Loot_Item " .. i, false, function(state) 
        Actions.FilterItem(i, state) 
    end)
end


-- ==========================================
-- 3. FUNKTIONEN & LOGIK (CALLBACKS)
-- ==========================================

function Actions.Toggle(v)
    print("Toggle changed to:", v)
end

function Actions.Slider(v)
    print("Slider value:", v)
end

function Actions.Keybind(key)
    print("Key pressed:", key.Name)
end

function Actions.Dropdown(opt)
    print("Method selected:", opt)
end

function Actions.ColorPicker(col)
    print("Color selected:", col)
end

function Actions.ToggleWithKey(v)
    print("Toggle with key state:", v)
end

function Actions.MultiDropdown(optTable)
    for k, v in pairs(optTable) do
        if v then 
            print("Multi-Select active:", k) 
        end
    end
end

function Actions.TextBox(text, enterPressed)
    print("Text entered:", text)
end

function Actions.SimpleButton()
    print("Simple button clicked!")
end

function Actions.FilterItem(index, state)
    print("Filter Item " .. index .. " is:", state)
end