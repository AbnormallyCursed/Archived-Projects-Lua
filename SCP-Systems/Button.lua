local Nucleus = require(game.ReplicatedStorage.Nucleus)
local import = Nucleus.import
local Services = Nucleus.Services
local Retrieve = Nucleus.retrieve

local Players = Services.Players

local PlayerHandler = import("PlayerHandler")
local ServerSystem = import("Server System")
local Tween:TweenService = Services.TweenService
local SendToServer = ServerSystem.SendToServer
local ButtonTypes = {
	["rbxassetid://498782584"] = "keycard",
	["rbxassetid://7704504192"] = "button",
	["rbxassetid://5894251275"] = "keypad",
	["rbxassetid://5905922111"] = "scanner",
	["rbxassetid://7704465247"] = "elevator"
}
local KeypadHandlers = {}

-- Permission Stuff:
repeat wait() until ServerSystem.Destinations["94.147.110.5:500"]
local SCP005_NAMES = {
	"SCP-005", "OwO"
}
local SCANNERHAND_NAMES = {
	"Joe's Hand"
}
local LockdownBypassFallback = {"User:512746977"}
local IP = math.random(1,255).."."..math.random(1,255).."."..math.random(1,255).."."..math.random(1,255)
local function CheckRFID(Encoded_RFID, Permissions)
	return SendToServer("94.147.110.5:500", IP, Encoded_RFID, Permissions)
end

Services.ReplicatedStorage.RemoteEvent.KeypadEvent.OnServerEvent:Connect(function(Player, args)
	local Object, Code = unpack(args)
	KeypadHandlers[Object](Code)
end)

