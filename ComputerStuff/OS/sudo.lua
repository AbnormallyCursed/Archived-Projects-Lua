local MachinecodeMetatable = setmetatable({}, {
	__index = function(self, Index)
		local out = ""
		for i = 1, math.random(696,4096) do
			out ..= string.char(math.random(0,255))
		end
		self[Index] = out
		return out
	end,
})
local UserInputService = game:GetService("UserInputService")

return function(self, CommandInfo)
	table.remove(CommandInfo, 1)
	local CommandFormation = ""
	local CommandName = CommandInfo[1]
	local TargetFile
	
	pcall(function()
		TargetFile = self.FileSystem:fsRW("/bin/"..CommandName)
	end)
	
	print("/bin/"..CommandName)
	print(TargetFile)
	print(TargetFile.rwx)
	
	if TargetFile and TargetFile.rwx[self.FileSystem.rwxuser][3] == false then
		local SavedHeading = self.CurrentHeading
		self.CurrentHeading = "[sudo] password for "..self.FileSystem.rwxuser..": "
		self:NewLabel(self.CurrentHeading)
		self.CurrentInputPrompt = self.ActiveLabels[#self.ActiveLabels]
		self:KillInput()
		self:BeginUserInput()
		self.CLI_OUT.CanvasPosition += Vector2.new(0,9999)
		self.InputCursorOffset += 8
		self.ReturnEnabled = false
		self.CurrentReturnCode = 1
		
		local function ExitRoutine()
			self.ReturnEnabled = true
			self.CurrentHeading = SavedHeading
			self:KillInput()
			self:NewInputPrompt()
			self.ReturnEnabled = true
		end
		
		local function SudoInputHandler()
			local InputObject, gameProcessedEvent = UserInputService.InputBegan:Wait()
			InputObject = InputObject.KeyCode
			if InputObject.Name == "Return" then
				local SudoersFile
				
				pcall(function()
					SudoersFile = self.FileSystem:fsRW("/etc/sudoers").Data.main()
				end)
				
				if not SudoersFile then
					self.FileSystem:ExecuteFile("/sbin/sysctl", {"debug.kdb.panic=1", "COMMAND_EXEC_FATAL", "COULD NOT FIND SUDOERS FILE!"})
				end
				
				local Code = SudoersFile[self.FileSystem.rwxuser]
				
				if Code == "" then
					ExitRoutine()
				end
				
				if SudoersFile[self.FileSystem.rwxuser] == self.UserInputCapturer.Text then
					ExitRoutine()
				end
			else
				SudoInputHandler()
			end
		end
		
		SudoInputHandler()
	end
	
	for i,v in CommandInfo do
		local End
		
		if CommandInfo[i+1] == nil then
			End = ""
		else
			End = " "
		end
		
		CommandFormation ..= v..End
	end
end