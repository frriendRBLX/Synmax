local mod = {}

local Plugin, Methods
function mod._init(p, m)
	Plugin, Methods = p, m
end

mod._info = "<settings> <color>"

mod.settings = {
	_index = function()
		mod._info = "<settings> <color>"
	end,

	
	color = {
		_index = function()
			mod._info = "<settings> <color> <norm|funct|err|info|defaults>"
		end,
		
		norm = function(...)
			_G.SYNMAX_CONFIG.SyntaxProperColor.Value = Color3.fromRGB((...)[1] or 1, (...)[2] or 1, (...)[3] or 1)
		end,
		
		funct = function(...)
			_G.SYNMAX_CONFIG.FunctionColor.Value = Color3.fromRGB((...)[1] or 1, (...)[2] or 1, (...)[3] or 1)	
		end,
		
		err = function(...)
			_G.SYNMAX_CONFIG.ErrorColor.Value = Color3.fromRGB((...)[1] or 1, (...)[2] or 1, (...)[3] or 1)
		end,
		
		info = function(...)
			_G.SYNMAX_CONFIG.InfoColor.Value = Color3.fromRGB((...)[1] or 1, (...)[2] or 1, (...)[3] or 1)
		end,
		
		defaults = function(...)
			_G.SYNMAX_CONFIG.ErrorColor.Value = Color3.fromRGB(255, 85, 127)
			_G.SYNMAX_CONFIG.FunctionColor.Value = Color3.fromRGB(85, 170, 255)
			_G.SYNMAX_CONFIG.SyntaxProperColor.Value = Color3.fromRGB(85, 255, 127)
			_G.SYNMAX_CONFIG.InfoColor.Value = Color3.fromRGB(255, 255, 127)
		end,
		
		export = function()
			local err = _G.SYNMAX_CONFIG.ErrorColor.Value
			local suc = _G.SYNMAX_CONFIG.SyntaxProperColor.Value
			local funct = _G.SYNMAX_CONFIG.FunctionColor.Value
			local info = _G.SYNMAX_CONFIG.InfoColor.Value
			
			local errMsg = string.format("%i %i %i", err.R * 255, err.G * 255, err.B * 255)
			local sucMsg = string.format("%i %i %i", suc.R * 255, suc.G * 255, suc.B * 255)
			local functMsg = string.format("%i %i %i", funct.R * 255, funct.G * 255, funct.B * 255)
			local infoMsg = string.format("%i %i %i", info.R * 255, info.G * 255, info.B * 255)
			
			print("+- Synmax Theme Export -+")
			print("+ Error Color:\n" .. errMsg)
			print("+ Function Color:\n" .. functMsg)
			print("+ Proper Color:\n" .. sucMsg)
			print("+ Info Color:\n" .. infoMsg)
			print("+-----------------------+")
		end
	}
}

function mod._getFunctionInfo()
	return {
		norm = {"-> Set color for correct syntax", "<R> <G> <B>"},
		funct = {"-> Set color for function", "<R> <G> <B>"},
		err = {"-> Set color for incorrect syntax", "<R> <G> <B>"},
		info = {"-> Set color for info", "<R> <G> <B>"},
		defaults = {"-> Returns to original color scheme", "()"}
	}
end

return mod