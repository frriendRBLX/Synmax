local module = {}

local TS = game:GetService("TweenService")

local TweenInProgress = false

module.TweenColor = function(obj, color)
	if obj.TextColor3 == color then return end
	
	local TI = TweenInfo.new(.25)
	local Tween = TS:Create(obj, TI, {TextColor3 = color})
	Tween:Play()
end

local posTween = nil
function module.TweenPos(obj, pos, speed)
	speed = speed or 0.5
	--if posTween then posTween:Cancel() end
	if pos == obj.Position then return end
	
	local TI = TweenInfo.new(speed, Enum.EasingStyle.Quad)
	posTween = TS:Create(obj, TI, {Position = pos})
	posTween:Play()	
end

return module
