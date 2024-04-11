local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Module = {}

Module["OuterSealDoor"] = function(Door, Status)
	if Status == "Open" then
		if not CollectionService:HasTag(Door.CFrame, "CFrameSet") then
			Door.CFrame.Open.Value = Door.Main.CFrame * CFrame.new(0,0,-14)
			Door.CFrame.Close.Value = Door.Main.CFrame
			CollectionService:AddTag(Door.CFrame, "CFrameSet")
		end
		local tweenInfo = TweenInfo.new(
			6,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)
		local tween = TweenService:Create(Door.Main, tweenInfo, {CFrame = Door.CFrame.Open.Value})
		Door.Main.Sound:Play()
		tween:Play()
	elseif Status == "Close" then
		local tweenInfo = TweenInfo.new(
			6,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)
		local tween = TweenService:Create(Door.Main, tweenInfo, {CFrame = Door.CFrame.Close.Value})
		Door.Main.Sound:Play()
		tween:Play()
	end
end

Module["InnerSealDoor"] = function(Door, Status)
	if Status == "Open" then
		if not CollectionService:HasTag(Door.CFrame, "CFrameSet") then
			Door.CFrame.Open.Value = Door.Main.CFrame * CFrame.new(0,8.88,0)
			Door.CFrame.Close.Value = Door.Main.CFrame
			CollectionService:AddTag(Door.CFrame, "CFrameSet")
		end
		local tweenInfo = TweenInfo.new(
			1.7,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.InOut,
			0,
			false,
			0
		)
		local tween = TweenService:Create(Door.Main, tweenInfo, {CFrame = Door.CFrame.Open.Value})
		Door.Main.Open:Play()
		tween:Play()
	elseif Status == "Close" then
		local tweenInfo = TweenInfo.new(
			1.2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)
		local tween = TweenService:Create(Door.Main, tweenInfo, {CFrame = Door.CFrame.Close.Value})
		Door.Main.Close:Play()
		tween:Play()
	end
end

Module["GearDoor"] = function(Door, Status)
	if Status == "Open" then
		if not CollectionService:HasTag(Door.CFrame, "CFrameSet") then
			Door.CFrame.Open.Value = Door.Main.CFrame * CFrame.Angles(0,math.rad(-100),0)
			Door.CFrame.Close.Value = Door.Main.CFrame
			CollectionService:AddTag(Door.CFrame, "CFrameSet")
		end
		local tweenInfo = TweenInfo.new(
			1.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)
		local tween = TweenService:Create(Door.Main, tweenInfo, {CFrame = Door.CFrame.Open.Value})
		Door.Main.Open:Play()
		tween:Play()
	elseif Status == "Close" then
		local tweenInfo = TweenInfo.new(
			1.2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)
		local tween = TweenService:Create(Door.Main, tweenInfo, {CFrame = Door.CFrame.Close.Value})
		Door.Main.Close:Play()
		tween:Play()
	end
end

function Module:Open(Door)
	local DoorFunction = Module[Door.Name]
	DoorFunction(Door, "Open")
end

function Module:Close(Door)
	local DoorFunction = Module[Door.Name]
	DoorFunction(Door, "Close")
end

return Module