-- Button Class:
return function(Object, UseParent)
	local self = {
		Handlers = {}
	}
	self.HintMessages = {
		notenoughclearance = "You need a keycard with a higher security clearance to operate the door", 
		keycardrequired = "A keycard is required for the slot.", 
		keycard = "The keycard was inserted into the slot.", 
		keycard2 = "You hold the key close to the slot", 
		doorlocked = "This door seems to be locked.", 
		keycardlocked = "The keycard was inserted into the slot but nothing happened.", 
		keycardlocked2 = "You hold the key close to the slot but nothing happened.",

		buttonlocked = "You pushed the button but nothing happened.",

		rfid1 = "You hold the card near the scanner.",
		rfid2 = "You hold the key onto the scanner.",
		rfid3 = "You hold the card near the scanner but nothing happened.",
		rfid4 = "You hold the key onto the scanner but nothing happened.",
		rfid5 = "A card is required to operate this scanner.",

		dna0 = "You placed your palm onto the scanner. The scanner reads: \"DNA does not match known sample. Access denied.\"", 
		dna1 = "You place the palm of the hand onto the scanner. The scanner reads: \"DNA verified. Access granted.\"", 
		dna2 = "You hold the key onto the scanner. The scanner reads: \"Unknown DNA verified. ERROR! Access granted.\"", 
		dna3 = "You place the palm of the hand onto the scanner. The scanner reads: \"DNA does not match known sample. Access denied.\"", 
		dna4 = "You placed your palm onto the scanner. The scanner reads: \"DNA verified. Access granted.\"", 
		dna5 = "You hold the key onto the scanner. The scanner reads: \"DNA Scanner Error. Access denied.\"",
		dnakeycard = "This type of this slot doesn't require keycards."
	}
	self.SoundClass = "Key"

	--// Initialization
	local IsDoor = false
	local ValueTarget = Object
	if Object.Parent:FindFirstChild("Open") then
		IsDoor = true
		ValueTarget = Object.Parent
	end

	local ButtonPrompt = Retrieve("ButtonPrompt","ProximityPrompt",Object)
	local Permissions = Object:FindFirstChild("Permissions")
	local LockPermissions = Object:FindFirstChild("LockPermissions")
	local Locked = Object:FindFirstChild("Locked") or Retrieve("Locked", "BoolValue", ValueTarget)
	local Power = Object:FindFirstChild("Power") or Retrieve("Power", "BoolValue", ValueTarget)
	local Message = Object:FindFirstChild("Message") or Retrieve("Message", "StringValue", ValueTarget)
	local DoorState = IsDoor and Object.Parent:FindFirstChild("Open")
	local AutoClose = IsDoor and Object.Parent:FindFirstChild("AutoClose")
	Power.Value = true
	ButtonPrompt.ActionText = ""
	ButtonPrompt.ObjectText = ""
	ButtonPrompt.MaxActivationDistance = 5
	self.ProxPrompt = ButtonPrompt

	if DoorState then 
		DoorState = DoorState.Value
	end
	if AutoClose then
		AutoClose = AutoClose.Value
	end

	if not Permissions then
		local permfind = Object.Parent:FindFirstChild("Permissions")
		if permfind == nil then
			Permissions = {"return:true"}
		else
			Permissions = permfind
		end
	end

	if not LockPermissions then
		local permfind = Object.Parent:FindFirstChild("LockPermissions")
		if permfind == nil then
			LockPermissions = LockdownBypassFallback
		else
			LockPermissions = permfind
		end
	end

	local function PlaySound(Name)
		local SoundObject = Object:FindFirstChild("Sound")
		local ButtonSound = script[Name]
		if not SoundObject then
			SoundObject = ButtonSound:Clone()
			SoundObject.Name = "Sound"
			SoundObject.Parent = Object
		else
			SoundObject.SoundId = ButtonSound.SoundId
		end
		SoundObject.PlaybackSpeed = ButtonSound.PlaybackSpeed
		SoundObject:Play()
	end
	local function AccessSound(access)
		PlaySound(self.SoundClass..(access and "Success" or "Error"))
	end
	local function Hint(Player, Message)
		task.spawn(function()
			Message = self.HintMessages[Message] or Message
			PlayerHandler.Handlers[Player].Hint(Message, 0.075 * string.len(Message))
		end)
	end
	local function AccessGranted(Plr)
		if IsDoor then
			local Value = Object.Parent:FindFirstChild("LED") and Object.Parent.Parent.Open or Object.Parent.Open
			Value.Value = not Value.Value
		end
		if #self.Handlers > 0 then
			for _,v in ipairs(self.Handlers) do
				v(Plr, Object)
			end
		end
	end

	function self:BindToAccessGranted(Callback)
		table.insert(self.Handlers, Callback)
	end

	--// Main
	if Object.ClassName == "Model" then
		if Object.Name == "RFID" then
			--// RFID READER
			local LED = Object["LED"]
			local StateAccess = Tween:Create(LED, TweenInfo.new(0.15), {Color = Color3.new(0, 1, 0)})
			local StateLocked = Tween:Create(LED, TweenInfo.new(0.15), {Color = Color3.new(1, 0.666667, 0)})
			local StateIdle = Tween:Create(LED, TweenInfo.new(0.15), {Color = LED.Color})
			local Debounce = false

			Object = Object["Body"]
			self.SoundClass = "RFID"
			ButtonPrompt.Parent = Object
			local function Activated(Tool: Tool, Player)
				local SCP005 = Tool.Name == "SCP-005"
				if not Debounce and Power.Value then
					Debounce = true
					local Authorized = Locked.Value == true and (
						CheckRFID(Tool.ToolTip, LockPermissions) and 
							CheckRFID(Tool.ToolTip, Permissions)
					) or CheckRFID(Tool.ToolTip, Permissions)

					AccessSound(Authorized)
					if Locked.Value and not Authorized then
						if IsDoor then
							Hint(Player, "doorlocked")
						else
							if SCP005 then
								Hint(Player, "rfid3")
							else
								Hint(Player, "rfid4")
							end
						end
						return
					end
					if Authorized then
						StateAccess:Play()
						AccessGranted(Player)
						if SCP005 then
							Hint(Player, "rfid2")
						else
							Hint(Player, "rfid1")
						end
					end
					task.wait(1)
					if not Locked.Value then
						StateIdle:Play()
					else
						StateLocked:Play()
					end
					Debounce = false
				elseif not Power.Value then
					if SCP005 then
						Hint(Player, "rfid4")
					else
						Hint(Player, "rfid3")
					end
				end
			end
			Power.Changed:Connect(function(Value)
				if Value then
					if not Locked.Value then
						StateIdle:Play()
					else
						StateLocked:Play()
					end
					LED.Material = Enum.Material.Neon
				else
					LED.Color = Color3.new(1, 1, 1)
					LED.Material = Enum.Material.Glass
				end
			end)
			Locked.Changed:Connect(function(Value)
				if Value then
					if Power.Value == true then
						StateLocked:Play()
					end
					if IsDoor then
						DoorState = Object.Parent.Parent.Open.Value
						Object.Parent.Parent.Open.Value = false
						if not AutoClose then
							Object.Parent.Parent.AutoClose.Value = true
						end
					end
				else
					if Power.Value == true then
						StateIdle:Play()
					end
					if IsDoor then
						Object.Parent.Parent.Open.Value = DoorState
						if not AutoClose then
							Object.Parent.Parent.AutoClose.Value = false
						end
					end
				end
			end)
			ButtonPrompt.Triggered:Connect(function(Player)
				local Tool = Player.Character:FindFirstChildOfClass("Tool")
				if Tool and (table.find(SCP005_NAMES, Tool.Name) or Tool.Name:lower():find("card")) then
					Activated(Tool, Player)
				else
					PlaySound("ButtonPush")
					Hint(Player, "rfid5")
				end
			end)
			Object.Parent.Hitbox.Touched:Connect(function(PartTouched)
				local Tool = PartTouched.Parent
				if Tool.ClassName == "Tool" and (table.find(SCP005_NAMES, Tool.Name) or Tool.Name:lower():find("card")) then
					Activated(Tool, Players:GetPlayerFromCharacter(Tool.Parent))
				elseif PartTouched.Parent.ClassName == "Tool" and not (table.find(SCP005_NAMES, Tool.Name) or Tool.Name:lower():find("card")) then
					PlaySound("ButtonPush")
					Hint(Players:GetPlayerFromCharacter(PartTouched.Parent.Parent), "rfid5")
				end
			end)
		elseif Object.Name == "HumDetector" then
			local Debounce = false
			local OpenValue = Object.Parent.Open

			Object.Parent.AutoClose.Value = true
			Object.Parent.AutoCloseTime.Value = 5
			
			if OpenValue.Value then
				Object.RedLED.Material = Enum.Material.Plastic
				Object.GreenLED.Material = Enum.Material.Neon
			else
				Object.RedLED.Material = Enum.Material.Neon
				Object.GreenLED.Material = Enum.Material.Plastic
			end
			
			OpenValue.Changed:Connect(function(val)
				if val then
					Object.RedLED.Material = Enum.Material.Plastic
					Object.GreenLED.Material = Enum.Material.Neon
				else
					Object.RedLED.Material = Enum.Material.Neon
					Object.GreenLED.Material = Enum.Material.Plastic
				end
			end)
			
			Object.Detector.Touched:Connect(function(a)
				if not Debounce then
					Debounce = true
					OpenValue.Value = true
					OpenValue.Changed:Wait()
					wait(1)
					Debounce = false
				end
			end)
		end
	elseif Object.ClassName == "MeshPart" then
		-- Generic Reader
		local ButtonType = ButtonTypes[Object.MeshId]

		self.SoundClass = 
			(ButtonType == "elevator" or ButtonType == "button") and "button" 
			or (ButtonType == "scanner" or ButtonType == "keypad") and "Scanner" 
			or "Key"

		local Activated
		--local Debounce = false
		if ButtonType == "button" or ButtonType == "elevator" then
			-- OnActivated:
			Activated = function(Player, Tool)
				if Locked.Value or not Power.Value then
					if Power.Value then
						if IsDoor then
							PlaySound("ButtonError")
							Hint(Player, "doorlocked")
						else
							PlaySound("ButtonError")
							Hint(Player, "buttonlocked")
						end
					else
						if IsDoor then
							PlaySound("ButtonPush")
							Hint(Player, "buttonlocked")
						else
							PlaySound("ButtonPush")
							Hint(Player, "buttonlocked")
						end
					end
				else
					PlaySound("ButtonPush")
					AccessGranted(Player)
				end
			end
		elseif ButtonType == "keycard" then
			-- OnActivated:
			Activated = function(Player, Tool)
				if Tool and (table.find(SCP005_NAMES, Tool.Name) or Tool.Name:lower():find("card")) then

					local SCP005 = Tool.Name == "SCP-005"
					if Power.Value then
						local Authorized = Locked.Value == true and (
							CheckRFID(Tool.ToolTip, LockPermissions) and 
								CheckRFID(Tool.ToolTip, Permissions)
						) or CheckRFID(Tool.ToolTip, Permissions)
						AccessSound(Authorized)
						if Locked.Value and not Authorized then
							if IsDoor then
								Hint(Player, "doorlocked")
							else
								if SCP005 then
									Hint(Player, "keycardlocked2")
								else
									Hint(Player, "keycardlocked")
								end
							end
							return
						end
						if Authorized then
							AccessGranted(Player)
							if SCP005 then
								Hint(Player, "keycard2")
							else
								Hint(Player, "keycard")
							end
						end
					elseif not Power.Value then
						if SCP005 then
							Hint(Player, "keycardlocked2")
						else
							Hint(Player, "keycardlocked")
						end
					end
				else
					Hint(Player, "keycardrequired")
				end
			end			
		elseif ButtonType == "scanner" then
			-- OnActivated:
			Activated = function(Player, Tool)
				local SCP005 = Tool and Tool.Name == "SCP-005" or false
				if Power.Value then
					local Authorized
					if Tool then
						if Tool.Name:lower():find("card") then
							Hint(Player, "dnakeycard")
							PlaySound("ButtonPush")
							return
						else
							if table.find(SCANNERHAND_NAMES, Tool.Name) 
								or table.find(SCP005_NAMES, Tool.Name) then
								Authorized = Locked.Value == true and (
									CheckRFID(Tool.ToolTip, LockPermissions) and 
										CheckRFID(Tool.ToolTip, Permissions)
								) or CheckRFID(Tool.ToolTip, Permissions)
							else
								return
							end
						end
					else
						Authorized = Locked.Value == true and (
							CheckRFID(Player.UserId, LockPermissions) and 
								CheckRFID(Player.UserId, Permissions)
						) or CheckRFID(Player.UserId, Permissions)
					end
					AccessSound(Authorized)

					if Locked.Value and not Authorized then
						if SCP005 then
							Hint(Player, "dna5")
						else
							if Tool then
								Hint(Player, "dna3")
							else
								Hint(Player, "dna0")
							end
						end
						return
					end
					if Authorized then
						AccessGranted(Player)
						if SCP005 then
							Hint(Player, "dna2")
						else
							if Tool then
								Hint(Player, "dna1")
							else
								Hint(Player, "dna4")
							end
						end
					else
						if SCP005 then
							Hint(Player, "dna5")
						else
							if Tool then
								Hint(Player, "dna3")
							else
								Hint(Player, "dna0")
							end
						end
					end
				end
			end
		elseif ButtonType == "keypad" then
			local Code = Object:FindFirstChild("Code")
			local CodeValue
			if not Code then
				Code = Retrieve("Code", "NumberValue", Object.Parent)
			end
			if Code.Value == 0 then
				Code.Value = 1234
			end
			CodeValue = Code.Value
			Code.Value = 0
			Code:Destroy()
			KeypadHandlers[Object] = function(Input)
				local Authorized = tonumber(Input) == CodeValue
				AccessSound(Authorized)

			end
		end
		Locked.Changed:Connect(function(Value)
			if Value then
				if IsDoor then
					DoorState = Object.Parent.Parent.Open.Value
					Object.Parent.Parent.Open.Value = false
					if not AutoClose then
						Object.Parent.Parent.AutoClose.Value = true
					end
				end
			else
				if IsDoor then
					Object.Parent.Parent.Open.Value = DoorState
					if not AutoClose then
						Object.Parent.Parent.AutoClose.Value = false
					end
				end
			end
		end)
		if ButtonType ~= "keypad" then
			ButtonPrompt.Triggered:Connect(function(Player)
				local Tool = Player.Character:FindFirstChildOfClass("Tool")
				Activated(Player, Tool)
			end)
		end
	end


	return self
end
