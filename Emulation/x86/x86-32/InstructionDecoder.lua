local Module = {
	PrefixTable = {},
	D = false, -- Segment Default D, false = 16, true = 32
}

-- I want to remind you that I put all this in manually
local PrefixLookupTable = {
	[0xF0] = "LOCK",
	[0xF1] = "BND", 
	--
	--— BND prefix is encoded using F2H if the following conditions are true:
	--• CPUID.(EAX=07H, ECX=0):EBX.MPX[bit 14] is set.
	--• BNDCFGU.EN and/or IA32_BNDCFGS.EN is set.
	--• When the F2 prefix precedes a near CALL, a near RET, a near JMP, a short Jcc, or a near Jcc instruction
	--(see Appendix E, “Intel® Memory Protection Extensions,” of the Intel® 64 and IA-32 Architectures
	--Software Developer’s Manual, Volume 1).
	--
	[0xF2] = "REPNE/REPN",
	[0xF3] = "REPE/REPZ",
	-- Segment Override Prefixes: 
	-- segment override (use with any branch instruction is reserved).
	[0x2E] = "CS",
	[0x36] = "SS",
	[0x3E] = "DS",
	[0x26] = "ES",
	[0x64] = "FS",
	[0x65] = "GS",
	-- Branch Hints:
	-- 0x2E, used in CS
	-- 0x3E, used in DS
	[0x66] = "OSOP", -- Operand-size override prefix is encoded using 66H (66H is also used as a mandatory prefix for some instructions).
	[0x67] = "ASOP", -- Address-size override prefix.
	
	-- REX Prefixes:
	[0x40] = "REX",
	[0x41] = "REX.B",
	[0x42] = "REX.X",
	[0x43] = "REX.XB",
	[0x44] = "REX.R",
	[0x45] = "REX.RB",
	[0x46] = "REX.RX",
	[0x47] = "REX.RXB",
	[0x48] = "REX.W",
	[0x49] = "REX.WB",
	[0x4A] = "REX.WX",
	[0x4B] = "REX.WXB",
	[0x4C] = "REX.WR",
	[0x4D] = "REX.WRB",
	[0x4E] = "REX.WRX",
	[0x4F] = "REX.WRXB",
	
	-- Unknown:
	[0x9B] = "?",
}

local rmLookupTable = {}
for i = 0, 255 do
	rmLookupTable[i] = {
		
	}
end

function Module:GetSizeOSA() -- Gets the Size as returned by the Operand Size Attribute
	return 
		((self.D == true or self.PrefixTable[0x66] == true)
		and 
		(self.D == true and self.PrefixTable[0x66] == true) == false) 
	and 32 or 16
end
function Module:GetSizeASA() -- Gets the Size as returned by the Operand Size Attribute
	return 
		((self.D == true or self.PrefixTable[0x67] == true)
			and 
			(self.D == true and self.PrefixTable[0x67] == true) == false) 
		and 32 or 16
end

function Module:Decode_x86_32()
	local FirstByte
	
	for i = 1, 4 do
		local Byte = self:loadnext8()
		print(Byte)
		if PrefixLookupTable[Byte] then
			self.PrefixTable[Byte] = true
		else
			FirstByte = Byte
			break
		end
	end
	
	print(self.MemoryMap)
	print("Hi!", FirstByte)
	
	if FirstByte == 0x0F then -- Multi-Byte Opcodes:
		
	else -- Single-Byte Opcodes:
		local Callback = self.SingleByteInstructions[FirstByte]
		if Callback then
			Callback(self)
		else
			-- illegal instruction exception
			warn("illegal instruction")
		end
	end
	
end

return Module
