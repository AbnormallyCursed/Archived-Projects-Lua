local function unpack(args)
	if args then
		return table.unpack(args)
	else
		return nil
	end
end

local Module = {}

function Module:StartFileSystem()
	local KernelClass = {
		ext4 = {
			RWXGroups = {}, 
			["/"] = {
				rwx = {
					other = {true, true, true},
					user = {true, true, true},
				},
				Name = "/",
				Location = "/",
				Type = "Directory",
				Data = nil,
				IsExecutable = false,
			}
		},
		rwxuser = "user",
	}
	local ext4 = KernelClass.ext4

	-- FS Functions:
	function KernelClass:fsRW(Path, Value)
		if Path == "/" then
			return ext4["/"]
		end
		local Path = Path:split("/")
		local Focus = ext4["/"]
		table.remove(Path,1)

		for i,v in ipairs(Path) do
			local Permissions = Focus.rwx[KernelClass.rwxuser]
			if i ~= #Path then
				if not Permissions[3] then
					return "execute access denied"
				end
				if Focus[v] == nil then
					return "directory does not exist", v
				end
				if Focus[v].Type ~= "Directory" then
					return "invalid file type to iterate over"
				end
				Focus = Focus[v]
			else
				if not Permissions[1] then
					return "read access denied"
				end
				if Value then
					if Permissions[2] then
						Focus[v] = Value
					else
						return "write access denied"
					end
				else
					return Focus[v]
				end
			end
		end
	end
	function KernelClass:fsAssignProperty(Path, Property, Value)
		local GetFile = KernelClass:fsRW(Path)
		GetFile[Property] = Value
		return "assigned Property"
	end
	function KernelClass:MakeFile(Location, Filename, Type, Data)
		if Filename == "rwx" or Filename == "Name" or Filename == "Location" or Filename == "Type" or Filename == "Data" or Filename == "IsExecutable" then
			warn("Invalid Filename", Filename)
			return "invalid filename", Filename
		end
		local FileClass = {
			rwx = {
				other = {false, false, false},
				user = {true, true, true},
				unpack(ext4.RWXGroups)
			},
			Name = Filename,
			Location = Location,
			Type = Type,
			Data = Data,
			IsExecutable = Type ~= "Directory" and Type ~= "File"
		}
		local TrueLocation = Location
		if Location == "/" then
			TrueLocation = ""
		end
		local ReturnValue = KernelClass:fsRW(TrueLocation.."/"..Filename, FileClass)
		if type(ReturnValue) ~= "string" then
			return "wrote File", FileClass
		else
			return ReturnValue
		end
	end
	function KernelClass:ExecuteFile(Location, ...)
		print(Location)
		local GetFile = KernelClass:fsRW(Location)
		if GetFile == nil then
			return "file does not exist"
		end
		local Data = GetFile.Data
		
		if GetFile.IsExecutable then
			if GetFile.rwx[KernelClass.rwxuser][3] then
				Data.main(...)
				return "file Executed"
			else
				return "execute Access Denied"
			end
		else
			return "file is not executable"
		end
	end
	function KernelClass:SetallPermissions(Location, value)
		KernelClass:fsAssignProperty(Location, "rwx", {
			other = {value, value, value},
			user = {value, value, value},
		})
	end
	
	--[[KernelClass:MakeFile("/", "bin", "Directory")
	KernelClass:MakeFile("/", "etc", "Directory")
	KernelClass:MakeFile("/", "sbin", "Directory")
	KernelClass:MakeFile("/", "usr", "Directory")
	KernelClass:MakeFile("/", "home", "Directory")
	KernelClass:MakeFile("/", "boot", "Directory")
	KernelClass:MakeFile("/", "dev", "Directory")
	KernelClass:MakeFile("/", "lost+found", "Directory")
	KernelClass:MakeFile("/", "lib", "Directory")
	KernelClass:MakeFile("/", "mnt", "Directory")
	KernelClass:MakeFile("/", "opt", "Directory")
	KernelClass:MakeFile("/", "proc", "Directory")
	KernelClass:MakeFile("/", "run", "Directory")
	KernelClass:MakeFile("/", "root", "Directory")
	KernelClass:MakeFile("/", "srv", "Directory")
	KernelClass:MakeFile("/", "sys", "Directory")
	KernelClass:MakeFile("/", "tmp", "Directory")
	KernelClass:MakeFile("/", "var", "Directory")
	--KernelClass:SetallPermissions("/bin", false)
	KernelClass:SetallPermissions("/etc", false)
	KernelClass:SetallPermissions("/sbin", false)
	--KernelClass:SetallPermissions("/usr", false)
	--KernelClass:SetallPermissions("/home", false)
	KernelClass:SetallPermissions("/boot", false)
	KernelClass:SetallPermissions("/dev", false)
	KernelClass:SetallPermissions("/lost+found", false)
	KernelClass:SetallPermissions("/lib", false)
	KernelClass:SetallPermissions("/mnt", false)
	KernelClass:SetallPermissions("/opt", false)
	KernelClass:SetallPermissions("/proc", false)
	KernelClass:SetallPermissions("/run", false)
	--KernelClass:SetallPermissions("/root", false)
	KernelClass:SetallPermissions("/srv", false)
	KernelClass:SetallPermissions("/sys", false)
	KernelClass:SetallPermissions("/tmp", false)
	KernelClass:SetallPermissions("/var", false)]]
	
	self["FileSystem"] = KernelClass
	return self
end

return Module