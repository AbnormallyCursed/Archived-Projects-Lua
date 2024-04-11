-- This system is my first anticheat, and it sucks compared to modern ones.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local wait = task.wait
local OP = OverlapParams.new()
local Module = {
	LoopSpeed = 0.3, -- Higher Tickspeeds = better detection but more stressful on performance
	JumpMOEcomp = 5.5, -- Adds this number to the maximum amount of height the player can jump, helps with margin of error
	ModuleStates = {
		Noclip = true, -- noclip detection, margin of error is 3% overall, respects cancollide
		WalkSpeed = true, -- walkspeed modification
		Fly = true, -- for cheap fly scripts
		Jump = true, -- Jump Modification also detects inf jump, & some advanced CFlys
	},
	PlayerStates = {},
}
OP.RespectCanCollide = true

Players.PlayerAdded:Connect(function(Player)

	local function Detected(Message)
		Player:Kick(Message or "Detected")
		coroutine.yield()
	end

	Module.PlayerStates[Player.UserId] = {}
	local PlayerState = Module.PlayerStates[Player.UserId] -- Whitelist States
	local ModuleStates = Module.ModuleStates
	local NoclipPart = Instance.new("Part")
	local QueryJump = true
	local LastYPos
	PlayerState["Noclip"] = false
	PlayerState["WalkSpeed"] = false
	PlayerState["Fly"] = false
	PlayerState["Jump"] = false
	NoclipPart.Parent = workspace
	NoclipPart.Size = Vector3.new(0.2,0.2,0.2)
	NoclipPart.Anchored = true
	NoclipPart.Position = Vector3.new(0,0,0)
	NoclipPart.CanCollide = false
	NoclipPart.Transparency = 1
	
	local StartHum = Player.CharacterAdded:Wait():WaitForChild("Humanoid")
	if StartHum.FloorMaterial.Name == "Air" then
		repeat wait() until StartHum.FloorMaterial.Name ~= "Air"
	end
	
	while wait() do
		local suc, err = pcall(function()
			local Character = Player.Character or Player.CharacterAdded:Wait()
			local Humanoid = Character.Humanoid
			local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 1)
			if Character:FindFirstChild("HumanoidRootPart") == nil then
				return
			end
			local BodyType = Character:FindFirstChild("Torso") and "R6" or "R15"
			local HumState = Humanoid:GetState()
			
			if ModuleStates.Noclip and not PlayerState.Noclip then
				NoclipPart.CFrame = HumanoidRootPart.CFrame
				local GetPartsInPart = workspace:GetPartsInPart(NoclipPart, OP)
				for _, v in ipairs(GetPartsInPart) do
					if not v:IsDescendantOf(Character) then
						if not(HumState.Name == "FallingDown" or HumState.Name == "GettingUp") then
							-- NRC Door System Integration
							local Ancestor = v:FindFirstAncestorOfClass("Model")
							local Open = Ancestor and (Ancestor:FindFirstChild("Open") or Ancestor.Parent:FindFirstChild("Open"))
							if Open and Open.Value == true or Open.Parent:FindFirstChild("IsMoving").Value == true then
								return
							end
							--
							Detected("Noclip")
						end
					end
				end
			end
			if ModuleStates.Fly and not PlayerState.Fly then
				if HumState == Enum.HumanoidStateType.Flying then
					Detected("Flying Humstate")
				end
				if (HumState == Enum.HumanoidStateType.PlatformStanding
					or HumState == Enum.HumanoidStateType.Running) and (HumanoidRootPart.Orientation.X >= 3 or HumanoidRootPart.Orientation.X < -3) 
					and Humanoid.FloorMaterial.Name == "Air" then
					Detected("Cheap Fly Script")
				end
			end
			if ModuleStates.Jump and not PlayerState.Jump then
				if HumState == Enum.HumanoidStateType.Freefall and Humanoid.Jump and Humanoid.FloorMaterial.Name == "Air" then
					if HumanoidRootPart.Position.Y > LastYPos and (HumanoidRootPart.Position.Y - LastYPos) > (Humanoid.JumpPower^2 / (2*workspace.Gravity))+Module.JumpMOEcomp then
						Detected("Jump Modification")
					end
				end
				LastYPos = HumanoidRootPart.Position.Y
			end
			if ModuleStates.WalkSpeed and not PlayerState.WalkSpeed then
				local Left,Right
				local TouchingPartsArray = {}
				if BodyType == "R15" then
					Left = Character.LeftFoot
					Right = Character.RightFoot
				else
					Left = Character["Left Leg"]
					Right = Character["Right Leg"]
				end
				for _,v in next, Left:GetTouchingParts() do
					if not v:IsDescendantOf(Character) then
						table.insert(TouchingPartsArray, v)
					end
				end
				for _,v in next, Right:GetTouchingParts() do
					if not v:IsDescendantOf(Character) then
						table.insert(TouchingPartsArray, v)
					end
				end
				for _,v in next, TouchingPartsArray do
					-- Allow an exception for "Conveyer" parts
					if v.AssemblyLinearVelocity.Magnitude == 0 or v.AssemblyAngularVelocity.Magnitude == 0 then
						if Humanoid.FloorMaterial.Name ~= "Air" and HumState == Enum.HumanoidStateType.Running and Vector3.new(HumanoidRootPart.Velocity.X,0,HumanoidRootPart.Velocity.Z).Magnitude > Humanoid.WalkSpeed+1 then
							Detected("Client Walkspeed Change")
						end
					end
				end
			end
		end)
		if not suc then
			if RunService:IsStudio() then
				warn(err)
			end
			Detected()
		end
		wait(Module.LoopSpeed)
	end

end)

function _G.Config(Name, Value)
	Module[Name] = Value
end
function _G:SetModuleState(Name, Value)
	if Name == "all" then
		for i,_ in next, Module.ModuleStates do
			Module.ModuleStates[i] = Value
		end
	else
		Module.ModuleStates[Name] = Value
	end
end
function _G:SetWhitelisted(Identifier, ModuleName, Value)
	local ModuleLists = {}
	if Identifier == "all" then
		for _,v in next, Module.PlayerStates do
			table.insert(ModuleLists, v)
		end
	else
		local userid
		if typeof(Identifier) == "number" then
			userid = Identifier
		elseif (typeof(Identifier) == "Instance" or typeof(Identifier) == "table") then
			userid = Identifier.UserId
		elseif typeof(Identifier) == "string" then
			local qid = tonumber(Identifier)
			if qid then
				userid = qid
			else
				userid = game.Players[Identifier].UserId
			end
		end
		table.insert(ModuleLists, Module.PlayerStates[userid])
	end
	for ind,v in next, ModuleLists do
		if ModuleName == "all" then
			for i,_ in next, v do
				Module.PlayerStates[ind][i] = Value
			end
		else
			Module.PlayerStates[ind][ModuleName] = Value
		end
	end
end

return Module
