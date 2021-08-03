local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera

local HistoryService = game:GetService("ChangeHistoryService")

local currentScript

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

module._info = "script <new|run>"

function parseSource(...)
	local args = ...
	local source = " "

	for _, item in ipairs(args) do
		source = source .. item .. " "
	end
	
	return source
end

module.new = function(...)
	local source

	if ... then
		source = parseSource(...)
	else 
		source = ""
	end
	
	currentScript = Instance.new("Script", game.ServerScriptService)
	
	
	if source ~= "" then currentScript.Source = source end
	Plugin:OpenScript(currentScript)
	HistoryService:SetWaypoint("Created Script")
end

module.run = function(...)
	local source = parseSource(...)
	loadstring(source)()
	HistoryService:SetWaypoint("Ran Code")
end

function module._getFunctionInfo()
	return {
		new = {"-> Creates a new script with given source", "(source)"},
		run = {"-> Runs a quick line of code", "(code)"}
	}
end


return module
