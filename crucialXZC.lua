--==================================================
-- crucialAT v2
-- Combat / Visual / Settings
-- PC + MOBILE
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- PREVIOUS INSTANCE
--==================================================

if _G.crucialAT_Unload then
pcall(_G.crucialAT_Unload)
end

--==================================================
-- CHARACTER
--==================================================

local Character =
LocalPlayer.Character
or LocalPlayer.CharacterAdded:Wait()

local Humanoid =
Character:WaitForChild("Humanoid")

--==================================================
-- DEFAULT SETTINGS
--==================================================

local Defaults = {

-- AIM  
Enabled = false,  
Smoothness = 0.2,  
FOV = 12,  
TargetMode = "Head",  
MaxDistance = 120,  
Prediction = 0,  

-- TRIGGER  
TriggerbotEnabled = false,  
TriggerDelay = 0.05,  

-- CHECKS  
TeamCheck = true,  
WallCheck = true,  

-- ESP  
ESPEnabled = false,  
ESPNames = false,  
ESPDistance = false,  
ESPHealth = false,  

-- VISUAL  
ShowFOV = true,  
FOVOffsetX = 0,
FOVOffsetY = 0,

-- KEYS  
AimbotKey = Enum.KeyCode.Q,  
TriggerKey = Enum.KeyCode.T

}

local Settings = {}

for key, value in pairs(Defaults) do
Settings[key] = value
end

--==================================================
-- STATE
--==================================================

local Unloaded = false
local Connections = {}
local ESPObjects = {}

local lastFireTime = 0

--==================================================
-- COLORS
--==================================================

local COLORS = {

Background = Color3.fromRGB(38, 4, 7),  
Background2 = Color3.fromRGB(24, 3, 5),  

Panel = Color3.fromRGB(48, 5, 9),  
PanelDark = Color3.fromRGB(30, 3, 6),  

Red = Color3.fromRGB(105, 12, 18),  
RedLight = Color3.fromRGB(145, 20, 28),  
RedDark = Color3.fromRGB(67, 7, 12),  

Text = Color3.fromRGB(245, 245, 245),  
SubText = Color3.fromRGB(180, 180, 180),  

ESP = Color3.fromRGB(255, 65, 75)

}

--==================================================
-- CONNECTION MANAGER
--==================================================

local function connect(signal, callback)

local connection = signal:Connect(callback)  

table.insert(  
	Connections,  
	connection  
)  

return connection

end

local function disconnectAll()

for _, connection in ipairs(Connections) do  

	if connection  
		and connection.Connected then  

		connection:Disconnect()  
	end  
end  

table.clear(Connections)

end

--==================================================
-- TWEEN
--==================================================

local function tween(object, properties, duration)

local info =  
	TweenInfo.new(  
		duration or 0.2,  
		Enum.EasingStyle.Quart,  
		Enum.EasingDirection.Out  
	)  

return TweenService:Create(  
	object,  
	info,  
	properties  
)

end

--==================================================
-- REMOVE OLD GUI
--==================================================

local oldGUI =
PlayerGui:FindFirstChild("crucialAT")

if oldGUI then
oldGUI:Destroy()
end

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui =
Instance.new("ScreenGui")

ScreenGui.Name = "crucialAT"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior =
Enum.ZIndexBehavior.Sibling

ScreenGui.Parent = PlayerGui

--==================================================
-- UI SCALE
--==================================================

local UIScale =
Instance.new("UIScale")

UIScale.Scale = 0.92
UIScale.Parent = ScreenGui

--==================================================
-- MAIN FRAME
--==================================================

local MainFrame =
Instance.new("Frame")

MainFrame.Name = "MainFrame"

MainFrame.Size =
UDim2.new(
0,
820,
0,
420
)

MainFrame.Position =
UDim2.new(
0.5,
-410,
0.5,
-210
)

MainFrame.BackgroundColor3 =
COLORS.Background

MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner =
Instance.new("UICorner")

MainCorner.CornerRadius =
UDim.new(0, 14)

MainCorner.Parent = MainFrame

local MainStroke =
Instance.new("UIStroke")

MainStroke.Color = COLORS.Red
MainStroke.Transparency = 0.25
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

--==================================================
-- TOP BAR
--==================================================

local TopBar =
Instance.new("Frame")

TopBar.Size =
UDim2.new(
1,
0,
0,
54
)

TopBar.BackgroundColor3 =
COLORS.Background2

TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

--==================================================
-- TITLE
--==================================================

local Title =
Instance.new("TextLabel")

Title.Size =
UDim2.new(
0,
300,
0,
34
)

Title.Position =
UDim2.new(
0,
20,
0,
5
)

Title.BackgroundTransparency = 1
Title.Text = "crucialAT"
Title.TextColor3 = COLORS.Text
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment =
Enum.TextXAlignment.Left

Title.Parent = TopBar

--==================================================
-- SUBTITLE
--==================================================

local Subtitle =
Instance.new("TextLabel")

Subtitle.Size =
UDim2.new(
0,
300,
0,
18
)

Subtitle.Position =
UDim2.new(
0,
21,
0,
30
)

Subtitle.BackgroundTransparency = 1
Subtitle.Text = "combat interface"
Subtitle.TextColor3 = COLORS.SubText
Subtitle.TextSize = 10
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment =
Enum.TextXAlignment.Left

Subtitle.Parent = TopBar

--==================================================
-- TOP BUTTON FACTORY
--==================================================

local function createTopButton(text, offset)

local button =  
	Instance.new("TextButton")  

button.Size =  
	UDim2.new(  
		0,  
		38,  
		0,  
		36  
	)  

button.Position =  
	UDim2.new(  
		1,  
		offset,  
		0,  
		9  
	)  

button.BackgroundColor3 = COLORS.Panel  
button.Text = text  
button.TextColor3 = COLORS.Text  
button.TextSize = 17  
button.Font = Enum.Font.GothamBold  
button.AutoButtonColor = false  
button.Parent = TopBar  

local corner =  
	Instance.new("UICorner")  

corner.CornerRadius =  
	UDim.new(0, 8)  

corner.Parent = button  

connect(  
	button.MouseEnter,  
	function()  

		tween(  
			button,  
			{  
				BackgroundColor3 =  
					COLORS.Red  
			},  
			0.12  
		):Play()  
	end  
)  

connect(  
	button.MouseLeave,  
	function()  

		tween(  
			button,  
			{  
				BackgroundColor3 =  
					COLORS.Panel  
			},  
			0.12  
		):Play()  
	end  
)  

