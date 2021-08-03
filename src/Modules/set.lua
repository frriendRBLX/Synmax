local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera
local HistoryService = game:GetService("ChangeHistoryService")

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

local funcInfo = {}

module._info = "[Requires Selection] set <Property> <New Value>"

local propertyList = {
	"Transparency", "BackgroundTransparency", "TextTransparency", "Name", "Text", "TextColor3", "BrickColor", "BackgroundColor3", "Image", "ImageTransparency",
	"Size", "Rotation", "Visible", "AutoButtonColor", "Color", "CanCollide", "Value", "Position"
}


for _, item in ipairs(propertyList) do
	module[item:lower()] = function(...)		
		local args = ...
		local value = args[1]:gsub(" ", "")
		local selArray = Select:Get()
		
		for i, item in ipairs(args) do
			if item == "~" then
				args[i] = nil	
			end
		end
		
		for _, selection in ipairs(selArray) do
			local objType = typeof(selection)
			local varType = typeof(selection[item])

			if varType == "boolean" then
				if value == "true" then
					selection[item] = true
				else
					selection[item] = false
				end
			elseif varType == "number" then
				selection[item] = tonumber(value)
			elseif varType == "Color3" then
				local r = args[1] or selection[item].R * 255
				local g = args[2] or selection[item].G * 255
				local b = args[3] or selection[item].B * 255
				
				print(r, g, b)
				
				selection[item] = Color3.fromRGB(r, g, b)
			elseif varType == "BrickColor" then
				selection[item] = BrickColor.new(args[1])
				
			elseif varType == "UDim2" then
				local x1 = args[1] or selection[item].X.Scale
				local x2 = args[2] or selection[item].X.Offset
				local y1 = args[3] or selection[item].X.Scale
				local y2 = args[4] or selection[item].X.Offset
				
				selection[item] = UDim2.new(x1, x2, y1, y2)
			elseif varType == "Vector3" then
				local x, y, z = args[1] or selection[item].X, args[2] or selection[item].Y, args[3] or selection[item].Z
				
				selection[item] = Vector3.new(x, y, z)
			elseif varType == "string" then
				local msg = ""
				
				for i = 1, #args do
					args[i] = args[i]:gsub(" ", "")
					msg = msg .. args[i] .. " "
				end
				
				selection[item] = msg
			end				
		end
		
		HistoryService:SetWaypoint("Updated Property")
	end
	
	--funcInfo[item:lower()] = {""}
end

return module
