local plugin = plugin or getfenv().PluginManager():CreatePlugin()

local VERSION = script.Parent.Version.Value

local toolbar = plugin:CreateToolbar("Synmax " .. VERSION)
local enableSynmax = toolbar:CreateButton("Enable Synmax", "Enable", "rbxassetid://5842944820")
local reloadMods = toolbar:CreateButton("Reload Mods", "Reload Mods", "rbxassetid://5838551687")
local SPACE = toolbar:CreateButton("->", "", "")
SPACE.Enabled = false

--local modsSettings = plugin:CreateToolbar("Synmax -> Saves")
local enableSave = toolbar:CreateButton("Enable Saves", "Toggles saving modules between places!", "rbxassetid://5899489624")
local overwrite = toolbar:CreateButton("Sync Overwrite", "Allow synmax to overwrite modules when loading. If the module exists its source will be replaced.", "rbxassetid://5899647852")
local forceLoad = toolbar:CreateButton("Force Sync", "Quickly pull the current Save. If Sync Overwrite is enabled, it will overwrite the source of exisitng modules.", "rbxassetid://5899625288")
forceLoad.ClickableWhenViewportHidden = true

local interface = plugin:CreateDockWidgetPluginGui(
	"Synmax",
	DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		true,
		500,
		500,
		80,
		80
	)
) 

-- Check for Update --
local Copy = game:GetObjects("rbxassetid://5843058376")[1]
local CopyVER = Copy:FindFirstChild("Version")
if CopyVER then
	if CopyVER.Value ~= VERSION then
		warn(("[Synmax] %s is Released! Update in your plugin manager!"):format(CopyVER.Value))
	end
end
Copy:Destroy()

interface.Title 	= "Synmax"

