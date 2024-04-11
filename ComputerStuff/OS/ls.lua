local CREATE = table.create
local CONCAT = table.concat
local Colors = {
	["Directory"] = "5555ff",
	["ELF"] = "55ff55",
}

local function ls_format_string(name: string, modifier)
	local StringList = CREATE(33-modifier, " ")
	if name:len() > 33-modifier then
		name = string.sub(name, 1, 30-modifier).."..."
	end
	local NameSplit = name:split("")
	for i = 1, #NameSplit do
		StringList[i] = NameSplit[i]
	end
	return CONCAT(StringList)
end

return function(self, CommandInfo)
	local PureArguments, Options = self:ParseCommandForOptions(CommandInfo)
	local Directory = PureArguments[1] or self.CurrentDirectory
	local Pointer = 1
	local CharCount = 0
	local ParseCharCount = 0
	local Formation = ""
	local LS_OUTPUT = {}
	local CurrentFS
	
	pcall(function()
		CurrentFS = self.FileSystem:fsRW(Directory)
	end)
	if not CurrentFS then
		self:NewLabel("ls: cannot access '"..Directory.."': No such file or directory")
		self.CurrentReturnCode = 0
		return
	end
	
	for Filename,_ in CurrentFS do
		if Filename == "rwx" or Filename == "Name" or Filename == "Location" or Filename == "Type" or Filename == "Data" or Filename == "IsExecutable" then
			continue
		end
		CharCount = Filename.."  "
		CharCount = #CharCount
	end
	for Filename, Data in CurrentFS do
		if Filename == "rwx" or Filename == "Name" or Filename == "Location" or Filename == "Type" or Filename == "Data" or Filename == "IsExecutable" then
			continue
		end
		if Filename:sub(1,1) == "." and not (Options["-a"] or Options["-A"] or Options["-all"]) then
			continue
		end
		local FormattedFilename
		if CharCount >= 4488 then
			FormattedFilename = ls_format_string(Filename)
		else
			FormattedFilename = Filename.."  "
		end
		if Options["--color=never"] then
			Formation ..= FormattedFilename
		else
			local Color = Colors[Data.Type] or "aaaaaa"
			Formation ..= '<font color="#'..Color..'">'..FormattedFilename..'</font>'
		end
		if Options["-1"] then
			LS_OUTPUT[#LS_OUTPUT+1] = Formation
			return
		end
		if CharCount >= 4488 then
			if Pointer == 4 then
				Pointer = 1
				LS_OUTPUT[#LS_OUTPUT+1] = Formation
				Formation = ""
			end
			Pointer += 1
		else
			if ParseCharCount >= 132 then
				LS_OUTPUT[#LS_OUTPUT+1] = Formation
			end
			ParseCharCount += #FormattedFilename
		end
	end
	if LS_OUTPUT[#LS_OUTPUT] ~= Formation then
		LS_OUTPUT[#LS_OUTPUT+1] = Formation
	end
	
	for _,v in ipairs(LS_OUTPUT) do
		self:NewLabel(v)
	end
	self.CurrentReturnCode = 0
end