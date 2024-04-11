local Module = {}



--Types of Immediates:
--Numerical Immediate
--Address Immediate

--Types of Registers:
--Normal Register
--Control Register
--Using Normal Register as Address Register/Offset Register

--When using Address Register / Offset Register the concept is, if you want to use the contents of the register as an address
--and have NO offset, you need to simply make the value of the offset operand "0"

--"I", -- Numerical Immediate
--"A", -- Address Immediate
--"R", -- Normal Register
--"S", -- Using Register as Offset Register / Address Register
--"O", -- Using as Immediate Offset (Primarily used in instructions where there is a label)

--"I/O", -- Immediate to offset, I don't see this being used lol
--"R/I", -- Register to Immediate :/
--"O/I", -- Offset to Immediate, cuh...
--"A/I", -- Address to Immediate
--"S/I", -- Register Offset to Immediate
--"I/I", -- Ah and the grand one, Immediate to Immediate


local BinUtils = require(script.Parent["Binary Utilities"])

local function ReverseTable(t)
	local NewTable = {}
	for i,v in next, t do
		NewTable[v] = i
	end
	return NewTable
end

local ControlBytes = {
	[0x01] = "A:8/I:8",
	[0x02] = "A:8/A:8",
	[0x03] = "A:8/R:8",
	[0x04] = "A:8/S:8",
	[0x05] = "A:16/I:8",
	[0x06] = "A:16/I:16",
	[0x07] = "A:16/A:8",
	[0x08] = "A:16/A:16",
	[0x09] = "A:16/R:8",
	[0x0A] = "A:16/R:16",
	[0x0B] = "A:16/S:8",
	[0x0C] = "A:16/S:16",
	[0x0D] = "A:32/I:8",
	[0x0E] = "A:32/I:16",
	[0x0F] = "A:32/I:32",
	[0x10] = "A:32/A:8",
	[0x11] = "A:32/A:16",
	[0x12] = "A:32/A:32",
	[0x13] = "A:32/R:8",
	[0x14] = "A:32/R:16",
	[0x15] = "A:32/R:32",
	[0x16] = "A:32/S:8",
	[0x17] = "A:32/S:16",
	[0x18] = "A:32/S:32",
	[0x19] = "A:64/I:8",
	[0x1A] = "A:64/I:16",
	[0x1B] = "A:64/I:32",
	[0x1C] = "A:64/I:64",
	[0x1D] = "A:64/A:8",
	[0x1E] = "A:64/A:16",
	[0x1F] = "A:64/A:32",
	[0x20] = "A:64/A:64",
	[0x21] = "A:64/R:8",
	[0x22] = "A:64/R:16",
	[0x23] = "A:64/R:32",
	[0x24] = "A:64/R:64",
	[0x25] = "A:64/S:8",
	[0x26] = "A:64/S:16",
	[0x27] = "A:64/S:32",
	[0x28] = "A:64/S:64",
	[0x29] = "A:128/I:8",
	[0x2A] = "A:128/I:16",
	[0x2B] = "A:128/I:32",
	[0x2C] = "A:128/I:64",
	[0x2D] = "A:128/I:128",
	[0x2E] = "A:128/A:8",
	[0x2F] = "A:128/A:16",
	[0x30] = "A:128/A:32",
	[0x31] = "A:128/A:64",
	[0x32] = "A:128/A:128",
	[0x33] = "A:128/R:8",
	[0x34] = "A:128/R:16",
	[0x35] = "A:128/R:32",
	[0x36] = "A:128/R:64",
	[0x37] = "A:128/R:128",
	[0x38] = "A:128/S:8",
	[0x39] = "A:128/S:16",
	[0x3A] = "A:128/S:32",
	[0x3B] = "A:128/S:64",
	[0x3C] = "A:128/S:128",
	[0x3D] = "R:8/I:8",
	[0x3E] = "R:8/A:8",
	[0x3F] = "R:8/R:8",
	[0x40] = "R:8/S:8",
	[0x41] = "R:16/I:8",
	[0x42] = "R:16/I:16",
	[0x43] = "R:16/A:8",
	[0x44] = "R:16/A:16",
	[0x45] = "R:16/R:8",
	[0x46] = "R:16/R:16",
	[0x47] = "R:16/S:8",
	[0x48] = "R:16/S:16",
	[0x49] = "R:32/I:8",
	[0x4A] = "R:32/I:16",
	[0x4B] = "R:32/I:32",
	[0x4C] = "R:32/A:8",
	[0x4D] = "R:32/A:16",
	[0x4E] = "R:32/A:32",
	[0x4F] = "R:32/R:8",
	[0x50] = "R:32/R:16",
	[0x51] = "R:32/R:32",
	[0x52] = "R:32/S:8",
	[0x53] = "R:32/S:16",
	[0x54] = "R:32/S:32",
	[0x55] = "R:64/I:8",
	[0x56] = "R:64/I:16",
	[0x57] = "R:64/I:32",
	[0x58] = "R:64/I:64",
	[0x59] = "R:64/A:8",
	[0x5A] = "R:64/A:16",
	[0x5B] = "R:64/A:32",
	[0x5C] = "R:64/A:64",
	[0x5D] = "R:64/R:8",
	[0x5E] = "R:64/R:16",
	[0x5F] = "R:64/R:32",
	[0x60] = "R:64/R:64",
	[0x61] = "R:64/S:8",
	[0x62] = "R:64/S:16",
	[0x63] = "R:64/S:32",
	[0x64] = "R:64/S:64",
	[0x65] = "R:128/I:8",
	[0x66] = "R:128/I:16",
	[0x67] = "R:128/I:32",
	[0x68] = "R:128/I:64",
	[0x69] = "R:128/I:128",
	[0x6A] = "R:128/A:8",
	[0x6B] = "R:128/A:16",
	[0x6C] = "R:128/A:32",
	[0x6D] = "R:128/A:64",
	[0x6E] = "R:128/A:128",
	[0x6F] = "R:128/R:8",
	[0x70] = "R:128/R:16",
	[0x71] = "R:128/R:32",
	[0x72] = "R:128/R:64",
	[0x73] = "R:128/R:128",
	[0x74] = "R:128/S:8",
	[0x75] = "R:128/S:16",
	[0x76] = "R:128/S:32",
	[0x77] = "R:128/S:64",
	[0x78] = "R:128/S:128",
	[0x79] = "S:8/I:8",
	[0x7A] = "S:8/A:8",
	[0x7B] = "S:8/R:8",
	[0x7C] = "S:8/S:8",
	[0x7D] = "S:16/I:8",
	[0x7E] = "S:16/I:16",
	[0x7F] = "S:16/A:8",
	[0x80] = "S:16/A:16",
	[0x81] = "S:16/R:8",
	[0x82] = "S:16/R:16",
	[0x83] = "S:16/S:8",
	[0x84] = "S:16/S:16",
	[0x85] = "S:32/I:8",
	[0x86] = "S:32/I:16",
	[0x87] = "S:32/I:32",
	[0x88] = "S:32/A:8",
	[0x89] = "S:32/A:16",
	[0x8A] = "S:32/A:32",
	[0x8B] = "S:32/R:8",
	[0x8C] = "S:32/R:16",
	[0x8D] = "S:32/R:32",
	[0x8E] = "S:32/S:8",
	[0x8F] = "S:32/S:16",
	[0x90] = "S:32/S:32",
	[0x91] = "S:64/I:8",
	[0x92] = "S:64/I:16",
	[0x93] = "S:64/I:32",
	[0x94] = "S:64/I:64",
	[0x95] = "S:64/A:8",
	[0x96] = "S:64/A:16",
	[0x97] = "S:64/A:32",
	[0x98] = "S:64/A:64",
	[0x99] = "S:64/R:8",
	[0x9A] = "S:64/R:16",
	[0x9B] = "S:64/R:32",
	[0x9C] = "S:64/R:64",
	[0x9D] = "S:64/S:8",
	[0x9E] = "S:64/S:16",
	[0x9F] = "S:64/S:32",
	[0xA0] = "S:64/S:64",
	[0xA1] = "S:128/I:8",
	[0xA2] = "S:128/I:16",
	[0xA3] = "S:128/I:32",
	[0xA4] = "S:128/I:64",
	[0xA5] = "S:128/I:128",
	[0xA6] = "S:128/A:8",
	[0xA7] = "S:128/A:16",
	[0xA8] = "S:128/A:32",
	[0xA9] = "S:128/A:64",
	[0xAA] = "S:128/A:128",
	[0xAB] = "S:128/R:8",
	[0xAC] = "S:128/R:16",
	[0xAD] = "S:128/R:32",
	[0xAE] = "S:128/R:64",
	[0xAF] = "S:128/R:128",
	[0xB0] = "S:128/S:8",
	[0xB1] = "S:128/S:16",
	[0xB2] = "S:128/S:32",
	[0xB3] = "S:128/S:64",
	[0xB4] = "S:128/S:128",
	[0xB5] = "O:8",
	[0xB6] = "O:16",
	[0xB7] = "O:32",
	[0xB8] = "O:64",
	[0xB9] = "A:64",
	[0xBA] = "A:64",
	[0xBB] = "A:64",
	[0xBC] = "A:64",
	[0xBD] = "I:64",
	[0xBE] = "I:64",
	[0xBF] = "I:64",
	[0xC0] = "I:64",
	[0xC1] = "R:64",
	[0xC2] = "R:64",
	[0xC3] = "R:64",
	[0xC4] = "R:64",
	[0xC5] = "S:64",
	[0xC6] = "S:64",
	[0xC7] = "S:64",
	[0xC8] = "S:64",
}

