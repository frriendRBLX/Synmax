local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera
local HistoryService = game:GetService("ChangeHistoryService")

local instanceList = _G.SYNMAX_TYPES.InstanceTypes

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

local funcInfo = {}

module._info = "new <objtype>"

for _, item in ipairs(instanceList) do
	module[item:lower()] = function(...)
		local args = ... or {nil, nil}
		local name = args[1] or nil
		local parentName = args[2]
		local parent = workspace
		
		if parentName then
			for _, item in ipairs(game:GetChildren()) do
				pcall(function()
					if item.Name:lower():find(parentName:gsub(" ", "")) then
						parent = item
					end
				end)
			end
		else
			parent = Select:Get()[1] or workspace
		end
				
		for _, item in ipairs(Select:Get()) do
			parent = item
		end
		
		local i = Instance.new(item, parent)
		
		if name and name ~= " " then
			i.Name = name
		end
		
		if i:IsA("Script") or i:IsA("LocalScript") then
			Plugin:OpenScript(i)
		end
		
		pcall(function()
			i.Position = Camera.CFrame.Position + (workspace.Camera.CFrame.LookVector * 10)
		end)
		Select:Set({i})
		
		HistoryService:SetWaypoint("Created Object")
	end
	
	game:GetService("Selection").SelectionChanged:Connect(function()
		if #game:GetService("Selection"):Get() > 0 then
			funcInfo[item:lower()] = {("-> Insert a %s with given properties"):format(item), ("<name> (%s)"):format(tostring(game:GetService("Selection"):Get()[1]))}
		else
			funcInfo[item:lower()] = {("-> Insert a %s with given properties"):format(item), "<name> <parent>"}
		end
	end)
	
	
end

function module._getFunctionInfo()
	return funcInfo
end


return module
