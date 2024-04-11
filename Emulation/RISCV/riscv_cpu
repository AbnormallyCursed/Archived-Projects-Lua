--RISC-V emulator written in pure Lua, by AbnormallyCursed

-- Settings for the CPU:
local Settings = {
	
}

return function() -- CPU Creator Function
	local self = {}
	self.Settings = table.freeze(Settings)
	self.Debug = true
	self.ThreadActor = script.MultiThread.Actor
	self.Services = setmetatable({}, {
		__index = function(Self, Index): Instance
			local Service: Instance = game:GetService(Index)
			Self[Index] = Service
			return Service
		end	
	})
	
	for _,Script in next, script:GetDescendants() do
		if Script.ClassName == "ModuleScript" and Script.Name ~= "Core" then
			for i,v in next, require(Script) do
				self[i] = v
			end
		end
	end
	
	self:InitThreads()
	self:StartInstructionProcessor()
	self:NewR5CPU()
	
	return self
end
