local module = {}

local HistoryService = game:GetService("ChangeHistoryService")

local Plugin, Methods

function module._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

local requireWhitelist = {
	"1936396537", -- DS2
	"1868400649", -- Khols
	
}

module._info = "[BETA] <av> <scan|quarentine>"

local quarentine = {}

function checkBetweenParenthesis(index, find, src)
	local requirement = ""

	local baseFindReq = index + find

	for i = baseFindReq, baseFindReq + 100 do
		local sub = src:sub(i, i)

		if sub ~= ")" and sub ~= "," then
			requirement = requirement .. sub
		else
			break
		end
	end
	
	return requirement
end

function scan(objs)	
	quarentine = {}
	
	local count = 0

	for _, item in ipairs(objs) do
		if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
			local src = item.Source:lower()
			local findRequire = src:find("require")
			local findMPS = src:find("getproductinfo")
			
			if findRequire then				
				local requirement = checkBetweenParenthesis(8, findRequire, src)
				
				if tonumber(requirement) and not table.find(requireWhitelist, requirement) then
					warn("[Synmax Scan] Possible Threat Found! (External Requirement)")
					table.insert(quarentine, item)
				end
			elseif findMPS then				
				local requirement = checkBetweenParenthesis(14, findMPS, src)

				if not tonumber(requirement) then
					warn("[Synmax Scan] Possible Threat Found! (Indirect GetProductInfo Call)")
					table.insert(quarentine, item)
				end
			end
		end
	end

	print(("%i Possible Threats Found"):format(#quarentine))
	
	if(#quarentine) > 0 then
		print("Use (av quarentine isolate) to view them")
	end
	
	game:GetService("Selection"):Set(quarentine)
	wait(0.1)
	game:GetService("Selection"):Set(quarentine)
end

module.av = {
	_index = function()
		module._info = "[BETA] <av> <scan|quarentine>"
	end
}

module.av.scan = {
	_index = function()
		module._info = "<av> <scan> <all|selection>"
	end,
	
	selection = function()
		module._info = "<av> <selection> (scan selected item)"

		if #game:GetService("Selection"):Get() > 0 then
			local objs = {}

			for _, item in ipairs(game:GetService("Selection"):Get()) do
				for _, i in ipairs(item:GetDescendants()) do
					table.insert(objs, i)
				end
			end

			scan(objs)
		end
	end,

	all = function()
		module._info = "<av> <workspace> (scan workspace)"

		local points = {
			game.Workspace,
			game.ReplicatedStorage,
			game.ServerScriptService,
			game.StarterPlayer,
			game.StarterPack,
			game.StarterGui,
			game.TestService
		}
		
		local objs = {}
		
		print(("[Synmax Scan] Registering Objects (%i Directories) ------"):format(#points))
		
		for _, x in ipairs(points) do
			wait(0.25)
			print("   -> ".. x.Name .. " -> Indexed..")
			for _, y in ipairs(x:GetDescendants()) do
				table.insert(objs, y)
			end 
		end
		
		print(("[Synmax Scan] Scanning Objects (%i Items) "):format(#objs))

		scan(objs)
	end,
}


function makeFolder()
	local folder = game.ServerStorage:FindFirstChild("Synmax_Quarentine") 

	if not folder then
		folder = Instance.new("Folder", game.ServerStorage)
		folder.Name = "Synmax_Quarentine"
	end
	
	return folder
end

module.av.quarentine = {
	_index = function()
		module._info = "<av> <quarentine> <isolate|examine|remove|clear>"
	end,
	
	isolate = function()
		local _info
		local folder = makeFolder()
		
		folder:ClearAllChildren()
		
		for _, item in ipairs(quarentine) do
			local temp = item:Clone()
			temp.Parent = folder
			
			local objVal = Instance.new("ObjectValue", temp)
			objVal.Name = "REF"
			objVal.Value = item
		end
		
		game:GetService("Selection"):Set({folder})
	end,
	
	examine = function(...)
		local name = (...)[1]
		local folder = makeFolder()
				
		local sel = nil
		
		for _, item in ipairs(folder:GetChildren()) do
			
			if item.Name:lower():find(name) then
				sel = item
			end
			
		end
		
		game:GetService("Selection"):Set({sel})
		
		Plugin:OpenScript(sel)
	end,
	
	remove = function()
		local sele = game:GetService("Selection"):Get()
		
		if sele[1] then
			local ref = sele[1]:FindFirstChild("REF")
			if ref then
				warn("[Synmax Scan] Removed Threat from Game!")
				ref.Value.Parent = nil
				sele[1].Parent = nil
			end
		end
	end,
	
	clear = {
		_index = function()
			module._info = "!> You Must Confirm this Action : Type 'confirm'"
		end,
		
		confirm = function()
			HistoryService:SetWaypoint("Removing Potential Threats")
			for _, item in ipairs(makeFolder():GetChildren()) do
				local ref = item:FindFirstChild("REF")
				if ref then
					if ref.Value then
						warn("[Synmax Scan] Removed Threat from Game!")
						ref.Value.Parent = nil
						item.Parent = nil
					end
				end
			end
			
			HistoryService:SetWaypoint("Removed Potential Threats")
		end
	}
}

function module._getFunctionInfo()
	return {
		examine = {"-> Opens infected item in script editor", "<name>"},
		isolate = {"-> Move all threats to ServerStorage>Synmax_Quarentine", "()"},
		remove = {"-> Removes Selected threat from Game", ("(S: %s)"):format(tostring(game:GetService("Selection"):Get()[1]))},
		confirm = {"-> Removes ALL threats from Game", ("(%i Threats)"):format(#quarentine)},
		selection = {"-> Scans Selected item for Harmful Code", ("(S: %s)"):format(tostring(game:GetService("Selection"):Get()[1]))},
		all = {"-> Scans Whole Game for Harmful Code", "()"}
	}
end

return module
