local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera

local Plugin
local Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

module._info = "translate <x> <y> <z>"

module.translate = function(...)
	local args = ...
	
	local x, y, z = args[1], args[2], args[3]
	x, y, z = tonumber(x), tonumber(y), tonumber(z)
	
	local selection = Select:Get()
	
	for _, obj in ipairs(selection) do
		if obj:IsA("BasePart") then
			local newVector = obj.Position + Vector3.new(x, y, z)
			obj.Position = newVector
		end
	end
end

function module._getFunctionInfo()
	return {
		translate = {"-> Translate Object's Position", "<x> <y> <z>"}
	}
end


return module