return button

end

--==================================================
-- TOP BUTTONS
--==================================================

local MinimizeButton =
createTopButton("—", -130)

local DragButton =
createTopButton("↔", -84)

local UnloadButton =
createTopButton("×", -40)

--==================================================
-- CONTENT
--==================================================

local Content =
Instance.new("Frame")

Content.Size =
UDim2.new(
1,
0,
1,
-54
)

Content.Position =
UDim2.new(
0,
0,
0,
54
)

Content.BackgroundTransparency = 1
Content.Parent = MainFrame

--==================================================
-- SIDEBAR
--==================================================

local Sidebar =
Instance.new("Frame")

Sidebar.Size =
UDim2.new(
0,
170,
1,
0
)

Sidebar.BackgroundColor3 =
COLORS.Background2

Sidebar.BorderSizePixel = 0
Sidebar.Parent = Content

--==================================================
-- PAGE CONTAINER
--==================================================

local PageContainer =
Instance.new("Frame")

PageContainer.Size =
UDim2.new(
1,
-190,
1,
-20
)

PageContainer.Position =
UDim2.new(
0,
180,
0,
10
)

PageContainer.BackgroundTransparency = 1
PageContainer.Parent = Content

--==================================================
-- PAGES
--==================================================

local Pages = {}
local TabButtons = {}

local function createPage(name)

local page =  
	Instance.new("Frame")  

page.Name = name  

page.Size =  
	UDim2.new(  
		1,  
		0,  
		1,  
		0  
	)  

page.BackgroundTransparency = 1  
page.Visible = false  
page.Parent = PageContainer  

Pages[name] = page  

return page

end

local CombatPage =
createPage("Combat")

local VisualPage =
createPage("Visual")

local SettingsPage =
createPage("Settings")

--==================================================
-- TAB CREATOR
--==================================================

local function createTab(name, text, y)

local button =  
	Instance.new("TextButton")  

button.Size =  
	UDim2.new(  
		1,  
		-20,  
		0,  
		44  
	)  

button.Position =  
	UDim2.new(  
		0,  
		10,  
		0,  
		y  
	)  

button.BackgroundColor3 =  
	COLORS.Background2  

button.Text = text  
button.TextColor3 = COLORS.SubText  
button.TextSize = 13  
button.Font = Enum.Font.GothamBold  
button.AutoButtonColor = false  
button.Parent = Sidebar  

local corner =  
	Instance.new("UICorner")  

corner.CornerRadius =  
	UDim.new(0, 9)  

corner.Parent = button  

TabButtons[name] = button  

connect(  
	button.MouseButton1Click,  
	function()  

		for pageName, page in pairs(Pages) do  
			page.Visible =  
				pageName == name  
		end  

		for buttonName, tab in pairs(TabButtons) do  

			local selected =  
				buttonName == name  

			tab.BackgroundColor3 =  
				selected  
				and COLORS.Red  
				or COLORS.Background2  

			tab.TextColor3 =  
				selected  
				and COLORS.Text  
				or COLORS.SubText  
		end  
	end  
)  

return button

end

createTab("Combat", "COMBAT", 20)
createTab("Visual", "VISUAL", 76)
createTab("Settings", "CONFIGURACIONES", 132)

--==================================================
-- LABEL FACTORY
--==================================================

local function createLabel(
parent,
text,
x,
y,
width
)

local label =  
	Instance.new("TextLabel")  

label.Size =  
	UDim2.new(  
		0,  
		width or 220,  
		0,  
		20  
	)  

label.Position =  
	UDim2.new(  
		0,  
		x,  
		0,  
		y  
	)  

label.BackgroundTransparency = 1  
label.Text = text  
label.TextColor3 = COLORS.SubText  
label.TextSize = 11  
label.Font = Enum.Font.GothamMedium  
label.TextXAlignment =  
	Enum.TextXAlignment.Left  

label.Parent = parent  

return label

end

--==================================================
-- INPUT FACTORY
--==================================================

local function createInput(
parent,
text,
x,
y,
width
)

local box =  
	Instance.new("TextBox")  

box.Size =  
	UDim2.new(  
		0,  
		width or 280,  
		0,  
		38  
	)  

box.Position =  
	UDim2.new(  
		0,  
		x,  
		0,  
		y  
	)  

box.BackgroundColor3 =  
	COLORS.PanelDark  

box.Text = text  
box.TextColor3 = COLORS.Text  
box.TextSize = 13  
box.Font = Enum.Font.Gotham  
box.ClearTextOnFocus = false  
box.TextXAlignment =  
	Enum.TextXAlignment.Center  

box.Parent = parent  

local corner =  
	Instance.new("UICorner")  

corner.CornerRadius =  
	UDim.new(0, 8)  

corner.Parent = box  

local stroke =  
	Instance.new("UIStroke")  

stroke.Color =  
	COLORS.RedDark  

stroke.Transparency = 0.2  
stroke.Parent = box  

return box

end

--==================================================
-- TOGGLE FACTORY
--==================================================

local function createToggle(
parent,
text,
x,
y,
callback,
defaultState
)

local button =  
	Instance.new("TextButton")  

button.Size =  
	UDim2.new(  
		0,  
		300,  
		0,  
		40  
	)  

button.Position =  
	UDim2.new(  
		0,  
		x,  
		0,  
		y  
	)  

button.BackgroundColor3 =  
	COLORS.PanelDark  

button.TextColor3 =  
	COLORS.Text  

button.TextSize = 12  
button.Font = Enum.Font.GothamBold  
button.AutoButtonColor = false  
button.Parent = parent  

local corner =  
	Instance.new("UICorner")  

corner.CornerRadius =  
	UDim.new(0, 8)  

corner.Parent = button  

local enabled =  
	defaultState == true  

local function updateVisual()  

	button.Text =  
		text  
		.. ": "  
		.. (  
			enabled  
			and "ON"  
			or "OFF"  
		)  

	button.BackgroundColor3 =  
		enabled  
		and COLORS.Red  
		or COLORS.PanelDark  
end  

updateVisual()  

connect(  
	button.MouseButton1Click,  
	function()  

		enabled =  
			not enabled  

		callback(enabled)  
		updateVisual()  
	end  
)  

local controller = {}  

controller.Button = button  

controller.SetState =  
	function(value)  

		enabled =  
			value == true  

		updateVisual()  
	end  

controller.GetState =  
	function()  
		return enabled  
	end  

return controller

end

--==================================================
-- COMBAT PAGE
--==================================================

