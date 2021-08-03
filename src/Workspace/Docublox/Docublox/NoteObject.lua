local note = {}
note.__index = note

note.IsOpen = false
note.Object = nil
note.Visible = false
note.Type = "NOTE"

note.Header = ""
note.Body = ""
note.Holder = nil

note.CreatedPlaceID = 0
note.CreatedTime = 0

note.TableIndex = 0

note._BIND = nil

local hideFolder = Instance.new("Folder", script.Parent)

-- METHODS ------------------------------------------------------------------------------------------
function note:SetState(bool)
	local Holder = self.Object
	local Options = Holder.OPTIONS
	
	local BodyText = Holder.BODY.BODY_TEXT
	local TEXT_SIZE = game:GetService("TextService"):GetTextSize(BodyText.Text, BodyText.TextSize, BodyText.Font, Vector2.new(Holder.AbsoluteSize.X, 1000000))

	local TEXT_Y = TEXT_SIZE.Y + 35 + 25 + 14 -- 25 is for the options, 14 is for padding!
	Holder.BODY.Size = UDim2.new(1, 0, 0, TEXT_Y)
	
	Options.Position = UDim2.new(0, 0, 0, TEXT_Y - 25)
	
	if bool then
		Holder:TweenSize(UDim2.new(1, 0, 0, TEXT_Y), "Out", "Quad", .25, true)
	else
		Holder:TweenSize(UDim2.new(1, 0, 0, 25), "Out", "Quad", .25, true)
	end
end

function note:SetVisible(bool)	
	if bool then
		self.Object.Visible = true
		self.Visible = true
		self.Object.Parent = self.Holder
	else
		self.Object.Visible = false
		self.Visbile = false
		self.Object.Parent = hideFolder
	end
end

function note:SetType(TYPE, COLOR) 
	self.Type = TYPE
	self.Object.HEADER.TYPE_COLOR.BackgroundColor3 = COLOR
	self.Object.BAR.BackgroundColor3 = COLOR
	self.Object.TOP_BAR.BackgroundColor3 = COLOR	
end

-- OOP CONNECTION HANDLING ----------------------------------------------------------------------------
function note:Fire()
	self._BIND:Fire()
end

function note:OnNoteUpdate(method)
	assert(type(method) == "function", "Type cannot be anything other than a function!")

	return self._BIND.Event:Connect(function()
		method()
	end)
end

function note:Destroy(fast)
	if fast then
		if self._BIND then
			self._BIND.Parent = nil
		end
	else
		self:SetState(false)
		wait(0.25)
		self.Object:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.25)
		wait(0.25)
	end
	
	self.Object.Parent = nil
end

function note:SetOpenState(bool)
	self.IsOpen = bool
end

-- NEW -------------------------------------------------------------------------------------------------
function note.new(template, holder, header, body, goto, pid)
	pid = pid or 0
	goto = goto or false
	local newNote = {}
	setmetatable(newNote, note)
		
	local temp = template:Clone()
	
	temp.HEADER.HEADER_TEXT.Text = header
	temp.BODY.BODY_TEXT.Text = body
	
	newNote.Header = header
	newNote.Body = body
	
	temp.BODY.BODY_TEXT:GetPropertyChangedSignal("Text"):Connect(function()
		newNote:SetState(true)
		newNote:SetOpenState(true)
		newNote.Body = temp.BODY.BODY_TEXT.Text
		newNote._BIND:Fire()
	end)
	
	temp.HEADER.MouseButton1Down:Connect(function()
		newNote.IsOpen = not newNote.IsOpen
		newNote:SetState(newNote.IsOpen)
		newNote._BIND:Fire()
	end)
		
	temp.Parent = holder
	
	newNote.Holder = holder
	newNote.Object = temp

	if goto then
		newNote.Object.BODY.BODY_TEXT:CaptureFocus()
		newNote:SetState(true)
	end
	
	-- Connections --
	newNote._BIND = Instance.new("BindableEvent")	

	return newNote
end

return note
