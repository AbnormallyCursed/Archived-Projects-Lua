--[[
	Writer: AbnormallyCursed
	Date: 9/5/2021
	
	Description:
	The Clientside aspect of the Game's Terminal system.
--]]

----------------------------------------------------------------------------------------------------------------------------------------|
-- V A R I A B L E S -------------------------------------------------------------------------------------------------------------------|
----------------------------------------------------------------------------------------------------------------------------------------|
-- #Default Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

-- #Nucleus (Standalone Class)
local Nucleus = require(ReplicatedStorage.Nucleus)

-- #API Overrides
local require = Nucleus._require

-- #Instances
local Player = Players.LocalPlayer
local tResources = ReplicatedStorage["Terminal Resources"]
local Mouse = Player:GetMouse()
local Character = Player.Character
local InvokeCommand = Nucleus:GetRemoteFunction("InvokeCommand")

-- #Tables

local MessageColors = {
	["Error"] = Color3.new(1, 0.32549, 0.32549);
	["Warning"] = Color3.new(1, 0.811765, 0.12549);
	["Default"] = Color3.new(0.843137, 0.662745, 0.294118)
}

----------------------------------------------------------------------------------------------------------------------------------------|
-- M A I N   S C R I P T ---------------------------------------------------------------------------------------------------------------|
----------------------------------------------------------------------------------------------------------------------------------------|
for _,Terminal in next, CollectionService:GetTagged("Terminal") do
	assert(Terminal:IsDescendantOf(workspace), "Assertion failure, terminal is not descendant of workspace.")
	
	local Display = Terminal:WaitForChild("Display")
	local CommandPrompt = tResources.CommandPrompt:Clone()
	local CommandLine = CommandPrompt.CommandLine
	local CurrentCamera = workspace.CurrentCamera
	local Status = false
	
	CommandPrompt.Parent = Display
	
	local function AddLine(Type, Text)
		assert(Type ~= "string", "Please change the type of ARG#1 to a string, current type: "..typeof(Text))
		assert(Text ~= "string", "Please change the type of ARG#2 to a string, current type: "..typeof(Text))
		
		local Retrieve = tResources:FindFirstChild(Type):Clone()
		
		if Type == "System Text" then
			Retrieve.Text.Text = Text
		end
		
		Retrieve.Parent = CommandLine
		return Retrieve
	end
	
	local function CameraIn()
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		
		local tweenInfo = TweenInfo.new(
			0.8, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)

		local tween = TweenService:Create(CurrentCamera, tweenInfo, {CFrame = Display.Camera.WorldCFrame})
		tween:Play()
		
		tween.Completed:Connect(function()
			CommandPrompt.Parent = Player.PlayerGui
			CommandPrompt.Adornee = Display
			CommandLine:FindFirstChild("Command")["User Text"]:CaptureFocus()
			for _,x in next, Player.Character:GetDescendants() do
				if x:IsA("BasePart") then
					x.LocalTransparencyModifier = 1
				end
			end
		end)
		
		
	end
	
	local function CameraOut()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		for _,x in next, Player.Character:GetDescendants() do
			if x:IsA("BasePart") then
				x.LocalTransparencyModifier = 0
			end
		end
		CommandPrompt.Parent = Display
		CurrentCamera.CameraType = Enum.CameraType.Custom
	end
	
	local function SetupCommand(Command)
		local String = string.format("C:/Users/%s>", Player.Name)
		local Formula = string.len(String) * 7
		Command.Text.Text = String
		Command["User Text"].Position = UDim2.new(0, Formula)
	end
	
	local function NewCommand()
		local OldCommand = CommandLine:FindFirstChild("Command")
		OldCommand.Name = "executed_cmd"
		OldCommand.Text.Text = OldCommand.Text.Text..OldCommand["User Text"].Text
		OldCommand["User Text"]:Destroy()
		AddLine("Blankspace")
		SetupCommand(AddLine("Command"))
		if Status == true then
			CommandLine:FindFirstChild("Command")["User Text"]:CaptureFocus()
		end
	end
	
	local function ExecuteCommand(Command)
		assert(typeof(Command) == "string", "Could not execute command, because it isn't a string!")
		local InvokeCommand = InvokeCommand:InvokeServer(Command, CommandPrompt)
		
		if InvokeCommand ~= nil and InvokeCommand.Message ~= nil then
			local SystemText = AddLine("System Text", InvokeCommand.Message)
			SystemText.Text.TextColor3 = MessageColors[InvokeCommand.Type]
		end
		
	end
	
	AddLine("System Text", "(c) 2022 ATLAS INC. | Unified Extensive Operating System - All Rights Reserved")
	AddLine("Blankspace")
	SetupCommand(AddLine("Command"))
	
	Mouse.Button2Down:Connect(function()
		if Mouse.Target == Display and (Display.Position - Player.Character.HumanoidRootPart.Position).Magnitude < 5 
			and Player.Character:FindFirstChildWhichIsA("Tool") == nil then
			Status = not Status
			if Status == true then
				CameraIn()
			else
				CameraOut()
			end
		end
	end)
	
	Mouse.Button1Up:Connect(function()
		if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable and Mouse.Target ~= Display then
			CameraOut()
		end
	end)
	
	Mouse.Button2Up:Connect(function()
		if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable and Mouse.Target ~= Display then
			CameraOut()
		end
	end)
	
	Player.CharacterAdded:Connect(function(Char)
		Char:WaitForChild("Humanoid").Died:Connect(CameraOut)
	end)
	
	UserInputService.InputBegan:connect(function(inputObject)
		if inputObject.KeyCode == Enum.KeyCode.Return and Status == true then
			ExecuteCommand(CommandLine:FindFirstChild("Command")["User Text"].Text)
			NewCommand()
		end 
	end)
	
end