local CombatTitle =
Instance.new("TextLabel")

CombatTitle.Size =
UDim2.new(
1,
0,
0,
32
)

CombatTitle.BackgroundTransparency = 1
CombatTitle.Text = "Combat"
CombatTitle.TextColor3 = COLORS.Text
CombatTitle.TextSize = 18
CombatTitle.Font = Enum.Font.GothamBold
CombatTitle.TextXAlignment =
Enum.TextXAlignment.Left

CombatTitle.Parent = CombatPage

local AimToggle =
createToggle(
CombatPage,
"Aimbot",
0,
45,
function(value)
Settings.Enabled = value
end,
Settings.Enabled
)

local TriggerToggle =
createToggle(
CombatPage,
"Triggerbot",
320,
45,
function(value)
Settings.TriggerbotEnabled = value
end,
Settings.TriggerbotEnabled
)

createLabel(
CombatPage,
"Smoothness",
0,
98
)

local SmoothBox =
createInput(
CombatPage,
"0.2",
0,
121,
300
)

createLabel(
CombatPage,
"FOV",
320,
98
)

local FOVBox =
createInput(
CombatPage,
"12",
320,
121,
300
)

createLabel(
CombatPage,
"Target",
0,
174
)

local TargetButtons = {}

local function createTargetButton(text, x)

local button =  
	Instance.new("TextButton")  

button.Size =  
	UDim2.new(  
		0,  
		95,  
		0,  
		36  
	)  

button.Position =  
	UDim2.new(  
		0,  
		x,  
		0,  
		198  
	)  

button.BackgroundColor3 =  
	COLORS.PanelDark  

button.Text = text  
button.TextColor3 = COLORS.Text  
button.TextSize = 11  
button.Font = Enum.Font.GothamBold  
button.AutoButtonColor = false  
button.Parent = CombatPage  

local corner =  
	Instance.new("UICorner")  

corner.CornerRadius =  
	UDim.new(0, 8)  

corner.Parent = button  

TargetButtons[text] = button  

connect(  
	button.MouseButton1Click,  
	function()  

		Settings.TargetMode = text  

		for mode, targetButton in pairs(  
			TargetButtons  
		) do  

			targetButton.BackgroundColor3 =  
				mode == Settings.TargetMode  
				and COLORS.Red  
				or COLORS.PanelDark  
		end  
	end  
)  

return button

end

createTargetButton("Head", 0)
createTargetButton("Torso", 105)
createTargetButton("Closest", 210)

TargetButtons.Head.BackgroundColor3 =
COLORS.Red

createLabel(
CombatPage,
"Trigger delay (ms)",
320,
174
)

local DelayBox =
createInput(
CombatPage,
"50",
320,
198,
140
)

createLabel(
CombatPage,
"CPS",
475,
174
)

local CPSBox =
createInput(
CombatPage,
"20",
475,
198,
145
)

createLabel(
CombatPage,
"Prediction",
0,
250
)

local PredictionBox =
createInput(
CombatPage,
"0",
0,
273,
300
)

local TeamToggle =
createToggle(
CombatPage,
"Team check",
320,
250,
function(value)
Settings.TeamCheck = value
end,
Settings.TeamCheck
)

local WallToggle =
createToggle(
CombatPage,
"Wall check",
320,
296,
function(value)
Settings.WallCheck = value
end,
Settings.WallCheck
)

--==================================================
-- VISUAL PAGE
--==================================================

local VisualTitle =
Instance.new("TextLabel")

VisualTitle.Size =
UDim2.new(
1,
0,
0,
32
)

VisualTitle.BackgroundTransparency = 1
VisualTitle.Text = "Visual"
VisualTitle.TextColor3 = COLORS.Text
VisualTitle.TextSize = 18
VisualTitle.Font = Enum.Font.GothamBold
VisualTitle.TextXAlignment =
Enum.TextXAlignment.Left

VisualTitle.Parent = VisualPage

local ESPToggle =
createToggle(
VisualPage,
"ESP",
0,
48,
function(value)
Settings.ESPEnabled = value
end,
Settings.ESPEnabled
)

local NamesToggle =
createToggle(
VisualPage,
"Names",
320,
48,
function(value)
Settings.ESPNames = value
end,
Settings.ESPNames
)

local DistanceToggle =
createToggle(
VisualPage,
"Distance",
0,
96,
function(value)
Settings.ESPDistance = value
end,
Settings.ESPDistance
)

local HealthToggle =
createToggle(
VisualPage,
"Health",
320,
96,
function(value)
Settings.ESPHealth = value
end,
Settings.ESPHealth
)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle =
Instance.new("Frame")

FOVCircle.Name = "FOVCircle"

FOVCircle.AnchorPoint =
Vector2.new(0.5, 0.5)

FOVCircle.Position =
UDim2.fromScale(0.5, 0.5)

FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Parent = ScreenGui

local FOVCorner =
Instance.new("UICorner")

FOVCorner.CornerRadius =
UDim.new(1, 0)

FOVCorner.Parent = FOVCircle

local FOVStroke =
Instance.new("UIStroke")

FOVStroke.Color = COLORS.RedLight
FOVStroke.Transparency = 0.35
FOVStroke.Thickness = 1
FOVStroke.Parent = FOVCircle

local function updateFOV()

local camera =  
	workspace.CurrentCamera  

if not camera then  
	return  
end  

local viewport =  
	camera.ViewportSize  

local smaller =  
	math.min(  
		viewport.X,  
		viewport.Y  
	)  

local radius =  
	(Settings.FOV / 45)  
	* (smaller * 0.45)  

FOVCircle.Size =  
	UDim2.fromOffset(  
		radius * 2,  
		radius * 2  
	)

FOVCircle.Position =
	UDim2.new(
		0.5,
		Settings.FOVOffsetX,
		0.5,
		Settings.FOVOffsetY
	)

FOVCircle.Visible =  
	Settings.ShowFOV

end

local FOVToggle =
createToggle(
VisualPage,
"FOV circle",
0,
144,
function(value)

Settings.ShowFOV = value  
		updateFOV()  
	end,  
	Settings.ShowFOV  
)

--==================================================
-- FOV OFFSET CONTROLS
--==================================================

createLabel(
VisualPage,
"FOV Position",
0,
198
)

-- label que muestra offset actual
local FOVOffsetLabel =
Instance.new("TextLabel")

FOVOffsetLabel.Size =
UDim2.new(
0,
300,
0,
18
)

FOVOffsetLabel.Position =
UDim2.new(
0,
0,
0,
218
)

