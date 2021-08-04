local mod = {}

--[[ Synmax Passthrough ]]--

local Plugin, Methods

function mod._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

--[[
	Plugin: we pass the plugin through so developers can utilize Plugin:OpenScript()!
	
	Methods: these are synmax methods. These will be documented as they are added!
	
	Be sure to avoid deleting the lines above, as doing so will break your module.
]]


--[[
	module._info tells synmax what to display as contextual information for users.
	
	This allows you to show the user their options when using your module.
]]--

mod._info = "<modName> <option1|option2>"

--[[
	Synmax relies on nested dictionaries to layout your module's arguments and options.
	
	The name of our module is our first argument. In this case, it's "template"
	
	Lets take a look at (layerone) below.
	
	When indexing this using synmax, the user will type:
		[ template layerone ]
	into the synmax terminal. This will take us to mod.layerone!
	
	Note: It's important to keep the names of methods and tables in lowercase :) 
	if they are not synmax may not read them properly.
	
	Lets dig a bit deeper!
]]--

mod.layerone = {
	--[[
		Below we have our first function! This function will take a tuple of arguments.
		
		Synmax devides arguments by spaces (" "). You can parse these together as needed.
		
		Below, we repeat the players first argument to them!
	]]--
	
	optiontwo = function(...)
		print((...)[1])
	end,
	
	--[[
		What if we wanted to go deeper?
	]]--
	
	optionthree = {
		optionfour = {
			optionfive = {
				--[[
				
				The user would need to type
				
				'template layerone optionthree optionfour optionfive'
				
				to get down here!
				
				]]--
			}
		}
	}
}
	
--[[
	Here we have our function info function. This tells synmax what to display when encountering a function!
	
	Notice how we have optiontwo equal to another table. This table requires two things.
	
	optiontwo[1]: The contextual information to display (string)
	optiontwo[2]: Contextual arguments (string)
	
	these are not required, but definetly help the end user understand your module.
]]--

function mod._getFunctionInfo()
	return {
		optiontwo = {"-> Say a word and I'll repeat it!", "<word>"}
	}
end

--[[
	This method is used when you need to clean up connections in your code. Totally optional!
--]]

function mod.cleanup()

end

--[[
	Okay, Now try it yourself! 
	
	Drop this mod into game->ServerStorage->SYNMAX_PLUGINS and try typing "template"
	
	If you have any questions on the development of modules for synmax, my DM's are always open.
	
	Contact me:
		- Dev Forum : https://devforum.roblox.com/u/frriend/
		- Twitter : https://twitter.com/frriendRoblox
		
	Made with <3 by frriend 
]]

return mod