local DecodedControlBytes = {}
local floor = math.floor
local ceil = math.ceil
local clamp = math.clamp
local tunpack = table.unpack

local UnsignedTypeDefinitions = {
	[8] = {0, 255},
	[16] = {0, 65535},
	[32] = {0,  4294967295},
	[64] = {0, 18446744073709552000},
}
local SignedTypeDefinitions = {
	[8] = {-127, 127},
	[16] = {-32767, 32767},
	[32] = {-2147483647, 2147483647},
	[64] = {-9223372036854776000, 9223372036854776000},
}
local FloatTypeDefinitions = {
	[32] = {-1.175494e-38, 3.402823e+38}, -- Single-precision floating-point format
	[64] = {-2.225074e-308, 1.797693e+308}, -- Double-precision floating-point format
	[128] = {-3.362103e-4932, 1.189731e+4932} -- Quadruple-precision floating-point format
}
local TypesU = {
	[8] = "B",
	[16] = "H",
	[32] = "I",
	[64] = "L"
}
local TypesS = {
	[8] = "b",
	[16] = "h",
	[32] = "i",
	[64] = "l"
}

local function GetMinimumBitSize(n: number)
	return math.floor(math.log(n, 2)) + 1
end

-- Non-Float type casting functions:
local function UnsignedTypeCast(Bitcount: number, n: number)
	return floor(clamp(n, tunpack(UnsignedTypeDefinitions[Bitcount])))