FOVOffsetLabel.BackgroundTransparency = 1
FOVOffsetLabel.Text = "X: 0  Y: 0"
FOVOffsetLabel.TextColor3 = COLORS.SubText
FOVOffsetLabel.TextSize = 11
FOVOffsetLabel.Font = Enum.Font.Gotham
FOVOffsetLabel.TextXAlignment =
Enum.TextXAlignment.Left

FOVOffsetLabel.Parent = VisualPage

local function updateOffsetLabel()
	FOVOffsetLabel.Text =
		"X: " .. Settings.FOVOffsetX
		.. "  Y: " .. Settings.FOVOffsetY
end

-- fábrica de botones de flecha
local ARROW_STEP = 5

local function createArrowButton(label, x, y, dx, dy)

	local btn =
		Instance.new("TextButton")

	btn.Size =
		UDim2.new(
			0,
			44,
			0,
			36
		)

	btn.Position =
		UDim2.new(
			0,
			x,
			0,
			y
		)

	btn.BackgroundColor3 = COLORS.PanelDark
	btn.Text = label
	btn.TextColor3 = COLORS.Text
	btn.TextSize = 16
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = false
	btn.Parent = VisualPage

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0, 8)

	corner.Parent = btn

	connect(
		btn.MouseEnter,
		function()
			tween(
				btn,
				{ BackgroundColor3 = COLORS.Red },
				0.1
			):Play()
		end
	)

	connect(
		btn.MouseLeave,
		function()
			tween(
				btn,
				{ BackgroundColor3 = COLORS.PanelDark },
				0.1
			):Play()
		end
	)

	connect(
		btn.MouseButton1Click,
		function()
			Settings.FOVOffsetX =
				Settings.FOVOffsetX + (dx * ARROW_STEP)
			Settings.FOVOffsetY =
				Settings.FOVOffsetY + (dy * ARROW_STEP)
			updateOffsetLabel()
			updateFOV()
		end
	)

	return btn
end

-- layout: ↑ centrado, ← ↓ →
-- ↑  at x=52
createArrowButton("↑",  52, 240,  0, -1)
-- ← at x=0, ↓ at x=52, → at x=104
createArrowButton("←",   0, 282, -1,  0)
createArrowButton("↓",  52, 282,  0,  1)
createArrowButton("→", 104, 282,  1,  0)

-- botón reset center
local FOVResetBtn =
Instance.new("TextButton")

FOVResetBtn.Size =
UDim2.new(
0,
140,
0,
36
)

FOVResetBtn.Position =
UDim2.new(
0,
160,
0,
282
)

FOVResetBtn.BackgroundColor3 = COLORS.RedDark
FOVResetBtn.Text = "Reset center"
FOVResetBtn.TextColor3 = COLORS.Text
FOVResetBtn.TextSize = 12
FOVResetBtn.Font = Enum.Font.GothamBold
FOVResetBtn.AutoButtonColor = false
FOVResetBtn.Parent = VisualPage

local fovResetCorner =
Instance.new("UICorner")

fovResetCorner.CornerRadius =
UDim.new(0, 8)

fovResetCorner.Parent = FOVResetBtn

connect(
FOVResetBtn.MouseButton1Click,
function()
	Settings.FOVOffsetX = 0
	Settings.FOVOffsetY = 0
	updateOffsetLabel()
	updateFOV()
end
)

--==================================================
-- SETTINGS PAGE
--==================================================

local SettingsTitle =
Instance.new("TextLabel")

SettingsTitle.Size =
UDim2.new(
1,
0,
0,
32
)

SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Configuraciones"
SettingsTitle.TextColor3 = COLORS.Text
SettingsTitle.TextSize = 18
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextXAlignment =
Enum.TextXAlignment.Left

SettingsTitle.Parent = SettingsPage

createLabel(
SettingsPage,
"Max distance",
0,
50
)

local DistanceBox =
createInput(
SettingsPage,
"120",
0,
73,
300
)

createLabel(
SettingsPage,
"Aimbot key",
320,
50
)

local AimKeyBox =
createInput(
SettingsPage,
"Q",
320,
73,
300
)

createLabel(
SettingsPage,
"Trigger key",
0,
126
)

local TriggerKeyBox =
createInput(
SettingsPage,
"T",
0,
149,
300
)

local ResetButton =
Instance.new("TextButton")

ResetButton.Size =
UDim2.new(
0,
300,
0,
40
)

ResetButton.Position =
UDim2.new(
0,
320,
0,
149
)

ResetButton.BackgroundColor3 =
COLORS.RedDark

ResetButton.Text = "Reset settings"
ResetButton.TextColor3 = COLORS.Text
ResetButton.TextSize = 12
ResetButton.Font = Enum.Font.GothamBold
ResetButton.AutoButtonColor = false
ResetButton.Parent = SettingsPage

local ResetCorner =
Instance.new("UICorner")

ResetCorner.CornerRadius =
UDim.new(0, 8)

ResetCorner.Parent = ResetButton

--==================================================
-- TARGET PART
--==================================================

local function getTargetPart(character)

if not character then  
	return nil  
end  

if Settings.TargetMode == "Head" then  

	return character:FindFirstChild("Head")  
end  

if Settings.TargetMode == "Torso" then  

	return character:FindFirstChild(  
		"HumanoidRootPart"  
	)  
	or character:FindFirstChild(  
		"UpperTorso"  
	)  
	or character:FindFirstChild(  
		"Torso"  
	)  
end  

local camera =  
	workspace.CurrentCamera  

if not camera then  
	return nil  
end  

local cameraPosition =  
	camera.CFrame.Position  

local lookVector =  
	camera.CFrame.LookVector  

local bestPart  
local bestAngle = Settings.FOV  

local names = {  
	"Head",  
	"HumanoidRootPart",  
	"UpperTorso",  
	"Torso",  
	"LowerTorso"  
}  

for _, name in ipairs(names) do  

	local part =  
		character:FindFirstChild(name)  

	if part  
		and part:IsA("BasePart") then  

		local offset =  
			part.Position  
			- cameraPosition  

		if offset.Magnitude > 0 then  

			local angle =  
				math.deg(  
					math.acos(  
						math.clamp(  
							lookVector:Dot(  
								offset.Unit  
							),  
							-1,  
							1  
						)  
					)  
				)  

			if angle < bestAngle then  

				bestAngle = angle  
				bestPart = part  
			end  
		end  
	end  
end  

return bestPart

end

--==================================================
-- TEAM CHECK
--==================================================

