local HttpService = game:GetService("HttpService")
local Module = {}

local function SanitizeJSON(json)
	json = string.gsub(json,'“','"')
	json = string.gsub(json,'”','"')
	return json
end

function Module:GetTables()
	warn("Decoding x86 Tables")
	local Tables = {
		SingleByte = HttpService:JSONDecode(SanitizeJSON(require(script.SingleByte))),
		MultiByte = HttpService:JSONDecode(SanitizeJSON(require(script.MultiByte))),
	}
	warn("x86 Tables Successfully Decoded")
	return Tables
end

return Module
