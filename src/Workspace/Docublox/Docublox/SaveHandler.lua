local save = {}

local storeID = "DocubloxSaves"

function save.Save(plug, objects)
	local saveArray = {}

	for i, item in ipairs(objects) do
		local temp = {}
		temp.Header = item.Header
		temp.Body = item.Body
		temp.Type = item.Type
		temp.CreatedPlaceID = item.CreatedPlaceID
		temp.CreatedTime = item.CreatedTime
		table.insert(saveArray, temp)
	end

	plug:SetSetting(storeID, saveArray)
end

function save.Load(plug)
	return plug:GetSetting(storeID)
end

return save