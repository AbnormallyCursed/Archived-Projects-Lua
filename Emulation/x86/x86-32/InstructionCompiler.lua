local Module = {}
local InstructionDefinitions = require(script.InstructionList)

-- This is probably where we'll have the least efficiency, making the mother of all omlettes here jack: can't fret over every egg
local register_conv = {
	["EAX"] = 0,
	["EDI"] = 1,
	["ESI"] = 2,
	["EBP"] = 3,
	["ESP"] = 4,
	["EBX"] = 5,
	["EDX"] = 6,
	["ECX"] = 7,
	["AL"] = 0,
	["BH"] = 1,
	["DH"] = 2,
	["CH"] = 3,
	["AH"] = 4,
	["BL"] = 5,
	["DL"] = 6,
	["CL"] = 7,
	["AX"] = 0,
	["DI"] = 1,
	["SI"] = 2,
	["BP"] = 3,
	["SP"] = 4,
	["BX"] = 5,
	["DX"] = 6,
	["CX"] = 7,
}

function Module:CompileInstructions(InstructionFolder: Folder, MultiByteFolder: Folder)
	local Tables = require(script["x86 Tables"]):GetTables()
	local InstructionList = require(script.InstructionList)
	local Overrides = require(script.overrides)
	local CacheTable = {}
	local CTR = 0
	local CTR2 = 0
	
	-- For possible future 64-bit implementation: ReadOperand already supports 64 bit (but they are implemented as RESERVED)
	local function ReadOperand(Operand: string, n: number, HasModRM: boolean?)
		if CacheTable[Operand] then
			return CacheTable[Operand]
		end
		
		local OperandType
		local AddressingMethod
		local Part1, Part2 = string.match(Operand, "(%l+)(%u+)")
		local OperandNumberSize = 0
		
		if Part1 == nil then
			Part1, Part2 = string.match(Operand, "(%u+)(%l+)")
			OperandType = Part2
			AddressingMethod = Part1
		else
			OperandType = Part1
			AddressingMethod = Part2
		end
		
		if AddressingMethod == nil or OperandType == nil then
			return
		end
		CTR += 1
		
		-- Simple Size Decoding:
		-- !!! STRING ON LEFT IS LOAD STRING ON RIGHT IS STORE !!! -- ( if the value is a string, it is how the operand size is retrieved)
		if OperandType == "b" then
			OperandNumberSize = 8
		elseif OperandType == "bs" then
			OperandNumberSize = 8
		elseif OperandType == "bss" then -- byte sign extended to the size of the SP
			OperandNumberSize = 8
		elseif OperandType == "bcd" then
			OperandNumberSize = 8
		elseif OperandType == "w" then
			OperandNumberSize = 16
		elseif OperandType == "wi" then
			OperandNumberSize = 16
		elseif OperandType == "vs" then -- sign extended to the size of the stack pointer??
			OperandNumberSize = "self:GetSizeOSA()"
		elseif OperandType == "v" then
			OperandNumberSize = "self:GetSizeOSA()"
		elseif OperandType == "vds" then -- sign extended to 64 bits for 64 bit operand size
			OperandNumberSize = "self:GetSizeOSA()" 
		elseif OperandType == "d" then
			OperandNumberSize = 32
		elseif OperandType == "di" then
			OperandNumberSize = 32
		elseif OperandType == "a" then
			warn("illegal operand type: ", OperandType) -- BOUND
		elseif OperandType == "c" then
			-- UNUSED
		elseif OperandType == "dqp" then
			-- Doubleword, or quadword, promoted by REX.W in 64-bit mode (for example, MOVSXD).
			--  	Added; combines d and qp
			OperandNumberSize = "self.PrefixTable[0x48] == true and 64 or 32"
		elseif OperandType == "dr" then
			-- Added 	Double-real. Only x87 FPU instructions (for example, FADD).
			OperandNumberSize = 32 -- I guess??
		elseif OperandType == "ds" then
			-- Doubleword, sign-extended to 64 bits (for example, CALL (E8).
			OperandNumberSize = 32 -- We don't really have sign extension :D
		elseif OperandType == "dq" then
			OperandNumberSize = 128
			warn("DQ COMPILED, DQ IS ILLEGAL AT THE CURRENT TIME")
		elseif OperandType == "e" then
			OperandNumberSize = 28
			-- x87 FPU environment (for example, FSTENV).
		elseif OperandType == "er" then
			-- Extended-real. Only x87 FPU instructions (for example, FLD).
			OperandNumberSize = 32 -- I have no idea what extended real means
		elseif OperandType == "p" then
			-- 32-bit or 48-bit pointer, depending on operand-size attribute (for example, CALLF (9A).
			OperandNumberSize = "self:GetSizeOSA() == 16 and 32 or 48"
		elseif OperandType == "pi" then
			-- Quadword MMX technology data. 
			OperandNumberSize = 64
		elseif OperandType == "pd" then
			-- 128-bit packed double-precision floating-point data.
			OperandNumberSize = 128
		elseif OperandType == "ps" then
			-- 128-bit packed single-precision floating-point data.
			OperandNumberSize = 128
		elseif OperandType == "psq" then
			-- 64-bit packed single-precision floating-point data.
			OperandNumberSize = 64
		elseif OperandType == "pt" then
			-- (80-bit far pointer.)
			OperandNumberSize = 80
		elseif OperandType == "ptp" then
			-- 32-bit or 48-bit pointer, depending on operand-size attribute, or 80-bit far pointer, promoted by REX.W in 64-bit mode (for example, CALLF (FF /3)). 
			OperandNumberSize = "self.PrefixTable[0x48] == true and (self:GetSizeOSA() == 16 and 32 or 48) or 80"
		elseif OperandType == "q" then
			OperandNumberSize = 64
			-- Quadword, regardless of operand-size attribute (for example, CALL (FF /2)). 
		elseif OperandType == "qi" then
			-- Qword-integer. Only x87 FPU instructions (for example, FILD).
			OperandNumberSize = 64
		elseif OperandType == "qp" then
			-- Quadword, promoted by REX.W (for example, IRETQ).
			OperandNumberSize = 64
		elseif OperandType == "s" then
			-- 6-byte pseudo-descriptor, or 10-byte pseudo-descriptor in 64-bit mode (for example, SGDT).
			OperandNumberSize = 48
		elseif OperandType == "sd" then
			-- Scalar element of a 128-bit packed double-precision floating data.
			OperandNumberSize = 128
		elseif OperandType == "si" then
			-- Doubleword integer register (e. g., eax). (unused even by Intel?)
			OperandNumberSize = 128
		elseif OperandType == "sr" then
			-- Single-real. Only x87 FPU instructions (for example, FADD).
			warn("illegal operand type: ", OperandType)
			OperandNumberSize = 32 -- wtf is this
		elseif OperandType == "ss" then
			-- Scalar element of a 128-bit packed single-precision floating data.
			OperandNumberSize = 64
		elseif OperandType == "st" then
			-- x87 FPU state (for example, FSAVE).
			warn("illegal operand type: ", OperandType)
			OperandNumberSize = 64 -- WHAT IS THIS AGHHHHHHHHHHHHHHHHHHHH
		elseif OperandType == "stx" then
			-- x87 FPU and SIMD state (FXSAVE and FXRSTOR).
			warn("illegal operand type: ", OperandType) 
			OperandNumberSize = 64 -- THE AGONIZING PAIN WHAT THE FUCK IS THIS
		elseif OperandType == "t" then
			-- 10-byte far pointer.
			OperandNumberSize = 80
		elseif OperandType == "vq" then
			-- Quadword (default) or word if operand-size prefix is used (for example, PUSH (50)).
			OperandNumberSize = "self.PrefixTable[0x66] == true and 64 or 16"
		elseif OperandType == "vqp" then
			-- Word or doubleword, depending on operand-size attribute, or quadword, promoted by REX.W in 64-bit mode.
			OperandNumberSize = "self.PrefixTable[0x48] == true and (self:GetSizeOSA()) or 64"
		elseif OperandType == "va" then
			OperandNumberSize = "self:GetSizeASA()"
		elseif OperandType == "dqa" then
			OperandNumberSize = "self:GetSizeASA() == 16 and 32 or 64"
		elseif OperandType == "wa" then
			OperandNumberSize = 16
		elseif OperandType == "wo" then
			-- ok so the OSA or like literally the operand's size??
			OperandNumberSize = "self:GetSizeOSA()"
		elseif OperandType == "ws" then
			warn("illegal operand type: ", OperandType) 
			OperandNumberSize = 32
		elseif OperandType == "da" then
			OperandNumberSize = 32
		elseif OperandType == "do" then
			OperandNumberSize = 32
		elseif OperandType == "qa" then
			OperandNumberSize = 64
		elseif OperandType == "qs" then
			OperandNumberSize = 64
		else
			error("[FATAL] Invalid Operand Type: ".. OperandType)
		end
		
		print("Compiling Operand: ", AddressingMethod, OperandType)
		local OperandFetch = "local Size"..n.." = "
		local OperandIsFunctionBased = type(OperandNumberSize) == "string"
		OperandFetch ..= OperandNumberSize..[[
		self:select(]]..n..", Size"..n..[[)
		%s

]]
		
		local OperandSET, OperandGET
		
		local function AddModRM() -- No support for multiple MOD R/M bytes, doesn't exist in x86 anyways pretty sure
			if not HasModRM then
				OperandFetch = OperandFetch:format("local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()")
				HasModRM = true
			end
		end
		
		-- Addressing Method:
		if AddressingMethod == "A" then
			OperandGET = "self:load(".."self:loadnext"..n.."()"..")"
			OperandSET = "self:store(".."self:loadnext"..n.."(),".." __VALUE__)"
		elseif AddressingMethod == "BA" then
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "BB" then
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "BD" then
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "C" then
			AddModRM()
			OperandGET = "self.cregs[REG]"
			OperandSET = "self.cregs[REG] = __VALUE__"
		elseif AddressingMethod == "D" then
			AddModRM()
			OperandGET = "self.dregs[REG]"
			OperandSET = "self.dregs[REG] = __VALUE__"
		elseif AddressingMethod == "E" then
			AddModRM()
			OperandGET = "ISREG and self.reg[REG] or self:load(MODRM)"
			OperandSET = [[
			if ISREG then
			    self.reg[REG] = __VALUE__
			else
			    self:store(MODRM, __VALUE__)
			end
			]]
		elseif AddressingMethod == "ES" then
			AddModRM()
			OperandGET = "ISREG and self.freg[REG] or self:load(MODRM)"
			OperandSET = [[
			if ISREG then
			    self.freg[REG] = __VALUE__
			else
			    self:store(MODRM, __VALUE__)
			end
			]]
		elseif AddressingMethod == "EST" then
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
			-- (Implies original E). A ModR/M byte follows the opcode and specifies the x87 FPU stack register. 
		elseif AddressingMethod == "F" then
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
			-- rFLAGS register
		elseif AddressingMethod == "G" then
			AddModRM()
			OperandGET = "self.reg[REG]"
			OperandSET = "self.reg[REG] = __VALUE__"
		elseif AddressingMethod == "H" then
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
			-- ??? The r/m field of the ModR/M byte always selects a general register, regardless of the mod field (for example, MOV (0F20)).
			-- shrimply not possible rn
		elseif AddressingMethod == "I" then
			OperandGET = "self:loadnext"..n.."()"
			OperandSET = "error('illegal')"
		elseif AddressingMethod == "J" then
			OperandGET = "self:loadnext"..n.."()"
			OperandSET = "error('illegal')"
		elseif AddressingMethod == "M" then
			AddModRM()
			OperandGET = "self:load(MODRM)"
			OperandSET = "self:store(MODRM, __VALUE__)"
		elseif AddressingMethod == "N" then
			-- The R/M field of the ModR/M byte selects a packed quadword MMX technology register.
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "O" then -- this one may need to be modified a lot
			OperandGET = "self:loadnext"..n.."()"
			OperandSET = "error('illegal')"
		elseif AddressingMethod == "P" then
			-- The reg field of the ModR/M byte selects a packed quadword MMX technology register.
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "Q" then
			-- A ModR/M byte follows the opcode and specifies the operand. The operand is either an MMX technology register or a memory address. If it is a memory address, the address is computed from a segment register and any of the following values: a base register, an index register, a scaling factor, and a displacement.
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "R" then
			-- The reg field of the ModR/M byte selects a packed quadword MMX technology register.
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "S" then
			AddModRM()
			-- The reg field of the ModR/M byte selects a segment register (only MOV (8C, 8E)).
			OperandGET = "self.sreg[REG]"
			OperandSET = "self.sreg[REG] = __VALUE__"
		elseif AddressingMethod == "SC" then
			--Stack operand, used by instructions which either push an operand to the stack or pop an operand from the stack. 
			--Pop-like instructions are, for example, POP, RET, IRET, LEAVE. Push-like are, for example, PUSH, CALL, INT. 
			--No Operand type is provided along with this method because it depends on source/destination operand(s).
			
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal")
		elseif AddressingMethod == "T" then
			AddModRM()
			-- The reg field of the ModR/M byte selects a test register (only MOV (0F24, 0F26)).
			OperandGET = "self.treg[REG]"
			OperandSET = "self.treg[REG] = __VALUE__"
		elseif AddressingMethod == "U" then
			AddModRM()
			OperandGET = "self.xmmreg[MODRM]"
			OperandSET = "self.xmmreg[MODRM] = __VALUE__"
		elseif AddressingMethod == "V" then
			AddModRM()
			OperandGET = "self.xmmreg[REG]"
			OperandSET = "self.xmmreg[REG] = __VALUE__"
		elseif AddressingMethod == "W" then
			AddModRM()
			OperandGET = "ISREG and self.xmmreg[REG] or self:load(MODRM)"
			OperandSET = [[
			if ISREG then
			    self.xmmreg[REG] = __VALUE__
			else
			    self:store(MODRM, __VALUE__)
			end
			]]
		elseif AddressingMethod == "X" then
			--Memory addressed by the DS:eSI or by RSI (only MOVS, CMPS, OUTS, and LODS). In 64-bit mode, only 64-bit (RSI) and 32-bit (ESI)
			--address sizes are supported. In non-64-bit modes, only 32-bit (ESI) and 16-bit (SI) address sizes are supported.
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "Y" then
			--Memory addressed by the ES:eDI or by RDI (only MOVS, CMPS, INS, STOS, and SCAS). In 64-bit mode, only 64-bit (RDI)
			--and 32-bit (EDI) address sizes are supported. In non-64-bit modes, only 32-bit (EDI) and 16-bit (DI) address sizes are 
			--supported. The implicit ES segment register cannot be overriden by a segment prefix.
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)
		elseif AddressingMethod == "Z" then
			-- The instruction has no ModR/M byte; the three least-significant bits of the opcode byte selects a general-purpose register
			OperandGET = "error('illegal')"
			OperandSET = "error('illegal')"
			warn("illegal addressing method:", AddressingMethod)			
		else
			print(AddressingMethod)
			local target = register_conv[AddressingMethod]
			if target ~= nil then
				OperandGET = "self.reg["..tostring(target).."]"
				OperandSET = "self.reg["..tostring(target).."] = __VALUE__"
				return HasModRM, OperandGET, OperandSET
			end
			error("[FATAL] Invalid Addressing Method: "..AddressingMethod)
		end
		
		--print("Addressing Method:", AddressingMethod, "Operand Type:", OperandType)
		return HasModRM, OperandGET, OperandSET, OperandFetch
	end
	local mnemonic_list = {}
	
	local function ReadInsTable(Tbl)
		local ResultTable = {}
		local ResultPointer = 0
		print("[*] x86 Instruction Compiler, Reading Instruction Table")
		
		for _,Instruction in Tbl do
			-- Operand READ:
			print("[*] Operand READ...")
			if Instruction.po == "" or (Overrides[Instruction.po] or Overrides.multi_byte[Instruction.po]) then
				continue
			end
			
			CTR2 += 1
			
			-- Checking how many operands are in the instruction:
			local p_Op1 = Instruction.op1 ~= ""
			local p_Op2 = Instruction.op2 ~= ""
			local p_Op3 = Instruction.op3 ~= ""
			local p_Op4 = Instruction.op4 ~= ""
			-- Defining Operand Fetch Functions:
			local f_Op1 = {ReadOperand(Instruction.op1, 1, false)}
			local f_Op2 = {ReadOperand(Instruction.op2, 2, f_Op1[1])}
			local f_Op3 = {ReadOperand(Instruction.op3, 3, f_Op1[1] or f_Op1[2])}
			local f_Op4 = {ReadOperand(Instruction.op4, 4, f_Op1[1] or f_Op1[2] or f_Op1[3])}
			local Operands = {f_Op1, f_Op2, f_Op3, f_Op4}
			
			local InstructionDefinition: string = InstructionList[Instruction.mnemonic]
			if not InstructionDefinition then
				warn("[WARNING] The Instruction Definition for: "..Instruction.mnemonic.." has not been implemented")
				continue
			end
			local Header = ""
			
			print("[*] Assembling Instruction...")
			for n,v in Operands do
				if v[1] == nil or v[4] == nil or v[3] == nil then
					continue
				end
				Header ..= v[4]
				local SET_Complete = "__OPERAND"..n.."_SET__"
				local GET_Complete = "__OPERAND"..n.."_GET__"
				InstructionDefinition = string.gsub(InstructionDefinition, GET_Complete, v[2])
				
				if string.find(InstructionDefinition, SET_Complete) then
					local SetProtocol = v[3]
					local Target = InstructionDefinition:match(SET_Complete..": (.*) ;")
					SetProtocol = SetProtocol:gsub("__VALUE__", Target)
					InstructionDefinition = string.gsub(InstructionDefinition, SET_Complete..": (.*) ;", SetProtocol)
				else
					warn("[WARNING] UNUSED OPERAND "..n.." DUMP:")
					print(Operands)
					print(Instruction)
				end
			end
			
			if InstructionDefinition:find("__OPERAND") then
				warn("attempted to set incomplete instruction definition, data:")
				warn(InstructionDefinition)
				warn("x86-32: "..Instruction.op1, Instruction.op2, Instruction.op3, Instruction.op4)
				print(Operands)
				print("[*] Instruction Assembly Failure, branching to next instruction")
				continue
		    end
			Header = Header:gsub("%%s","")
			print("[*] Assembled Successfully")
			ResultTable[ResultPointer] = Header..[[
			
			]]..InstructionDefinition
			if mnemonic_list[Instruction.mnemonic] == nil then
				mnemonic_list[Instruction.mnemonic] = {}
			end
			mnemonic_list[Instruction.mnemonic][Instruction.po] = ResultTable[ResultPointer]
			ResultPointer += 1
		end
		
		print("[*] Instruction Table Parsing Complete")
		return ResultTable
	end
	
	InstructionFolder:ClearAllChildren()
	warn("[main] Reading Single Byte...")
	local ResultTable = ReadInsTable(Tables.SingleByte)
	print("[main] Instruction Compilation Complete")
	print("[main] Generating x86 Instruction Files...")
	
	print("[main] done, successfully compiled:")
	print(CTR, "operands")
	print(CTR2, "instructions")
	assert(game:GetService('RunService'):IsStudio(), "THIS SECTION MUST BE RUN IN STUDIO")
	
	for title,v in mnemonic_list do
		local Module = Instance.new("ModuleScript")
		Module.Name = title
		Module.Parent = InstructionFolder
		Module.Source = "return {"
		for Opcode, InstructionString in v do
			Module.Source ..= "[0x"..Opcode.."] = function(self)\n"..InstructionString.."\nend,\n"
		end
		Module.Source ..= "}"
	end
	
end

return Module
