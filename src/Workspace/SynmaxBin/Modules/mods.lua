local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera

local Plugin
local Methods
local interface

local main = script.GUI.Main

function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m

	interface = Methods.makeWindow("SynmaxMods", 250, 250, 250, 60)	
	interface.Title = "Synmax > Mods"
end

module.mods = function()
	main.Parent = interface
	interface.Enabled = not interface.Enabled
	
	local MOD = Methods.getCmdList()
	
	local str = ""
	for _, item in ipairs(MOD) do
		str = str .. "[" .. item .. "] "
		main.Info.Text = str
	end		
end

function module._getFunctionInfo()
	return {
		mods = {"-> Opens mod list", "()"}
	}
end


return module