local function isEnemy(player)

if player == LocalPlayer then  
	return false  
end  

if Settings.TeamCheck  
	and LocalPlayer.Team ~= nil  
	and player.Team ~= nil  
	and LocalPlayer.Team == player.Team then  

	return false  
end  

return true

end

--==================================================
-- WALL CHECK
--==================================================

local function hasLineOfSight(part)

if not part then  
	return false  
end  

if not Settings.WallCheck then  
	return true  
end  

local camera =  
	workspace.CurrentCamera  

if not camera then  
	return false  
end  

local origin =  
	camera.CFrame.Position  

local direction =  
	part.Position - origin  

local params =  
	RaycastParams.new()  

params.FilterType =  
	Enum.RaycastFilterType.Exclude  

params.FilterDescendantsInstances = {  
	Character  
}  

local result =  
	workspace:Raycast(  
		origin,  
		direction,  
		params  
	)  

if not result then  
	return false  
end  

return result.Instance:IsDescendantOf(  
	part.Parent  
)

end

--==================================================
-- FOV OFFSET RAY
-- Devuelve el vector de dirección mundial que
-- corresponde al centro del FOV desplazado.
--==================================================

local function getFOVRay(camera)

	local viewport = camera.ViewportSize

	-- centro de pantalla + offset en píxeles
	local screenCenter = Vector2.new(
		viewport.X / 2 + Settings.FOVOffsetX,
		viewport.Y / 2 + Settings.FOVOffsetY
	)

	-- Unproject: convierte pixel → ray de mundo
	local ray = camera:ScreenPointToRay(
		screenCenter.X,
		screenCenter.Y
	)

	return ray.Direction

end

--==================================================
-- CLOSEST PLAYER
--==================================================

local function getClosestPlayer()

local camera =  
	workspace.CurrentCamera  

if not camera then  
	return nil  
end  

local closestPart  
local closestAngle = Settings.FOV  

local cameraPosition =  
	camera.CFrame.Position  

-- usamos la dirección del FOV desplazado como referencia
local lookVector = getFOVRay(camera)

for _, player in ipairs(  
	Players:GetPlayers()  
) do  

	if player ~= LocalPlayer  
		and isEnemy(player)  
		and player.Character then  

		local targetCharacter =  
			player.Character  

		local humanoid =  
			targetCharacter:FindFirstChildOfClass(  
				"Humanoid"  
			)  

		if humanoid  
			and humanoid.Health > 0 then  

			local part =  
				getTargetPart(  
					targetCharacter  
				)  

			if part then  

				local offset =  
					part.Position  
					- cameraPosition  

				local distance =  
					offset.Magnitude  

				if distance <= Settings.MaxDistance  
					and distance > 0 then  

					local angle =  
						math.deg(  
							math.acos(  
								math.clamp(  
									lookVector:Dot(  
										offset.Unit  
									),  
									-1,  
									1  
								)  
							)  
						)  

					if angle < closestAngle  
						and hasLineOfSight(part) then  

						closestAngle = angle  
						closestPart = part  
					end  
				end  
			end  
		end  
	end  
end  

return closestPart

end

--==================================================
-- AIM LOOP
--==================================================

RunService:BindToRenderStep(
"crucialAT_v2_Aim",
Enum.RenderPriority.Camera.Value + 1,
function()

if Unloaded  
		or not Settings.Enabled then  

		return  
	end  

	if not Character  
		or not Humanoid  
		or Humanoid.Health <= 0 then  

		return  
	end  

	local camera =  
		workspace.CurrentCamera  

	if not camera then  
		return  
	end  

	local target =  
		getClosestPlayer()  

	if not target then  
		return  
	end  

	local predictedPosition =  
		target.Position  
		+ (  
			target.AssemblyLinearVelocity  
			* Settings.Prediction  
		)  

	-- Si hay offset, ajustamos el CFrame para que
	-- el target quede bajo el centro del FOV desplazado,
	-- no bajo el centro de pantalla.
	if Settings.FOVOffsetX ~= 0
		or Settings.FOVOffsetY ~= 0 then

		local fovDir = getFOVRay(camera)

		-- ángulo entre lookVector y fovDir
		local lookVec = camera.CFrame.LookVector
		local axis = lookVec:Cross(fovDir)

		if axis.Magnitude > 1e-6 then

			local angle = math.acos(
				math.clamp(
					lookVec:Dot(fovDir),
					-1, 1
				)
			)

			-- rotación que lleva lookVector → fovDir
			local correction =
				CFrame.fromAxisAngle(
					axis.Unit,
					-angle
				)

			-- aplicamos la corrección inversa al targetCFrame
			-- para que el aim compense el offset
			local targetCFrame =
				CFrame.lookAt(
					camera.CFrame.Position,
					predictedPosition
				)

			local correctedCFrame =
				camera.CFrame.Position
				+ (correction * (targetCFrame.LookVector))

			camera.CFrame =
				camera.CFrame:Lerp(
					CFrame.new(camera.CFrame.Position)
					* CFrame.lookAt(
						Vector3.zero,
						correction * targetCFrame.LookVector
					),
					Settings.Smoothness
				)

		else

			local targetCFrame =  
				CFrame.lookAt(  
					camera.CFrame.Position,  
					predictedPosition  
				)  

			camera.CFrame =  
				camera.CFrame:Lerp(  
					targetCFrame,  
					Settings.Smoothness  
				)
		end

	else

		local targetCFrame =  
			CFrame.lookAt(  
				camera.CFrame.Position,  
				predictedPosition  
			)  

		camera.CFrame =  
			camera.CFrame:Lerp(  
				targetCFrame,  
				Settings.Smoothness  
			)
	end
end

)

--==================================================
-- TRIGGERBOT
--==================================================

local function getTool()

if not Character then  
	return nil  
end  

return Character:FindFirstChildOfClass("Tool")

end

local function isValidTarget(part)

if not part then  
	return false  
end  

local model =  
	part:FindFirstAncestorOfClass("Model")  

if not model  
	or model == Character then  

	return false  
end  

local humanoid =  
	model:FindFirstChildOfClass("Humanoid")  

if not humanoid  
	or humanoid.Health <= 0 then  

	return false  
end  

local player =  
	Players:GetPlayerFromCharacter(model)  

if not player then  
	return false  
end  

return isEnemy(player)

end

local function raycastTrigger()

local camera =  
	workspace.CurrentCamera  

if not camera then  
	return nil  
end  

local origin =  
	camera.CFrame.Position  

