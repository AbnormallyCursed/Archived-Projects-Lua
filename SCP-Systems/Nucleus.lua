--!nocheck

local ServiceCache = {DataStoreService = game:GetService("DataStoreService")}
local IsServer = game["Run Service"]:IsServer()
local ModuleScriptCache = {}

for _,v in ipairs(game:GetChildren()) do
	pcall(function()
		ServiceCache[string.gsub(v.Name, "%s+", "")] = v
	end)
end

local Paths = {
	script,
	ServiceCache.ReplicatedStorage:WaitForChild("common",1),
	ServiceCache.ReplicatedStorage:WaitForChild("GameModules",0.5),
	ServiceCache["RunService"]:IsServer() and ServiceCache.ServerScriptService.import or nil
}
for _, ImportPath in next, Paths do
	for _,Script in next, ImportPath:GetDescendants() do
		if Script.ClassName == "ModuleScript" and Script.Name ~= "Nucleus" then
			local FindScript = ModuleScriptCache[Script.Name]
			if FindScript then
				warn("Import: Duplicate ModuleScript '"..Script.Name.."' skipped")
			else
				ModuleScriptCache[Script.Name] = Script
				if not IsServer then
					Script.Name = ""
					Script.Parent = nil
				end
			end
		end
	end
end

local Nucleus = {Services = ServiceCache, common = ServiceCache.ReplicatedStorage:WaitForChild("common",1)}

function Nucleus.import(locator: string)
	local QuickImport = ModuleScriptCache[locator]
	if QuickImport then
		if typeof(QuickImport) == "Instance" then
			ModuleScriptCache[locator] = require(QuickImport)
			return ModuleScriptCache[locator]
		else
			return QuickImport
		end
	else
		warn(string.format("Import failed with input '%s'", locator))
	end
end

function Nucleus.retrieve(name:string, ClassName: string, Parent: Instance)
	local Retrieve = Parent:FindFirstChild(name)
	if Retrieve == nil then
		local NewRetrieve = Instance.new(ClassName)
		NewRetrieve.Parent = Parent
		NewRetrieve.Name = name
		Retrieve = NewRetrieve
	end
	return Retrieve
end

return Nucleus
