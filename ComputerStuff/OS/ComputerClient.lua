local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

local VelocityThreshold = 10 -- At what absolute velocity the player will stop interacting with the terminal (helpful for things like being shoved)

local SpecialKeys = {
	"LeftControl",
	"RightControl",
	"LeftShift",
	"RightShift",
	"Backspace",
	"Return"
}
local ConvTable = {
	["1"] = "!",
	["2"] = "@",
	["3"] = "#",
	["4"] = "$",
	["5"] = "%",
	["6"] = "^",
	["7"] = "&",
	["8"] = "*",
	["9"] = "(",
	["0"] = ")",
	["`"] = "~",
	["-"] = "_",
	["="] = "+",
	["["] = "{",
	["]"] = "}",
	[";"] = ":",
	["'"] = '"',
	[","] = "<",
	["."] = ">",
	["/"] = "?",
	[ [[\]] ] = "|"
}

for _, Display in next, {
	[1] = workspace:WaitForChild("screen")
	} do
	--local UI = cTable.UI
	local Settings = Display:FindFirstChild("Settings")
	assert(Settings ~= nil, "assertion fail: no settings found")
	if Settings.ClassName == "ModuleScript" then
		Settings = require(Settings)
	elseif Settings.ClassName == "ObjectValue" then
		Settings = require(Settings.Value)
	end

	local CameraState = false
	local PowerState = Display.PowerState
	local User = Display.User
	local CurrentTween
	local FocusConnection
	local FilthyGUI = Player.PlayerGui:WaitForChild("SurfaceGui")

	--------------------------------
	-- CAMERA AND STATE FUNCTIONS --
	--------------------------------

	local function CameraIn()
		if Settings.PreventWalking == true then
			Player.Character.Humanoid.WalkSpeed = 0
			Player.Character.Humanoid.JumpPower = 0
		end
		Camera.CameraType = Enum.CameraType.Scriptable
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		CameraState = true
		local tweenInfo = TweenInfo.new(
			0.8, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)

		local tween = TweenService:Create(Camera, tweenInfo, {
			CFrame = Display.Camera.WorldCFrame
		})
		CurrentTween = tween
		tween:Play()
		Player.PlayerGui.SurfaceGui.TextBox:CaptureFocus()
		tween.Completed:Connect(function()
			CurrentTween:Destroy()
			-- Ensures the character does not get in the way of the display
			FocusConnection = Player.PlayerGui.SurfaceGui.TextBox.FocusLost:Connect(function()
				Player.PlayerGui.SurfaceGui.TextBox:CaptureFocus()
			end)
			for _, v in next, Player.Character:GetDescendants() do
				if v:IsA("BasePart") or v:IsA("MeshPart") then
					v.Transparency = 1
				end
			end
			Player.PlayerGui.SurfaceGui.TextBox:CaptureFocus()
		end)
	end

	local function CameraOut()
		if Settings.PreventWalking == true and Player.Character:FindFirstChild("Humanoid").Health > 0 then
			-- WARNING! This can cause issues when the player is intended to be slower, please come back to this at another time!
			Player.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed 
			Player.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterJumpPower
		end

		if Player.Character ~= nil then
			-- For the sake of being able to see your character again
			for _, v in next, Player.Character:GetDescendants() do
				if (v:IsA("BasePart") or v:IsA("MeshPart")) and v.Name ~= "HumanoidRootPart" then
					v.Transparency = 0
				end
			end
		end

		if User.Value == Player then
			if (Player.Character.HumanoidRootPart.Position - Display.Position).Magnitude < Settings.DistanceToActivate then
				warn("this cuh so intelligent")
			else
				warn("Server Exit Failure!") -- Nothing we can do
			end
		end
		FocusConnection:Disconnect()
		Player.PlayerGui.SurfaceGui.TextBox:ReleaseFocus()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		Camera.CameraType = Enum.CameraType.Custom
		CameraState = false
		if CurrentTween ~= nil then
			CurrentTween:Cancel()
			CurrentTween:Destroy()
		end
	end

	---------------------------------------------------------------------
	-- CAMERA HANDLER / INTERACTION HANDLER & CHARACTER STATE HANDLERS --
	---------------------------------------------------------------------

	PowerState.Changed:Connect(function(Value)
		if Value == false then
			CameraOut()
		end
	end)

	-- Interacting with the computer / toggling active/inactive state
	Mouse.Button2Down:Connect(function()
		if PowerState.Value == true then
			pcall(function()
				if Player.Character:FindFirstChild("Humanoid").Health > 0 -- Making sure the player is not dead
					and Player.Character:FindFirstChildOfClass("Tool") == nil -- Ensuring that the clicking was not accidental
					and (Player.Character.HumanoidRootPart.Position - Display.Position).Magnitude < Settings.DistanceToActivate -- Distance
				then
					if CameraState == false then -- Checking if the player is (already interacting with the computer or not)
						if Mouse.Target == Display then
							if User.Value == nil then -- Set User on Server
								CameraIn()
								warn("this cuh so dumb")
							end
						end
					else
						if Mouse.Target ~= Display then
							CameraOut()
						end
					end
				end
			end)
		end
	end)

	-- Purpose of this function is to further ensure that abnormalities cannot occur during sessions
	local function BindToCharacter(Char) 
		repeat
			wait()
		until Char ~= nil
		local Humanoid = Char:WaitForChild("Humanoid")
		local IsDead = false

		-- Velocity Checker
		spawn(function()
			while IsDead == false do
				wait(0.28)
				if Char.HumanoidRootPart.Velocity.Magnitude > 5 and CameraState == true then
					CameraOut()
				end
			end
		end)

		-- Health & Dead State Checker
		local Connection
		Connection = Humanoid.HealthChanged:Connect(function()
			CameraOut()
			if Humanoid.Health <= 0 then
				Connection:Disconnect()
				IsDead = true
			end
		end)
	end

	-- Absolutely Ensures the character is checked
	spawn(function()
		Player.CharacterAdded:Connect(BindToCharacter)
		BindToCharacter(Player.Character)
	end)


	------------------------------
	-- COMPUTER CLIENT HANDLING --
	------------------------------

	PowerState.Value = true -- Testing
end
