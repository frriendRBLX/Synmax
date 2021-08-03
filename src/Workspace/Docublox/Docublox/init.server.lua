local plugin = plugin or getfenv().PluginManager():CreatePlugin()

--[[
	Docublox - Document Your game.
]]--

local toolbar = plugin:CreateToolbar("Docublox")
local enableDocublox = toolbar:CreateButton("Enable Docublox", "Enable", "rbxassetid://5926053063")
local enablePlaceSpecific = toolbar:CreateButton("Toggle Place Specific", "Filter out all notes that were not created under this place!", "rbxassetid://5926080304")
local forceLoad = toolbar:CreateButton("Force Sync", "Quickly pull the current ", "rbxassetid://5899625288")

local PluginEnabled = plugin:GetSetting("IsPluginEnabled") or false
local PlaceSpecificLoading = plugin:GetSetting("PlaceSpecific") or false

local connections = {}

local PluginID = 5924843001
local VERSION = script.Parent.Version.Value

enablePlaceSpecific:SetActive(PlaceSpecificLoading)

-- Check for Update --
local Copy = game:GetObjects("rbxassetid://" .. PluginID)[1]
local CopyVER = Copy:FindFirstChild("Version")
if CopyVER then
	if CopyVER.Value ~= VERSION then
		warn(("[Docublox] %s is Released! Update in your plugin manager!"):format(CopyVER.Value))
	end
end
Copy:Destroy()

local interface = plugin:CreateDockWidgetPluginGui(
	"Docublox",
	DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Left,
		false,
		false,
		500,
		500,
		250,
		80
	)
) 

local ButtonColorEnum = {
	BUG = Color3.fromRGB(255, 85, 127),
	METHOD = Color3.fromRGB(0, 170, 255),
	NOTE = Color3.fromRGB(255, 255, 127),
	ALL = Color3.fromRGB(85, 255, 127),
	OFF = Color3.fromRGB(38, 38, 38)
}

interface.Title = "Docublox - V1.0"
wait()

local GUI = script.Parent.UI.MAIN
GUI.Parent = interface

-- [[ OOP MODULES ]] --
local NoteObject = require(script.NoteObject)
local SaveModule = require(script.SaveHandler)
local NoteObjs = {}

-- [[ NOTES ]] -----------------------------------------------------------------------------------
local HEADER 		= GUI.HEADER
local HOLDER 		= GUI.HOLDER
local INPUT 		= GUI.INPUT
local SEARCH 		= GUI.SEARCH
local SORT 			= GUI.SORT

local TEMPLATE	 	= GUI.TEMPLATE

HEADER.LABEL.Text = ("Docublox [%s]"):format(VERSION)

-- [[ INPUT SECTION ]] ---------------------------------------------------------------------------
local INPUT_HEADER 	= INPUT.HEADER.INPUT
local INPUT_TYPE 	= INPUT.TYPE
local INPUT_SUBMIT 	= INPUT.SUBMIT

local TS			= game:GetService("TweenService")
local UIS 			= game:GetService("UserInputService")
local ColorTI		= TweenInfo.new(0.25)

local TYPE = "NOTE"
local SORT_TYPE = "ALL"

function sortByType()
	for _, note in ipairs(NoteObjs) do
		if PlaceSpecificLoading then
			if note.CreatedPlaceID ~= game.GameId then
				note:SetVisible(false)
				note:SetOpenState(true)
								
				continue
			end
		end	
				
		spawn(function()
			if note.Type == SORT_TYPE or SORT_TYPE == "ALL" then
				note:SetVisible(true)
				note:SetOpenState(false)
				note.Object:TweenSize(UDim2.new(1, 0, 0, 25), "Out", "Quad", 0.2, true)
			elseif note.Visible and note.Object.Parent == HOLDER then
				note.Object:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
				wait(0.25)
				note:SetVisible(false)
				note:SetOpenState(true)
			end
		end)
		
	end
end

function sortByNameAndType(str)
	for _, note in ipairs(NoteObjs) do
		if PlaceSpecificLoading then
			if note.CreatedPlaceID ~= game.GameId then
				note:SetVisible(false)
				note:SetOpenState(true)

				continue
			end
		end	
		
		if (note.Type == SORT_TYPE or SORT_TYPE == "ALL") and note.Header:lower():find(str:lower()) then
			note:SetVisible(true)
		else
			note:SetVisible(false)
		end
	end
end

local clickCooldown = false
function registerButtonObject(item, IsSorting)
	item.MouseButton1Down:Connect(function()
		if clickCooldown then return end
		clickCooldown = true
		
		for _, otherItem in ipairs(item.Parent:GetChildren()) do
			local Tween = TS:Create(otherItem, ColorTI, {BackgroundColor3 = ButtonColorEnum.OFF})
			local TextTween = TS:Create(otherItem.Label, ColorTI, {TextColor3 = Color3.new(1,1,1)})
			Tween:Play()
			TextTween:Play()
		end
		
		local Tween = TS:Create(item, ColorTI, {BackgroundColor3 = ButtonColorEnum[item.Name]})
		local TextTween = TS:Create(item.Label, ColorTI, {TextColor3 = ButtonColorEnum.OFF})
		Tween:Play()
		TextTween:Play()
		
		if IsSorting then
			local SearchTween = TS:Create(SEARCH.MAIN, ColorTI, {BackgroundColor3 = ButtonColorEnum[item.Name]})
			SearchTween:Play()
			SORT_TYPE = item.Name
			sortByType()
		else
			TYPE = item.Name
		end
		
		wait(0.25)
		clickCooldown = false
	end)
