return function(self, CommandInfo)
	local TargetLocation = CommandInfo[2]
	local Test
	
	if TargetLocation == ".." then
		if self.CurrentDirectory == "/" then
			self:NewLabel("-bash: cd: cannot go to a level higher than root")
		else
			local Target = string.gsub(self.CurrentDirectory, "/%w*$", "")
			
			if Target == "" then
				Target = "/"
			end
			
			self.CurrentDirectory = Target
		end
		
		return
	end
	
	if not TargetLocation then
		self:NewLabel("-bash: cd: no target specified")
		self.CurrentReturnCode = 0
		return
	end
	
	if TargetLocation:sub(1,1) ~= "/" then
		local Start = self.CurrentDirectory
		if Start:sub(#Start, #Start) ~= "/" then
			Start = Start.."/"
		end
		
		if self.CurrentDirectory == "/" then
			TargetLocation = self.CurrentDirectory..CommandInfo[2]
		else
			TargetLocation = self.CurrentDirectory.."/"..CommandInfo[2]
		end
	end
		
	pcall(function()
		Test = self.FileSystem:fsRW(TargetLocation)
	end)
	
	if Test == nil then
		self:NewLabel("-bash: cd: "..TargetLocation.." No such file or directory")
		self.CurrentReturnCode = 0
		return
	end
	if type(Test) == "string" then
		self:NewLabel("-bash: cd: "..TargetLocation.." "..Test)
		self.CurrentReturnCode = 0
		return
	else
		self.CurrentDirectory = TargetLocation
	end
	
	self.CurrentReturnCode = 0
end