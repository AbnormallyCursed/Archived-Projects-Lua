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
	self:ClearAllLabels()
end