end

for _, button in ipairs(INPUT_TYPE:GetChildren()) do
	registerButtonObject(button, false)
end

for _, button in ipairs(SORT:GetChildren()) do
	registerButtonObject(button, true)
end

function updateCanvasHeight()
	for _, item in ipairs(NoteObjs) do
		-- set height based on each item on screen currently.		
	end
end

-- Clamp Header Text, and Play a Tween Indicating if Input can be Sent --
local LastProperHeader = ""
INPUT_HEADER:GetPropertyChangedSignal("Text"):Connect(function()
	local ButtonTween
	
	if INPUT_HEADER.Text == "" then
		ButtonTween = TS:Create(INPUT_SUBMIT, ColorTI, {BackgroundColor3 = Color3.fromRGB(255, 85, 127)})
	else
		if INPUT_HEADER.TextFits and INPUT_HEADER.Text:len() < 40 then
			LastProperHeader = INPUT_HEADER.Text
		else
			INPUT_HEADER.Text = LastProperHeader
		end
		
		ButtonTween = TS:Create(INPUT_SUBMIT, ColorTI, {BackgroundColor3 = Color3.fromRGB(38, 38, 38)})
	end
	
	ButtonTween:Play()
end)

SEARCH.MAIN.QUEREY:GetPropertyChangedSignal("Text"):Connect(function()
	local Querey = SEARCH.MAIN.QUEREY.Text 
	
	if Querey == "" then
		sortByType()
	else
		sortByNameAndType(Querey)
	end
end)

function newNote(Header, Body, Type, Goto, PID, ostime)
	Goto = Goto or false
	
	local NewNoteObj = NoteObject.new(TEMPLATE, HOLDER, Header, Body, Goto) 
	local Object = NewNoteObj.Object
	
	NewNoteObj:SetType(Type, ButtonColorEnum[Type])
	
	NewNoteObj:OnNoteUpdate(function()
		SaveModule.Save(plugin, NoteObjs)
	end)
	
	NewNoteObj.Object.OPTIONS.DELETE.MouseButton1Down:Connect(function()
		local find = nil

		for i, item in ipairs(NoteObjs) do
			if item.Header == NewNoteObj.Header then
				find = i
				break
			end
		end
					
		if find then
			table.remove(NoteObjs, find)
			NewNoteObj:Destroy()
		end
	end)

	if SORT_TYPE == "ALL" or Type == SORT_TYPE then
		NewNoteObj:SetVisible(true)	
	end
	
	NewNoteObj.TableIndex = #NoteObjs
	NewNoteObj.CreatedPlaceID = PID or game.GameId
	NewNoteObj.CreatedTime = ostime or os.time()
	NewNoteObj.Object.OPTIONS.EDIT.Label.Text = ("PID: " .. NewNoteObj.CreatedPlaceID)

	table.insert(NoteObjs, #NoteObjs + 1, NewNoteObj)
 	INPUT_HEADER.Text = ""
end

function loadData()
	local Data = SaveModule.Load(plugin)

	if Data then
		for i, item in ipairs(Data) do
			wait()
			newNote(item.Header, item.Body, item.Type, false, item.CreatedPlaceID, item.CreatedTime)
		end
	end
end

-- Topbar Buttons --
table.insert(connections, enablePlaceSpecific.Click:Connect(function()
	PlaceSpecificLoading = not PlaceSpecificLoading
	enablePlaceSpecific:SetActive(PlaceSpecificLoading)
	plugin:SetSetting("PlaceSpecific", PlaceSpecificLoading)
	sortByType()
end))

table.insert(connections, enableDocublox.Click:Connect(function()
	interface.Enabled = not interface.Enabled
	PluginEnabled = interface.Enabled
	enableDocublox:SetActive(interface.Enabled)
	plugin:SetSetting("IsPluginEnabled", PluginEnabled)
end))


local CC = false
table.insert(connections, forceLoad.Click:Connect(function()
	forceLoad:SetActive(false)

	if CC then return end
	CC = true
	
	for i, item in ipairs(NoteObjs) do		
		item:Destroy(true)
	end
	
	NoteObjs = {}
	
	print "[Docublox] Pulled latest state of files successfully!"
	
	loadData()
	sortByType()
	
	wait(1)
	CC = false
end))


INPUT_SUBMIT.MouseButton1Down:Connect(function()
	for _, item in ipairs(NoteObjs) do
		if item.Object then
			if item.Object.Parent == item.Holder then
				item:SetState(false)
			end
		end
		
	end
	
	if INPUT_HEADER.Text == "" then return end
	newNote(INPUT_HEADER.Text, "", TYPE, true)
	SaveModule.Save(plugin, NoteObjs)
end)

table.insert(connections, INPUT_HEADER.FocusLost:Connect(function(enter, instance)
	if enter then
		for _, item in ipairs(NoteObjs) do
			item:SetState(false)
		end
		
		if INPUT_HEADER.Text == "" then return end
		newNote(INPUT_HEADER.Text, "", TYPE, true)
		SaveModule.Save(plugin, NoteObjs)
	end
end))

plugin.Unloading:Connect(function()
	SaveModule.Save(plugin, NoteObjs)

	for _, item in ipairs(connections) do
		item:Disconnect()
	end

	print '[Docublox Unloaded]'
end)

loadData()
sortByType()

interface.Enabled = PluginEnabled
enableDocublox:SetActive(PluginEnabled)

print(string.format("[Docublox] %i Notes Loaded", #NoteObjs))

