local Nucleus = require(game.ReplicatedStorage.Nucleus)
local import = Nucleus.import
local Services = Nucleus.Services
local common = Nucleus.common
local OSM = common.OSM
local Door = import("Door")
local Button = import("Button")
local PlayerHandler = import("PlayerHandler")
local Zone = require(OSM.Zone)

local function Hint(Player, Message)
	task.spawn(function()
		PlayerHandler.Handlers[Player].Hint(Message, 0.075 * string.len(Message))
	end)
end

local ElevatorModule = {}

function ElevatorModule.Teleport(A,B)
	--print("TELEPORT CALLED")
	local zone = Zone.new(A)
	zone.playerEntered:Connect(function(player)
		--print("player entered")
		local character = player.Character
		local offset = A.CFrame:toObjectSpace(character:WaitForChild("HumanoidRootPart").CFrame)
		character:WaitForChild("HumanoidRootPart").CFrame = B.CFrame  * offset
	end)
	--print("waiting")
	wait(1.855e+43)
	--print("destroyed")
	zone:Destroy()
end

local FunnyTable = {
	[1] = "Stop spamming the button.",
	[2] = "Pressing it harder does not make the elevator come faster.",
	[3] = "If you continue pressing this button I will kick you",
	[4] = "You already called the elevator."
}

function ElevatorModule.CreateGenericElevator(Floors, OptionalStartFloor) -- currently the system supports a maximum of 99 floors
	assert(typeof(Floors) == "table")
	--print("yse created")
	-- Setup
	local Table = {
		Doors = {},
		InternalButtons = {},
		CallButtons = {},
		Floors = {},
		RideLength = 9.6,
		CurrentFloor = 1,
		Broken = false,
		BrokenMessage = "The elevator appears to be broken."
	}

	for _, Floor in next, Floors do
		Table.Floors[Floor.Name] = Floor -- This is how the call system works for Generic Elevators
		table.insert(Table.Doors, Door.new(Floor.DoorElevator, "doorelevator"))
		table.insert(Table.CallButtons, Button(Floor.CallButton, false))
		--print('yesa')
		for _, InternalButton in next, Floor["Internal Buttons"]:GetChildren() do
			--print("butotn")
			table.insert(Table.InternalButtons, Button(InternalButton, false))
			--print("trol~")
		end
	end

	local function ObtainRealism(floorname) -- returns the floor number instead of the full "Floor1" etc.
		return tonumber(string.sub(floorname, 6,7))
	end

	local Debounce = false
	local AllowCall = true

	function Table.Call(From, To)
		if Debounce == false then
			Debounce = true
			local truefrom = ObtainRealism(From)
			local trueto = ObtainRealism(To)
			Table.Doors[truefrom].SetState(false)
			wait(1.25)
			for _,Floor in next, Table.Floors do
				local Sound = Instance.new("Sound")
				Sound.MaxDistance = math.huge
				Sound.RollOffMaxDistance = 38
				Sound.Volume = 0.55
				Sound.RollOffMode = Enum.RollOffMode.LinearSquare
				Sound.SoundId = "rbxassetid://5876044476"
				Sound.Parent = Floor.Elevator
				Sound:Play()			
				Sound.Ended:Connect(function() Sound:Destroy() end)
			end
			-- insert elevator animation here
			wait(Table.RideLength)
			ElevatorModule.Teleport(Table.Floors[From].Elevator, Table.Floors[To].Elevator)		
			Table.Doors[trueto].SetState(true)	
			Table.CurrentFloor = trueto
			Debounce = false
		end
	end

	if OptionalStartFloor ~= nil then
		Table.Call("Floor"..tostring(Table.CurrentFloor), "Floor"..tostring(OptionalStartFloor))
	else
		Table.Doors[Table.CurrentFloor].SetState(true)
	end	

	local Clicks = 0
	for _, CallButton in next, Table.CallButtons do
		CallButton:BindToAccessGranted(function(Player, Object)
			--print(Player, "ME!")
			if Table.Broken == false then
				if Table.CurrentFloor == ObtainRealism(Object.Parent.Name) then
					Hint(Player, "The elevator is already on this floor.")
				else
					if Debounce == true then
						Clicks = Clicks + 1
						--print(Clicks)
						if Clicks >= 3 then
							Hint(Player, FunnyTable[math.random(1,4)])
						else
							Hint(Player, "You already called the elevator.")
						end
					else
						Hint(Player, "You called the elevator.")
						Table.Call("Floor"..tostring(Table.CurrentFloor), Object.Parent.Name)
					end
				end
			else
				Hint(Player, Table.BrokenMessage)
			end
		end)
	end

	for _, InternalButton in next, Table.InternalButtons do
		InternalButton:BindToAccessGranted(function(Player, Object)
			if Table.Broken == false then
				InternalButton.ProxPrompt.Enabled = false
				Table.Call("Floor"..tostring(Table.CurrentFloor), Object.Name)
				InternalButton.ProxPrompt.Enabled = true
			else
				Hint(Player, Table.BrokenMessage)
			end
		end)

	end

	return Table
end

return ElevatorModule