local direction =  
	camera.CFrame.LookVector  
	* Settings.MaxDistance  

local params =  
	RaycastParams.new()  

params.FilterType =  
	Enum.RaycastFilterType.Exclude  

params.FilterDescendantsInstances = {  
	Character  
}  

local result =  
	workspace:Raycast(  
		origin,  
		direction,  
		params  
	)  

if not result  
	or not result.Instance then  

	return nil  
end  

if not isValidTarget(  
	result.Instance  
) then  

	return nil  
end  

return result.Instance

end

local function fireInstant()

local tool =  
	getTool()  

if not tool then  
	return false  
end  

tool:Activate()  

return true

end

local function checkTriggerbot()

if Unloaded  
	or not Settings.TriggerbotEnabled then  

	return  
end  

local now = time()  

if now - lastFireTime  
	< Settings.TriggerDelay then  

	return  
end  

local hitPart =  
	raycastTrigger()  

if not hitPart then  
	return  
end  

local camera =  
	workspace.CurrentCamera  

if not camera then  
	return  
end  

local direction =  
	hitPart.Position  
	- camera.CFrame.Position  

if direction.Magnitude <= 0 then  
	return  
end  

local angle =  
	math.deg(  
		math.acos(  
			math.clamp(  
				camera.CFrame.LookVector:Dot(  
					direction.Unit  
				),  
				-1,  
				1  
			)  
		)  
	)  

if angle <= Settings.FOV then  

	if fireInstant() then  
		lastFireTime = now  
	end  
end

end

connect(
RunService.Heartbeat,
checkTriggerbot
)

--==================================================
-- ESP
--==================================================

local function removeESP(player)

local object =  
	ESPObjects[player]  

if not object then  
	return  
end  

for _, item in pairs(object) do  

	if typeof(item) == "Instance" then  
		item:Destroy()  
	end  
end  

ESPObjects[player] = nil

end

local function createESP(player)

if player == LocalPlayer then  
	return  
end  

removeESP(player)  

local billboard =  
	Instance.new("BillboardGui")  

billboard.Name =  
	"crucialAT_ESP"  

billboard.Size =  
	UDim2.new(  
		0,  
		200,  
		0,  
		65  
	)  

billboard.StudsOffset =  
	Vector3.new(0, 3, 0)  

billboard.AlwaysOnTop = true  
billboard.Enabled =  
	Settings.ESPEnabled  

billboard.Parent = PlayerGui  

local label =  
	Instance.new("TextLabel")  

label.Size =  
	UDim2.fromScale(1, 1)  

label.BackgroundTransparency = 1  
label.TextColor3 = COLORS.ESP  
label.TextStrokeTransparency = 0.25  
label.TextSize = 12  
label.Font = Enum.Font.GothamBold  
label.Parent = billboard  

ESPObjects[player] = {  
	Container = billboard,  
	Label = label  
}

end

local function updateESP()

for player, object in pairs(  
	ESPObjects  
) do  

	if not player.Parent then  

		removeESP(player)  
		continue  
	end  

	local character =  
		player.Character  

	local humanoid =  
		character  
		and character:FindFirstChildOfClass(  
			"Humanoid"  
		)  

	local root =  
		character  
		and character:FindFirstChild(  
			"HumanoidRootPart"  
		)  

	if not character  
		or not humanoid  
		or not root  
		or humanoid.Health <= 0 then  

		object.Container.Enabled = false  
		continue  
	end  

	object.Container.Adornee = root  

	object.Container.Enabled =  
		Settings.ESPEnabled  
		and isEnemy(player)  

	if not object.Container.Enabled then  
		continue  
	end  

	local parts = {}  

	if Settings.ESPNames then  
		table.insert(  
			parts,  
			player.DisplayName  
		)  
	end  

	if Settings.ESPHealth then  
		table.insert(  
			parts,  
			"HP "  
				.. math.floor(  
					humanoid.Health  
				)  
		)  
	end  

	if Settings.ESPDistance  
		and Character  
		and Character:FindFirstChild(  
			"HumanoidRootPart"  
		) then  

		local localRoot =  
			Character.HumanoidRootPart  

		local distance =  
			(  
				root.Position  
				- localRoot.Position  
			).Magnitude  

		table.insert(  
			parts,  
			math.floor(distance)  
				.. " studs"  
		)  
	end  

	object.Label.Text =  
		table.concat(  
			parts,  
			"\n"  
		)  
end

end

for _, player in ipairs(
Players:GetPlayers()
) do

if player ~= LocalPlayer then  
	createESP(player)  
end

end

connect(
Players.PlayerAdded,
function(player)
createESP(player)
end
)

connect(
Players.PlayerRemoving,
function(player)
removeESP(player)
end
)

connect(
RunService.Heartbeat,
updateESP
)

--==================================================
-- INPUT VALIDATION
--==================================================

connect(
SmoothBox.FocusLost,
function()

local value =  
		tonumber(SmoothBox.Text)  

	if value  
		and value >= 0.01  
		and value <= 0.5 then  

		Settings.Smoothness = value  

		SmoothBox.Text =  
			string.format(  
				"%.2f",  
				value  
			)  

	else  

		SmoothBox.Text =  
			string.format(  
				"%.2f",  
				Settings.Smoothness  
			)  
	end  
end

)

connect(
FOVBox.FocusLost,
function()

local value =  
		tonumber(FOVBox.Text)  

	if value  
		and value >= 1  
		and value <= 45 then  

		Settings.FOV = value  

		FOVBox.Text =  
			tostring(value)  

		updateFOV()  

	else  

		FOVBox.Text =  
			tostring(Settings.FOV)  
	end  
end

)

connect(
DistanceBox.FocusLost,
function()

local value =  
		tonumber(DistanceBox.Text)  

	if value  
		and value >= 10  
		and value <= 1000 then  

		Settings.MaxDistance = value  

		DistanceBox.Text =  
			tostring(value)  

	else  

		DistanceBox.Text =  
			tostring(Settings.MaxDistance)  
	end  
end

)

connect(
DelayBox.FocusLost,
function()

local delay =  
		tonumber(DelayBox.Text)  

	if not delay  
		or delay < 0 then  

		delay = 0  
	end  

	delay =  
		math.clamp(  
			delay,  
			0,  
			5000  
		)  

	Settings.TriggerDelay =  
		delay / 1000  

	DelayBox.Text =  
		string.format(  
			"%.2f",  
			delay  
		)  

	if delay <= 0 then  

		CPSBox.Text = "MAX"  

	else  

		CPSBox.Text =  
			string.format(  
				"%.2f",  
				1000 / delay  
			)  
	end  
end

)

