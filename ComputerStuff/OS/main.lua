local UserInputService = game:GetService("UserInputService")
local Module = {}

function Module:StartMain()
	self.ReturnEnabled = true
	self.CurrentReturnCode = 0
	
	local function MakeExecutable(Directory, ModuleScript)
		local Executable = require(ModuleScript)
		assert(typeof(Executable) == "function", "bin executable module must return function value")
		self.FileSystem:MakeFile(Directory, ModuleScript.Name, "ELF", { main = Executable })
	end
	
	local function GetInstanceDirectory(File: Instance)
		local FileFullName = File:GetFullName()
		local FileName = tostring(File)
		FileFullName = string.sub(FileFullName, 49, FileFullName:len())
		FileFullName = string.gsub(FileFullName, "%.", "/")
		FileFullName = string.sub(FileFullName, 1, (FileFullName:len()-FileName:len()))
		
		if FileFullName:sub(FileFullName:len(), FileFullName:len()) == "/" then
			FileFullName = string.sub(FileFullName, 1, FileFullName:len()-1)
		end
		
		
		return FileFullName
	end
	
	local function Tree(Dir: Folder)
		for _,File in Dir:GetChildren() do
			if File.ClassName == "ModuleScript" then
				MakeExecutable(GetInstanceDirectory(File), File)
			elseif File.ClassName == "Folder" then
				self.FileSystem:MakeFile(GetInstanceDirectory(File), tostring(File), "Directory")
				Tree(File)
			end
		end
	end
	
	Tree(self.Ignore)
	
	function self:ParseCommandForOptions(CommandInfo)
		local PureArguments = {}
		local Options = {}
		
		for _,v in CommandInfo do
			if v:sub(1,1) == "-" then
				Options[v] = true
			else
				PureArguments[#PureArguments+1] = v
 			end
		end
		
		table.remove(PureArguments, 1)
		return PureArguments, Options
	end
	function self:ExecuteCommand(CommandString: string)
		local SplitCommandString = CommandString:split(" ")
		local Target
		
		if SplitCommandString[1]:sub(1,2) == "./" then
			Target = self.CurrentDirectory.."/"..SplitCommandString[1]:sub(3, SplitCommandString[1]:len())
			local TargetFile
			
			if Target:sub(1,2) == "//" then
				Target = Target:sub(2, Target:len())
			end
						
			pcall(function()
				TargetFile = self.FileSystem:fsRW(Target)
			end)
			if not TargetFile then
				self:NewLabel("-bash: "..SplitCommandString[1]..": not found")
				self.CurrentReturnCode = 0
				return
			end
		else
			Target = "/bin/"..SplitCommandString[1]
		end
		
		local Status = "file Execution Failure"
		Status = self.FileSystem:ExecuteFile(Target, self, SplitCommandString)
		if Status ~= "file Executed" then
			if Status == "file does not exist" then
				Status = "command not found"
			end
			if not Status then
				Status = "unknown error occured"
			end
			self:NewLabel("-bash: "..SplitCommandString[1]..": "..Status)
			self.CurrentReturnCode = 0
			return
		end
	end
	
	UserInputService.InputBegan:Connect(function(InputObject, gameProcessedEvent)
		InputObject = InputObject.KeyCode
		if InputObject.Name == "Return" and self.ReturnEnabled then
			self.ReturnEnabled = false
			self:ExecuteCommand(self.UserInputCapturer.Text)
			if self.CurrentReturnCode == 0 then
				self:KillInput()
				self:NewInputPrompt()
				self.ReturnEnabled = true
			end
		end
	end)
	
	--[[self.FileSystem:fsAssignProperty("/bin/echo", "rwx", {
		other = {true, true, true},
		user = {true, false, false},
	})]]
end

return Module
