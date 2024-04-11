-- Heftig_HD and AbnormallyCursed

local Module = {}
local Threads = {}
local ThreadCounter: number = 0

function Module:InitThreads()
	local Folder: Folder = Instance.new("Folder", (self.Services.RunService:IsServer() and self.Services.ServerStorage) or self.Services.ReplicatedStorage)
	Folder.Name = ""
	for i = 1, 128 do
		local Thread = self.ThreadActor:Clone()
		local Core = Thread:WaitForChild("Core")
		Thread.Name = ""
		Core.Name = ""
		Thread.Parent = Folder
		require(Core)(self)
		Threads[i] = Thread
	end
end

function Module:RunThread(Function, ...)
	ThreadCounter += 1
	if ThreadCounter > 128 then
		ThreadCounter = 1
	end
	Threads[ThreadCounter]:SendMessage("MultiThread", Function, ...)
end

return Module
