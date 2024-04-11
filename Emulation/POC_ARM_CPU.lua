-- This is a proof of concept ARM CPU of unmarked type, this is also an archaic CPU although this one works far better than the CORTEX M3 replica.

-- Originally Called cheap 2$ cpu, it is no longer cheap (as it's high quality now) so..
-- "Bootleg ARM CPU" it is
-- Also fits with our type of binary, which is called "bootleg binary"

local BinaryHandler = require(script.Parent.BinaryHandler)

local tonum = tonumber
local format = string.format

-- // Binary Utilities Section:
local null32bit = "00000000000000000000000000000000"
local null64bit = "0000000000000000000000000000000000000000000000000000000000000000"

-- // CPU Functionality
local RegisterTemplate = setmetatable({
	-- General Purpose Registers:
	["R0"] = "0",
	["R1"] = "0",
	["R2"] = "0",
	["R3"] = "0",
	["R4"] = "0",
	["R5"] = "0",
	["R6"] = "0",
	["R7"] = "0",
	["R8"] = "0",
	["R9"] = "0",
	["R10"] = "0",
	["R11"] = "0",
	["R12"] = "0",
	-- Special Registers:
	["R13"] = "0", -- Stack Pointer (SP)
	["R14"] = "0", -- Link Register (LR)
	["R15"] = "61440", -- Program Counter (PC)
	-- Program Status Registers:
	["CPSR"] = null32bit,
	["SPSR"] = null32bit,
	["SPCR"] = null32bit,
}, {
	__newindex = function(self, Index, Value)
		self[Index] = tostring(Value)
	end,
})
local FieldRegistry = {
	-- // CPSR
	["CPSR.M"] = {1,5}, -- Mode
	-- Condition Flags
	["CPSR.N"] = {31,31},
	["CPSR.Z"] = {30,30},
	["CPSR.C"] = {29,29},
	["CPSR.V"] = {28,28},
	["CPSR.Q"] = {27,27},
	-- Mask Bits:
	["CPSR.A"] = {8,8},
	["CPSR.I"] = {7,7},
	["CPSR.F"] = {6,6},
	-- Uncategorized:
	["CPSR.GE"] = {19,16},
	["CPSR.E"] = {9,9},
	["ISCR.E"] = {1,1}, -- Processor "is handling exception" boolean
	--["CPSR.J"] = {24,24}, -- Jazelle bit, no implementation right now
	--["CPSR.T"] = {10,10}, -- Thumb execution state bit, no implementation right now
	
}
local decimal32bit = 2^32
local ModeEncodeTable = {
	["USR"] = "10000",
	["FIQ"] = "10001",
	["IRQ"] = "10010",
	["SVC"] = "10011",
	["MON"] = "10110",
	["ABT"] = "10111",
	["HYP"] = "11010", -- No Hypervisor Functionality as we do not include the virtualization extensions
	["UND"] = "11011",
	["SYS"] = "10000"
}
local RegisterEncodeTable = {
	["00001"] = "R0",
	["00010"] = "R1",
	["00011"] = "R2",
	["00100"] = "R3",
	["00101"] = "R4",
	["00110"] = "R5",
	["00111"] = "R6",
	["01000"] = "R7",
	["01001"] = "R8",
	["01010"] = "R9",
	["01011"] = "R10",
	["01100"] = "R11",
	["01101"] = "R12",
	["01110"] = "R13",
	["01111"] = "R14",
	["10000"] = "R15",
	["10001"] = "CPSR",
	["10010"] = "SPSR",
	["10011"] = "SPCR"
}
local TypeEncoding = {
	["001"] = "Register",
	["010"] = "Immediate"
}
local InstructionEncodeTable = require(script.Parent.SharedEncodings)
local CondEncodeTable = {
	["0001"] = "HI",
	["0010"] = "CC",
	["0011"] = "MI",
	["0100"] = "LE",
	["0101"] = "CS",
	["0110"] = "VC",
	["0111"] = "NE",
	["1000"] = "GT",
	["1001"] = "EQ",
	["1010"] = "VS",
	["1011"] = "LT",
	["1100"] = "PL",
	["1101"] = "LS",
	["1110"] = "GE"
}
local Suffixes = {
	EQ = "Z=1",
	NE = "Z=0",
	CS = "C=1",
	CC = "C=0",
	MI = "N=1",
	PL = "N=0",
	VS = "V=1",
	VC = "V=0",
	HI = "C=1&Z=0",
	LS = "C=1?Z=0",
	GE = "N=V",
	LT = "N!V",
	GT = "Z=0&N=V",
	LE = "Z=1&N!V",
}
local ALU_Masks = {
	["N"] = "31:31",
	["Z"] = "30:30",
	["C"] = "29:29",
	["V"] = "28:28",
	["Q"] = "27:27",
	["A"] = "8:8",
	["I"] = "7:7",
	["F"] = "6:6"
}

-- A faster wait function for the Instruction Cycle:
local Time = task.wait()
local function BetterWait()
	if Time > 0.01 then
		Time -= 0.01
	else
		Time = task.wait()
	end
end
local function ReverseTable(t)
	local NewTable = {}
	for i,v in next, t do
		NewTable[v] = i
	end
	return NewTable
end
local function replace_char(pos, str, r)
	return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end
local function ReadMask(Mask)
	if Mask == nil then return nil end
	local SplitMask = string.split(Mask,":")
	for index,value in ipairs(SplitMask) do
		SplitMask[index] = tonumber(value)
	end
	if SplitMask[2] == 0 then
		return SplitMask[1], SplitMask[1]
	end
	return table.unpack(SplitMask)
end

--RegisterEncodeTable = ReverseTable(RegisterEncodeTable)
--ModeEncodeTable = ReverseTable(ModeEncodeTable)
--InstructionEncodeTable = ReverseTable(InstructionEncodeTable)

return function(MEM_BUS) -- CPU Creator Function :)
	local Registers = RegisterTemplate
	
	local function rrwField(FieldName, value) -- field based register read/write
		local s,e = table.unpack(FieldRegistry[FieldName])
		local Target = string.split(FieldName,".")[1]
		
		if value then
			Registers[Target] = string.sub(Registers[Target],1,s-1)..value
		else
			return string.sub(Registers[Target], s,e)
		end
	end
	local function GetPrivlegeLevel()
		local pMode = rrwField("CPSR.M")
		for Name,Value in next, ModeEncodeTable do
			if pMode == Value then
				if Name == "USR" then
					return 0
				elseif Name == "HYP" then
					return 2
				else -- Literally all other modes have a PL of 1
					return 1
				end
			end
		end
	end
	local function CheckSuffix(Suffix)
		local DecodeSuffix = string.split(Suffixes[Suffix],"")
		local Position = 1

		local function Check()
			local Flag = string.sub(Registers["CPSR"], ReadMask(ALU_Masks[DecodeSuffix[Position]]))
			Position += 1
			local Operator = DecodeSuffix[Position]
			Position += 1
			local Value = DecodeSuffix[Position]
			Position += 1
			local Continue = DecodeSuffix[Position]
			local IsTrue

			local ValueIsFlag = string.find(Value, "%u") and true or false
			if ValueIsFlag then
				Value = string.sub(Registers["CPSR"], ReadMask(ALU_Masks[Value]))
			end

			if Operator == "=" then
				IsTrue = (Flag == Value)
			elseif Operator == "!" then
				IsTrue = (Flag ~= Value)
			end

			if Continue and (Continue == "?" or Continue == "&") then
				local Result = Check()
				if Continue == "&" then
					return (IsTrue == true and Result == true)
				end
				if Continue == "?" then
					return (IsTrue == true or Result == true)
				end
			end
			return IsTrue
		end
		return Check()
	end
	local function ReportALU(OperationResult, InstructionName)
		if typeof(OperationResult) == "number" then
			local FlagsToUpdate = {}

			-- We do not do elseif so we can allow for Multiple Flags to be active at once
			if OperationResult < 0 then
				table.insert(FlagsToUpdate, ALU_Masks["N"])
			end
			if OperationResult == 0 then
				table.insert(FlagsToUpdate, ALU_Masks["Z"])
			end
			if ((InstructionName == "ADD" or InstructionName == "ADC") and OperationResult >= decimal32bit) 
				or ((InstructionName == "SUB" or InstructionName == "SBC") and OperationResult > 0) then
				table.insert(FlagsToUpdate, ALU_Masks["C"])
			end
			if (InstructionName == "ADD" or InstructionName == "SUB" or InstructionName == "CMP"
				or InstructionName == "ADC" or InstructionName == "SBC" or InstructionName == "CMN") 
				and (OperationResult > 2^31 or OperationResult < -2^31) 	then
				table.insert(FlagsToUpdate, ALU_Masks["V"])
			end

			-- Clear all flags, and then update them based on the result of the operations
			for _,v in next, ALU_Masks do
				local Pos = tonumber(v:split(":")[1])
				local NewSplit = Registers["CPSR"]:split("")
				NewSplit[Pos] = "0"
				local NewString = ""
				for _,v in next, NewSplit do
					NewString = NewString..v
				end
				Registers["CPSR"] = NewString
			end
			for _,v in next, FlagsToUpdate do
				local Pos = tonumber(v:split(":")[1])
				local NewSplit = Registers["CPSR"]:split("")
				NewSplit[Pos] = "1"
				local NewString = ""
				for _,v in next, NewSplit do
					NewString = NewString..v
				end
				Registers["CPSR"] = NewString
			end
		end
	end
	local function HandleOperand(Operand)
		if type(Operand) == "number" then
			return Operand
		elseif type(Operand) == "string" then
			if tonumber(Operand) then
				return Operand
			elseif Operand:sub(1,1) == "R" or table.find({"CPSR", "SPSR", "SPCR"}, Operand) then
				return Registers[Operand]
			end
		end
	end
	
	local InstructionSet = {
		["ADD"] = function(S, Rd, Operand)
			local OP = Registers[Rd]+HandleOperand(Operand)
			if S then
				ReportALU(OP)
			end
			print(OP)
			Registers[Rd] += OP
		end,
		["SUB"] = function(S, Rd, Operand)
			local OP = Registers[Rd]-HandleOperand(Operand)
			if S then
				ReportALU(OP)
			end
			Registers[Rd] -= OP
		end,
		["MUL"] = function(S, Rd, Operand)
			local OP = Registers[Rd]*HandleOperand(Operand)
			if S then
				ReportALU(OP)
			end
			Registers[Rd] *= OP
		end,
		["DIV"] = function(S, Rd, Operand)
			local OP = Registers[Rd]/HandleOperand(Operand)
			if S then
				ReportALU(OP)
			end
			Registers[Rd] /= OP
		end,
		["EXP"] = function(S, Rd, Operand)
			local OP = Registers[Rd]^HandleOperand(Operand)
			if S then
				ReportALU(OP)
			end
			Registers[Rd] *= OP
		end,
		["MOD"] = function(S, Rd, Operand)
			local OP = Registers[Rd]%HandleOperand(Operand)
			if S then
				ReportALU(OP)
			end
			Registers[Rd] /= OP
		end,
		["LDR"] = function(Rd, Operand)
			Registers[Rd] = MEM_BUS.load(HandleOperand(Operand))
		end,
		["STR"] = function(Rd, Operand)
			print(Operand)
			MEM_BUS.store(HandleOperand(Operand), Registers[Rd])
		end,
		["MOV"] = function(Rd, Operand)
			Registers[Rd] = HandleOperand(Operand)
		end,
		["CMP"] = function(Rn, Operand)
			local OP = Registers[Rn] - HandleOperand(Operand)
			ReportALU(OP, "CMP")
		end,
		["CMN"] = function(Rn, Operand)
			local OP = Registers[Rn] + HandleOperand(Operand)
			ReportALU(OP, "CMP")
		end,
		["JMP"] = function(Operand)
			Registers["R15"] = HandleOperand(Operand)
		end,
		
	}
	
	local function EnterException(ExceptionName)
		if rrwField("ISCR.E") == "0" then
			rrwField("ISCR.E", "1")
			rrwField("CPSR.M", ModeEncodeTable[ExceptionName])
			if ExceptionName == "IRQ" then
				-- JMP to 0x1
			end
		else
			warn("An exception is already being served, new exception placed in buffer")
		end
	end
	
	local Cond
	local Instruction
	local PrivlegeLevel
	local InstructionName
	local InstructionFunction
	local InstructionArguments
	local function ReadLength(End)
		local val = string.sub(Instruction,1,End)
		Instruction = string.sub(Instruction, End+1, Instruction:len())
		return val
	end
	local function ReadArguments(...)
		local ArgumentTable = {}
		for _,v in next, {...} do
			if v:sub(1,1) == "?" then
				v = TypeEncoding[ReadLength(3)]
			end
			if v == "Register" then
				table.insert(ArgumentTable, RegisterEncodeTable[ReadLength(5,5)])
			elseif v == "flag" then
				table.insert(ArgumentTable, ReadLength(1,1) == "1")
			elseif v == "Immediate" then
				table.insert(ArgumentTable, Instruction)
			end	
		end
		return ArgumentTable
	end
	
	task.spawn(function()
		while true do
			BetterWait()
			wait(2)
			Instruction = MEM_BUS.load(Registers["R15"])
			if not Instruction then
				task.wait(0.5)
				return
			end
			Cond = CondEncodeTable[ReadLength(4)]
			if Cond and not CheckSuffix(Cond) then
				return
			end
			PrivlegeLevel = GetPrivlegeLevel()
			local INS_BITS = ReadLength(5)
			InstructionName = InstructionEncodeTable[INS_BITS]
			InstructionFunction = InstructionSet[InstructionName]
			
			if table.find({"ADD","SUB","MUL","DIV","EXP","MOD"}, InstructionName) then
				InstructionArguments = ReadArguments("flag", "Register", "?")
			elseif table.find({"ADD", "SUB", "LDR", "STR", "CMP", "CMN"}, InstructionName) then
				InstructionArguments = ReadArguments("Register", "?")
			elseif InstructionName == "JMP" then
				InstructionArguments = ReadArguments("?")
			end

			InstructionFunction(unpack(InstructionArguments))
			Registers["R15"]+=1
		end
	end)
	
	
end
