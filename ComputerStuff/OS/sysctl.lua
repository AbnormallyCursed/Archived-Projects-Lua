local function RandomHexadecimal()
	local RealHex = string.format("%X", Random.new():NextInteger(0, 2^64-1))
	
	if RealHex:len() == 16 then
		return RealHex
	else
		return RandomHexadecimal()
	end
end

return function(self, CommandInfo)
	local PureArguments, Options = self:ParseCommandForOptions(CommandInfo)
	
	if PureArguments[1] == "debug.kdb.panic=1" then
		local Trace = string.gsub(debug.traceback("Call Trace:"), "ReplicatedStorage.Default.OperatingSystem.", ""):split("\n")
		
		for _,v in Trace do
			self:NewLabel(v.." : "..RandomHexadecimal())
		end
		
		local err1 = PureArguments[2] or "n/a"
		local err2 = PureArguments[3] or "unknown cause! exitcode=0x00"
		
		self:NewLabel("status: "..RandomHexadecimal().." "..err1)
		self:NewLabel("---[ end trace "..RandomHexadecimal().." ]---")
		self:NewLabel("Kernel panic - not syncing: "..err2)
		self:NewLabel("--[ end Kernel panic - not syncing "..err2.." ]---")
		self.CurrentReturnCode = -1
		self:KillInput()
		coroutine.yield()
	end
	
end