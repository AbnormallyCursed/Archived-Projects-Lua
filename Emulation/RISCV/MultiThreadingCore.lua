-- Heftig_HD

local self
local Actor: Actor = script:GetActor()
script = nil
local function RunThread(Function, ...)
	Function(self, ...)
end
Actor:BindToMessageParallel("MultiThread", RunThread)
return function(Table)
	self = Table
end
