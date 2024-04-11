-- This file has not been modified for github release, this is an incredibly archaic CPU
-- but it features a general purpose turing complete instruction set, (that does not work because this was my first CPU)

--# Computer System
--# Project for an advanced and realistic computer system written in LuaU for ROBLOX
--@ 3/22/2023

--This module acts as the SOC/CPU

--@ Credits:
--AbnormallyCursed - All of the code
--Quenty - Mainly open source modules from the Nevermore repository

---- TODO: For the much further future, add those tiny implementations for specific flags under instructions
---- TODO: Process Signed Binary, I really wish ARM Developer documentation specified what isnt and is signed :/
---- TODO: Extension: UMULL, UMLAL, SMULL, SMLAL, SDIV and UDIV. These are entirely based off of signed & unsigned binary
---- TODO: Whoops, I was a goober, make ALU reports for the bitwise instructions
---- TODO: BIC & ORN, I would do them now but the descriptions are too confusing
---- TODO: Refine the ALU Reporting system as well as make implementations for APSR, see:
---- TODO: IT/I under Branch & Control Instructions in the ISA, must be done in the future

--https://developer.arm.com/documentation/dui0552/a/the-cortex-m3-instruction-set/about-the-instruction-descriptions/conditional-execution?lang=en

--   (As it stands the method is going to be an updatable flag that tells functions how to process binary)

--Remove REV instruction? see notes on line 519 & 520

--╔═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
--║                                                      INFO  SECTION                                                          ║
--╚═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
--// Miscellaneous:
--In assembly mode #n allows you to offset addresses by n

--Copied from section "Memory Access Instructions" in the InstructionSet table
--addr_mode
--Rn
--reglist
--goober docs:
--https://developer.arm.com/documentation/dui0552/a/the-cortex-m3-instruction-set/memory-access-instructions/ldm-and-stm
--https://developer.arm.com/documentation/dui0068/b/ARM-Instruction-Reference/ARM-memory-access-instructions/LDM-and-STM?lang=en
--as it stands there are 2 addressing modes, IA and DB

--Since I got confused on this: LDR loads from address into register, STR stores from register into address
--Least and most significant byte visualized in a 32 bit pattern left is most significant, right is least significant
--00000000000000000000000000000000
--^^^^^^^^                ^^^^^^^^
--// Processor Modes
--    User

--    FIQ - Fast Interrupt Request

--    IRQ - Interrupt Request

--    Supervisor

--    Abort

--    Undefined

--    System

--// General-purpose, 32-bit registers:
--Fifteen general-purpose registers are visible at any one time, depending on the current processor mode,
--as r0, r1, ... ,r13, r14. During execution, r15 does not contain the address of the currently executing instruction. The
--address of the currently executing instruction is typically pc-8 for ARM, or pc-4 for Thumb.

--// The program counter (pc)
--The program counter is accessed as r15 (or pc). It is incremented by one word (four bytes) for each instruction in ARM state,
--Branch instructions load the destination address into the program counter. You can also load the program counter directly using
--data operation instructions. For example, to return from a subroutine, you can copy the link register into the program counter
--using: MOV pc,lr

--// Register Access:
--In ARM state, all instructions can access r0 to r14, and most also allow access to r15 (pc). 
--The MRS and MSR instructions can move the contents of the CPSR and SPSRs to a general-purpose register,
--where they can be manipulated by normal data processing operations. Refer to MRS and MSR for more information.

--// Conditional Execution:
--https://developer.arm.com/documentation/dui0068/b/Writing-ARM-and-Thumb-Assembly-Language/Conditional-execution?lang=en
--https://developer.arm.com/documentation/dui0068/b/ARM-Instruction-Reference/Conditional-execution?lang=en

--~~// MEGA SECTION : Instruction Information //~~


--// ARM memory access instructions:
--@ LDR and STR;
--B is an optional suffix. If B is present, the least significant byte of Rd is transferred. 
--If op is LDR, the other bytes of Rd are cleared.

--T is an optional suffix. If T is present, the memory system treats the access as though the processor was in User mode,
--even if it is in a privileged mode (see Processor mode).
--T has no effect in User mode. You cannot use T with a pre-indexed offset.

--// Condition flags:
--@ MVN and MOV;
--If S is specified, these instructions:
--    update the N and Z flags according to the result

--    can update the C flag during the calculation of Operand2 (see Flexible second operand)

