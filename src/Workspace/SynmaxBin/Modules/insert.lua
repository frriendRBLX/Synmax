local module = {}

local Select = game:GetService("Selection")
local IS = game:GetService("InsertService")
local Camera = workspace.Camera

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

module._info = "insert <model id>"

module.insert = function(...)
	local id = (...)[1]:gsub(" ", "")
	local Model = game:GetObjects("rbxassetid://" .. id)[1]
	
	if Model then
		Model.Parent = workspace
		local primary = nil
		
		print(("[Synmax -> Insert] Successfully loaded (%s)"):format(Model.Name))
		
		for _, item in ipairs(Model:GetDescendants()) do
			if item:IsA("Part") then
				Model.PrimaryPart = item
				Model:MoveTo(Camera.CFrame.Position + (workspace.Camera.CFrame.LookVector * 10))
				break
			end
		end
	else
		print(("[Synmax -> Insert] Model not Found! (%s)"):format(id))
	end
end

function module._getFunctionInfo()
	return {
		insert = {"-> Insert an Item by Name", "<asset id>"}
	}
end

return module