connect(
CPSBox.FocusLost,
function()

local cps =  
		tonumber(CPSBox.Text)  

	if not cps  
		or cps <= 0 then  

		cps = 20  
	end  

	cps =  
		math.clamp(  
			cps,  
			0.1,  
			100  
		)  

	local delay =  
		1000 / cps  

	Settings.TriggerDelay =  
		delay / 1000  

	DelayBox.Text =  
		string.format(  
			"%.2f",  
			delay  
		)  

	CPSBox.Text =  
		string.format(  
			"%.2f",  
			cps  
		)  
end

)

connect(
PredictionBox.FocusLost,
function()

local value =  
		tonumber(PredictionBox.Text)  

	if not value then  
		value = 0  
	end  

	value =  
		math.clamp(  
			value,  
			0,  
			5  
		)  

	Settings.Prediction = value  
	PredictionBox.Text =  
		tostring(value)  
end

)

--==================================================
-- KEY PARSER
--==================================================

local function keyFromText(text)

text =  
	string.upper(  
		string.sub(  
			text,  
			1,  
			1  
		)  
	)  

if #text ~= 1 then  
	return nil  
end  

local success, key =  
	pcall(  
		function()  
			return Enum.KeyCode[text]  
		end  
	)  

if success and key then  
	return key  
end  

return nil

end

connect(
AimKeyBox.FocusLost,
function()

local key =  
		keyFromText(  
			AimKeyBox.Text  
		)  

	if key then  

		Settings.AimbotKey = key  
		AimKeyBox.Text = key.Name  

	else  

		AimKeyBox.Text =  
			Settings.AimbotKey.Name  
	end  
end

)

connect(
TriggerKeyBox.FocusLost,
function()

local key =  
		keyFromText(  
			TriggerKeyBox.Text  
		)  

	if key then  

		Settings.TriggerKey = key  
		TriggerKeyBox.Text = key.Name  

	else  

		TriggerKeyBox.Text =  
			Settings.TriggerKey.Name  
	end  
end

)

--==================================================
-- KEYBINDS
--==================================================

connect(
UserInputService.InputBegan,
function(input, processed)

if processed then  
		return  
	end  

	if input.KeyCode ==  
		Settings.AimbotKey then  

		Settings.Enabled =  
			not Settings.Enabled  

		AimToggle.SetState(  
			Settings.Enabled  
		)  
	end  

	if input.KeyCode ==  
		Settings.TriggerKey then  

		Settings.TriggerbotEnabled =  
			not Settings.TriggerbotEnabled  

		TriggerToggle.SetState(  
			Settings.TriggerbotEnabled  
		)  
	end  
end

)

--==================================================
-- RESET SETTINGS
--==================================================

connect(
ResetButton.MouseButton1Click,
function()

for key, value in pairs(  
		Defaults  
	) do  

		Settings[key] = value  
	end  

	-- INPUTS  

	SmoothBox.Text = "0.2"  
	FOVBox.Text = "12"  
	DelayBox.Text = "50"  
	CPSBox.Text = "20"  
	PredictionBox.Text = "0"  
	DistanceBox.Text = "120"  
	AimKeyBox.Text = "Q"  
	TriggerKeyBox.Text = "T"  

	-- TOGGLES  

	AimToggle.SetState(  
		Settings.Enabled  
	)  

	TriggerToggle.SetState(  
		Settings.TriggerbotEnabled  
	)  

	TeamToggle.SetState(  
		Settings.TeamCheck  
	)  

	WallToggle.SetState(  
		Settings.WallCheck  
	)  

	ESPToggle.SetState(  
		Settings.ESPEnabled  
	)  

	NamesToggle.SetState(  
		Settings.ESPNames  
	)  

	DistanceToggle.SetState(  
		Settings.ESPDistance  
	)  

	HealthToggle.SetState(  
		Settings.ESPHealth  
	)  

	FOVToggle.SetState(  
		Settings.ShowFOV  
	)

	Settings.FOVOffsetX = 0
	Settings.FOVOffsetY = 0
	updateOffsetLabel()

	for mode, button in pairs(  
		TargetButtons  
	) do  

		button.BackgroundColor3 =  
			mode == "Head"  
			and COLORS.Red  
			or COLORS.PanelDark  
	end  

	updateFOV()  
end

)

--==================================================
-- MAIN DRAG SYSTEM
--==================================================

local dragging = false
local dragStart
local startPosition

local function beginDrag(input)

dragging = true  
dragStart = input.Position  
startPosition = MainFrame.Position

end

local function updateDrag(input)

if not dragging then  
	return  
end  

local delta =  
	input.Position - dragStart  

MainFrame.Position =  
	UDim2.new(  
		startPosition.X.Scale,  
		startPosition.X.Offset + delta.X,  

		startPosition.Y.Scale,  
		startPosition.Y.Offset + delta.Y  
	)

end

connect(
DragButton.InputBegan,
function(input)

if input.UserInputType ==  
		Enum.UserInputType.MouseButton1  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		beginDrag(input)  
	end  
end

)

connect(
DragButton.InputEnded,
function(input)

if input.UserInputType ==  
		Enum.UserInputType.MouseButton1  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		dragging = false  
	end  
end

)

connect(
UserInputService.InputChanged,
function(input)

if not dragging then  
		return  
	end  

	if input.UserInputType ==  
		Enum.UserInputType.MouseMovement  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		updateDrag(input)  
	end  
end

)

--==================================================
-- MINI BUTTON
--==================================================

local MiniButton =
Instance.new("TextButton")

MiniButton.Name = "MiniButton"

MiniButton.Size =
UDim2.fromOffset(
58,
58
)

MiniButton.Position =
UDim2.new(
0,
20,
0.5,
-29
)

MiniButton.BackgroundColor3 =
COLORS.Background

MiniButton.Text = "i"
MiniButton.TextColor3 = COLORS.Text
MiniButton.TextSize = 23
MiniButton.Font = Enum.Font.GothamBold

MiniButton.Visible = false
MiniButton.Active = true
MiniButton.AutoButtonColor = false
MiniButton.Parent = ScreenGui

local MiniCorner =
Instance.new("UICorner")

MiniCorner.CornerRadius =
UDim.new(1, 0)

MiniCorner.Parent = MiniButton

local MiniStroke =
Instance.new("UIStroke")

MiniStroke.Color =
COLORS.Red

MiniStroke.Parent = MiniButton