end
local function SignedTypeCast(Bitcount: number, n: number)
	return ceil(clamp(n, tunpack(SignedTypeDefinitions[Bitcount])))
end
local function SpecialTypeCast(Bitcount: number, n: number)
	return floor(clamp(n, SignedTypeDefinitions[Bitcount][1], UnsignedTypeDefinitions[Bitcount][2]))
end
-- Floating-Point type casting functions:
local function FloatTypeCast(Bitcount: number, n: number)
	return clamp(n, tunpack(FloatTypeDefinitions[Bitcount]))
end
local function PrepForBitwise(Bitcount: number, n: number)
	local IsSigned = n < 0 -- Cheap way of doing it
	
	if IsSigned then
		n = SignedTypeCast(Bitcount, n)
	else
		n = UnsignedTypeCast(Bitcount, n)
	end
	
	return BinUtils:EncodeToBinary(IsSigned and TypesS[Bitcount] or TypesU[Bitcount], n), IsSigned
end

for i,v in ControlBytes do
	local Split1 = v:split("/")
	local Op1 = Split1[1]:split(":")
	local Op2
	
	if Split1[2] then
		Op2 = Split1[2]:split(":")
	end
	
	DecodedControlBytes[i] = {Op1 or Op2, Op1 and Op2}
end

