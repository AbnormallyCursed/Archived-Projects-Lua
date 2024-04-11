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

return function(self, CommandInfo)
	local PureArguments, Options = self:ParseCommandForOptions(CommandInfo)
	local Directory = self.CurrentDirectory
	local TargetFile
	
	if PureArguments[1] == nil then
		self:NewLabel("-bash: cat: no target specified")
		self.CurrentReturnCode = 0
		return
	end
	
	if PureArguments[1]:sub(1,1) == "/" then
		Directory = PureArguments[1]
	else
		Directory ..= "/"..PureArguments[1]
	end
	
	if Directory:sub(2,2) == "/" then
		Directory = Directory:sub(2, Directory:len())
	end
	
	print(Directory)
	pcall(function()
		TargetFile = self.FileSystem:fsRW(Directory)
	end)
	if not TargetFile or TargetFile == "directory does not exist" then
		self:NewLabel("ls: cannot access '"..Directory.."': No such file or directory")
		self.CurrentReturnCode = 0
		return
	end
	
	local Data = TargetFile.Data
	if type(Data) == "string" then
		self:NewLabel(Data)
		return
	elseif type(Data) == "table" then
		self:NewLabel(MachinecodeMetatable[Data.main])
		return
	else
		self:NewLabel("")
	end
end