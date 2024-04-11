local Module = {}
local RunServ = game:GetService("RunService")
local type = type
local AsDict = {
	EXCEPTION_MISALIGNED_FETCH = 0,
	EXCEPTION_FAULT_FETCH = 1,
	EXCEPTION_ILLEGAL_INSTRUCTION = 2,
	EXCEPTION_BREAKPOINT = 3,
	EXCEPTION_MISALIGNED_LOAD = 4,
	EXCEPTION_FAULT_LOAD = 5,
	EXCEPTION_MISALIGNED_STORE = 6,
	EXCEPTION_FAULT_STORE = 7,
	EXCEPTION_USER_ECALL = 8,
	EXCEPTION_SUPERVISOR_ECALL = 9,
	EXCEPTION_HYPERVISOR_ECALL = 10,
	EXCEPTION_MACHINE_ECALL = 11,
	EXCEPTION_FETCH_PAGE_FAULT = 12,
	EXCEPTION_LOAD_PAGE_FAULT = 13,
	EXCEPTION_STORE_PAGE_FAULT = 15
}

function Module:CreateCore(CoreList)
	local RegisterSet = {
		-- RX
		[0] = 0,
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0,
		[9] = 0,
		[10] = 0,
		[11] = 0,
		[12] = 0,
		[13] = 0,
		[14] = 0,
		[15] = 0,
		[16] = 0,
		[17] = 0,
		[18] = 0,
		[19] = 0,
		[20] = 0,
		[21] = 0,
		[22] = 0,
		[23] = 0,
		[24] = 0,
		[25] = 0,
		[26] = 0,
		[27] = 0,
		[28] = 0,
		[29] = 0,
		[30] = 0,
		[31] = 0,
		-- EX
		[32] = 0,
		[33] = 0,
		[34] = 0,
		[35] = 0,
		[36] = 0,
		[37] = 0,
		[38] = 0,
		[39] = 0,
		[40] = 0,
		[41] = 0,
		[42] = 0,
		[43] = 0,
		[44] = 0,
		[45] = 0,
		[46] = 0,
		[47] = 0,
		[48] = 0,
		[49] = 0,
		[50] = 0,
		[51] = 0,
		[52] = 0,
		[53] = 0,
		[54] = 0,
		[55] = 0,
		[56] = 0,
		[57] = 0,
		[58] = 0,
		[59] = 0,
		[60] = 0,
		[61] = 0,
		[62] = 0,
		[63] = 0,
		-- X
		[64] = 0,
		[65] = 0,
		[66] = 0,
		[67] = 0,
		[68] = 0,
		[69] = 0,
		[70] = 0,
		[71] = 0,
		[72] = 0,
		[73] = 0,
		[74] = 0,
		[75] = 0,
		[76] = 0,
		[77] = 0,
		[78] = 0,
		[79] = 0,
		[80] = 0,
		[81] = 0,
		[82] = 0,
		[83] = 0,
		[84] = 0,
		[85] = 0,
		[86] = 0,
		[87] = 0,
		[88] = 0,
		[89] = 0,
		[90] = 0,
		[91] = 0,
		[92] = 0,
		[93] = 0,
		[94] = 0,
		[95] = 0,
		-- L
		[96] = 0,
		[97] = 0,
		[98] = 0,
		[99] = 0,
		[100] = 0,
		[101] = 0,
		[102] = 0,
		[103] = 0,
		[104] = 0,
		[105] = 0,
		[106] = 0,
		[107] = 0,
		[108] = 0,
		[109] = 0,
		[110] = 0,
		[111] = 0,
		[112] = 0,
		[113] = 0,
		[114] = 0,
		[115] = 0,
		[116] = 0,
		[117] = 0,
		[118] = 0,
		[119] = 0,
		[120] = 0,
		[121] = 0,
		[122] = 0,
		[123] = 0,
		[124] = 0,
		[125] = 0,
		[126] = 0,
		[127] = 0,
		-- CR
		[128] = 0,
		[129] = 0,
		[130] = 0,
		[131] = 0,
		[132] = 0,
		[133] = 0,
		[134] = 0,
		[135] = 0,
		[136] = 0,
		[137] = 0,
		[138] = 0,
		[139] = 0,
		[140] = 0,
		[141] = 0,
		[142] = 0,
		[143] = 0,
		-- XMM
		[144] = 0,
		[145] = 0,
		[146] = 0,
		[147] = 0,
		[148] = 0,
		[149] = 0,
		[150] = 0,
		[151] = 0,
		[152] = 0,
		[153] = 0,
		[154] = 0,
		[155] = 0,
		[156] = 0,
		[157] = 0,
		[158] = 0,
		[159] = 0,
		-- Special:
		[160] = 1, -- Program Counter (PC)
		[161] = 0, -- Stack Pointer (SP)
		[162] = 0, -- Stack Base Pointer (RBP)
		-- The rest of the registers for x86 are encoded as one of the general purpose registers
		[163] = 0,
		[164] = 0,
		[165] = 0,
	}
	
	self.REGISTERS = RegisterSet
	self.PC = RegisterSet[160]
	
	local ALU_Flags = {}
	ALU_Flags.CF = false
	ALU_Flags.ZF = false
	ALU_Flags.SF = false
	ALU_Flags.OF = false
	self.FFLAGS = ALU_Flags
	
	local CoreControlSelectedCore = 2
	
	function self:RaiseException(Name: string, Vector: number)
		if Name == "SoftwareInterrupt" then
			self:Push(self.PC)
			self.PC = Vector
		elseif Name == "OverflowTrap" then
			print("Attempd to raise Overflow Trap Exception")
		elseif Name == "DebugTrap" then
			print("Attempd to raise Debug Trap Exception")
		elseif Name == "CoreControl" then -- Multi-Core-Control
			local Code = bit32.extract(Vector, 30, 2) -- First two bits of a 32 bit binary string
			local Data = bit32.extract(Vector, 0, 29) -- the rest of the bits
			
			if Code == 0 then -- Core Select
				CoreControlSelectedCore = Data
			elseif Code == 1 then -- Set Program Counter
				local Core = CoreList[CoreControlSelectedCore]
				Core.REGISTERS[160] = Core.REGISTERS[Data]
				Core.PC = Core.REGISTERS[Data]
			elseif Code == 2 then
				local Core = CoreList[CoreControlSelectedCore]
				if Data == 0 then
					Core:halt()
				else
					Core:start()
				end
			elseif Code == 3 then
				return #CoreList
			end
		else
			self:Push(AsDict[Name] or 16)
			self.PC = 0
		end
	end
	
	local function Catch(ExceptionName, Callback)
		local s = false
		local ret
		
		pcall(function()
			ret = Callback()
			s = true
		end)
		if s == false then
			self:RaiseException(ExceptionName)
		end
		
		return ret
	end
	
	function self:load(Address)
		return self:MemoryBusLOAD(Address)
	end
	
	function self:store(Address, Value)
		Catch("EXCEPTION_FAULT_STORE", function()
			self:MemoryBusSTORE(Address, Value)
		end)
	end
	
	function self:ReportToALU(Operand, Result)
		ALU_Flags.CF = false
		ALU_Flags.ZF = false
		ALU_Flags.SF = false
		ALU_Flags.OF = false
		if Result >= 2^63 or Result < -2^63 then
			ALU_Flags.OF = true
		end
		if Result >= 2^64 then
			ALU_Flags.CF = true
		end
		if Result == 0 then
			ALU_Flags.ZF = true
		end
		if Result < 0 then
			ALU_Flags.SF = true
		end
	end

	function self:CheckCOND(Condition)
		local Result = false
		if Condition == 0 then -- if overflow (O)
			Result = ALU_Flags.OF
		elseif Condition == 1 then -- NO: if not overflow
			Result = ALU_Flags.OF == false
		elseif Condition == 2 then -- S: if sign
			Result = ALU_Flags.SF
		elseif Condition == 3 then -- NS: if not sign
			Result = ALU_Flags.SF == false
		elseif Condition == 4 then -- E: if equal / if zero (Z)
			Result = ALU_Flags.ZF
		elseif Condition == 5 then -- NE: if not equal
			Result = ALU_Flags.ZF == false
		elseif Condition == 6 then -- C: if carry
			Result = ALU_Flags.CF
		elseif Condition == 7 then -- NC: if not carry
			Result = ALU_Flags.CF == false
		elseif Condition == 8 then -- BE: if below or equal 
			Result = ALU_Flags.CF == true or ALU_Flags.ZF == true
		elseif Condition == 9 then -- NBE: if not below or equal
			Result = ALU_Flags.CF == false and ALU_Flags.ZF == false
		elseif Condition == 10 then -- NGE: if not greater or equal 
			Result = ALU_Flags.SF ~= ALU_Flags.OF
		elseif Condition == 11 then -- GE: if greater or equal 
			Result = ALU_Flags.SF == ALU_Flags.OF
		elseif Condition == 12 then -- LE: if less or equal
			Result = ALU_Flags.ZF == true or ALU_Flags.SF ~= ALU_Flags.OF
		elseif Condition == 13 then -- NLE: if not less or equal
			Result = ALU_Flags.ZF == false and ALU_Flags.SF == ALU_Flags.OF
		elseif Condition == 14 then -- P: if parity
			Result = ALU_Flags.PF
		elseif Condition == 15 then -- NP: if not parity
			Result = ALU_Flags.PF == false
		end
		return Result
	end
	
	function self:Push(Value: number)
		RegisterSet[162]-=1
		self:store(RegisterSet[162], Value)
	end
	
	function self:Pop()
		local Result = self:load(RegisterSet[162])
		RegisterSet[162]+=1
		return Result
	end
	
	function self:step()
		local Opcode = Catch("EXCEPTION_FAULT_FETCH", function()
			local opc = self:load(self.PC)
			assert(type(opc) == "number")
			return opc
		end)
		if Opcode == 0 then -- NOP
			warn("NOP")
			self.PC += 1
			RegisterSet[160] += 1
			return
		end
		Catch("EXCEPTION_ILLEGAL_INSTRUCTION", function()
			self.InstructionIndex[Opcode]()
			RegisterSet[160] = self.PC
		end)
	end
	
	local Connection: RBXScriptConnection
	
	function self:start()
		Connection = RunServ.Heartbeat:Connect(function()
			wait(1)
			self:step()
		end)
	end
	
	function self:halt()
		Connection:Disconnect()
	end
	
	return self
end

function Module:CreateCPU(CoreCount: number)
	local CoreList = {}
	
	for i = 1, CoreCount do
		local NewCore = Module:CreateCore(CoreList)
		CoreList[i] = NewCore
	end
	
	return CoreList[1]
end

return Module