--    do not affect the V flag.
    
--@ ADD, SUB, RSB, ADC, SBC, and RSC;
--If S is specified, these instructions update the N, Z, C and V flags according to the result.



local core = require(script.Parent.Parent.core)
local import = core.import

local BinaryProcessor = import("BinaryHandler")

local null32bit = "00000000000000000000000000000000"
local decimal32bit = 2^32

-- Binary Translator Tables, generated automatically so there's no order
local OpcodeTable = {
	["000001"] = "MLA",
	["000010"] = "STM",
	["000011"] = "ADR",
	["000100"] = "LDM",
	["000101"] = "MRS",
	["000110"] = "SBC",
	["000111"] = "ADD",
	["001000"] = "RRX",
	["001001"] = "LDR",
	["001010"] = "LSL",
	["001011"] = "RSB",
	["001100"] = "BLX",
	["001101"] = "SUB",
	["001110"] = "ASR",
	["001111"] = "B",
	["010000"] = "EOR",
	["010001"] = "STR",
	["010010"] = "I",
	["010011"] = "BL",
	["010100"] = "MOVT",
	["010101"] = "MSR",
	["010110"] = "MUL",
	["010111"] = "TEQ",
	["011000"] = "MLS",
	["011001"] = "BX",
	["011010"] = "TST",
	["011011"] = "REV",
	["011100"] = "CMP",
	["011101"] = "ROR",
	["011110"] = "SWP",
	["011111"] = "ADC",
	["100000"] = "LSR",
	["100001"] = "ORR",
	["100010"] = "CMN",
	["100011"] = "MVN",
	["100100"] = "CLZ",
	["100101"] = "MOV",
	["100110"] = "AND"
}
local RegisterTable = {
	["00001"] = "r13",
	["00010"] = "APSR",
	["00011"] = "r8",
	["00100"] = "r9",
	["00101"] = "r12",
	["00110"] = "r15",
	["00111"] = "SPSR",
	["01000"] = "r11",
	["01001"] = "CPSR",
	["01010"] = "r14",
	["01011"] = "r10",
	["01100"] = "r5",
	["01101"] = "r4",
	["01110"] = "r7",
	["01111"] = "r6",
	["10000"] = "r0",
	["10001"] = "r1",
	["10010"] = "r2",
	["10011"] = "r3"
}
local CondTable = {
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
local ShiftTable = {
	["001"] = "LSL",
	["010"] = "ASR",
	["011"] = "ORR",
	["100"] = "EOR",
	["101"] = "AND",
	["110"] = "ROR",
	["111"] = "LSR"
}

-- Defaults for quick resetting of CPU State:
local regdefault = {
	-- General Purpose
	["r0"] = null32bit,
	["r1"] = null32bit,
	["r2"] = null32bit,
	["r3"] = null32bit,
	["r4"] = null32bit,
	["r5"] = null32bit,
	["r6"] = null32bit,
	["r7"] = null32bit,
	["r8"] = null32bit,
	["r9"] = null32bit,
	["r10"] = null32bit,
	["r11"] = null32bit,
	["r12"] = null32bit,
	["r13"] = null32bit, -- By convention, r13 is used as a stack pointer (sp) in ARM assembly language.
	["r14"] = null32bit, -- In User mode, r14 is used as a link register (lr) to store the return address when a subroutine call is made. It can also be used as a general-purpose register if the return address is stored on the stack.
	["r15"] = "00000000000000000000000000000001", -- Program Counter, hardcoded to memory address 0x1
	-- Status:
	["CPSR"] = null32bit,
	["SPSR"] = null32bit,
	["APSR"] = null32bit,
	__newindex = function(Registers, Register, Value)
		if type(Value) == "string" then
			if Value:len() ~= 32 then
				warn("Value does not correspond to a bit length of 32")
			else
				Registers[Registers] = Value
			end
		end
	end,
}
local MSR_FieldMasks = {
	["c"] = "7:0",
	["x"] = "8:15",
	["s"] = "16:23",
	["f"] = "24:31"
}
local ALU_Masks = {
	["N"] = "31:31",
	["Z"] = "30:30",
	["C"] = "29:29",
	["V"] = "28:28",
	["Q"] = "27:27",
}
local Shift_Dictionary = {
	["ASR"] = bit32.arshift,
	["LSL"] = bit32.lshift,
	["LSR"] = bit32.rshift,
	["ROR"] = bit32.rrotate,
	["AND"] = bit32.band,
	["EOR"] = bit32.bxor,
	["ORR"] = bit32.bor
}

local function ReadMask(Mask)
	if Mask == nil then return nil end
	local SplitMask = string.split(Mask,":")
	for index,value in ipairs(SplitMask) do
		SplitMask[index] = tonumber(value)
	end

	if SplitMask[2] == 0 then
		print("gh")
		return SplitMask[1], SplitMask[1]
	end

	return table.unpack(SplitMask)
end

local Suffixes = {
	EQ = "Z=1",
	NE = "Z=0",
	CS = "C=1",
	CC = "C=0",
	-- Do not understand these two, no implementation
	--HS = "C=1",
	--LO = "C=0",
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

-- Creates a new CPU & Assembly Processor
-- Requires a BUS Table
return function(CPU_BUS)

	local ProcessorMode = "Undefined"
	local Registers = regdefault

	local function OutputMessage(Message)
		warn(Message)
	end

	-- SignedBinary uses the first bit to tell rather or not the value is negative or not
	-- If Argument 2 is empty here, it simply returns integer value, otherwise you set rather or not it is a negative value
	local function SignedBinary(Binary, BitValue)
		local MostSignificant = string.sub(Binary,1,1)
		Binary = string.sub(Binary,2,Binary:len())

		if BitValue then
			MostSignificant = BitValue
			return MostSignificant..Binary
		else
			local Value = tonumber(Binary,2)
			if MostSignificant == "1" then
				Value = -Value
			end
			return Value
		end
	end

	local function DecimalTo32BitBinary(Decimal)
		if Decimal == 0 then return null32bit end -- Roblox for some reason does not like processing 0 binary
		local Binary = BinaryProcessor.GetBinary(Decimal)
		local Length = Binary:len()

		if Length < 1 or Length > 32 then
			OutputMessage("out of range")
		else
			if Length ~= 32 then
				-- ALWAYS use least significant bits for this or the binary decimal system will kill you
				local MaskedNull = string.sub(null32bit, 1, 32-Length).."%s"					
				Binary = string.format(MaskedNull, Binary)
			end
		end
		return Binary
	end

	local function ProcessOperand2(Operand2)
		-- the goober in question
		if Operand2.constant then
			assert(Operand2.constant:len() == "7", "invalid Operand2 constant, is not length of 7")
			return Operand2.constant
		else
			local Rm = Operand2.Rm
			if Operand2.shift then
				local Decimal = tonumber(Registers[Rm], 2)
				if Operand2.shift == "RRX" then
					Decimal = bit32.rrotate(Decimal, 1)
				else
					Decimal = Shift_Dictionary[Operand2.shift](Decimal, Operand2.n)
				end
				-- Registers[Rm] = DecimalTo32BitBinary(Decimal)
				-- Learned from ARM Operand2 Documentation: "However, the contents in the register Rm remains unchanged."
				-- So we do not update Rm we just return the result
				return Decimal
			end
		end
	end

	local function replace_char(pos, str, r)
		return str:sub(1, pos-1) .. r .. str:sub(pos+1)
	end
	local function GetSignedDecimal(binary)
		local sign = binary:sub(1,1)
		local bin = tonumber(binary:sub(2,binary:len()),2)
		if sign == "1" then
			return -bin
		else
			return bin
		end
	end
	local function CheckSuffix(Suffix) -- Unecessary and overcomplicated? perhaps..
		local DecodeSuffix = string.split(Suffixes[Suffix],"")
		local Position = 1

		local function Check()
			local Flag = string.sub(Registers["APSR"], ReadMask(ALU_Masks[DecodeSuffix[Position]]))
			Position += 1
			local Operator = DecodeSuffix[Position]
			Position += 1
			local Value = DecodeSuffix[Position]
			Position += 1
			local Continue = DecodeSuffix[Position]
			local IsTrue

			local ValueIsFlag = string.find(Value, "%u") and true or false
			if ValueIsFlag then
				Value = string.sub(Registers["APSR"], ReadMask(ALU_Masks[Value]))
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

	local function ReportToALU(InstructionName, OperationResult)
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
				local Pos,_ = ReadMask(v)
				Registers["CPSR"] = replace_char(Pos, Registers["CPSR"], "0")
			end
			for _,v in next, FlagsToUpdate do
				local Pos,_ = ReadMask(v)
				Registers["CPSR"] = replace_char(Pos, Registers["CPSR"], "1")
			end
		else
			-- idk yet
		end
	end

	local InstructionSet = {
		-- // Memory Access Instructions:

		-- Zero offset: The value in Rn is used as the address for the transfer.
		-- Pre-Index offset: The offset is applied to the value in Rn, the result is used as the memory address.
		-- Program-relative: This does not have any place being within the Instruction Set as it is assembler specific
		-- Post-Index offset: The value in Rn is used as the memory address for the transfer. The offset is applied to the value in Rn after the data transfer takes place.

		["LDR"] = function(args) -- T is temporarily redundant for now
			local Rd = tostring(Registers[args.Rd])
			if args.B then
				local LeastSignificantByte = string.sub(Rd, ReadMask("25:32"))
				Rd = string.sub(tostring(null32bit), ReadMask("1:24"))
				Rd ..= LeastSignificantByte
				Registers[Rd] = Rd
			end
			local Address = Registers[args.Rn]
			if args.pre then
				Address = DecimalTo32BitBinary(tonumber(Address,2)+args.imm10)
			end
			Registers[args.Rd] = CPU_BUS.AddressBus[Address]
			if not args.pre then
				Registers[args.Rn] = DecimalTo32BitBinary(tonumber(Address,2)+args.imm10)
			end
		end,
		["STR"] = function(args)
			local Rd = tostring(Registers[args.Rd])
			if args.B then
				local LeastSignificantByte = string.sub(Rd, ReadMask("25:32"))
				Rd = string.sub(tostring(null32bit), ReadMask("1:24"))
				Rd ..= LeastSignificantByte
				Registers[Rd] = Rd
			end
			local Address = Registers[args.Rn]
			if args.pre then
				Address = DecimalTo32BitBinary(tonumber(Address,2)+args.imm10)
			end
			CPU_BUS.AddressBus[Address] = Registers[args.Rd]
			if not args.pre then
				Registers[args.Rn] = DecimalTo32BitBinary(tonumber(Address,2)+args.imm10)
			end
		end,
		["LDM"] = function(args)
			local addr_mode = args.addr_mode or "IA"
			local Address = Registers[args.rn]

			for IndexNumber,v in ipairs(args.reglist) do
				Registers[v] = CPU_BUS.AddressBus[Address]
				Address = tonumber(Address,2)
				if addr_mode == "IA" then
					Address -= 1
				else
					Address += 1
				end
				Address = DecimalTo32BitBinary(Address)
				if args["!"] then
					Registers[args.rn] = Address
				end
			end
		end,
		["STM"] = function(args)
			local addr_mode = args.addr_mode or "IA"
			local Address = Registers[args.rn]

			for IndexNumber,v in ipairs(args.reglist) do
				CPU_BUS.AddressBus[Address] = Registers[v]
				Address = tonumber(Address,2)
				if addr_mode == "IA" then
					Address -= 1
				else
					Address += 1
				end
				Address = DecimalTo32BitBinary(Address)
				if args["!"] then
					Registers[args.rn] = Address
				end
			end
		end,
		["ADR"] = function(args)
			local Address = tonumber(Registers["r15"],2)
			local label = args.label
			if label > 0 then
				Address += label
			else
				Address -= label
			end
			Registers[args.Rd] = DecimalTo32BitBinary(Address)
		end,
		["SWP"] = function(args)
			if args.B then
				CPU_BUS.AddressBus[args.Rn] = string.sub(Registers[args.Rm], 25,32)
				Registers[args.Rd] = string.sub(CPU_BUS.AddressBus[args.Rn], 25,32)
			else
				CPU_BUS.AddressBus[args.Rn] = Registers[args.Rm]
				Registers[args.Rd] = CPU_BUS.AddressBus[args.Rn]
			end
		end,

		-- // General Data Processing Instructions:

		["ADD"] = function(args)
			print(args.imm12)
			print(args.Operand2)
			local Value = args.imm12 or ProcessOperand2(args.Operand2)
			local Result = tonumber(Registers[args.Rn],2) + (tonumber(Value, 2) or Value)
			if args.S then
				ReportToALU("ADD", Result)
			end
			Registers[args.Rn] = DecimalTo32BitBinary(Result)
		end,
		["SUB"] = function(args)
			local Value = args.imm12 or ProcessOperand2(args.Operand2)
			local Result = tonumber(Registers[args.Rn],2) - (tonumber(Value, 2) or Value)
			if args.S then
				ReportToALU("SUB", Result)
			end
			Registers[args.Rn] = DecimalTo32BitBinary(Result)
		end,
		["ADC"] = function(args)
			print("I'm FAT, will implement later")
		end,
		["SBC"] = function(args)
			print("I'm FAT, will implement later")
		end,
		["RSB"] = function(args)
			local Value = args.imm12 or ProcessOperand2(args.Operand2)
			local Result = (tonumber(Value, 2) or Value) - tonumber(Registers[args.Rn],2)
			if args.S then
				ReportToALU("SUB", Result) -- TECHNICALLY, this is still a SUB operation
			end
			Registers[args.Rn] = DecimalTo32BitBinary(Result)
		end,
		["AND"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			Registers[args.Rd] = DecimalTo32BitBinary(bit32.band(tonumber(Registers[args.Rn],2),Value))
		end,
		["EOR"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			Registers[args.Rd] = DecimalTo32BitBinary(bit32.bxor(tonumber(Registers[args.Rn],2),Value))
		end,
		["ORR"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			Registers[args.Rd] = DecimalTo32BitBinary(bit32.bor(tonumber(Registers[args.Rn],2),Value))
		end,

		--The BIC instruction performs an AND operation on the bits in Rn with the complements of the corresponding bits
		--in the value of Operand2.
		    
		--The ORN instruction performs an OR operation on the bits in Rn with the complements of the corresponding bits 
		--in the value of Operand2.

		["ASR"] = function(args)
			local Value = args.n or tonumber(string.sub(Registers[args.Rs],25,32),2)
			Registers[args.Rd] = DecimalTo32BitBinary(bit32.arshift(tonumber(Registers[args.Rm],2),Value))
		end,
		["LSL"] = function(args)
			local Value = args.n or tonumber(string.sub(Registers[args.Rs],25,32),2)
			Registers[args.Rd] = DecimalTo32BitBinary(bit32.lshift(tonumber(Registers[args.Rm],2),Value))
		end,
		["LSR"] = function(args)
			local Value = args.n or tonumber(string.sub(Registers[args.Rs],25,32),2)
			Registers[args.Rd] = DecimalTo32BitBinary(bit32.rshift(tonumber(Registers[args.Rm],2),Value))
		end,
		["ROR"] = function(args)
			local Value = args.n or tonumber(string.sub(Registers[args.Rs],25,32),2)
			Registers[args.Rd] = DecimalTo32BitBinary(bit32.rrotate(tonumber(Registers[args.Rm],2),Value))
		end,
		["RRX"] = function(args) -- ??? this feels wrong, come back later I think
			Registers[args.Rm] = bit32.rrotate(tonumber(Registers[args.Rm],2),1) 
		end,
		["CLZ"] = function(args)
			local SplitRegister = string.split(Registers[args.Rm],"")
			for i,v in next, SplitRegister do
				if v == "1" then
					Registers[args.Rd] = DecimalTo32BitBinary(i)
					break
				end
			end
		end,
		["CMP"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			local Result = tonumber(Registers[args.Rn],2) - (tonumber(Value, 2) or Value)
			ReportToALU("CMP", Result)
		end,
		["CMN"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			local Result = tonumber(Registers[args.Rn],2) + (tonumber(Value, 2) or Value)
			ReportToALU("CMN", Result)
		end,
		["MOV"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			Registers[args.Rd] = Value
			if args.S then
				ReportToALU("ADD", tonumber(Registers[args.Rd],2))
			end
		end,
		["MVN"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			Registers[args.Rd] = bit32.bnot(Value)
			if args.S then
				ReportToALU("ADD", tonumber(Registers[args.Rd],2))
			end
		end,
		["MOVT"] = function(args)
			print("I'm FAT, will implement later")
		end,
		-- No REV16 or REVSH implementation, & RBIT is undocumented, endian switching feels useless for our case anyway
		-- REV for our case does NOT allow for universal endian reversal, Idk how I would do this and this is good enough
		["REV"] = function(args)
			local Binary = BinaryProcessor.GetBinary(tonumber(Registers[args.Rn],2))
			local Length = Binary:len()

			if Length < 1 or Length > 32 then
				OutputMessage("out of range")
			else
				if Length ~= 32 then
					local MaskedNull = "%s"..string.sub(null32bit, 1, 32-Length)					
					Binary = string.format(MaskedNull, Binary)
				end
			end

			Registers[args.Rd] = Binary
		end,
		["TST"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			local Result = bit32.band(tonumber(Registers[args.Rn],2),Value)
			ReportToALU("ADD", Result)
		end,
		["TEQ"] = function(args)
			local Value = ProcessOperand2(args.Operand2)
			local Result = bit32.bor(tonumber(Registers[args.Rn],2),Value)
			ReportToALU("ADD", Result)
		end,

		-- // Multiply & Divide Instructions:

		["MUL"] = function(args)
			local Result = tonumber(Registers[args.Rn],2) * tonumber(Registers[args.Rm],2)
			if args.S then
				ReportToALU("MUL",Result)
			end
			Registers[args.Rd] = DecimalTo32BitBinary(Result)
		end,
		["MLA"] = function(args)
			local Result = tonumber(Registers[args.Rn],2) * tonumber(Registers[args.Rm],2)
			Result += tonumber(Registers[args.Ra],2)
			if args.S then
				ReportToALU("MUL",Result)
			end
			Registers[args.Rd] = DecimalTo32BitBinary(Result)
		end,
		["MLS"] = function(args)
			local Result = tonumber(Registers[args.Rn],2) * tonumber(Registers[args.Rm],2)
			Result -= tonumber(Registers[args.Ra],2)
			if args.S then
				ReportToALU("MUL",Result)
			end
			Registers[args.Rd] = DecimalTo32BitBinary(Result)
		end,
		-- UMULL, UMLAL, SMULL, and SMLAL, SDIV and UDIV are missing. SignedBinary must be processed properly first

		-- // Branch and control instructions

		["B"] = function(args)
			Registers["r15"] = args.label
		end,
		["BL"] = function(args)
			Registers["r14"] = args.label
		end,
		["BX"] = function(args) 
			Registers["r15"] = Registers[args.Rm]
		end,
		["BLX"] = function(args)
			Registers["r14"] = Registers[args.Rm]
		end,
		["I"] = function(args)
			local Extension = string.split(args.extension,"")
			-- This has to be done in the future
		end,
		-- No Implementation for: Table Branch Byte and Table Branch Halfword. (TBB & TBH)

		-- // Miscellaneous Instructions:
		-- Rd is the destination register, must NOT be r15. psr is either CPSR or SPSR
		["MRS"] = function(args)
			local Rd = args.Rd
			local psr = args.psr
			Registers[Rd] = Registers[psr]
		end,		
		-- I don't understand #immed_8r so no implementation for that
		-- Also we do not allow for manipulating multiple fields at once so you will require 1 instruction for each
		["MSR"] = function(args)
			local psr = args.psr
			local field = args.field
			local Rm = args.Rm
			local a,b = ReadMask(MSR_FieldMasks[field])
			a = a or 1
			b = b or 32
			local Masked = string.sub(Registers[Rm], a,b)
			local left = string.sub(Registers[psr],1,a-1)
			local right = string.sub(Registers[psr],b+1,32)
			Registers[psr] = left..Masked..right
		end,

		-- From henceforth in the instruction set, most instructions are hereby disrespectful of official ARM docs
		-- As well as a lot of unrealism will reside, however all further instructions will encourage the use of the above
		-- Later on there may be a project for RISC-V emulation instead of an ARM Replica
		-- I am unsatisfied with this CPU but I have ARM to blame for their poor documentation & myself to blame for not
		-- knowing enough about CPUs yet

	}

	local function DoCycle()
		-- Fetch:
		warn("CYCLE")
		local MemoryValue = CPU_BUS.AddressBus[Registers["r15"]]
		local ArgumentTable = {}
		print("FETCH")
		-- Decode:
		-- The way we decode is kinda like a mini-lexer y'know?
		print("DECODE")
		local function GetBinary(s,e) -- Advantage from using regular sub() is that this function subs the actual mem val
			local Val = string.sub(MemoryValue,s,e)
			if s > 32 or e > 32 then return error(string.format("OUT OF RANGE %s, %s",s,e)) end
			MemoryValue = MemoryValue:sub(s+1,32)
			return Val
		end
		local function GetRegister(Name)
			if Name then
				ArgumentTable[Name] = RegisterTable[GetBinary(1,5)]
			else
				return RegisterTable[GetBinary(1,5)] -- 32 registers maximum
			end
		end
		local function CheckSuffix(Name)
			local suf = GetBinary(1,1) == "1"
			ArgumentTable[Name] = suf
		end
		local function CheckCond()
			return true
			--return CheckSuffix(CondTable[GetBinary(1,4)])
		end
		local function CheckIfRegister()
			local Reg = RegisterTable[string.sub(MemoryValue,1,5)]
			return Reg ~= nil
		end
		local function DecodeOperand2() -- Operand2: constant form, Operand2: Rm, shift, n
			local Operand2Table = {}
			if CheckIfRegister() then -- "Register with optional shift"
				MemoryValue = MemoryValue:sub(1+1,32)
				Operand2Table.Rm = RegisterTable[string.sub(MemoryValue,1,5)]
				local bit3 = GetBinary(1,3)
				print(bit3)
				Operand2Table.shift = ShiftTable[bit3]
				Operand2Table.n = tonumber(GetBinary(1,6),2)
			else
				Operand2Table.constant = GetBinary(1,7)
			end
			return Operand2Table
		end

		local Opcode = OpcodeTable[MemoryValue:sub(1,6)]
		local Instruction = InstructionSet[Opcode]

		MemoryValue = MemoryValue:sub(7,32)

		-- I really wanted to avoid so many if then elses, I really did.. but it was too complex to do so and I just wanna
		-- get it done, on the bright side however this should help slow things down, cause yes I want things to be slowed
		-- PLUS, I had a lot of inconsistencies when making arg tables/ the instruction sets. I think I might try again 
		-- with this cpu thing on RISC-V and try and do a full on emulator, cause I have learned a lot with this, perhaps
		-- enough to do that

		-- This function sets the standard! it is the most complex instruction afterall
		-- Let me explain some of my methodology so I can know how to use this when the time comes
		-- Essentially, the first part which gets the suffixes, you must realize there are 4 variations
		-- In all variations B is an optional suffix, T is only a valid suffix in some specific variations
		-- Why include T universally then?, well even though it is not included in the docs it is technically just another
		-- optional argument.

		if Opcode == "LDR" or Opcode == "STR" then
			if not CheckCond() then return end
			CheckSuffix("B")
			GetRegister("Rd")
			GetRegister("Rn")
			local HasOffset = GetBinary(1,1) == "1"
			local PreIndexed = GetBinary(1,1) == "1"

			-- Rm, expr, Subtract, shift, minus, n
			if HasOffset then
				local Offset = tonumber(GetBinary(1,10),2) -- 2^10
				ArgumentTable.imm10 = Offset
				ArgumentTable.pre = PreIndexed
			end
		elseif Opcode == "LDM" or Opcode == "STM" then
			if not CheckCond() then return end
			ArgumentTable["addr_mode"] = GetBinary(1,1) == "1" and "IA" or "DB"
			GetRegister("rn")
			CheckSuffix("!")
			local regtable = {}			
			for i = 1,10 do
				local Reg = GetRegister()
				if Reg then
					table.insert(regtable,Reg)
					continue
				end
			end
			ArgumentTable.reglist = regtable
		elseif Opcode == "ADR" then
			if not CheckCond() then return end
			GetRegister("Rd")
			ArgumentTable.label = GetSignedDecimal(GetBinary(1,12))
		elseif (Opcode == "ADD" or Opcode == "SUB" or Opcode == "ADC" or Opcode == "SBC" or Opcode == "RSB") then
			-- 000111 0 01000 01000  10011 001 1111111
			-- 000000 0 00000 00000  00000 000 0000000
			-- ^^^^^^ ^ ^^^^^ ^^^^^  ^^^^^ ^^^ ^^^^^^^
			-- Opcode, S, Rd, Rn, Operand2(Register, Shift, ShiftAmount)

			if not CheckCond() then return end
			CheckSuffix("S")
			GetRegister("Rd")
			GetRegister("Rn")
			if (Opcode == "ADD" or Opcode == "SUB") and not CheckIfRegister() then
				ArgumentTable.imm12 = GetBinary(1,12)
			else
				ArgumentTable.Operand2 = DecodeOperand2()
			end
		end
		-- Execute:
		print("EXECUTE")
		Instruction(ArgumentTable) -- Execute Instruction
		Registers["r15"] = DecimalTo32BitBinary(tonumber(Registers["r15"],2)+1) -- Increment Program Counter
		return -- Exit
	end

	DoCycle()
end 
