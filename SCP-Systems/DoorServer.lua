local Nucleus = require(game.ReplicatedStorage.Nucleus)
local Retrieve = Nucleus.retrieve
local Services = Nucleus.Services
local Common = Nucleus.common

local AddonFolder = script
local Remote = Services.ReplicatedStorage.DoorRemote
local DoorList = require(Services.ReplicatedStorage.DataStorage.DoorList)
local Door = {}

local function MakeSound(Part, ID, Name)
	local NewSound = Instance.new("Sound")
	NewSound.Parent = Part
	NewSound.SoundGroup = Services.SoundService.Doors
	NewSound.RollOffMode = Enum.RollOffMode.LinearSquare
	NewSound.RollOffMinDistance = 0
	NewSound.RollOffMaxDistance = 200
	NewSound.Volume = 0.5
	NewSound.PlayOnRemove = true
	NewSound.SoundId = ID
	return NewSound
end

function Door.new(DoorModel, ListIndex)
	local self = {
		OpenState = Retrieve("Open", "BoolValue", DoorModel),
		AutoClose = Retrieve("AutoClose", "BoolValue", DoorModel),
		AutoCloseTime = Retrieve("AutoCloseTime", "NumberValue", DoorModel),
		IsMoving = Retrieve("IsMoving", "BoolValue", DoorModel),
		-- Door Cache:
		DoorCache = {},
		-- Sound Cache:
		DoorClose = {},
		DoorOpen = {},
		-- CFrame Cache:
		OpenCache = {},
		CloseCache = {},
	}
	
	local Open = self.OpenState
	local Settings = DoorList[ListIndex]
	local NoPhysical = true
	local StoredValue = Open.Value
	local IsMoving = self.IsMoving
	local AllowInterruption = Settings.AllowInterruption
		
	if self.AutoCloseTime.Value == 0 then
		self.AutoCloseTime.Value = 7
	end
	
	for _, v in next, DoorModel:GetDescendants() do
		-- Sound Cache Setup:
		if v.ClassName == "Sound" then
			if v.Name == "DoorOpenSFX" then
				NoPhysical = false
				table.insert(self.DoorOpen, v)
			elseif v.Name == "DoorCloseSFX" then
				NoPhysical = false
				table.insert(self.DoorClose, v)
			elseif v.Name == "DoorSFX" then
				NoPhysical = false
				table.insert(self.DoorOpen, v)
				table.insert(self.DoorClose, v)
			end
			v.SoundGroup = Services.SoundService.Doors
		elseif v.ClassName == "Model" and (v.Name:lower():find("door") or v.Name == "Scripted") then
			-- Door Cache Setup:
			local Mover = v.PrimaryPart
			if not Mover then
				Mover = v:FindFirstChild("MainPart") or error(string.format("Could not find the Mover Part in %s", v.Name))
			end
			table.insert(self.DoorCache, {v,Mover})
		elseif v.ClassName == "MeshPart" and (v.Name:lower():find("door") or v.Name == "Scripted") then
			table.insert(self.DoorCache, {v,v})
		elseif AddonFolder:FindFirstChild(v.Name) then
			-- Addon Setup:
			require(AddonFolder[v.Name])(v, self, DoorModel)
		end
	end
	if not Settings.OpenServer then
		for _, v in next, self.DoorCache do
			local OpenValue = Retrieve("OpenTarget", "CFrameValue", v[2])
			local CloseValue = Retrieve("CloseTarget", "CFrameValue", v[2])
			OpenValue.Value = v[2].CFrame * Settings[v[1].Name.."Offset"] or Settings["DoorOffset"]
			CloseValue.Value = v[2].CFrame
		end
		if NoPhysical then
			local Obj = DoorModel:FindFirstChild("Frame") or DoorModel:FindFirstChild("Main")
			if Obj.ClassName == "Model" then
				Obj = Obj:FindFirstChildOfClass("BasePart")
			end
			for _, v in next, Settings.DoorOpen.SoundList do
				table.insert(self.DoorOpen, MakeSound(Obj, v))
			end
			for _, v in next, Settings.DoorClose.SoundList do
				table.insert(self.DoorClose, MakeSound(Obj, v))
			end
		end
	end

	function self.SetState(Value)
		if Value ~= nil then
			Open.Value = Value
		else
			Open.Value = not Open.Value
		end
	end

	function self.Open()
		if (not AllowInterruption and IsMoving.Value == false) or AllowInterruption then
			if Settings.OpenServer then
				-- Custom/Function Based:
				Settings.OpenServer(DoorModel)
				Remote:FireAllClients("Open", self, DoorModel, ListIndex)
				Open.Value = true
				IsMoving.Value = true
				StoredValue = Open.Value
				local CanChange = true
				local Connection
				Connection = IsMoving.Changed:Connect(function()
					CanChange = false
				end)
				task.wait(Settings.OpenCycleTime)
				if CanChange then
					IsMoving.Value = false
				end
				Connection:Disconnect()
			else
				-- Automated:
				self.DoorOpen[math.random(1, #self.DoorOpen)]:Play()
				Remote:FireAllClients("Open", self, DoorModel, ListIndex)
				Open.Value = true
				IsMoving.Value = true
				StoredValue = Open.Value
				local CanChange = true
				local Connection
				Connection = Open.Changed:Connect(function()
					CanChange = false
				end)
				task.wait(Settings.DoorOpen.TweenInfo.Time)
				if CanChange then
					IsMoving.Value = false
				end
				Connection:Disconnect()
			end
			if self.AutoClose.Value == true and Open.Value == true then
				task.wait(self.AutoCloseTime.Value - 2.257)
				local Alarm = Retrieve("Alarm", "Sound", DoorModel:FindFirstChild("Frame") or DoorModel:FindFirstChild("Main"))
				Alarm.SoundId = "rbxassetid://302274478"
				Alarm:Play()
				task.wait(2)
				if Open.Value == true then
					if Open.Value == true then
						self.SetState(false)
					end
				end
			end
		else
			warn("The state of the door cannot be changed at this time as it is currently cycling. Interruption denied.")
			Open.Value = StoredValue
		end
	end

	function self.Close()
		if (not AllowInterruption and IsMoving.Value == false) or AllowInterruption then
			if Settings.CloseServer then
				-- Custom/Function Based:
				Settings.CloseServer(DoorModel)
				Remote:FireAllClients("Close", self, DoorModel, ListIndex)
				Open.Value = false
				IsMoving.Value = true
				StoredValue = Open.Value
				local CanChange = true
				local Connection
				Connection = IsMoving.Changed:Connect(function()
					CanChange = false
				end)
				task.wait(Settings.OpenCycleTime)
				if CanChange then
					IsMoving.Value = false
				end
				Connection:Disconnect()
			else
				-- Automated:
				self.DoorClose[math.random(1, #self.DoorClose)]:Play()
				Remote:FireAllClients("Close", self, DoorModel, ListIndex)
				Open.Value = false
				IsMoving.Value = true
				StoredValue = Open.Value
				local CanChange = true
				local Connection
				Connection = Open.Changed:Connect(function()
					CanChange = false
				end)
				task.wait(Settings.DoorOpen.TweenInfo.Time)
				if CanChange then
					IsMoving.Value = false
				end
				Connection:Disconnect()
			end
		else
			Open.Value = StoredValue
		end
	end

	Open.Changed:Connect(function(Value)
		if Value == true then
			self.Open()
		else
			self.Close()
		end
	end)
	
	Services.Players.PlayerAdded:Connect(function(Player)
		if Open.Value == true then
			Remote:FireClient(Player, "Open", self, DoorModel, ListIndex)
		end
	end)
	
	if Open.Value == true then
		self.Open()
	end
	
	return self
end

return Door
