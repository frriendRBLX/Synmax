local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera
local HistoryService = game:GetService("ChangeHistoryService")

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

module._info = "select <param> <type>"

local Types = require(script.Parent.Parent.Ref.Types)
local instanceList = Types.InstanceTypes

local lastSelection = workspace

Select.SelectionChanged:Connect(function()
	lastSelection = Select:Get()[1]
end)

local funcInfo = {
	next = {"-> Goes down a directory", "()"},
	updir = {"-> Goes up a directory", "()"},
	loose = {"-> Finds object by substring (ex: 'scr' -> 'Script')", "<substring>"},
	strict = {"-> Finds object by strict name (ex: 'Script' -> 'Script')", "<name>"},
	all = {"-> Gets Children of Selected Object", "()"},
}

module.select = {
	_index = function()
		module._info = string.format("select <all|byname|bytype|updir|next>", tostring(lastSelection))
	end,
	
	next = function()
		if #Select:Get() > 0 then
			local obj = Select:Get()[1]:GetChildren()
			obj = obj[1]
			
			
			Select:Set({obj})
		end
	end,
	
	bytype = {
		_index = function()
			module._info = "select bytype <type>"
		end
	},
	
	byname = {
		_index = function()
			module._info = "select byname <strict|loose> <name>"
			
			if #Select:Get() < 1 then
				lastSelection = workspace
			end
		end,
		
		strict = function(...)
			local args = ...
			local name = args[1]
			
			local matches = {}
			
			for _, obj in ipairs(lastSelection:GetDescendants()) do
				if obj.Name == name then
					table.insert(matches, obj)
				end
			end
			
			if #matches > 0 then
				Select:Set(matches)
			end
			
			HistoryService:SetWaypoint("Selected Objects")
		end,
		
		loose = function(...)
			local args = ...
			local name = args[1]

			local matches = {}

			for _, obj in ipairs(lastSelection:GetDescendants()) do
				if obj.Name:lower():find(name:lower()) then
					table.insert(matches, obj)
				end
			end

			if #matches > 0 then
				Select:Set(matches)
			end
			
			HistoryService:SetWaypoint("Selected Objects")
		end
	},
	
	updir = function(...)
		if lastSelection then
			if lastSelection.Parent then
				lastSelection = lastSelection.Parent
				Select:Set({lastSelection})
				HistoryService:SetWaypoint("Went Up a Parent")
			end
		end
	end,
	
	all = function(...)
		local matches = {}
		
		for _, obj in ipairs(lastSelection:GetDescendants()) do
			table.insert(matches, obj)
		end
		
		if #matches > 0 then
			Select:Set(matches)
		end
	end
}

for _, item in ipairs(instanceList) do
	module.select.bytype[item:lower()] = function(...)
		local matches = {}
		
		if #Select:Get() < 1 then
			lastSelection = workspace
		end
		
		for _, obj in ipairs(lastSelection:GetDescendants()) do
			if obj:IsA(item) then
				table.insert(matches, obj)
			end
		end
		
		if #matches > 0 then
			Select:Set(matches)
		end
		
		HistoryService:SetWaypoint("Selected Objects")
	end
	
	funcInfo[item:lower()] = {("-> Select objects by %s type in %s"):format(item, tostring(lastSelection)), "()"}
end

function module._getFunctionInfo()
	return funcInfo
end


return module