local connections = {}

 --			_________________________________________________
 --		   /												 |
 --		  |	                                             __  |
 --		  |	                                            /_ | |
 --		  |	 ___ _   _ _ __  _ __ ___   __ ___  __ __   _| | |
 --		  |	/ __| | | | '_ \| '_ ` _ \ / _` \ \/ / \ \ / / | |
 --		  |	\__ \ |_| | | | | | | | | | (_| |>  <   \ V /| | | 
 --		  |	|___/\__, |_| |_|_| |_| |_|\__,_/_/\_\   \_/ |_| |
 --		  |	      __/ |                                      |
 --		  |	     |___/                                       |
 --		  |													 |
 --		  |	   Developed by frriend | 2020		  			 |
 --		  |__________________________________________________/

--[[ VARIABLES ]]--

local UIS 			= game:GetService("UserInputService")
local config 		= script.Parent.Config
local mods 			= script.Parent.Modules
local externalMods 	= game.ServerStorage:FindFirstChild("SYNMAX_PLUGINS")
local cmds 			= {}
local interfaces   	= {}
local pluginCount 	= 0
local main 			= script.Parent.GUI:WaitForChild("Main")
local inputBox 		= main.TextBox
local predictBox 	= inputBox.Predict
local info 			= main.Info
local hidePredict   = inputBox.Hide
local RunService 	= game:GetService("RunService")

local Effects		= require(script.Effects)

local SavesEnabled  = plugin:GetSetting("SaveModsEnabled") or false
local PluginEnabled = plugin:GetSetting("IsPluginEnabled") or false
local OWEnabled 	= plugin:GetSetting("IsOverwriteEnabled") or false

for _, item in ipairs(config:GetChildren()) do
	
	-- Fix this in the future..
	
	if item:IsA("BoolValue") then
		local curSett = plugin:GetSetting(item.Name) or false
		if curSett then item.Value = curSett end
		
		local function reload(pointer)
			if item.Value then
				pointer.ImageTransparency = 0
			else
				pointer.ImageTransparency = .75
			end
		end

		table.insert(connections, item.Pointer.Value.MouseButton1Down:Connect(function()
			local pointer = item.Pointer.Value
			
			item.Value = not item.Value
			plugin:SetSetting(item.Name, item.Value)

			reload(pointer)
		end))

		reload(item.Pointer.Value)
	elseif item:IsA("Color3Value") then
				
		function fromArrayToRGB(arr)
			return Color3.new(arr[1]/ 255, arr[2] / 255, arr[3] / 255)
		end
		
		function fromRGBToArray(col)
			return {col.R * 255, col.G * 255, col.B * 255}
		end
		
		local curSett = plugin:GetSetting(item.Name) or fromRGBToArray(item.Value)
		
		if curSett then
			item.Value = fromArrayToRGB(curSett)
		end
		
		table.insert(connections, item.Changed:Connect(function()
			plugin:SetSetting(item.Name, fromRGBToArray(item.Value))
		end))
	end
end

local SessionActive	= false
local lastCommand	= ""

main.Parent 		= interface

_G.SYNMAX_CONFIG	= config
_G.SYNMAX_TYPES 	= require(script.Parent.Ref.Types)

local StyleTween 	= require(script.StyleTween)
	
--[[ FUNCTIONS ]]--

-- Handles Button States --
interface.Enabled = PluginEnabled
enableSave:SetActive(SavesEnabled)
enableSynmax:SetActive(PluginEnabled)
overwrite:SetActive(OWEnabled)

function ToggleSynmax()
	PluginEnabled = not PluginEnabled
	interface.Enabled = PluginEnabled
	enableSynmax:SetActive(PluginEnabled)
	plugin:SetSetting("IsPluginEnabled", PluginEnabled)
end

function debug_warn(warning)
	if config.OutputEnabled.Value then
		warn(warning)
	end
end

function debug_print(warning)
	if config.OutputEnabled.Value then
		print(warning)
	end
end

table.insert(connections, predictBox.Changed:Connect(function()
	inputBox.TextSize = predictBox.TextSize
end))

local modbin = Instance.new("Folder", script.Parent)
modbin.Name = "bin"

local functions = {	
	getCmdList = function()
		local m = {}
		
		for x, mod in next, cmds do
			table.insert(m, x)
		end
				
		return m
	end,
	
	makeWindow = function(tag, xSize, xMin, ySize, yMin)
		if interfaces[tag] then
			return interfaces[tag]
		else
			interfaces[tag] = plugin:CreateDockWidgetPluginGui(
				tag,
				DockWidgetPluginGuiInfo.new(
					Enum.InitialDockState.Float,
					false,
					true,
					xSize,
					xMin,
					ySize,
					yMin
				)
			) 
			
			return interfaces[tag]
		end
	end,
	
	_VER = VERSION
}

-- Saving/Loading Modules --
local saveKey = "PluginModuleSaves"
local loading = false

function saveModules()
	local temp = {}
	for _, item in ipairs(externalMods:GetChildren()) do
		table.insert(temp, {item.Name, item.Source})
	end
	
	plugin:SetSetting(saveKey, temp)
	
	debug_print("[Synmax -> Cross-save] Saving Custom Modules..")
end

function loadSavedModules(override)
	if SessionActive and not override then return end
	SessionActive, loading = true, true
	
	local skipped, overwritten = 0, 0
	
	local loadedMods = {}	
	local data = plugin:GetSetting(saveKey)
	
	if data then
		for _, savedModArray in ipairs(data) do
			local existing = nil
			for _, curMod in ipairs(externalMods:GetChildren()) do
				if savedModArray[1] == curMod.Name then
					existing = curMod
				end
			end
			
			if not existing then
				local newMod = Instance.new("ModuleScript", externalMods)
				newMod.Name = savedModArray[1]
				newMod.Source = savedModArray[2]
				table.insert(loadedMods, newMod)
			else
				debug_print(("[Synmax -> Cross-save] Module '%s' exists already! Skipping.."):format(existing.Name))
				
				if OWEnabled then
					existing.Source = savedModArray[2]
					overwritten += 1
					debug_print(("[Synmax -> Cross-save] Module '%s' has been Modified."):format(existing.Name))
				else
					skipped += 1
				end
			end
		end
	end

	loading = false
	
	debug_print((":: [Synmax -> Cross-save] [%i New Modules | %i Updated Modules | %i Skipped]"):format(#loadedMods, overwritten, skipped))
end

-- Refreshes plugin information [Called by reloadMods Button]
function refreshPlugins()
	reloadMods:SetActive(false)
	if loading then return end

	-- Unload Mods --------------------------------
	for key, MOD in pairs(cmds) do
		local s, _ = pcall(function()
			MOD.cleanup()
		end)

		if not s then
			debug_warn(("[Synmax -> Refresh] Module %s Doesn't have a cleanup() callback!"):format(key))
		end
	end

	cmds = nil 
	cmds = {}
	
	if SavesEnabled then
		loadSavedModules() -- Called Once!
		saveModules()
	end
	
	modbin:ClearAllChildren()

	pluginCount = 0
	
	local function loadModFolder(folder)
		for _, item in ipairs(folder:GetChildren()) do
			local mod = item:Clone()
			mod.Parent = modbin
			
			item.Name = item.Name:lower()
			
			local loadSuccess, _ = pcall(function()
				cmds[item.Name] = require(mod)
				cmds[item.Name]._init(plugin, functions)
			end)
				
			if not loadSuccess then
				debug_warn("[Synmax -> Mod Manager] " .. mod.Name .. " Could not be Loaded. Make sure that required parameters are present!")
				continue
			end
			
			pluginCount = pluginCount + 1
		end
	end
	
	loadModFolder(mods)
	loadModFolder(externalMods)

	debug_print(string.format("[Synmax] %i Plugins Loaded", pluginCount))
end

table.insert(connections, game:GetService("StudioService"):GetPropertyChangedSignal("ActiveScript"):Connect(function(test)
	if SavesEnabled then saveModules() end
end))

local function keyCombo(_, _)
	local keysPressed = UIS:GetKeysPressed()
		
	local space, shift, up = false, false, false

	for _, key in ipairs(keysPressed) do
		if (key.KeyCode == Enum.KeyCode.Space) then
			space = true
		end

		if (key.KeyCode == Enum.KeyCode.LeftShift) then
			shift = true
		end
	end

	if space and shift and RunService:IsEdit()then
		ToggleSynmax()
		game:GetService("RunService").RenderStepped:Wait()
		inputBox.Text = ""
		inputBox:CaptureFocus()
	end 
end

--[[ ON PLUGIN BOOT ]]--

if not externalMods then
	externalMods = Instance.new("Folder", game.ServerStorage)
	externalMods.Name = "SYNMAX_PLUGINS"
end

refreshPlugins()

--[[ CONNECTIONS ]]--

table.insert(connections, externalMods.ChildAdded:Connect(refreshPlugins))
table.insert(connections, externalMods.ChildRemoved:Connect(refreshPlugins))
table.insert(connections, enableSynmax.Click:Connect(ToggleSynmax))
table.insert(connections, reloadMods.Click:Connect(refreshPlugins))
table.insert(connections, UIS.InputBegan:Connect(keyCombo))

table.insert(connections, forceLoad.Click:Connect(function()
	forceLoad:SetActive(false)
	loadSavedModules(true)
	debug_print("[Synmax -> Cross-save] Forced Sync Successful")
end))

table.insert(connections, overwrite.Click:Connect(function()
	OWEnabled = not OWEnabled
	overwrite:SetActive(OWEnabled)
	plugin:SetSetting("IsOverwriteEnabled", OWEnabled)
end))

table.insert(connections, enableSave.Click:Connect(function()
	SavesEnabled = not SavesEnabled
	enableSave:SetActive(SavesEnabled)
	plugin:SetSetting("SaveModsEnabled", SavesEnabled)
end))

---------------------------

-- Modular System Search --

local selectedMethod = nil
local selMethodArgs = {}
local selectedMod = nil
local lastArgs = 1
local functionArg = 0
local funcArgs = "<params>"

local PosState = false
local isRunning = false
local autoFilled = false

local infoText = ""
local infoDebounce = false

local methodRunning = false

function changeInfo()
	
	if info.Text == infoText or infoDebounce then return end
	infoDebounce = true
	
	spawn(function()
		StyleTween.TweenPos(info, UDim2.new(0, 0, 1.5, 0), .25)	

		wait(0.25)
		info.Text = infoText
		StyleTween.TweenPos(info, UDim2.new(0, 0, 0.7, 0), .25)
		infoDebounce = false
	end)
end

local oldText = ""
function updateMain()
	info.TextColor3 = config.InfoColor.Value

	if isRunning or methodRunning then return end
	isRunning = true
	
	local t = inputBox.Text
	local args = string.split(t, " ")
	
	if #args <= 1 then
		args = string.split(t, ".")
	end
	
	local freeze = ""
	local contextArray = {}
	local currentArg = t

	selectedMod = nil
	selectedMethod = nil
	selMethodArgs = {}
	
	local pathFound = false
	local isFunction = false

	--[[GET ARGS]]--
	if #args > 1 then 
		lastArgs = #args
		currentArg = args[#args]
		
		-- Gets Root Module --
		if cmds[args[1]] then
			selectedMod = cmds[args[1]]
			local path = cmds[args[1]]
			
			for i, getArg in ipairs(args) do
				-- Deturmines if the refrence is a Function or deeper Table --
				
				if path[getArg] and type(path[getArg]) == "table" then
					path = path[getArg]
					
					local suc, err = pcall(function()
						path._index()
					end)
										
				elseif type(path[getArg]) == "function" and i < #args then -- :)
					selectedMethod = path[getArg]
					isFunction = true
					functionArg = i			
				end
			end
			
			contextArray = path
		end
		
		-- If we are setting function variables 
		if isFunction and #args > functionArg then
			selMethodArgs = {}
			local newArgs = {}
			
			for i = functionArg + 1, #args do
				if args[i]:gsub(" ", "") ~= "" then
					table.insert(newArgs, args[i])
				end
			end
			
			selMethodArgs = newArgs
		end
		
		-- Freezes Arguments to string to display --
		for i = 1, #args - 1 do
			freeze = freeze .. args[i] .. " "
		end		
	else
		contextArray = cmds
	end
		
	--[[ TAB FUNCTIONALITY ]]--
	if currentArg:find("	") then
		if predictBox.Text ~= "" and currentArg ~= "" and not isFunction then
			inputBox.Text = predictBox.Text .. " "
			inputBox.CursorPosition = inputBox.Text:len() + 1
			autoFilled = true
		else
			inputBox.Text = inputBox.Text:gsub("	", "")
			autoFilled = true
		end
	end
	
	--[[ RECALL FUNCTIONALITY ]]--
	if inputBox.Text:gsub(" ", "") == ";" then
		inputBox.Text = lastCommand
		inputBox.CursorPosition = inputBox.Text:len() + 1
		autoFilled = true
	end
	
	--[[ SYNMAX METHOD GUIDANCE ]]--
	if selectedMethod then
		local data = selectedMod._getFunctionInfo
		if data then
			data = data()
			local lastArg = args[#args - 1]
			
			if data[lastArg] then
				infoText = (data[lastArg][1] or "[Docs Missing]"):upper()
				funcArgs = data[lastArg][2] or "<params>"
			else
				--infoText = "[Docs Missing]"
			end
		end
	else -- if none provided..
		funcArgs = "<params>"
	end
	
	--[[ PREDICTION HANDLER ]]--
	local predict = ""
	for cmd, mod in next, contextArray do
		local testitem = string.sub(cmd, 1, string.len(currentArg))
		
		if not cmd:find("_") then -- MAKE SURE IT ISN'T A MODIFIER
			if not pcall(function() testitem:find(currentArg) end) then currentArg = "" end -- Prevents wierd error.
			if testitem:find(currentArg) and t ~= "" and not isFunction then
				predict = freeze .. cmd
				pathFound = true
				
			elseif isFunction and #selMethodArgs == 0 and #args > functionArg then
				predict = freeze .. funcArgs				
			end 
		end

	end

	--[[ HANDLES INFO FROM SELECTED MOD ]]--
	if selectedMod and not isFunction and selectedMod._info then
		infoText = selectedMod._info:upper()		
	elseif not isFunction then
		infoText = pluginCount .. " Modules Loaded [Use (;) to recall]"
	end
	
	--[[ COLOR CODING / FONT ]]--
	
	local function setFormat(textColor, font)
		StyleTween.TweenColor(predictBox, textColor)
		StyleTween.TweenColor(inputBox, textColor)
		predictBox.Font = font
		inputBox.Font = font
	end
		
	--[[ Token Colors ]]--
	if pathFound and not isFunction then
		setFormat(config.SyntaxProperColor.Value, Enum.Font.SourceSans)
		inputBox.Text = inputBox.Text:lower()
	elseif isFunction then
		setFormat(config.FunctionColor.Value, Enum.Font.SourceSansItalic)
	elseif inputBox.Text ~= "" then
		wait()
		setFormat(config.ErrorColor.Value, Enum.Font.SourceSansLight)
		inputBox.Text = inputBox.Text:lower()
	end
	
	hidePredict.Size = UDim2.new(0, inputBox.TextBounds.X, 2, 0)
	predictBox.Text = predict

	-- Animated Text Prediction --
	if predict ~= "" and currentArg ~= "" or isFunction then
		StyleTween.TweenPos(predictBox, UDim2.new(0, 0, 0, 0))	
	else
		predictBox.Text = ""
		predictBox.Position = UDim2.new(-1, 0, 0, 0)
	end
	
	--[[ Allows function calls ]]--
	isRunning = false
		
	changeInfo()
	--[[ Rerun to register autofills ]]--
	if autoFilled then
		autoFilled = false
		wait()
		updateMain()
	end
end

table.insert(connections, inputBox:GetPropertyChangedSignal("Text"):Connect(updateMain))

updateMain()

--[[ PLAYER RETURN METHOD ]]--
table.insert(connections, inputBox.FocusLost:Connect(function(enter, instance)
	if enter then
		lastCommand = inputBox.Text
		
		if not config.Pinned.Value then
			interface.Enabled = false
		end
		
		methodRunning = true
		
		info.Text = ("-> Executing Method..")
		
		local succ, err = pcall(function()
			selectedMethod(selMethodArgs)
		end)
		
		methodRunning = false
		
		if not succ then
			if config.OutputEnabled.Value then
				debug_warn("[Synmax] (Internal Error) : " .. err)
			end
		end
		
		if config.Pinned.Value then
			StyleTween.TweenPos(inputBox, UDim2.new(0, 0, -1, 0), .25)
			Effects.Sounds.sendCommand()
			wait(.25)
			inputBox.Text = ""
			wait()
			inputBox:CaptureFocus()
			inputBox.Position = UDim2.new(0, 0, 0, 0)
		end
	end
end))

plugin.Unloading:Connect(function()
	if SavesEnabled then saveModules() end
	
	for _, item in ipairs(connections) do
		item:Disconnect()
	end
	
	debug_print '[Synmax Unloaded]'
end)
