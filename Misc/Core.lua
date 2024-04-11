local Door = require(game.ServerScriptService["Laser Hall System"].Door)
local TweenService = game:GetService("TweenService")
local LaserHall = workspace["Laser Hall"]
local Stages = {}

Door:Open(LaserHall.OuterSealDoor)
Door:Open(LaserHall.InnerSealDoor)
Door:Open(LaserHall.GearDoor)

LaserHall.Trigger.Touched:Connect(function()
	if script.Parent.ACTIVE.Value == true then
		LaserHall.Trigger.CanTouch = false
		LaserHall.PlayerStopperOne.CanCollide = true
		LaserHall.PlayerStopperTwo.CanCollide = true
		Door:Close(LaserHall.OuterSealDoor)
		Door:Close(LaserHall.InnerSealDoor)
		Door:Close(LaserHall.GearDoor)
		wait(8)
		LaserHall.Trigger.On:Play()
		for _,v in next, LaserHall:GetDescendants() do
			if v:IsA("BasePart") then
				if v.Material == Enum.Material.Neon then
					v.Color = Color3.new(0.431373, 0.6, 0.792157)
				end
			end
		end

		for _,v in next, LaserHall:GetDescendants() do
			if v:IsA("PointLight") then
				v.Color = Color3.new(0.431373, 0.6, 0.792157)
			end
		end	

		local Stage1 = Stages["1"]
		local Stage2 = Stages["2"]
		local Stage3 = Stages["3"]
		local Stage4 = Stages["4"]
		local Stage5 = Stages["5"]
		wait(4)
		Stage1()
		wait(6)
		Stage2()
		wait(6)
		Stage3()
		wait(6)
		Stage4()
		wait(6)
		Stage5()
	end
end)

local function LaserTouched(Toucher)
	if Toucher.Parent:FindFirstChild("Humanoid") ~= nil then
		local Character = Toucher.Parent
		wait(0.0001)
		Toucher:Destroy()
		Character.Humanoid.Health = 0
	end
end

local function ActivateLasers(Stage)
	local CompleteStage = "Stage"..tostring(Stage)
	for _,v in next, LaserHall.Lasers:FindFirstChild(CompleteStage):GetChildren() do
		v.Transparency = 0
		v.CanTouch = true
		v.Touched:Connect(function(ALPHA)
			LaserTouched(ALPHA)
		end)
	end
	LaserHall.Lasers.Panel.Activator:Play()
	wait(0.2)
	LaserHall.Lasers.Panel.Active:Play()
end

local function DeactivateLasers(Stage)
	local CompleteStage = "Stage"..tostring(Stage)
	for _,v in next, LaserHall.Lasers:FindFirstChild(CompleteStage):GetChildren() do
		v.Transparency = 1
		v.CanTouch = false
		v.Touched:Connect(function(ALPHA)
			LaserTouched(ALPHA)
		end)
	end
	LaserHall.Lasers.Panel.Activator:Play()
	LaserHall.Lasers.Panel.Active:Stop()
end

Stages["1"] = function()
	local Origin = LaserHall.Lasers.Stage1.Laser.CFrame
	ActivateLasers(1)
	local Tween = TweenService:Create(LaserHall.Lasers.Stage1.Laser, TweenInfo.new(
		1.5
		,Enum.EasingStyle.Linear
		,Enum.EasingDirection.In),
		{CFrame = LaserHall.Lasers.Stage1.Laser.CFrame * CFrame.new(0,0,-29.6)}
	)
	Tween:Play()
	Tween.Completed:Connect(function()
		wait(2)
		DeactivateLasers(1)
		LaserHall.Lasers.Stage1.Laser.CFrame = Origin
	end)
end

Stages["2"] = function()
	local Origin = LaserHall.Lasers.Stage2.Laser.CFrame
	ActivateLasers(2)
	local Tween = TweenService:Create(LaserHall.Lasers.Stage2.Laser, TweenInfo.new(
		1.5
		,Enum.EasingStyle.Linear
		,Enum.EasingDirection.In),
		{CFrame = LaserHall.Lasers.Stage2.Laser.CFrame * CFrame.new(0,0,-29.6)}
	)
	Tween:Play()
	Tween.Completed:Connect(function()
		wait(2)
		DeactivateLasers(2)
		LaserHall.Lasers.Stage2.Laser.CFrame = Origin
	end)
end

Stages["3"] = function()
	local Origin = LaserHall.Lasers.Stage3.Laser.CFrame
	ActivateLasers(3)
	local Tween = TweenService:Create(LaserHall.Lasers.Stage3.Laser, TweenInfo.new(
		1.5
		,Enum.EasingStyle.Linear
		,Enum.EasingDirection.In),
		{CFrame = LaserHall.Lasers.Stage3.Laser.CFrame * CFrame.new(0,3,-29.6)}
	)
	Tween:Play()
	Tween.Completed:Connect(function()
		wait(2)
		DeactivateLasers(3)
		LaserHall.Lasers.Stage3.Laser.CFrame = Origin
	end)
end

Stages["4"] = function()
	local Origin = LaserHall.Lasers.Stage4.Laser.CFrame
	ActivateLasers(4)
	local Tween = TweenService:Create(LaserHall.Lasers.Stage4.Laser, TweenInfo.new(
		1.5
		,Enum.EasingStyle.Linear
		,Enum.EasingDirection.In),
		{CFrame = LaserHall.Lasers.Stage4.Laser.CFrame * CFrame.new(0,-5,-29.6)}
	)
	Tween:Play()
	Tween.Completed:Connect(function()
		wait(2)
		DeactivateLasers(4)
		LaserHall.Lasers.Stage4.Laser.CFrame = Origin
	end)
end

Stages["5"] = function() -- now that's just unfair >:(
	LaserHall.Lasers.Panel.Active.Volume = 0.1
	local Origin = LaserHall.Lasers.Stage5.Laser.CFrame
	ActivateLasers(5)
	local Tween = TweenService:Create(LaserHall.Lasers.Stage5.Laser, TweenInfo.new(
		2
		,Enum.EasingStyle.Linear
		,Enum.EasingDirection.In),
		{CFrame = LaserHall.Lasers.Stage5.Laser.CFrame * CFrame.new(0,0,-29.6)}
	)
	Tween:Play()
	Tween.Completed:Connect(function()
		wait(2)
		DeactivateLasers(5)
		LaserHall.Lasers.Stage5.Laser.CFrame = Origin
		wait(6)
		Door:Open(LaserHall.OuterSealDoor)
		Door:Open(LaserHall.InnerSealDoor)
		Door:Open(LaserHall.GearDoor)
		LaserHall.Lasers.Panel.Active.Volume = 0.04
		
		LaserHall.Trigger.CanTouch = true
		LaserHall.PlayerStopperOne.CanCollide = false
		LaserHall.PlayerStopperTwo.CanCollide = false

		LaserHall.Trigger.Off:Play()
		for _,v in next, LaserHall:GetDescendants() do
			if v:IsA("BasePart") then
				if v.Material == Enum.Material.Neon then
					v.Color = Color3.new(1, 1, 1)
				end
			end
		end

		for _,v in next, LaserHall:GetDescendants() do
			if v:IsA("PointLight") then
				v.Color = Color3.new(1, 1, 1)
			end
		end	
		
	end)
end