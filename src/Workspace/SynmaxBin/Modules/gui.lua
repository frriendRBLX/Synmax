local module = {}

local Select = game:GetService("Selection")
local Camera = workspace.Camera

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

local funcInfo = {
	zero = {"-> Resets Objects Size and Position to Zero", "()"},
	round = {"-> Adds UICorner to Object with Given Parameters", "<Scale> <offset>"},
	midfit = {"-> Centers Object on Screen", "()"},
	fit = {"-> Scales the Object to Fit its parent", "()"},
	evenpad = {"-> Adds UIPadding to Object with Even Parameters", "<Scale> <offset>"}
}

local guiTypes = {
	"ScreenGui", "Frame", "TextLabel", "TextButton", "ImageButton", "TextBox"
}

module.gui = {
	_index = function()
		module._info = "gui <add|select|format|fx>"
	end,
	
	select = {},

	add = {
		_index = function()
			module._info = "gui add <element> <name>"
		end
	},
	
	format = {
		_index = function()
			module._info = "gui format <zero|midfit|fit>"
		end,
		
		zero = function(...)
			local item = checkSelection()

			if item then
				item.Size = UDim2.new(0, 0, 0, 0)
				item.Position = UDim2.new(0, 0, 0, 0)
				item.BorderSizePixel = 0

				if item.Text then
					item.Text = ""
				end
			end
		end,

		midfit = function(...)
			local item = checkSelection()

			if item then
				item.Size = UDim2.new(0.5, 0, 0.5, 0)
				item.Position = UDim2.new(0.25, 0, 0.25, 0)
			end
		end,
		
		fit = function(...)
			local item = checkSelection()

			if item then
				item.Size = UDim2.new(1, 0, 1, 0)
				item.Position = UDim2.new(0, 0, 0, 0)
			end
		end
	},
	
	fx = {
		_index = function()
			module._info = "gui fx <round>"
		end,

		round = function(...)
			local item = checkSelection()
			local radiusScale = (...)[1] or nil
			local radiusOffset = (...)[2] or nil

			if item then
				local corner = Instance.new("UICorner", item)

				if radiusScale then
					corner.CornerRadius.Scale = tonumber(radiusScale)
					if radiusOffset then
						corner.CornerRadius.Offset = tonumber(radiusOffset)
					end
				end

			end
		end,
		
		evenpad = function(...)
			local item = checkSelection()
			local Scale = (...)[1] or 0.1
			local Offset = (...)[2] or 0

			if item then
				local pad = Instance.new("UIPadding", item)

				if Scale then
					pad.PaddingBottom = UDim.new(Scale, Offset)
					pad.PaddingTop = UDim.new(Scale, Offset)
					pad.PaddingLeft = UDim.new(Scale, Offset)
					pad.PaddingRight = UDim.new(Scale, Offset)
				end

			end
		end
	}
}


function updateGUIList()		
	local items = game.StarterGui:GetChildren()
	
	module.gui.select = nil
	module.gui.select = {
		_index = function()
			module._info = "gui select <gui>"
		end
	}
	
	for _, item in ipairs(items) do
		module.gui.select[item.Name:lower()] = function()
			Select:Set({item})
		end
		
		funcInfo[item.Name:lower()] = {("-> Select GUI Named %s"):format(item.Name), ("()")}
	end
end

game.StarterGui.ChildRemoved:Connect(updateGUIList)
game.StarterGui.ChildAdded:Connect(updateGUIList)
updateGUIList()

for _, t in ipairs(guiTypes) do
	module.gui.add[t:lower()] = function(...)
		local name = (...)[1] or nil
		if name then name = name:gsub(" ", "") end
		
		local instance = Instance.new(t)

		if #Select:Get() > 0 then
			instance.Parent = Select:Get()[1]
		else
			instance.Parent = game.StarterGui
		end
		
		if name then
			instance.Name = name
		end
		
		Select:Set({instance})
	end
	
	game:GetService("Selection").SelectionChanged:Connect(function()
		funcInfo[t:lower()] = {("-> Create a new GUI Object inside the Parent (%s)"):format(tostring(game:GetService("Selection"):Get()[1])), "()"}
	end)
end

function checkSelection()
	local item = nil


	if Select:Get()[1] then
		item = Select:Get()[1]
	end

	if item then
		return item
	end
	
	return nil
end

function module._getFunctionInfo()
	return funcInfo
end

return module
