local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera
local HistoryService = game:GetService("ChangeHistoryService")

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

module._info = "<players> <loadchar>"

module.players = {
	_index = function()
		module._info = "<players> <loadchar>"
	end,
	
	loadchar = function(...)
		local UID = game.Players:GetUserIdFromNameAsync((...)[1])
		
		if UID then			
			local succ, err = pcall(function()
				local IS = game:GetService("InsertService")
				--IS:LoadAsset()

				local info = game.Players:GetCharacterAppearanceAsync(UID)
				
				local dummy = game:GetObjects("rbxassetid://5895769811")
				dummy = dummy[1]
				dummy.Parent = game.Workspace
				
				dummy:SetPrimaryPartCFrame(CFrame.new(workspace.Camera.CFrame.Position + (workspace.Camera.CFrame.LookVector * 10), workspace.Camera.CFrame.Position))
				
				for _, item in ipairs(info:GetChildren()) do
					item.Parent = dummy
				end
			end)
			
			if succ then
				print(("[Synmax -> Players] Character (%i) has been loaded"):format(UID))
			else
				warn("[Synmax -> Players] Error: " .. err)
			end
		end		
	end
}

function module._getFunctionInfo()
	return {
		loadchar = {"-> Loads player model from name", "<name>"}
	}
end


return module
