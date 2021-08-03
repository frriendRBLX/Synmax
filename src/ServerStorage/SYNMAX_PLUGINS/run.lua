local registeredFunctions = {}

local mod = {}

local Plugin, Methods
mod._init = function(p, m)
	Plugin, Methods = p, m
end

mod._info = 'function <execute|add>'

mod['function'] = {
	execute = function(...)
		local arg = ...
		local funcName = arg[1]
		table.remove(arg, 1)


		if registeredFunctions[funcName] then
			registeredFunctions[funcName](unpack(arg))
		end
	end,

	add = function(...)
		local arg = ...
		local path = arg[1]
		local steps = string.split(path, '.')
		local cur
		for i = 1, #steps do
			if cur == nil then
				if steps[i] == 'game' then
					cur = game
				elseif steps[i] == 'workspace' then
					cur = workspace
				end

			else
				local new = cur:FindFirstChild(steps[i])
				if not new then
					warn('Could not find', cur:GetFullName() .. '.' .. steps[i])
					return
				end
				cur = new
			end
		end

		if not cur:IsA('ModuleScript') then
			warn(cur:GetFullName(), 'is not a modulescript!')
			return
		end

		local module = require(cur:Clone())

		for i, v in pairs(module) do
			if type(v) == 'function' then
				registeredFunctions[cur.Name .. '.' .. tostring(i)] = v
				print('Registered new function', i)
			end
		end
	end
}

function mod.getFunctionInfo()
	return {
		execute = {'execute a function', 'module.function'},
		add = {'Add a ModuleScripts Function', 'module'}
	}
end


return