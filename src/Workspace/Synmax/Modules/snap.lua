local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera
local HistoryService = game:GetService("ChangeHistoryService")

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

module._info = "snap"

module.snap = function(...)
	local args = ...
	
	local studs = args[1] or 1
	
	local selection = Select:Get()
	
	for _, obj in ipairs(selection) do
		if obj:IsA("BasePart") then			
			local x = math.floor(obj.Position.X, studs) 
			local y = obj.Position.Y
			local z = math.floor(obj.Position.Z, studs) 
			
			x = x + (1 - (obj.Size.X / 2)) 
			z = z + (1 - (obj.Size.Z / 2)) 
			
			obj.Position = Vector3.new(x, y, z)
		end
	end
	
	HistoryService:SetWaypoint("Snapped to Grid")
end

function module._getFunctionInfo()
	return {
		snap = {"-> Snaps Part to Grid", "()"}
	}
end


return module