function Module:StartISA()
	-- It's Destination to source
	local InstructionCounter = 0
	local AssemblerTree = {}
	local InstructionIndex = {}

	local function NewInstruction(Mnemonic: string, Callback, NoOperands)
		InstructionCounter+=1
		AssemblerTree[Mnemonic] = InstructionCounter
		
		if NoOperands then
			InstructionIndex[InstructionCounter] = Callback
			return
		end
		local iso = InstructionCounter
		InstructionIndex[InstructionCounter] = function()
			warn(iso)
			self.PC += 1
			local Decoded = DecodedControlBytes[self:load(self.PC)]
			local Operands = {}
			
			for i = 1, #Decoded do
				local Target = Decoded[i]
				local Type = Target[1]
				local Bitcount = tonumber(Target[2])
				self.PC += 1
				local TargetOperand = self:load(self.PC)
				
				if Type == "I" then -- Treated as Signed
					-- Note: SpecialTypeCast FLOORs, floating point support needs to be modified here
					Operands[#Operands+1] = SpecialTypeCast(Bitcount, TargetOperand)
				elseif Type == "A" then
					Operands[#Operands+1] = UnsignedTypeCast(Bitcount, self:load(TargetOperand))
				elseif Type == "R" then
					-- Note: SpecialTypeCasting on accesses of floating point registers should be noted
					Operands[#Operands+1] = SpecialTypeCast(Bitcount, self.REGISTERS[TargetOperand])
				elseif Type == "S" then -- The Immediate value used as offset is treated as signed
					Operands[#Operands+1] = self:load(self.REGISTERS[TargetOperand]+self:load(self.PC+1))
					self.PC+=1
				elseif Type == "O" then -- Offset from operand
					Operands[#Operands+1] = self.PC+TargetOperand
				end
				
				Operands[#Operands+1] = Bitcount
			end
			
			warn("got here")
			local Result = Callback(tunpack(Operands))
			
			if Result then
				local Target = Decoded[1]
				local Type = Target[1]
				
				if Type == "A" then
					self:store(self.PC-1) -- Negate one to attempt to get first operand which is destination
				elseif Type == "R" then
					-- Note: SpecialTypeCasting on accesses of floating point registers should be noted
					self.REGISTERS[self:load(self.PC-1)] = Result
				elseif Type == "S" then -- The Immediate value used as offset is treated as signed
					self:store(self.REGISTERS[self:load(self.PC-2)]+self:load(self.PC-1), Result)
				end
				
			end
		end
	end
	
	-- Operand1 is the value of destination, Operand2 is the value of the source
	-- Basic Arithmetic:
	NewInstruction("ADD", function(Operand1, Op1Size, Operand2, Op2Size)
		return SpecialTypeCast(Op1Size, Operand1 + Operand2)
	end)
	NewInstruction("SUB", function(Operand1, Op1Size, Operand2, Op2Size)
		return SpecialTypeCast(Op1Size, Operand1 - Operand2)
	end)
	NewInstruction("MOV", function(Operand1, Op1Size, Operand2, Op2Size)
		warn("AAA")
		print(Operand1, Operand2)
		return Operand2
	end)
	NewInstruction("MUL", function(Operand1, Op1Size, Operand2, Op2Size)
		return UnsignedTypeCast(Op1Size, Operand1 * Operand2)
	end)
	NewInstruction("DIV", function(Operand1, Op1Size, Operand2, Op2Size)
		return UnsignedTypeCast(Op1Size, Operand1 / Operand2)
	end)
	NewInstruction("IMUL", function(Operand1, Op1Size, Operand2, Op2Size)
		return SignedTypeCast(Op1Size, Operand1 * Operand2)
	end)
	NewInstruction("IDIV", function(Operand1, Op1Size, Operand2, Op2Size)
		return SignedTypeCast(Op1Size, Operand1 / Operand2)
	end)
	-- Bitwise:
	
	
	
	NewInstruction("AND", function(Operand1, Op1Size, Operand2, Op2Size)
		local BinaryOP1, Op1IsNegative = PrepForBitwise(Op1Size, Operand1):split("")
		local BinaryOP2, Op2IsNegative = PrepForBitwise(Op2Size, Operand2):split("")
		local Result = ""
		
		for i = 1, Op1Size do
			Result ..= "0"
		end
		Result = Result:split("")
		
		for i = 1, Op1Size do
			if BinaryOP1[i] == BinaryOP2[i] then
				Result[i] = "1"
			end
		end
		
		if Op1IsNegative and Result[1] == "1" then
			return -tonumber(table.concat(Result),2)
		else
			return tonumber(table.concat(Result),2)
		end		
	end)
	NewInstruction("OR", function(Operand1, Op1Size, Operand2, Op2Size)
		local BinaryOP1, Op1IsNegative = PrepForBitwise(Op1Size, Operand1):split("")
		local BinaryOP2, Op2IsNegative = PrepForBitwise(Op2Size, Operand2):split("")
		local Result = ""

		for i = 1, Op1Size do
			Result ..= "0"
		end
		Result = Result:split("")

		for i = 1, Op1Size do
			if BinaryOP1[i] ~= "0" or BinaryOP2[i] ~= "0" then
				Result[i] = "1"
			end
		end

		if Op1IsNegative and Result[1] == "1" then
			return -tonumber(table.concat(Result),2)
		else
			return tonumber(table.concat(Result),2)
		end		
	end)
	NewInstruction("XOR", function(Operand1, Op1Size, Operand2, Op2Size)
		local BinaryOP1, Op1IsNegative = PrepForBitwise(Op1Size, Operand1):split("")
		local BinaryOP2, Op2IsNegative = PrepForBitwise(Op2Size, Operand2):split("")
		local Result = ""

		for i = 1, Op1Size do
			Result ..= "0"
		end
		Result = Result:split("")

		for i = 1, Op1Size do
			if (BinaryOP1[i] == "1" and BinaryOP2[i] == "0") or (BinaryOP1[i] == "0" and BinaryOP2[i] == "1") then
				Result[i] = "1"
			end
		end

		if Op1IsNegative and Result[1] == "1" then
			return -tonumber(table.concat(Result),2)
		else
			return tonumber(table.concat(Result),2)
		end		
	end)
	NewInstruction("NOT", function(Operand1, Op1Size) -- Single Operand Operation
		local BinaryOP1, Op1IsNegative = PrepForBitwise(Op1Size, Operand1):split("")
		local Result = ""

		for i = 1, Op1Size do
			Result ..= "0"
		end
		Result = Result:split("")

		for i = 1, Op1Size do
			if BinaryOP1[i] == "0" then
				Result[i] = "1"
			elseif BinaryOP1 == "1" then
				Result[i] = "0"
			end
		end

		if Op1IsNegative and Result[1] == "1" then
			return -tonumber(table.concat(Result),2)
		else
			return tonumber(table.concat(Result),2)
		end		
	end)
	-- Shifts can actually be done very easily with math
	-- In terms of the x86-compatibility-ness, we will NOT implement things like "Multiply r/m32 by 2, once."
	NewInstruction("SAR", function(Operand1, Op1Size, Operand2, Op2Size) 
		local n = Operand1
		
		for i = 1, Operand2 do
			n = SignedTypeCast(Op1Size, n / 2)
		end
		
		return n
	end)
	NewInstruction("SHR", function(Operand1, Op1Size, Operand2, Op2Size) 
		local n = Operand1

		for i = 1, Operand2 do
			n = UnsignedTypeCast(Op1Size, n / 2)
		end

		return n
	end)
	NewInstruction("SAL", function(Operand1, Op1Size, Operand2, Op2Size) 
		local n = Operand1

		for i = 1, Operand2 do
			n = SignedTypeCast(Op1Size, n * 2)
		end

		return n
	end)
	NewInstruction("SHL", function(Operand1, Op1Size, Operand2, Op2Size) 
		local n = Operand1

		for i = 1, Operand2 do
			n = UnsignedTypeCast(Op1Size, n * 2)
		end

		return n
	end)
	NewInstruction("JMP", function(Operand1, Op1Size) 
		warn("JMP", Operand1)
		self.PC = Operand1
	end)
	-----------------------
	-- CONDITIONAL JUMPS --
	-----------------------
	NewInstruction("JO", function(Operand1, Op1Size) 
		if self:CheckCOND(0) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JNO", function(Operand1, Op1Size) 
		if self:CheckCOND(1) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JS", function(Operand1, Op1Size) 
		if self:CheckCOND(2) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JNS", function(Operand1, Op1Size) 
		if self:CheckCOND(3) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JE", function(Operand1, Op1Size) 
		if self:CheckCOND(4) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JNE", function(Operand1, Op1Size) 
		if self:CheckCOND(5) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JC", function(Operand1, Op1Size) 
		if self:CheckCOND(6) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JNC", function(Operand1, Op1Size) 
		if self:CheckCOND(7) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JBE", function(Operand1, Op1Size) 
		if self:CheckCOND(8) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JNBE", function(Operand1, Op1Size) 
		if self:CheckCOND(9) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JNGE", function(Operand1, Op1Size) 
		if self:CheckCOND(10) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JGE", function(Operand1, Op1Size) 
		if self:CheckCOND(11) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JLE", function(Operand1, Op1Size) 
		if self:CheckCOND(12) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JNLE", function(Operand1, Op1Size) 
		if self:CheckCOND(13) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JP", function(Operand1, Op1Size) 
		if self:CheckCOND(14) then
			self.PC = Operand1
		end
	end)
	NewInstruction("JNP", function(Operand1, Op1Size) 
		if self:CheckCOND(15) then
			self.PC = Operand1
		end
	end)
	--==============--
	-- END OF BLOCK --
	--==============--
	NewInstruction("CMP", function(Operand1, Op1Size, Operand2, Op2Size) 
		self:ReportToALU("CMP", Operand1-Operand2)
	end)
	NewInstruction("CALL", function(Operand1, Op1Size) 
		self:Push(self.PC+1)
		self.PC = Operand1
	end)
	NewInstruction("HLT", function() 
		self:halt()
	end, true)
	NewInstruction("INTO", function() 
		if self.FFLAGS.OF then
			self:RaiseException("OverflowTrap")
		end
	end, true)
	NewInstruction("INT1", function() 
		self:RaiseException("DebugTrap")
	end, true)
	NewInstruction("INT", function(Operand1, Op1Size) 
		self:RaiseException("SoftwareInterrupt", UnsignedTypeCast(Op1Size, Operand1))
	end)
	NewInstruction("INT3", function() -- Multi-Core-Control
		self:RaiseException("CoreControl")
	end, true)
	NewInstruction("IRET", function() 
		self.PC = self:Pop()
	end, true)
	NewInstruction("RET", function() 
		self.PC = self:Pop()
	end, true)
	NewInstruction("PUSH", function(Operand1, Op1Size) 
		self:Push(Operand1)
	end)
	NewInstruction("POP", function() 
		return self:Pop()
	end)
	
	--================--
	-- FLOATING POINT --
	--================--
	-- not yet implemented
	NewInstruction("FADD", function(Operand1, Op1Size, Operand2, Op2Size)
		return FloatTypeCast(Op1Size, Operand1 + Operand2)
	end)
	NewInstruction("FSUB", function(Operand1, Op1Size, Operand2, Op2Size)
		return FloatTypeCast(Op1Size, Operand1 - Operand2)
	end)
	
	print(AssemblerTree)
	self.InstructionIndex = InstructionIndex
end

return Module
