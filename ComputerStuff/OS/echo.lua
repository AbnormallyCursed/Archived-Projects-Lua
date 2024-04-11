return function(self, CommandInfo)
	local Part = true
	local Message = ""
	local Target = ""
	
	for i = 2, #CommandInfo do
		local Element = CommandInfo[i]
		if Element == ">" then
			Part = false
			continue
		end
		if Part then
			Message ..= Element.." "
		else
			Target ..= Element.." "
		end
	end
	
	Message = string.sub(Message, 1, Message:len()-1)
	Target = string.sub(Target, 1, Target:len()-1)
	
	if Target == "" then
		self:NewLabel(Message)
	else
		pcall(function()
			local file = self.FileSystem:fsRW(Target)
			if file then
				if file.Type == "Directory" then
					self:NewLabel("-bash: "..Target..": Is a directory")
				else
					if file.IsExecutable then
						file.Data.main(Message:split(" "))
					end
				end
			else
				local List = Target:split("/")
				local s = pcall(function()
					self.FileSystem:MakeFile(Target, List[#List], "File", Message)
					print(Message)
				end)
				if not s then
					self:NewLabel("-bash: "..Target..": No such file or directory")
				end
			end
		end)
	end
	
	self.CurrentReturnCode = 0
end