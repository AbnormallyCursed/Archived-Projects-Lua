return function() -- CPU Creator Function
	local self = {}
	self.Debug = true
	self.ThreadActor = script.Resources.Actor
	self.Services = setmetatable({}, {
		__index = function(Self, Index): Instance
			local Service: Instance = game:GetService(Index)
			Self[Index] = Service
			return Service
		end	
	})

	for _,Script in next, script.Network:GetDescendants() do
		if Script.ClassName == "ModuleScript" then
			for i,v in next, require(Script) do
				self[i] = v
			end
		end
	end
	
	self:StartISA()
	self:CreateCore()
	
	return self
end
