local module = {}

function playSFX(id)
	spawn(function() 
		local sound = Instance.new("Sound")
		sound.SoundId = id
		game:GetService("SoundService"):PlayLocalSound(sound)
		sound.Ended:Wait()
		sound:Destroy()
	end)
end

module.Sounds = {
	sendCommand = function() playSFX("rbxassetid://2668781453") end,
}

return module
