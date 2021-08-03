local module = {}

local Select = game:GetService("Selection")

local Plugin, Methods
function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

module._info = "find <path>"

local funcInfo = {}

function setup()	
	for _, g in ipairs(game:GetChildren()) do
		local suc, err = pcall(function()
			module[g.Name:lower()] = function(...)
				local args = ...
				local name = args[1]
				name = name:gsub(" ", "")
				
				for _, item in ipairs(g:GetDescendants()) do
					if string.find(item.Name:lower(), name) then
						Select:Set({item})
						
						if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
							Plugin:OpenScript(item)
						end
						
						return	
					end
				end
			end
			
			funcInfo[g.Name:lower()] = {("-> Search %s for an object by name"):format(g.Name), "<name>"}
		end)
	end
end

setup()

function module._getFunctionInfo()
	return funcInfo
end

return module
