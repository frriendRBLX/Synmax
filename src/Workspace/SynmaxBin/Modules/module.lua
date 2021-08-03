local mod = {}

--[[ Synmax Passthrough ]]--

local Select = game:GetService("Selection")

local Plugin, Methods

function mod._init(pluginRef, m) 
	Plugin = pluginRef
	Methods = m
end

mod._info = "Module <load|unload|run|peek>"
mod.current = nil

-- Attempt to Load the current module into the system --
function attemptToLoad(object)
    if object:IsA("ModuleScript") then
        mod.current = require(object)
        print(("Module %s Successfully Loaded."):format(object.Name))
    else
        warn("Selected object is not a module script.")
    end
end

-- Allows us to peek at a modules enviroment by type --
function peekByType(...)
    local function echoResult(index, key, value)

        -- For End User Readability (hide memory address) --
        local printValue = value
        if type(value) == "function" then
            printValue = "(...)"
        elseif type(value) == "table" then
            printValue = string.format("{%i}", #value)
        end

        print(("%i. %s => %s | TYPE: %s"):format(index, key, tostring(printValue), string.upper(type(value))))
    end

    local index = 0
    for key, value in pairs(mod.current) do
        index += 1

        if not (...) then
            echoResult(index, key, value)
        else
            for _, getType in pairs(table.pack(...)) do
                if type(value) == getType then
                    echoResult(index, key, value)
                end
            end
        end
    end
end

function checkIfLoaded()
    if mod.current then
        return true
    else
        warn("No module loaded.")
        return false
    end
end

mod.module = {
    _index = function()
        mod._info = "Module <load|unload|run|peek>"
    end,

    load = {
        _index = function()
            mod._info = "Module load <selected|bypath>"
        end,

        selected = function()
            local get = Select:Get()[1]
            attemptToLoad(get)
        end,
        
        bypath = function(...) 
            -- Let garbage collector take the old module --
            if mod.current then
                mod.current = nil
            end
            
            -- Split path into segments seperated by periods --
            local path = string.split((...)[1], ".")
            
            -- Traverse path and catch any issues in formatting --
            local current = game
            for _, step in ipairs(path) do
                local s, _ = pcall(function()
                    current = current[step]
                end)

                if not s then 
                    warn(("Path [%s] was unable to be parsed."):format((...)[1]))
                    return
                end
            end

            attemptToLoad(current)            
        end
    },
    

    run = function(...)
        -- Verify a Module is Loaded --
        local modref = mod.current

        if not modref then
            warn("No module loaded. Use the load method to inject a module.")
            return
        end

        -- Isolate Arguments and Seperate Function Name --

        local arguments = (...)
        local method = table.remove(arguments, 1)

        -- Verify that method exists, and that its a function --
        if modref[method] then
            if type(modref[method]) == "function" then
                local _, e = pcall(modref[method], table.unpack(arguments))
                warn(("Method Executed. Result: %s"):format(e or "SUCCESS"))
            else
                warn(("%s is a %s, not a function."):format(method, type(modref)))
            end
        else
            warn(("%s is not a valid member of the loaded module."):format(method))
        end
    end,

    unload = function()
        if checkIfLoaded() then
            mod.current = nil
            print("Successfully unloaded module!")            
        end
    end,

    -- Peeks inside of a modules enviroment. Pulls all of its 
    peek = {
        _index = function()
            mod._info = "Module peek <bytype|methods|all>"
        end,

        bytype = function(...)
            if not checkIfLoaded() then return end
            if not (...) then warn("No Types Passed.") end

            local _, e = pcall(peekByType, ...)
            if e then warn(e) end
            -- elaborate more!
        end,

        methods = function()
            if checkIfLoaded() then
                peekByType("function")
            end
        end,

        all = function()
            if checkIfLoaded() then
                peekByType()
            end
        end
    }
}

function mod._getFunctionInfo()
	return {
        load = {"-> Load a Module by path", "<path>"},
        run = {"-> Run a Method from a Module", "<method>(<arguments>)"},
        unload = {"-> Unload the current method", "()"},
        selected = {"-> Load the selected Module", "()"},
        byType = {"-> View current module members by type", "(...)"},
        methods = {"-> View all methods of the current module", "()"},
        all = {"-> View all members of the current module", "()"}
	}
end

function mod.cleanup()
    
end

return mod
