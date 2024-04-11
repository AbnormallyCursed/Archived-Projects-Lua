local Tween = game:GetService("TweenService")
local Remote = game:GetService("ReplicatedStorage").DoorRemote
local DoorList = require(game.ReplicatedStorage.DataStorage.DoorList)
local DoorCache = {}

Remote.OnClientEvent:Connect(function(State, self, DoorModel, ListIndex)
	local Cache = DoorCache[DoorModel]
	local Settings = DoorList[ListIndex]
	
	if Settings.OpenClient then
		-- Custom/Function Open & Close
		Settings[State.."Client"](DoorModel, self.DoorCache)
	else
		-- Automatic
		if not Cache then
			DoorCache[DoorModel] = {
				OpenTweenCache = {},
				CloseTweenCache = {},
			}
			Cache = DoorCache[DoorModel]
			for _,v in next, self.DoorCache do
				Cache.OpenTweenCache[v[1]] = Tween:Create(
					v[2],
					Settings.DoorOpen.TweenInfo,
					{CFrame = v[2].OpenTarget.Value}
				)
				Cache.CloseTweenCache[v[1]] = Tween:Create(
					v[2],
					Settings.DoorClose.TweenInfo,
					{CFrame = v[2].CloseTarget.Value}
				)
			end
		end
		for _,v in next, self.DoorCache do
			Cache[State.."TweenCache"][v[1]]:Play()
		end
	end
end)