--==================================================
-- MINI BUTTON DRAG SYSTEM
--==================================================

local miniDragging = false
local miniDragStart
local miniStartPosition
local miniMoved = false

local MINI_DRAG_THRESHOLD = 8

local function beginMiniDrag(input)

miniDragging = true  
miniMoved = false  

miniDragStart =  
	input.Position  

miniStartPosition =  
	MiniButton.Position

end

local function updateMiniDrag(input)

if not miniDragging then  
	return  
end  

local delta =  
	input.Position  
	- miniDragStart  

if delta.Magnitude >= MINI_DRAG_THRESHOLD then  
	miniMoved = true  
end  

if not miniMoved then  
	return  
end  

local camera =  
	workspace.CurrentCamera  

if not camera then  
	return  
end  

local viewport =  
	camera.ViewportSize  

local buttonSize =  
	MiniButton.AbsoluteSize  

local newX =  
	miniStartPosition.X.Offset  
	+ delta.X  

local newY =  
	miniStartPosition.Y.Offset  
	+ delta.Y  

local maxX =  
	math.max(  
		0,  
		viewport.X - buttonSize.X  
	)  

local maxY =  
	math.max(  
		0,  
		viewport.Y - buttonSize.Y  
	)  

newX =  
	math.clamp(  
		newX,  
		0,  
		maxX  
	)  

newY =  
	math.clamp(  
		newY,  
		0,  
		maxY  
	)  

MiniButton.Position =  
	UDim2.new(  
		0,  
		newX,  
		0,  
		newY  
	)

end

local function endMiniDrag()

if not miniDragging then  
	return  
end  

miniDragging = false

end

connect(
MiniButton.InputBegan,
function(input)

if input.UserInputType ==  
		Enum.UserInputType.MouseButton1  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		beginMiniDrag(input)  
	end  
end

)

connect(
MiniButton.InputEnded,
function(input)

if input.UserInputType ==  
		Enum.UserInputType.MouseButton1  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		endMiniDrag()  
	end  
end

)

connect(
UserInputService.InputChanged,
function(input)

if not miniDragging then  
		return  
	end  

	if input.UserInputType ==  
		Enum.UserInputType.MouseMovement  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		updateMiniDrag(input)  
	end  
end

)

--==================================================
-- MINIMIZE
--==================================================

local function minimizeUI()

if Unloaded then  
	return  
end  

tween(  
	MainFrame,  
	{  
		Size =  
			UDim2.new(  
				0,  
				820,  
				0,  
				0  
			)  
	},  
	0.22  
):Play()  

task.wait(0.18)  

if Unloaded then  
	return  
end  

MainFrame.Visible = false  
MiniButton.Visible = true  

MiniButton.Size =  
	UDim2.fromOffset(  
		0,  
		0  
	)  

tween(  
	MiniButton,  
	{  
		Size =  
			UDim2.fromOffset(  
				58,  
				58  
			)  
	},  
	0.22  
):Play()

end

--==================================================
-- RESTORE
--==================================================

local function restoreUI()

if Unloaded then  
	return  
end  

MiniButton.Visible = false  

MainFrame.Visible = true  

MainFrame.Size =  
	UDim2.new(  
		0,  
		820,  
		0,  
		0  
	)  

tween(  
	MainFrame,  
	{  
		Size =  
			UDim2.new(  
				0,  
				820,  
				0,  
				420  
			)  
	},  
	0.25  
):Play()

end

connect(
MinimizeButton.MouseButton1Click,
minimizeUI
)

--==================================================
-- MINI BUTTON CLICK / RESTORE
--==================================================

connect(
MiniButton.MouseButton1Click,
function()

-- Si se movió, fue un arrastre,  
	-- no un clic para restaurar.  

	if miniMoved then  

		miniMoved = false  
		return  
	end  

	restoreUI()  
end

)

--==================================================
-- DEFAULT PAGE
--==================================================

Pages.Combat.Visible = true

TabButtons.Combat.BackgroundColor3 =
COLORS.Red

TabButtons.Combat.TextColor3 =
COLORS.Text

--==================================================
-- CHARACTER RESPAWN
--==================================================

connect(
LocalPlayer.CharacterAdded,
function(newCharacter)

if Unloaded then  
		return  
	end  

	Character = newCharacter  

	Humanoid =  
		newCharacter:WaitForChild(  
			"Humanoid"  
		)  

	lastFireTime = 0  
end

)

--==================================================
-- RESPONSIVE SCALE
--==================================================

local lastScale

local function updateScale()

local camera =  
	workspace.CurrentCamera  

if not camera then  
	return  
end  

local viewport =  
	camera.ViewportSize  

local scale  

if viewport.X < 600 then  

	scale =  
		math.clamp(  
			viewport.X / 900,  
			0.55,  
			0.75  
		)  

elseif viewport.X < 900 then  

	scale = 0.75  

elseif viewport.X < 1200 then  

	scale = 0.82  

else  

	scale = 0.92  
end  

if lastScale ~= scale then  

	lastScale = scale  
	UIScale.Scale = scale  
end

end

connect(
RunService.RenderStepped,
function()

if Unloaded then  
		return  
	end  

	updateScale()  
	updateFOV()  
end

)

--==================================================
-- UNLOAD
--==================================================

local function Unload()

if Unloaded then  
	return  
end  

Unloaded = true  

Settings.Enabled = false  
Settings.TriggerbotEnabled = false  

pcall(  
	function()  

		RunService:  
			UnbindFromRenderStep(  
				"crucialAT_v2_Aim"  
			)  
	end  
)  

for player in pairs(ESPObjects) do  
	removeESP(player)  
end  

disconnectAll()  

if ScreenGui then  
	ScreenGui:Destroy()  
end  

_G.crucialAT_Unload = nil

end

connect(
UnloadButton.MouseButton1Click,
Unload
)

_G.crucialAT_Unload =
Unload

--==================================================
-- OPEN ANIMATION
--==================================================

MainFrame.Visible = true

MainFrame.Size =
UDim2.new(
0,
0,
0,
0
)

MainFrame.Position =
UDim2.new(
0.5,
0,
0.5,
0
)

tween(
MainFrame,
{
Size =
UDim2.new(
0,
820,
0,
420
),

Position =  
		UDim2.new(  
			0.5,  
			-410,  
			0.5,  
			-210  
		)  
},  
0.35

):Play()

--==================================================
-- INITIAL UPDATE
--==================================================

task.defer(
function()

updateScale()  
	updateFOV()  
end

)
