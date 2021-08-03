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
	
	interface = Methods.makeWindow("SynmaxAbout", 250, 250, 250, 60)	
	interface.Title = "Synmax > About"
end

module.about = function()
	main.Parent = interface
	interface.Enabled = not interface.Enabled
	
	main.VER.Text = Methods._VER
end

function module._getFunctionInfo()
	return {
		about = {"-> Opens about menu", "()"}
	}
end


return module
