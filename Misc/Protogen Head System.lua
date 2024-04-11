local AuthorizedUsers = {512746977}
local TS = game:GetService("TweenService")
local IDs = {
	[1] = "rbxassetid://4875663686",
	[2] = "rbxassetid://5529402614",
	[3] = "rbxassetid://4971709309",
	[4] = "rbxassetid://5077040698",
	[5] = "rbxassetid://5529572711",
	[6] = "rbxassetid://5818540068",
	[7] = "rbxassetid://5858419987",
	[8] = "rbxassetid://5677888439",
	[9] = "rbxassetid://5374937750",
	[10] = "rbxassetid://5268440657",
	[11] = "rbxassetid://5818559399",
	[12] = "rbxassetid://5268451514",
	[13] = "rbxassetid://5818453337",
	[14] = "rbxassetid://4993889289",
	[15] = "rbxassetid://5677662660",
	[16] = "http://www.roblox.com/asset/?id=7479912403"
}
local ProtogenHeads = {}
local function init(plr: Player)
	if table.find(AuthorizedUsers, plr.UserId) then
		local NewClone = script.ScreenGui:Clone()
		NewClone.Parent = plr.PlayerGui
		NewClone.LocalScript.Disabled = false
	end
end

game.Players.PlayerAdded:Connect(init)
for _,v in game.Players:GetPlayers() do
	init(v)
end

game.Players.PlayerAdded:Connect(function(plr)
	if table.find(AuthorizedUsers, plr.UserId) then
		plr.CharacterAppearanceLoaded:Connect(function()
			local child = plr.Character:GetChildren()
			for i, v in pairs(child) do
				if v:IsA("Accessory") and (v.Name:lower():gsub("%s*", ""):find("cybercritter") or v.Name:lower():find("digi")) then
					v:Destroy()
				end
			end
			local ProtogenHead = script.ProtogenHead:Clone()
			local Weld = Instance.new("Weld")
			ProtogenHead.Middle.CFrame = plr.Character.Head.CFrame
			ProtogenHead.Parent = plr.Character
			Weld.Part1 = plr.Character.Head
			Weld.Part0 = ProtogenHead.Middle
			Weld.Parent = ProtogenHead.Middle
			ProtogenHead.Middle.Anchored = false
			ProtogenHeads[plr] = {ProtogenHead, Protocols = {}}
		end)
	end
end)

local ProtogenEvent = Instance.new("RemoteEvent")
ProtogenEvent.Parent = game.ReplicatedStorage
ProtogenEvent.Name = "ProtogenEvent"

ProtogenEvent.OnServerEvent:Connect(function(plr: Player, protocol: string, color: Color3)
	if table.find(AuthorizedUsers, plr.UserId) then
		local Target = ProtogenHeads[plr]
		if Target[1] == nil then
			return
		end
		
		if protocol == "Confirm" then
			local dontcontinue = false
			if Target.Rainbow then
				Target.Rainbow = false
				dontcontinue = true
			end
			
			if table.find(Target.Protocols, "Rainbow") and dontcontinue == false then
				Target.Rainbow = true
				wait(0.5) 
				spawn(function()
					while Target.Rainbow == true do 
						wait(0.5) 
						game:GetService('TweenService'):Create(
							Target[1].Lights,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
						{Color = Color3.fromRGB(255, 0, 0)}):Play() 
						wait(0.5)
						game:GetService('TweenService'):Create(
							Target[1].Lights,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
						{Color = Color3.fromRGB(255, 155, 0)}):Play() 
						wait(0.5)
						game:GetService('TweenService'):Create(
							Target[1].Lights,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
						{Color = Color3.fromRGB(255, 255, 0)}):Play() 
						wait(0.5)
						game:GetService('TweenService'):Create(
							Target[1].Lights,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
						{Color = Color3.fromRGB(0, 255, 0)}):Play() 
						wait(0.5)
						game:GetService('TweenService'):Create(
							Target[1].Lights,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
						{Color = Color3.fromRGB(0, 255, 255)}):Play() 
						wait(0.5)
						game:GetService('TweenService'):Create(
							Target[1].Lights,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
						{Color = Color3.fromRGB(0, 155, 255)}):Play() 
						wait(0.5)
						game:GetService('TweenService'):Create(
							Target[1].Lights,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
						{Color = Color3.fromRGB(255, 0, 255)}):Play() 
						wait(0.5)
						game:GetService('TweenService'):Create(
							Target[1].Lights,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
						{Color = Color3.fromRGB(255, 0, 155)}):Play() 
						wait(0.5)
					end
				end)
			else
				TS:Create(Target[1].Lights, TweenInfo.new(0.2), {Color = color}):Play()
			end
			
			for _,v in Target.Protocols do
				if tonumber(v) then
					TS:Create(Target[1].Lights, TweenInfo.new(0.1), {Color = Color3.new(0,0,0)}):Play()
					Target[1].Screen.TextureID = IDs[tonumber(v)]
					wait(0.1)
					TS:Create(Target[1].Lights, TweenInfo.new(0.1), {Color = color}):Play()
				end
			end
			
			table.clear(Target.Protocols)
		else
			table.insert(Target.Protocols, protocol)
		end
	else
		plr:Kick("unauthorized usage")
	end
end)