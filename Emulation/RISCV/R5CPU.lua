-- RISC-V Emulator: AbnormallyCursed, 8/30/2023 - 9/26/2023
-- THIS FILE HAS BEEN MODIFIED FOR GITHUB RELEASE.
-- At the time of writing we will likely want to implement our own bitwise functions to support 64 bit operations.
-- Perhaps RV64I instruction results need to be typecasted to int

local Module = {}
local BinUtils = require(script.Parent["Binary Utilities"])
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

-- General Math & Bitwise Utilities
local function AND(Operand1, Operand2)
	local Op1Size = GetMinimumBitSize(Operand1)
	local Op2Size = GetMinimumBitSize(Operand2)
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
end

local function OR(Operand1, Operand2)
	local Op1Size = GetMinimumBitSize(Operand1)
	local Op2Size = GetMinimumBitSize(Operand2)
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
end

local function XOR(Operand1, Operand2)
	local Op1Size = GetMinimumBitSize(Operand1)
	local Op2Size = GetMinimumBitSize(Operand2)
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
end

local function NOT(Operand1, Operand2)
	local Op1Size = GetMinimumBitSize(Operand1)
	local Op2Size = GetMinimumBitSize(Operand2)
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
end

local function SAR(Operand1, Operand2)
	local Op1Size = GetMinimumBitSize(Operand1)
	local Op2Size = GetMinimumBitSize(Operand2)
	local n = Operand1

	for i = 1, Operand2 do
		n = SignedTypeCast(Op1Size, n / 2)
	end

	return n
end

local function SHR(Operand1, Operand2)
	local Op1Size = GetMinimumBitSize(Operand1)
	local Op2Size = GetMinimumBitSize(Operand2)
	local n = Operand1

	for i = 1, Operand2 do
		n = UnsignedTypeCast(Op1Size, n / 2)
	end

	return n
end

local function SAL(Operand1, Operand2)
	local Op1Size = GetMinimumBitSize(Operand1)
	local Op2Size = GetMinimumBitSize(Operand2)
	local n = Operand1

	for i = 1, Operand2 do
		n = SignedTypeCast(Op1Size, n * 2)
	end

	return n
end

local function SHL(Operand1, Operand2)
	local Op1Size = GetMinimumBitSize(Operand1)
	local Op2Size = GetMinimumBitSize(Operand2)
	local n = Operand1

	for i = 1, Operand2 do
		n = UnsignedTypeCast(Op1Size, n * 2)
	end

	return n
end

local LSHIFT = function(op1, op2)

end

local RSHIFT = function()

end

local ARSHIFT = function()

end

local BOR = function()

end

local BAND = function()

end

local ONEC = function()

end

local ABS = function()

end

-- R5 Constant Data
-- AbnormallyCursed, 8/30/2023

local function maskFromRange(bitFrom, bitUntil)
	return LSHIFT(( LSHIFT(1, (bitUntil - bitFrom + 1)) - 1), bitFrom)
end

XLEN_32 = 32
XLEN_64 = 64

-- Privlege Levels
PRIVILEGE_U = 0 -- User
PRIVILEGE_S = 1 -- Supervisor
PRIVILEGE_H = 2 -- Hypervisor
PRIVILEGE_M = 3 -- Machine

-- Software Interrupts
USIP_SHIFT = 0 -- User
SSIP_SHIFT = 1 -- Supervisor
HSIP_SHIFT = 2 -- Hypervisor
MSIP_SHIFT = 3 -- Machine

-- Timer Interrupts
UTIP_SHIFT = 4 -- User
STIP_SHIFT = 5 -- Supervisor
HTIP_SHIFT = 6 -- Hypervisor
MTIP_SHIFT = 7 -- Machine

-- External interrupts
UEIP_SHIFT = 8 -- User
SEIP_SHIFT = 9 -- Supervisor
HEIP_SHIFT = 10 -- Hypervisor
MEIP_SHIFT = 11 -- Machine

-- Interrupt masks for mip/mideleg CSRs
USIP_MASK = LSHIFT(0b1, USIP_SHIFT)
SSIP_MASK = LSHIFT(0b1, SSIP_SHIFT)
HSIP_MASK = LSHIFT(0b1, HSIP_SHIFT)
MSIP_MASK = LSHIFT(0b1, MSIP_SHIFT)
UTIP_MASK = LSHIFT(0b1, UTIP_SHIFT)
STIP_MASK = LSHIFT(0b1, STIP_SHIFT)
HTIP_MASK = LSHIFT(0b1, HTIP_SHIFT)
MTIP_MASK = LSHIFT(0b1, MTIP_SHIFT)
UEIP_MASK = LSHIFT(0b1, UEIP_SHIFT)
SEIP_MASK = LSHIFT(0b1, SEIP_SHIFT)
HEIP_MASK = LSHIFT(0b1, HEIP_SHIFT)
MEIP_MASK = LSHIFT(0b1, MEIP_SHIFT)

-- Machine status (mstatus[h]) CSR masks and offsets
STATUS_UIE_SHIFT = 0 -- U-mode interrupt-enable bit
STATUS_SIE_SHIFT = 1 -- S-mode interrupt-enable bit
STATUS_MIE_SHIFT = 3 -- M-mode interrupt-enable bit
STATUS_UPIE_SHIFT = 4 -- Prior U-mode interrupt-enabled bit.
STATUS_SPIE_SHIFT = 5 -- Prior S-mode interrupt-enabled bit.
STATUS_UBE_SHIFT = 6 -- U-mode fetch/store endianness (0 = little, 1 = big).
STATUS_MPIE_SHIFT = 7 -- Prior M-mode interrupt-enabled bit.
STATUS_SPP_SHIFT = 8 -- Prior S-mode privilege mode.
STATUS_MPP_SHIFT = 11 -- Prior M-mode privilege mode.
STATUS_FS_SHIFT = 13 -- Floating point unit status.
STATUS_XS_SHIFT = 15 -- User-mode extension status.
STATUS_MPRV_SHIFT = 17 -- Modify PRiVilege.
STATUS_SUM_SHIFT = 18 -- Permit Supervisor User Memory access.
STATUS_MXR_SHIFT = 19 -- Make eXecutable Readable.
STATUS_TVM_SHIFT = 20 -- Trap Virtual Memory
STATUS_TW_SHIFT = 21 -- Timeout Wait
STATUS_TSR_SHIFT = 22 -- Trap SRET
STATUS_UXL_SHIFT = 32 -- User mode XLEN
STATUS_SXL_SHIFT = 34 -- Supervisor mode XLEN
STATUS_SBE_SHIFT = 36 -- Supervisor mode endianness (0 = little, 1 = bit)
STATUS_MBE_SHIFT = 37 -- Machine mode endianness (0 = little, 1 = bit)
STATUS_SD_SHIFT = 63 -- State Dirty

STATUS_UIE_MASK = LSHIFT(1, STATUS_UIE_SHIFT)
STATUS_SIE_MASK = LSHIFT(1, STATUS_SIE_SHIFT)
STATUS_MIE_MASK = LSHIFT(1, STATUS_MIE_SHIFT)
STATUS_UPIE_MASK = LSHIFT(1, STATUS_UPIE_SHIFT)
STATUS_SPIE_MASK = LSHIFT(1, STATUS_SPIE_SHIFT)
STATUS_UBE_MASK = LSHIFT(1, STATUS_UBE_SHIFT)
STATUS_MPIE_MASK = LSHIFT(1, STATUS_MPIE_SHIFT)
STATUS_SPP_MASK = LSHIFT(1, STATUS_SPP_SHIFT)
STATUS_MPP_MASK = LSHIFT(0b11, STATUS_MPP_SHIFT)
STATUS_FS_MASK = LSHIFT(0b11, STATUS_FS_SHIFT)
STATUS_XS_MASK = LSHIFT(0b11, STATUS_XS_SHIFT)
STATUS_MPRV_MASK = LSHIFT(1, STATUS_MPRV_SHIFT)
STATUS_SUM_MASK = LSHIFT(1, STATUS_SUM_SHIFT)
STATUS_MXR_MASK = LSHIFT(1, STATUS_MXR_SHIFT)
STATUS_TVM_MASK = LSHIFT(1, STATUS_TVM_SHIFT)
STATUS_TW_MASK = LSHIFT(1, STATUS_TW_SHIFT)
STATUS_TSR_MASK = LSHIFT(1, STATUS_TSR_SHIFT)
STATUS_UXL_MASK = LSHIFT(0b11, STATUS_UXL_SHIFT)
STATUS_SXL_MASK = LSHIFT(0b11, STATUS_SXL_SHIFT)
STATUS_SBE_MASK = LSHIFT(1, STATUS_SBE_SHIFT)
STATUS_MBE_MASK = LSHIFT(1, STATUS_MBE_SHIFT)
STATUS_SD_MASK = LSHIFT(1, STATUS_SD_SHIFT)

-- Exception codes used mep/medeleg CSRs
EXCEPTION_MISALIGNED_FETCH = 0
EXCEPTION_FAULT_FETCH = 1
EXCEPTION_ILLEGAL_INSTRUCTION = 2
EXCEPTION_BREAKPOINT = 3
EXCEPTION_MISALIGNED_LOAD = 4
EXCEPTION_FAULT_LOAD = 5
EXCEPTION_MISALIGNED_STORE = 6
EXCEPTION_FAULT_STORE = 7
EXCEPTION_USER_ECALL = 8
EXCEPTION_SUPERVISOR_ECALL = 9
EXCEPTION_HYPERVISOR_ECALL = 10
EXCEPTION_MACHINE_ECALL = 11
EXCEPTION_FETCH_PAGE_FAULT = 12
EXCEPTION_LOAD_PAGE_FAULT = 13
EXCEPTION_STORE_PAGE_FAULT = 15

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

-- Supported counters in [m|s]counteren CSRs
MCOUNTERN_CY = LSHIFT(1, 0)
MCOUNTERN_TM = LSHIFT(1, 1)
MCOUNTERN_IR = LSHIFT(1, 2)
MCOUNTERN_HPM3 = LSHIFT(1, 3) -- Contiguous HPM counters up to HPM31 after this.

-- SATP CSR masks
SATP_PPN_MASK32 = maskFromRange(0, 21)
SATP_ASID_MASK32 = maskFromRange(22, 30)
SATP_MODE_MASK32 = maskFromRange(31, 31)
SATP_PPN_MASK64 = maskFromRange(0, 43)
SATP_ASID_MASK64 = maskFromRange(44, 59)
SATP_MODE_MASK64 = maskFromRange(60, 63)

-- SATP Modes
local SATP_MODE_NONE = LSHIFT(0, 60);
local SATP_MODE_SV32 = LSHIFT(1, 31);
local SATP_MODE_SV39 = LSHIFT(8, 60);
local SATP_MODE_SV48 = LSHIFT(9, 60);
local SATP_MODE_SV57 = LSHIFT(10, 60);
local SATP_MODE_SV64 = LSHIFT(11, 60);

-- Page sizes are 4KiB (V2p73)
PAGE_ADDRESS_SHIFT = 12
PAGE_ADDRESS_MASK = LSHIFT(1, PAGE_ADDRESS_SHIFT) - 1

-- Page table entry masks. See V2p73
PTE_DATA_BITS = 10 -- Number of PTE data bits.
PTE_V_MASK = LSHIFT(0b1, 0) -- Valid flag.
PTE_R_MASK = LSHIFT(0b1, 1) -- Allow read access.
PTE_W_MASK = LSHIFT(0b1, 2) -- Allow write access.
PTE_X_MASK = LSHIFT(0b1, 3) -- Allow code execution (instruction fetch).
PTE_U_MASK = LSHIFT(0b1, 4) -- Allow access to user mode only.
PTE_G_MASK = LSHIFT(0b1, 5) -- Global mapping.
PTE_A_MASK = LSHIFT(0b1, 6) -- Accessed flag (read, written or fetched).
PTE_D_MASK = LSHIFT(0b1, 7) -- Dirty flag (written).
PTE_RSW_MASK = LSHIFT(0b11, 8) -- Reserved for supervisor software.

-- Config for SV39/48 configuration
SV32_LEVELS = 2
SV39_LEVELS = 3
SV48_LEVELS = 4

-- Floating point extension CSR
FCSR_FFLAGS_NX_MASK = LSHIFT(0b1, 0) -- Inexact.
FCSR_FFLAGS_UF_MASK = LSHIFT(0b1, 1) -- Underflow.
FCSR_FFLAGS_OF_MASK = LSHIFT(0b1, 2) -- Overflow.
FCSR_FFLAGS_DZ_MASK = LSHIFT(0b1, 3) -- Division by zero.
FCSR_FFLAGS_NV_MASK = LSHIFT(0b1, 4) -- Invalid operation.
FCSR_FRM_SHIFT = 5
FCSR_FFLAGS_MASK = 0b11111
FCSR_FRM_MASK = LSHIFT(0b111, FCSR_FRM_SHIFT)

-- Floating point rounding modes
FCSR_FRM_RNE = 0b000 -- Round to nearest, ties to even.
FCSR_FRM_RTZ = 0b001 -- Round towards zero.
FCSR_FRM_RDN = 0b010 -- Round down (towards negative infinity).
FCSR_FRM_RUP = 0b011 -- Round up (towards positive infinity).
FCSR_FRM_RMM = 0b100 -- Round to nearest, ties to max magnitude.
FCSR_FRM_DYN = 0b111 -- Use rm field of instruction to determine rounding mode.

-- States for FS field in mstatus
FS_OFF = 0 -- All off.
FS_INITIAL = 1 -- None dirty or clean, some on.
FS_CLEAN = 2 -- None dirty, some clean.
FS_DIRTY = 3 -- Some dirty.

-- Size Stuff:
local SIZE_8 = 8
local SIZE_16 = 16
local SIZE_32 = 32
local SIZE_64 = 64

local SIZE_8_BYTES = SIZE_8 / 8
local SIZE_16_BYTES = SIZE_16 / 8
local SIZE_32_BYTES = SIZE_32 / 8
local SIZE_64_BYTES = SIZE_64 / 8

local SIZE_8_LOG2 = 0
local SIZE_16_LOG2 = 1
local SIZE_32_LOG2 = 2
local SIZE_64_LOG2 = 3

-- Upper bit mask for 32bit float values in 64bit registers
NAN_BOXING_MASK = LSHIFT(0xFFFFFFFF, 32) -- May need to use a custom bit32 LSHIFT for this
CANONICAL_ISA_ORDER = "IEMAFDQLCBJTPVNSUHKORWXYZG"

SIGN_MASK = LSHIFT(1, (2^64 - 1)) -- Something tells me this sign mask is gonna cause trouble, I don't get it

--
-- Computes flags for the machine ISA CSR given a list of extension letters.
--
-- @param extensions the list of extensions to build a mask from.
-- @return the mask representing the list of extensions.
--

function isa(...)
	local result = 0
	for _,ch in ipairs({...}) do
		local extension = string.upper(ch)

		if extension:byte() < string.byte("A") or extension:byte() > string.byte("Z") then
			error("Not a valid extension letter: ", extension)
		end

		result = BOR(result, LSHIFT(1, (extension - string.byte("A")) ))
	end

	return result
end

--
-- Gets the value for the MXL field in the misa CSR for a given XLEN.
--
-- @param xlen the XLEN to get the MXL value for. Must be 32, 64 or 128.
-- @return the MXL for the specified XLEN.
--

function mxl(xlen)
	return xlen == 32 and 0b01 or xlen == 64 and 0b10 or xlen == 128 and 0b11 or error("illegal argument")
end
function xlenf(mxl)
	return mxl == 0b01 and 32 or mxl == 0b10 and 64 or mxl == 0b11 and 128 or 0
end
function mxLSHIFT(xlen)
	return xlen - 2
end
function mxlMask(xlen)
	return LSHIFT(0b11, mxLSHIFT(xlen))
end
function interrupt(xlen)
	-- Highest bit means it's an interrupt/asynchronous exception, otherwise a regular exception.
	return LSHIFT(1, xlen-1)
end

--
-- Gets the mask for extracting the status dirty flag.
-- <p>
-- The position of this bit depends on the current {@code XLEN}.
--
-- @param xlen the current {@code XLEN}.
-- @return the mask for the status dirty bit.
--


function getStatusStateDirtyMask(xlen)
	return LSHIFT(1, (xlen - 1))
end

local InstructionSize = 32


-- R5 Main: AbnormallyCursed, 9/24/2023
--
--Sometime after I finished the instruction list I realized.. floats
--because of our system it treats them as decimal numbers by default, and there's no real way we can fix this
--so I came up with this to convert integer value of a float back into a float, also the other way around just incase :)

--At the time of writing this message, 4:40 AM, 9/26/2023.. I think it's fixed?
--We will find out during testing phase
--

local FOUR_BYTE_NULL = string.char(0)..string.char(0)..string.char(0)..string.char(0)

local function FLOAT64_TO_INTEGER64(n: number, Signed: boolean)
	return string.unpack(Signed and "l" or "L", string.pack("d", n))
end
local function FLOAT32_TO_INTEGER64(n: number, Signed: boolean)
	return string.unpack(Signed and "l" or "L", FOUR_BYTE_NULL..string.pack("f", n))
end
local function FLOAT64_TO_INTEGER32(n: number, Signed: boolean)
	return string.unpack(Signed and "i" or "I", string.pack("d", n))
end
local function FLOAT32_TO_INTEGER32(n: number, Signed: boolean)
	return string.unpack(Signed and "i" or "I", string.pack("f", n))
end
local function INTEGER64_TO_FLOAT64(n: number, Signed: boolean)
	return string.unpack("d", string.pack(Signed and "l" or "L", n))
end
local function INTEGER64_TO_FLOAT32(n: number, Signed: boolean)
	return string.unpack("f", string.pack(Signed and "l" or "L", n))
end
local function INTEGER32_TO_FLOAT64(n: number, Signed: boolean)
	return string.unpack("d", string.pack(Signed and "i" or "I", n))
end
local function INTEGER32_TO_FLOAT32(n: number, Signed: boolean)
	return string.unpack("f", string.pack(Signed and "i" or "I", n))
end

local function NewTLB()
	return setmetatable({
		hash = -1,
		toOffset = 0,
		breakpoints = {}
	}, {
		__index = function(t, index)
			return {}
		end,
	})
end

function Module:NewR5CPU()

	local function TreatAsSigned(Size: number, n: number)
		local STR = self:NewEncoding(n, Size, false)
		return STR:sub(1,1) == "0" and n or -n
	end

	local InstructionList = {}
	local fetchTLB = NewTLB(256)
	local loadTLB = NewTLB(256)
	local storeTLB = NewTLB(256)
	local cycleDebt = 0

	-- UBE, SBE, MBE hardcoded to zero for little endianness
	local MSTATUS_MASK = BAND(BAND(ONEC(STATUS_UBE_MASK), ONEC(STATUS_SBE_MASK)), ONEC(STATUS_MBE_MASK))

	-- No time and no high perf counters.
	local COUNTEREN_MASK = BOR(MCOUNTERN_CY, MCOUNTERN_IR)

	-- Supervisor status (sstatus) CSR mask over mstatus.
	-- NOTE: using BOR like this might cause unwanted behavior
	local SSTATUS_MASK = BOR(STATUS_UIE_MASK, STATUS_SIE_MASK, STATUS_UPIE_MASK, STATUS_SPIE_MASK, STATUS_SPP_MASK, STATUS_FS_MASK, STATUS_XS_MASK, STATUS_SUM_MASK, STATUS_MXR_MASK, STATUS_UXL_MASK)

	-- Translation look-aside buffer config.
	local TLB_SIZE = 256 -- Must be a power of two for fast modulo via `& (TLB_SIZE - 1)`.

	-------------------------------------------------------------------
	-- RV32I / RV64I
	local PC = 0x1000 -- Program Counter
	local mxl = 0 -- Current MXLEN, stored to restore after privilege change.
	local xlen = XLEN_32 -- Current XLEN, allows switching between RV32I and RV64I.
	local XREGS = table.create(31, 0)
	XREGS[0] = 0
	setmetatable(XREGS, {
		__newindex = function(t,index,value)
			t[index] = math.floor(value)
		end,
	})

	-------------------------------------------------------------------
	-- RV64FD
	local FREGS = table.create(31, 0)
	FREGS[0] = 0
	local fflags = 0 -- So called Soft Float Flags, likely needs a proper implementation
	local frm = 0
	local fs = 0
	local fpu32 = fflags -- self:SoftFloat(fflags)
	local fpu64 = fflags -- self:SoftDouble(fflags)

	-------------------------------------------------------------------
	-- RV64A
	local reservation_set = -1

	-------------------------------------------------------------------
	-- User-level CSRs
	local mcycle = 0

	-- Machine-level CSRs
	local mstatus = 0 -- Machine Status Register
	local mtvec = 0 -- Machine Trap-Vector Base-Address Register 0b11=Mode: 0=direct, 1=vectored
	local medeleg, mideleg = 0, 0 -- Machine Trap Delegation Registers
	local mip = 0 -- Pending Interrupts
	local mie = 0 -- Enabled Interrupts
	local mcounteren = 0 -- Machine Counter-Enable Register
	local mscratch = 0 -- Machine Scratch Register
	local mepc = 0 -- Machine Exception Program Counter
	local mcause = 0 -- Machine Cause Register
	local mtval = 0 -- Machine Trap Value Register

	-- Supervisor-level CSRs
	local stvec = 0 -- Supervisor Trap Vector Base Address Register 0b11=Mode: 0=direct, 1=vectored
	local scounteren = 0 -- Supervisor Counter-Enable Register
	local sscratch = 0 -- Supervisor Scratch Register
	local sepc = 0 -- Supervisor Exception Program Counter
	local scause = 0 -- Supervisor Cause Register
	local stval = 0 -- Supervisor Trap Value Register
	local satp = 0 -- Supervisor Address Translation and Protection Register 0

	-------------------------------------------------------------------
	-- Misc. state
	local PRIV = 0 -- Current privilege level.
	local waitingForInterrupt

	-- Random Stuff:
	local function resolveRoundingMode(rm)
		if rm == FCSR_FRM_DYN then
			rm = frm
		end
		if rm > FCSR_FRM_RMM then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 30)
		end
		return rm
	end

	local function checkFloat(Value)
		if BAND(Value, NAN_BOXING_MASK) ~= NAN_BOXING_MASK then
			return 0/0 -- NAN
		else
			return Value
		end
	end

	local function sClassify(n: number)
		return error("haha, no")
	end

	function self:advxpcall(callback, callback2)
		xpcall(callback, function(err)
			warn(err)
			local split = err:split(":")
			callback2(err, AsDict[err], tonumber(split[2]) or PC)
		end)
	end

	function self:raiseInterrupts(mask: number)
		mip = BOR(0, mask) 
		if waitingForInterrupt and BAND(mip, mie) ~= 0 then
			waitingForInterrupt = false
		end
	end

	function self:reset(hard: boolean, PCN: number)
		PC = PCN
		waitingForInterrupt = false
		PRIV = PRIVILEGE_M
		mstatus = BAND(mstatus, ONEC(STATUS_MIE_MASK))
		mstatus = BAND(mstatus, ONEC(STATUS_MPRV_MASK))
		mcause = 0
		mxl = mxl(XLEN_64)
		xlen = XLEN_64
		self:flushTLB()

		if hard then
			for i = 1, #XREGS do
				XREGS[i] = 0
			end
			reservation_set = -1
			mcycle = 0
			mstatus = BOR(LSHIFT(mxl(xlen), STATUS_UXL_SHIFT), LSHIFT(mxl(xlen), STATUS_SXL_SHIFT))
			mtvec = 0
			medeleg = 0
			mideleg = 0
			mip = 0
			mie = 0
			mcounteren = 0
			mscratch = 0
			mepc = 0
			mtval = 0
			stvec = 0
			scounteren = 0
			sscratch = 0
			sepc = 0
			scause = 0
			stval = 0
			satp = 0
		end
	end

	function self:step(cycles: number)
		local paidDebt = math.min(cycles, cycleDebt)
		cycles -= paidDebt
		cycleDebt -= paidDebt

		if waitingForInterrupt then
			mcycle += cycles
			return
		end

		local cycleLimit = mcycle + cycles
		while (not waitingForInterrupt and mcycle < cycleLimit) do
			print("cycling,", PC)
			local pending = BAND(mip, mie)
			if pending ~= 0 then
				self:raiseInterrupt(pending)
			end

			self:interpret(false, false)
		end

		if waitingForInterrupt and mcycle < cycleLimit then
			mcycle = cycleLimit
		end

		cycleDebt += cycleLimit - mcycle
	end

	function self:interpret(singleStep: boolean, ignoreBreakpoints: boolean)
		self:advxpcall(function()
			local cache = self:fetchPage(PC)
			local device = cache.device
			local instOffset = PC + cache.toOffset
			local inst = 0
			local instEnd = instOffset - BAND(PC, PAGE_ADDRESS_MASK) -- Page start.
				+ (LSHIFT(1, PAGE_ADDRESS_SHIFT) - 2)

			self:advxpcall(function()
				if instOffset < instEnd then -- Likely case, instruction fully inside page.
					inst = device.load(instOffset, SIZE_32_LOG2)
				else -- Unlikely case, instruction may leave page if it is 32bit.
					inst = BAND(device.load(instOffset, SIZE_16_LOG2), 0xFFFF)
					if (BAND(inst, 0b11) == 0b11) then -- 32bit instruction.
						local highCache = self:fetchPage(PC + 2)
						local highDevice = highCache.device
						inst = BOR(inst, highDevice.load(LSHIFT((PC + 2 + highCache.toOffset), SIZE_16_LOG2), 16))
					end
				end
			end, function()
				self:RaiseException(EXCEPTION_FAULT_FETCH, PC)
			end)

			local A
			if ignoreBreakpoints then
				A = nil
			else
				A = cache.breakpoints
			end

			if (xlen == XLEN_32) then
				self:interpretTrace32(device, inst, PC, instOffset, singleStep and 0 or instEnd, A)
			else 
				self:interpretTrace64(device, inst, PC, instOffset, singleStep and 0 or instEnd, A)
			end
		end, function(name, exceptiontype, address)
			self:RaiseException(exceptiontype, address)
		end)
	end

	function self:interpretTrace32(device, inst, PCN, instOffset, instEnd, breakpoints)
		self:advxpcall(function()
			--for i = 1, math.huge do
			if (breakpoints ~= nil and breakpoints.contains(PC)) then
				PC = PCN
				warn("HANDLE BREAKPOINT: ", PC) --debugInterface.handleBreakpoint(PC)
				return
			end

			mcycle += 1
			self:decode(inst)
			PC += 4

			--if (ABS(instOffset) < ABS(instEnd)) then
			--inst = device.load(instOffset, SIZE_32_LOG2)
			--else
			--PC = PCN
			--return]]
			--end
			--end
		end, function(name, exceptiontype, address)
			if name == "EXCEPTION_FAULT_FETCH" then
				PC = PCN
				return self:RaiseException(EXCEPTION_FAULT_FETCH, inst)
			elseif name == "EXCEPTION_ILLEGAL_INSTRUCTION" then
				PC = PCN
				return self:RaiseException(EXCEPTION_ILLEGAL_INSTRUCTION, inst)
			else
				PC = PCN
				return self:RaiseException(exceptiontype, address)
			end
		end)
	end

	function self:interpretTrace64(device, inst, PCN, instOffset, instEnd, breakpoints)
		print("should not be called rn")
		self:advxpcall(function()
			--for i = 1, math.huge do
			if (breakpoints ~= nil and breakpoints.contains(PC)) then
				PC = PCN
				warn("HANDLE BREAKPOINT: ", PC) --debugInterface.handleBreakpoint(PC)
				return
			end

			mcycle += 1	
			self:decode(inst) 
			PC += 4
			--if (instOffset < instEnd) then
			inst = device.load(instOffset, SIZE_32_LOG2)
			--else
			--	PC = PCN
			--	return
			--end]]
			--end
		end, function(name, exceptiontype, address)
			if name == "EXCEPTION_FAULT_FETCH" then
				PC = PCN
				return self:RaiseException(EXCEPTION_FAULT_FETCH, inst)
			elseif name == "EXCEPTION_ILLEGAL_INSTRUCTION" then
				PC = PCN
				return self:RaiseException(EXCEPTION_ILLEGAL_INSTRUCTION, inst)
			else
				PC = PCN
				return self:RaiseException(exceptiontype, address)
			end
		end)
	end

	function self:RaiseException(exception, value)
		if typeof(exception) == "string" then
			warn("Exception Raised:", exception, value)
			return
		end

		-- Exceptions take cycle.
		mcycle += 1

		--
		-- Check whether to run supervisor level trap instead of machine level one.
		-- We don't implement the N extension (user level interrupts) so if we're
		-- currently in S or U privilege level we'll run the S level trap handler
		-- either way -- assuming that the current interrupt/exception is allowed
		-- to be delegated by M level.
		--

		local interruptMask = interrupt(xlen);
		local async = BAND(exception, interruptMask) ~= 0;
		local cause = BAND(exception, ONEC(interruptMask));
		local deleg = async and mideleg or medeleg;

		--
		-- Was interrupt for current priv level enabled? There are cases we can
		-- get here even for interrupts! Specifically when an M level interrupt
		-- is raised while in S mode. This will get here even if M level interrupt
		-- enabled bit is zero, as per spec (Volume 2 p21).
		--

		local oldIE = BAND(RSHIFT(mstatus, PRIV), 0b1)
		local vec = 0

		if PRIV <= PRIVILEGE_S and BAND(RSHIFT(deleg, cause), 0b1) ~= 0 then
			scause = exception
			sepc = PC
			stval = value
			mstatus = BOR(BAND(mstatus, ONEC(STATUS_SPIE_MASK)), LSHIFT(oldIE, STATUS_SPIE_SHIFT))
			mstatus = BOR(BAND(mstatus, ONEC(STATUS_SPP_MASK)), LSHIFT(PRIV, STATUS_SPP_SHIFT))
			mstatus = BAND(mstatus, ONEC(STATUS_SIE_MASK))
			self:setPrivilege(PRIVILEGE_S)
			vec = stvec
		else
			mcause = exception
			mepc = PC
			mtval = value
			mstatus = BOR(BAND(mstatus, ONEC(STATUS_MPIE_MASK)), LSHIFT(oldIE, STATUS_MPIE_SHIFT))
			mstatus = BOR(BAND(mstatus, ONEC(STATUS_MPP_MASK)), LSHIFT(PRIV, STATUS_MPP_SHIFT))
			mstatus = BAND(mstatus, ONEC(STATUS_MIE_MASK))
			self:setPrivilege(PRIVILEGE_M)
			vec = mtvec
		end

		local mode = BAND(vec, 0b11)

		if mode == 0b01 then -- Vectored
			if async then
				PC = BAND(vec, ONEC(0b1)) + 4 * cause;
			else
				PC = BAND(vec, ONEC(0b1))
			end
		else
			PC = vec
		end

		return
	end

	function self:CreateTLBEntry()
		return {
			hash = -1,
			toOffset = 0,
			device = nil,
			breakpoints = nil,
		}
	end

	function self:setPrivilege(level)
		if PRIV == level then
			return
		end

		self:flushTLB()

		if level == PRIVILEGE_S then
			xlen = xlenf(RSHIFT(BAND(mstatus, STATUS_SXL_MASK), STATUS_SXL_SHIFT))
		elseif level == PRIVILEGE_U then
			xlen = xlenf(RSHIFT(BAND(mstatus, STATUS_UXL_MASK), STATUS_UXL_SHIFT))
		else
			xlen = xlenf(mxl)
		end

		PRIV = level
	end

	-- MEMORY:

	function self:getPageFaultException(accessType, address)
		if accessType == PTE_R_MASK then
			return EXCEPTION_LOAD_PAGE_FAULT, address
		elseif accessType == PTE_W_MASK then
			return EXCEPTION_STORE_PAGE_FAULT, address
		elseif accessType == PTE_X_MASK then
			return EXCEPTION_FETCH_PAGE_FAULT, address
		end
	end

	function self:fetchPage(address)
		if BAND(address, 1) ~= 0 then
			error("EXCEPTION_MISALIGNED_FETCH:"..address)
		end

		local index = BAND(LSHIFT(address, PAGE_ADDRESS_SHIFT), TLB_SIZE - 1)
		local hash = BAND(address, ONEC(PAGE_ADDRESS_MASK))
		local TLBEntry = fetchTLB[index]

		if TLBEntry and TLBEntry.hash == hash then
			return TLBEntry
		else
			return self:fetchPageSlow(address)
		end
	end

	function self:getPhysicalAddress(virtualAddress, accessType, bypassPermissions)
		local privilege;
		if BAND(mstatus, STATUS_MPRV_MASK) ~= 0 and accessType ~= PTE_X_MASK then
			privilege = RSHIFT(BAND(mstatus, STATUS_MPP_MASK), STATUS_MPP_SHIFT)
		else
			privilege = PRIV
		end

		if privilege == PRIVILEGE_M then
			if xlen == XLEN_32 then
				return BAND(virtualAddress, 0xFFFFFFFF)
			end
		else
			return virtualAddress
		end

		local mode;
		if xlen == XLEN_32 then
			mode = BAND(satp, SATP_PPN_MASK32)
			if mode == SATP_MODE_NONE then
				return BAND(virtualAddress, 0xFFFFFFFF);
			end
		else
			mode = BAND(satp, SATP_PPN_MASK64)
			if mode == SATP_MODE_NONE then
				return virtualAddress
			end
		end

		local levels, pteSizeLog2;
		local ppnMask;

		if mode == SATP_MODE_SV32 then
			levels = SV32_LEVELS
			ppnMask = SATP_PPN_MASK32
			pteSizeLog2 = SIZE_32_LOG2
		elseif mode == SATP_MODE_SV39 then
			levels = SV39_LEVELS
			ppnMask = SATP_PPN_MASK64
			pteSizeLog2 = SIZE_64_LOG2
		elseif mode == SATP_MODE_SV48 then
			assert(mode == SATP_MODE_SV48, "mode not SATP_MODE_SV48")
			levels = SV48_LEVELS
			ppnMask = SATP_PPN_MASK64
			pteSizeLog2 = SIZE_64_LOG2
		end

		local xpnSize = PAGE_ADDRESS_SHIFT - pteSizeLog2
		local xpnMask = BAND(1, xpnSize) - 1

		-- Virtual address translation, V2p75f.

		local pteAddress = LSHIFT(BAND(satp, ppnMask), PAGE_ADDRESS_SHIFT) -- 1
		local i = levels-1

		while i >= 0 do
			i -= 1
			local vpnShift = PAGE_ADDRESS_SHIFT + xpnSize * i
			local vpn = BAND(RSHIFT(virtualAddress, vpnShift), xpnMask)
			pteAddress += LSHIFT(vpn, pteSizeLog2) -- equivalent to vpn * PTE size

			local pte;

			self:advxpcall(function()
				pte = self.physicalMemory:load(pteAddress, pteSizeLog2) -- 2
			end, function()
				pte = 0
			end)

			if BAND(pte, PTE_V_MASK) == 0 or ( BAND(pte, PTE_R_MASK) == 0 and BAND(pte, PTE_W_MASK) ~= 0 ) then -- 3
				error(self:getPageFaultException(accessType, virtualAddress))
			end

			-- 4
			local xwr = BAND(pte, (BOR(PTE_X_MASK, BOR(PTE_W_MASK, PTE_R_MASK))))
			if xwr == 0 then -- r=0 && x=0: pointer to next level of the page table. w=0 is implicit due to r=0 (see 3).
				local ppn = RSHIFT(pte, PTE_DATA_BITS)
				pteAddress = LSHIFT(ppn, PAGE_ADDRESS_SHIFT)
				continue
			end

			-- 5. Leaf node, do access permission checks.

			if not bypassPermissions then
				-- Check privilege. Can only be in S or U mode here, M was handled above. V2p61.
				local userModeFlag = BAND(pte, PTE_U_MASK) ~= 0
				if privilege == PRIVILEGE_S then
					if userModeFlag and (accessType == PTE_X_MASK or BAND(mstatus, STATUS_SUM_MASK) == 0) then
						error(self:getPageFaultException(accessType, virtualAddress))
					end
				elseif not userModeFlag then
					error(self:getPageFaultException(accessType, virtualAddress))
				end

				-- MXR allows read on execute-only pages.
				if ( BAND(mstatus, STATUS_MXR_MASK) ~= 0 ) then
					xwr = BOR(xwr, PTE_R_MASK)
				end

				-- Check access flags.
				if BAND(xwr, accessType) == 0 then
					error(self:getPageFaultException(accessType, virtualAddress))
				end
			end

			-- 6. Check misaligned superpage.
			if i > 0 then
				local ppnLSB = BAND(RSHIFT(pte, PTE_DATA_BITS), xpnMask);
				if (ppnLSB ~= 0)  then
					error(self:getPageFaultException(accessType, virtualAddress))
				end
			end

			-- 7. Update accessed and dirty flags.
			if BAND(pte, PTE_A_MASK) == 0 or (accessType == PTE_W_MASK and BAND(pte, PTE_D_MASK) == 0) then
				pte = BOR(pte, PTE_A_MASK)
				if accessType == PTE_W_MASK then
					pte = BOR(pte, PTE_D_MASK)
				end

				self:advxpcall(function()
					self.physicalMemory:store(pteAddress, pte, pteSizeLog2)
				end, function()
					error(self:getPageFaultException(accessType, virtualAddress))
				end)
			end

			-- 8. physical address = pte.ppn[LEVELS-1:i], va.vpn[i-1:0], va.pgoff
			local vpnAndPageOffsetMask = LSHIFT(1, vpnShift) - 1
			local ppn = LSHIFT(RSHIFT(pte, PTE_DATA_BITS), PAGE_ADDRESS_SHIFT)

			return BOR(BAND(ppn, ONEC(vpnAndPageOffsetMask)), BAND(virtualAddress, vpnAndPageOffsetMask))
		end

		error(self:getPageFaultException(accessType, virtualAddress))
	end

	function self:fetchPageSlow(address) -- Yeah.. slow alright, good lord this whole thing is gonna be slow isn't it?
		local physicalAddress = self:getPhysicalAddress(address, PTE_X_MASK, false)
		local range = self.physicalMemory:getMemoryRange(physicalAddress)
		print(physicalAddress)
		if range == nil or not range.device.supportsFetch then
			error("EXCEPTION_FAULT_FETCH:"..address)
		end

		local tlb = self:updateTLB(fetchTLB, address, physicalAddress, range)
		-- Some sort of subset thing here with breakpoints, not gonna mess around with it tbh

		return tlb
	end

	function self:loadSlow(address, sizeLog2)
		local physicalAddress = self:getPhysicalAddress(address, PTE_R_MASK, false)
		local range = self.physicalMemory:getMemoryRange(physicalAddress)

		if not range then
			error("EXCEPTION_FAULT_LOAD:"..address)
		end

		self:advxpcall(function()
			if range.device.supportsFetch then
				local entry = self:updateTLB(loadTLB, address, physicalAddress, range)
				return entry.device.load(address + entry.toOffset, sizeLog2)
			else
				return range.device.load(physicalAddress - range.address, sizeLog2)
			end
		end, function()
			return error("EXCEPTION_FAULT_LOAD:"..address)
		end)
	end

	function self:storeSlow(address, value, sizeLog2)
		local physicalAddress = self:getPhysicalAddress(address, PTE_W_MASK, false)
		local range = self.physicalMemory:getMemoryRange(physicalAddress)

		if not range then
			error("EXCEPTION_FAULT_STORE:"..address)
		end

		self:advxpcall(function()
			if range.device.supportsFetch then
				local entry = self:updateTLB(storeTLB, address, physicalAddress, range)
				local offset = address + entry.toOffset
				entry.device.store(offset, value, sizeLog2)
				self.physicalMemory:setDirty(range, offset)
			else
				return range.device.store(physicalAddress - range.start, value, sizeLog2)
			end
		end, function()
			return error("EXCEPTION_FAULT_STORE:"..address)
		end)
	end

	function self:loadx(address, size, sizeLog2)
		local index = BAND(RSHIFT(address, PAGE_ADDRESS_SHIFT), TLB_SIZE - 1)
		local alignment = size / 8 -- Enforce aligned memory access.
		local alignmentMask = alignment - 1
		local hash = BAND(address, ONEC(BAND(PAGE_ADDRESS_MASK, ONEC(alignmentMask))))
		local entry = loadTLB[index]

		if entry.hash == hash then
			local ret
			self:advxpcall(function()
				ret = entry.device.load(address + entry.toOffset, sizeLog2)
			end, function()
				error("EXCEPTION_FAULT_LOAD:"..address)
			end)
			return ret
		else
			return self:loadSlow(address, sizeLog2)
		end
	end

	function self:storex(address, value, size, sizeLog2)
		local index = BAND(RSHIFT(address, PAGE_ADDRESS_SHIFT), TLB_SIZE - 1)
		local alignment = size / 8 -- Enforce aligned memory access.
		local alignmentMask = alignment - 1
		local hash = BAND(address, ONEC(BAND(PAGE_ADDRESS_MASK, ONEC(alignmentMask))))
		local entry = loadTLB[index]

		if entry.hash == hash then
			self:advxpcall(function()
				entry.device.store(address + entry.toOffset, value, sizeLog2)
			end, function()
				error("EXCEPTION_FAULT_STORE:"..address)
			end)
		else
			return self:storeSlow(address, value, sizeLog2)
		end
	end
	-- 8
	function self:load8(address)
		self:loadx(address, 8, 0)
	end
	function self:store8(address, value)
		self:storex(address, value, 8, 0)
	end
	-- 16
	function self:load16(address)
		self:loadx(address, 16, 1)
	end
	function self:store16(address, value)
		self:storex(address, value, 16, 1)
	end
	-- 32
	function self:load32(address)
		self:loadx(address, 32, 2)
	end
	function self:store32(address, value)
		self:storex(address, value, 32, 2)
	end
	-- 64
	function self:load64(address)
		self:loadx(address, 64, 3)
	end
	function self:store64(address, value)
		self:storex(address, value, 64, 3)
	end

	-- TLB:

	function self:flushTLB(address)
		--
		--// Only reset the most necessary field, the hash (which we use to check if an entry is applicable).
		-- // Reset per-array for *much* faster clears due to it being a faster memory access pattern/the
		-- // hotspot optimizer being able to more efficiently handle it (probably the latter, I suspect this
		--// gets replaced by a memset with stride).
		--
		for i = 1, TLB_SIZE do
			fetchTLB[i].hash = -1
		end
		for i = 1, TLB_SIZE do
			loadTLB[i].hash = -1
		end
		for i = 1, TLB_SIZE do
			storeTLB[i].hash = -1
		end
	end

	function self:updateTLB(tlb, address, physicalAddress, range)
		return self:updateTLBEntry(tlb[BAND(RSHIFT(address, PAGE_ADDRESS_SHIFT), TLB_SIZE - 1)], address, physicalAddress, range)
	end

	function self:updateTLBEntry(tlb, address, physicalAddress, range)
		tlb.hash = BAND(address, ONEC(PAGE_ADDRESS_MASK))
		tlb.toOffset = physicalAddress - address - range.start
		tlb.device = range.device

		return tlb
	end

	-- Misc:

	function self:misa()
		-- Base ISA descriptor CSR (misa) (V2p16).
		return BOR(LSHIFT(mxl(xlen), mxLSHIFT(xlen)), isa('I', 'M', 'A', 'C', 'F', 'D', 'S', 'U'))
	end

	function self:getSupervisorStatusMask()
		return BOR(SSTATUS_MASK, getStatusStateDirtyMask(xlen))
	end

	function self:getStatus(mask)
		local status = BAND(BOR(mstatus, LSHIFT(fs, STATUS_FS_SHIFT)), mask)
		local dirty = (BAND(mstatus, STATUS_FS_MASK) == STATUS_FS_MASK) or (BAND(mstatus, STATUS_XS_MASK) == STATUS_XS_MASK)
		return BOR(status, (dirty and getStatusStateDirtyMask(xlen) or 0))
	end

	function self:checkCounterAccess(bit)
		-- See Volume 2 p36: mcounteren/scounteren define availability to next lowest privilege level.
		if PRIV < PRIVILEGE_M then
			local countern = 0
			if PRIV < PRIVILEGE_S then
				countern = scounteren
			else
				countern = mcounteren
			end

			if BAND(countern, LSHIFT(1, bit)) == 0 then
				error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
			end
		end
	end

	-- CSR:
	function self:checkCSR(csr, throwIfReadonly)
		if throwIfReadonly and ((csr >= 0xC00 and csr <= 0xC1F) or (csr >= 0xC80 and csr <= 0xC9F)) then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end

		-- Topmost bits, i.e. csr[11:8], encode access rights for CSR by convention. Of these, the top-most two bits,
		-- csr[11:10], encode read-only state, where 0b11: read-only, 0b00..0b10: read-write.

		if throwIfReadonly and (BAND(csr, 0b1100_0000_0000) == 0b1100_0000_0000) then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end

		-- The two following bits, csr[9:8], encode the lowest privilege level that can access the CSR
		if PRIV < BAND(RSHIFT(csr, 8), 0b11) then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end
	end

	function self:readCSR(csr)
		if csr == 0x001 then -- fflags, Floating-Point Accrued Exceptions.
			if (fs == FS_OFF) then return -1 end
			return fpu32.flags.value;
		elseif csr == 0x002 then -- frm, Floating-Point Dynamic Rounding Mode.
			if (fs == FS_OFF) then return -1 end
			return frm;
		elseif csr == 0x003 then -- fcsr, Floating-Point Control and Status Register (frm + fflags).
			if (fs == FS_OFF) then return -1 end
			return BOR(LSHIFT(frm, 5), fpu32.flags.value)


			-- User Trap Setup
			-- 0x000: ustatus, User status register.
			-- 0x004: uie, User interrupt-enabled register.
			-- 0x005: utvec, User trap handler base address.

			-- User Trap Handling
			-- 0x040: uscratch, Scratch register for user trap handlers.
			-- 0x041: uepc, User exception program counter.
			-- 0x042: ucause, User trap cause.
			-- 0x043: utval, User bad address or instruction.
			-- 0x044: uip, User interrupt pending.

			-- Supervisor Trap Setup:
		elseif csr == 0x100 then -- sstatus, Supervisor status register.
			return self:getStatus(self:getSupervisorStatusMask())

			-- 0x102: sedeleg, Supervisor exception delegation register.
			-- 0x103: sideleg, Supervisor interrupt delegation register.
		elseif csr == 0x104 then -- sie, Supervisor interrupt-enable register.
			return BAND(mie, mideleg) -- Effectively read-only because we don't implement N.
		elseif csr == 0x105 then -- stvec, Supervisor trap handler base address.
			return stvec
		elseif csr == 0x106 then -- scounteren, Supervisor counter enable.
			return scounteren

			-- Supervisor Trap Handling
		elseif csr == 0x140 then -- sscratch Scratch register for supervisor trap handlers.
			return sscratch
		elseif csr == 0x141 then -- sepc Supervisor exception program counter.
			return sepc
		elseif csr == 0x142 then -- scause Supervisor trap cause.
			return scause
		elseif csr == 0x143 then -- stval Supervisor bad address or instruction.
			return stval
		elseif csr == 0x144 then -- sip Supervisor interrupt pending.
			return BAND(mip, mideleg) -- Effectively read-only because we don't implement N.

			-- Supervisor Protection and Translation	
		elseif csr == 0x180 then -- satp Supervisor address translation and protection.
			if PRIV == PRIVILEGE_S and BAND(mstatus, STATUS_TVM_MASK) ~= 0 then
				error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
			end
			return satp

			-- Virtual Supervisor Registers
			-- 0x200: vsstatus, Virtual supervisor status register.
			-- 0x204: vsie, Virtual supervisor interrupt-enable register.
			-- 0x205: vstvec, Virtual supervisor trap handler base address.
			-- 0x240: vsscratch, Virtual supervisor scratch register.
			-- 0x241: vsepc, Virtual supervisor exception program counter.
			-- 0x242: vscause, Virtual supervisor trap cause.
			-- 0x243: vstval, Virtual supervisor bad address or instruction.
			-- 0x244: vsip, Virtual supervisor interrupt pending.
			-- 0x280: vsatp, Virtual supervisor address translation and protection

			-- Machine Trap Setup
		elseif csr == 0x300 then -- mstatus Machine status register.
			return self:getStatus(MSTATUS_MASK)
		elseif csr == 0x301 then -- misa ISA and extensions
			return self:misa()
		elseif csr == 0x302 then -- medeleg Machine exception delegation register.
			return medeleg
		elseif csr == 0x303 then -- mideleg Machine interrupt delegation register.
			return mideleg
		elseif csr == 0x304 then -- mie Machine interrupt-enable register.
			return mie
		elseif csr == 0x305 then -- mtvec Machine trap-handler base address.
			return mtvec
		elseif csr == 0x306 then -- mcounteren Machine counter enable.
			return mcounteren
		elseif csr == 0x310 then -- mstatush, Additional machine status register, RV32 only.
			if xlen ~= XLEN_32 then
				error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
			end
			return RSHIFT(self:getStatus(MSTATUS_MASK), 32)

			-- Debug/Trace Registers
		elseif csr == 0x7A0 then -- tselect
			return 0
		elseif csr == 0x7A1 then -- tdata1
			return 0
		elseif csr == 0x7A2 then -- tdata2
			return 0
		elseif csr == 0x7A3 then -- tdata3
			return 0

			-- Machine Trap Handling
		elseif csr == 0x340 then -- mscratch Scratch register for machine trap handlers.
			return mscratch
		elseif csr == 0x341 then -- mepc Machine exception program counter.
			return mepc
		elseif csr == 0x342 then -- mcause Machine trap cause.
			return mcause
		elseif csr == 0x343 then -- mtval Machine bad address or instruction.
			return mtval
		elseif csr == 0x344 then -- mip Machine interrupt pending.
			return mip

			-- 0x34A: mtinst, Machine trap instruction (transformed).
			-- 0x34B: mtval2, Machine bad guest physical address.

			-- Machine Memory Protection
			-- 0x3A0: pmpcfg0. Physical memory protection configuration.
			-- 0x3A1: pmpcfg1. Physical memory protection configuration, RV32 only.
			-- 0x3A2: pmpcfg2. Physical memory protection configuration.
			-- 0x3A3...0x3AE: pmpcfg3...pmpcfg14, Physical memory protection configuration, RV32 only.
			-- 0x3AF: pmpcfg15, Physical memory protection configuration, RV32 only.
			-- 0x3B0: pmpaddr0, Physical memory protection address register.
			-- 0x3B1...0x3EF: pmpaddr1...pmpaddr63, Physical memory protection address register.

			-- Hypervisor Trap Setup
			-- 0x600: hstatus, Hypervisor status register.
			-- 0x602: hedeleg, Hypervisor exception delegation register.
			-- 0x603: hideleg, Hypervisor interrupt delegation register.
			-- 0x604: hie, Hypervisor interrupt-enable register.
			-- 0x606: hcounteren, Hypervisor counter enable.
			-- 0x607: hgeie, Hypervisor guest external interrupt-enable register.

			-- Hypervisor Trap Handling
			-- 0x643: htval, Hypervisor bad guest physical address.
			-- 0x644: hip, Hypervisor interrupt pending.
			-- 0x645: hvip, Hypervisor virtual interrupt pending.
			-- 0x64A: htinst, Hypervisor trap instruction (transformed).
			-- 0xE12: hgeip, Hypervisor guest external interrupt pending.

			-- Hypervisor Protection and Translation
			-- 0x680: hgatp, Hypervisor guest address translation and protection.

			-- Hypervisor Counter/Timer Virtualization Registers
			-- 0x605: htimedelta, Delta for VS/VU-mode timer.
			-- 0x615: htimedeltah, Upper 32 bits of htimedelta, RV32 only.

			-- Machine Counter/Timers
			-- mcycle, Machine cycle counter.
		elseif csr == 0xB00 or csr == 0xB02 then -- minstret, Machine instructions-retired counter.
			return mcycle

			-- 0xB03: mhpmcounter3, Machine performance-monitoring counter.
			-- 0xB04...0xB1F: mhpmcounter4...mhpmcounter31, Machine performance-monitoring counter.
			-- mcycleh, Upper 32 bits of mcycle, RV32 only.
		elseif csr == 0xB80 or csr == 0xB82 then -- -- minstreth, Upper 32 bits of minstret, RV32 only.
			if xlen ~= XLEN_32 then
				error("")
			end
			return RSHIFT(mcycle, 32)

			-- 0xB83: mhpmcounter3h, Upper 32 bits of mhpmcounter3, RV32 only.
			-- 0xB84...0xB9F: mhpmcounter4h...mhpmcounter31h, Upper 32 bits of mhpmcounter4, RV32 only.

			-- Counters and Timers
			-- cycle

		elseif csr == 0xC00 or csr == 0xC02 then -- -- instret
			-- counteren[2:0] is IR, TM, CY. As such the bit index matches the masked csr value.
			self:checkCounterAccess(BAND(csr, 0b11))
			return mcycle;
		elseif csr == 0xC01 then -- time
			return self.rtc.getTime();

			-- 0xC03 ... 0xC1F: hpmcounter3 ... hpmcounter31
			-- cycleh

		elseif csr == 0xC80 or csr == 0xC82 then -- -- instreth
			if xlen ~= XLEN_32 then
				error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
			end

			-- counteren[2:0] is IR, TM, CY. As such the bit index matches the masked csr value.
			self:checkCounterAccess(BAND(csr, 0b11))
			return RSHIFT(mcycle, 32)

			-- 0xC81: timeh
			-- 0xC83 ... 0xC9F: hpmcounter3h ... hpmcounter31h

			-- Machine Information Registers
		elseif csr == 0xF11 then -- mvendorid, Vendor ID.
			return 0 -- Not implemented.
		elseif csr == 0xF12 then -- marchid, Architecture ID. 
			return 0 -- Not implemented.
		elseif csr == 0xF13 then -- mimpid, Implementation ID.
			return 0 -- Not implemented. 
		elseif csr == 0xF14 then -- mhartid, Hardware thread ID.
			return 0 -- Single, primary hart.
		else
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end
	end

	function self:writeCSR(csr, value)
		-- Floating-Point Control and Status Registers
		if csr == 0x001 then  -- fflags, Floating-Point Accrued Exceptions.
			fpu32.flags.value = BAND(value, 0b11111)
			fs = FS_DIRTY
		elseif csr == 0x002 then -- frm, Floating-Point Dynamic Rounding Mode.
			frm = BAND(value, 0b111)
			fs = FS_DIRTY
		elseif csr == 0x003 then -- fcsr, Floating-Point Control and Status Register (frm + fflags).
			frm = BAND(RSHIFT(value, 5), 0b111)
			fpu32.flags.value = BAND(value, 0b11111)
			fs = FS_DIRTY
			-- User Trap Setup
			-- 0x000: ustatus, User status register.
			-- 0x004: uie, User interrupt-enabled register.
			-- 0x005: utvec, User trap handler base address.

			-- User Trap Handling
			-- 0x040: uscratch, Scratch register for user trap handlers.
			-- 0x041: uepc, User exception program counter.
			-- 0x042: ucause, User trap cause.
			-- 0x043: utval, User bad address or instruction.
			-- 0x044: uip, User interrupt pending.

			-- Supervisor Trap Setup
		elseif csr == 0x100 then  -- sstatus, Supervisor status register.
			local supervisorStatusMask = self:getSupervisorStatusMask()
			self:setStatus(BOR(BAND(mstatus, ONEC(supervisorStatusMask)), BAND(value, supervisorStatusMask)))

			-- 0x102: sedeleg, Supervisor exception delegation register.
			-- 0x103: sideleg, Supervisor interrupt delegation register.
		elseif csr == 0x104 then -- sie, Supervisor interrupt-enable register.
			-- Can only set stuff that's delegated to S mode.
			local mask = mideleg
			mie = BOR(BAND(mie, ONEC(mask)), BAND(value, mask))
		elseif csr == 0x105 then -- stvec, Supervisor trap handler base address.
			-- Don't allow reserved modes.
			if BAND(value, 0b11) < 2 then
				stvec = value
			end
		elseif csr == 0x106 then -- scounteren, Supervisor counter enable.
			scounteren = BAND(value, COUNTEREN_MASK)
			-- Supervisor Trap Handling
		elseif csr == 0x140 then -- sscratch Scratch register for supervisor trap handlers.
			sscratch = value
		elseif csr == 0x141 then -- sepc Supervisor exception program counter.
			sepc = BAND(value, ONEC(0b1))
		elseif csr == 0x142 then -- scause Supervisor trap cause.
			scause = value
		elseif csr == 0x143 then -- stval Supervisor bad address or instruction.
			stval = value
		elseif csr == 0x144 then -- sip Supervisor interrupt pending.
			-- Can only set stuff that's delegated to S mode.
			local mask = mideleg
			mip = BOR(BAND(mip, ONEC(mask)), BAND(value, mask))

			-- Supervisor Protection and Translation
		elseif csr == 0x180 then -- satp Supervisor address translation and protection.
			-- Say no to ASID (not implemented).
			local validatedValue

			if xlen == XLEN_32 then
				validatedValue = BAND(value, ONEC(SATP_ASID_MASK32));
			else
				validatedValue = BAND(value, ONEC(SATP_ASID_MASK64));
			end

			local change = satp ^ validatedValue
			if change ~= 0 then
				if PRIV == PRIVILEGE_S and BAND(mstatus, STATUS_TVM_MASK) ~= 0 then
					error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
				end

				if xlen ~= XLEN_32 then
					-- We only support Sv39 and Sv48. On unsupported writes spec says just don't change anything.
					local mode = BAND(validatedValue, SATP_MODE_SV64)
					if mode ~= SATP_MODE_SV39 and mode ~= SATP_MODE_SV48 then
						return
					end
				end

				-- From RISC-V Privileged Architectures, section 4.2.1
				-- "Changing satp.MODE from Bare to other modes and vice versa also takes effect immediately,
				-- without the need to execute an SFENCE.VMA instruction."
				if xlen == XLEN_32 then
					if (BAND(satp, SATP_MODE_MASK32) == SATP_MODE_NONE) ~= (BAND(validatedValue, SATP_MODE_MASK32) == SATP_MODE_NONE) then
						self:flushTLB()
					end
				else
					if (BAND(satp, SATP_MODE_MASK64) == SATP_MODE_NONE) ~= (BAND(validatedValue, SATP_MODE_MASK64) == SATP_MODE_NONE) then
						self:flushTLB()
					end
				end

				satp = validatedValue
				return true -- Invalidate fetch cache.
			end


			-- Virtual Supervisor Registers
			-- 0x200: vsstatus, Virtual supervisor status register.
			-- 0x204: vsie, Virtual supervisor interrupt-enable register.
			-- 0x205: vstvec, Virtual supervisor trap handler base address.
			-- 0x240: vsscratch, Virtual supervisor scratch register.
			-- 0x241: vsepc, Virtual supervisor exception program counter.
			-- 0x242: vscause, Virtual supervisor trap cause.
			-- 0x243: vstval, Virtual supervisor bad address or instruction.
			-- 0x244: vsip, Virtual supervisor interrupt pending.
			-- 0x280: vsatp, Virtual supervisor address translation and protection

			-- Machine Trap Setup
		elseif csr == 0x300 then -- mstatus Machine status register.
			self:setStatus(BAND(value, MSTATUS_MASK))
		elseif csr == 0x301 then -- misa ISA and extensions
			-- We do not support changing feature sets dynamically.
		elseif csr == 0x302 then -- medeleg Machine exception delegation register.
			-- From Volume 2 p31: For exceptions that cannot occur in less privileged modes, the corresponding
			-- medeleg bits should be hardwired to zero. In particular, medeleg[11] is hardwired to zero.
			medeleg = BAND(value, ONEC(LSHIFT(1, EXCEPTION_MACHINE_ECALL)))

		elseif csr == 0x303 then -- mideleg Machine interrupt delegation register.
			local mask = BOR(SSIP_MASK, BOR(STIP_MASK, SEIP_MASK))
			mideleg = BOR(BAND(mideleg, ONEC(mask)), BAND(value, mask))
		elseif csr == 0x304 then -- mie Machine interrupt-enable register.
			-- Same note on line 304/305 applies
			local mask = BOR(MTIP_MASK, MSIP_MASK, SEIP_MASK, STIP_MASK, SSIP_MASK)
			print("ACKNOWLEDGE 0x304 CSR WRITE")
			mie = BOR(BAND(mie, ONEC(mask)), BAND(value, mask))
		elseif csr == 0x305 then -- mtvec Machine trap-handler base address.
			-- Don't allow reserved modes.
			if BAND(value, 0b11) < 2 then
				mtvec = value
			end
		elseif csr == 0x306 then -- mcounteren Machine counter enable.
			mcounteren = BAND(value, COUNTEREN_MASK)
		elseif csr == 0x310 then -- mstatush Additional machine status register, RV32 only.
			if xlen ~= XLEN_32 then
				error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
			end
			self:setStatus(BAND(LSHIFT(value, 32), MSTATUS_MASK))
			-- Debug/Trace Registers
		elseif csr == 0x7A0 then -- tselect

		elseif csr == 0x7A1 then -- tdata1

		elseif csr == 0x7A2 then -- tdata2

		elseif csr == 0x7A3 then -- tdata3


			-- Machine Trap Handling
		elseif csr == 0x340 then -- mscratch Scratch register for machine trap handlers.
			mscratch = value
		elseif csr == 0x341 then -- mepc Machine exception program counter.
			mepc = BAND(value, ONEC(0b1))
		elseif csr == 0x342 then -- mcause Machine trap cause.
			mcause = value
		elseif csr == 0x343 then -- mtval Machine bad address or instruction.
			mtval = value
		elseif csr == 0x344 then -- mip Machine interrupt pending.
			local mask = BOR(STIP_MASK, SSIP_MASK)
			print("ACKNOWLEDGE 0x344 CSR WRITE")
			mip = BOR(BAND(mip, ONEC(mask)), BAND(value, mask))

			-- 0x34A: mtinst, Machine trap instruction (transformed).
			-- 0x34B: mtval2, Machine bad guest physical address.

			-- Machine Memory Protection
			-- 0x3A0: pmpcfg0. Physical memory protection configuration.
			-- 0x3A1: pmpcfg1. Physical memory protection configuration, RV32 only.
			-- 0x3A2: pmpcfg2. Physical memory protection configuration.
			-- 0x3A3...0x3AE: pmpcfg3...pmpcfg14, Physical memory protection configuration, RV32 only.
			-- 0x3AF: pmpcfg15, Physical memory protection configuration, RV32 only.
			-- 0x3B0: pmpaddr0, Physical memory protection address register.
			-- 0x3B1...0x3EF: pmpaddr1...pmpaddr63, Physical memory protection address register.

			-- Hypervisor Trap Setup
			-- 0x600: hstatus, Hypervisor status register.
			-- 0x602: hedeleg, Hypervisor exception delegation register.
			-- 0x603: hideleg, Hypervisor interrupt delegation register.
			-- 0x604: hie, Hypervisor interrupt-enable register.
			-- 0x606: hcounteren, Hypervisor counter enable.
			-- 0x607: hgeie, Hypervisor guest external interrupt-enable register.

			-- Hypervisor Trap Handling
			-- 0x643: htval, Hypervisor bad guest physical address.
			-- 0x644: hip, Hypervisor interrupt pending.
			-- 0x645: hvip, Hypervisor virtual interrupt pending.
			-- 0x64A: htinst, Hypervisor trap instruction (transformed).

			-- Hypervisor Protection and Translation
			-- 0x680: hgatp, Hypervisor guest address translation and protection.

			-- Hypervisor Counter/Timer Virtualization Registers
			-- 0x605: htimedelta, Delta for VS/VU-mode timer.
			-- 0x615: htimedeltah, Upper 32 bits of htimedelta, RV32 only.

			-- Proprietary CSRs.
		elseif csr == 0xBC0 then -- Switch to 32 bit XLEN.
			-- This CSR exists purely to allow switching the CPU to 32 bit mode from programs
			-- that were compiled for 32 bit. Since those cannot set the MXL bits of the misa
			-- CSR when the machine is currently in 64 bit mode.
			self:setXLEN(XLEN_32)
			return true
		else
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end
	end

	function self:csrrwx(rd, newValue, csr)
		local exitTrace;
		self:checkCSR(csr, newValue)

		if rd ~= 0 then -- Explicit check, spec says no read side-effects when rd = 0.
			local oldValue = self:readCSR(csr)
			exitTrace = self:writeCSR(csr, newValue)
			XREGS[rd] = oldValue -- Write to register last, avoid lingering side-effect when write errors.
		else
			exitTrace = self:writeCSR(csr, newValue)
		end

		return exitTrace
	end

	function self:csrrscx(rd, rs1, csr, mask, isSet)
		local mayChange = rs1 ~= 0

		if mayChange then
			self:checkCSR(csr, true)
			local value = self:readCSR(csr)
			local masked = isSet and BOR(mask, value) or BAND(ONEC(mask), value)
			local exitTrace = self:writeCSR(csr, masked)
			if rd ~= 0 then
				XREGS[rd] = value
			end

			return exitTrace
		elseif rd ~= 0 then
			self:checkCSR(csr, false)
			XREGS[rd] = self:readCSR(csr)
		end

		return false
	end
	--------------------------------
	-- RV32I Base Instruction Set --
	--------------------------------
	function InstructionList:LUI(imm, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = TreatAsSigned(20, imm)
		end
	end
	function InstructionList:AUIPC(imm, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = PC + TreatAsSigned(20, imm)
		end
	end
	function InstructionList:JAL(offset, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = PC + InstructionSize
		end

		PC = PC + TreatAsSigned(20, offset)
	end
	function InstructionList:JALR(imm12, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = PC + InstructionSize
		end

		PC = BAND((XREGS[rs1] + TreatAsSigned(12, imm12)), ONEC(1))
	end
	function InstructionList:BEQ(imm12, rs1, funct3, rs2, opcode)
		if XREGS[rs1] == XREGS[rs2] then
			PC = PC + TreatAsSigned(12, imm12)
			return true
		else
			return false
		end
	end
	function InstructionList:BNE(imm12, rs1, funct3, rs2, opcode)
		if XREGS[rs1] ~= XREGS[rs2] then
			PC = PC + TreatAsSigned(12, imm12)
			return true
		else
			return false
		end
	end
	function InstructionList:BLT(imm12, rs1, funct3, rs2, opcode)
		if XREGS[rs1] < XREGS[rs2] then
			PC = PC + TreatAsSigned(12, imm12)
			return true
		else
			return false
		end
	end
	function InstructionList:BGE(imm12, rs1, funct3, rs2, opcode)
		if XREGS[rs1] >= XREGS[rs2] then
			PC = PC + TreatAsSigned(12, imm12)
			return true
		else
			return false
		end
	end
	function InstructionList:BLTU(imm12, rs1, funct3, rs2, opcode) -- Unsigned variant of BLT
		if ABS(XREGS[rs1]) < ABS(XREGS[rs2]) then
			PC = PC + TreatAsSigned(12, imm12)
			return true
		else
			return false
		end
	end
	function InstructionList:BGEU(imm12, rs1, funct3, rs2, opcode) -- Unsigned variant of BGE
		if ABS(XREGS[rs1]) >= ABS(XREGS[rs2]) then
			PC = PC + TreatAsSigned(12, imm12)
			return true
		else
			return false
		end
	end
	function InstructionList:LB(imm12, rs1, funct3, rd, opcode)
		local Result = self:load8(XREGS[rs1] + TreatAsSigned(12, imm12))
		if rd ~= 0 then
			XREGS[rd] = Result
		end
	end
	function InstructionList:LH(imm12, rs1, funct3, rd, opcode)
		local Result = self:load16(XREGS[rs1] + TreatAsSigned(12, imm12))
		if rd ~= 0 then
			XREGS[rd] = Result
		end
	end
	function InstructionList:LW(imm12, rs1, funct3, rd, opcode)
		local Result = self:load16(XREGS[rs1] + TreatAsSigned(12, imm12))
		if rd ~= 0 then
			XREGS[rd] = Result
		end
	end
	function InstructionList:LBU(imm12, rs1, funct3, rd, opcode) -- Unsigned variant of LB
		local Result = BAND(self:load8(XREGS[rs1] + TreatAsSigned(12, imm12)), 0xFF)
		if rd ~= 0 then
			XREGS[rd] = Result
		end
	end
	function InstructionList:LHU(imm12, rs1, funct3, rd, opcode) -- Unsigned variant of LH
		local Result = BAND(self:load16(XREGS[rs1] + TreatAsSigned(12, imm12)), 0xFFFF)
		if rd ~= 0 then
			XREGS[rd] = Result
		end
	end
	function InstructionList:SB(imm7, rs2, rs1, funct3, imm5, opcode)
		self:store8(XREGS[rs1] + TreatAsSigned(7, imm7), XREGS[rs2])
	end
	function InstructionList:SH(imm7, rs2, rs1, funct3, imm5, opcode)
		self:store16(XREGS[rs1] + TreatAsSigned(7, imm7), XREGS[rs2])
	end
	function InstructionList:SW(imm7, rs2, rs1, funct3, imm5, opcode)
		self:store8(XREGS[rs1] + TreatAsSigned(7, imm7), XREGS[rs2])
	end
	function InstructionList:ADDI(imm12, rs1, funct3, rd, opcode)
		--print(TreatAsSigned(12, imm12))
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] + TreatAsSigned(12, imm12)
		end
	end
	function InstructionList:SLTI(imm12, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] < TreatAsSigned(12, imm12) and 1 or 0
		end
	end
	function InstructionList:SLTIU(imm12, rs1, funct3, rd, opcode) -- Unsigned variant of SLTI
		if rd ~= 0 then
			XREGS[rd] = ABS(XREGS[rs1]) < ABS(TreatAsSigned(12, imm12)) and 1 or 0
		end
	end
	function InstructionList:XORI(imm12, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] ^ TreatAsSigned(12, imm12)
		end
	end
	function InstructionList:ORI(imm12, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = BOR(XREGS[rs1], TreatAsSigned(12, imm12))
		end
	end
	function InstructionList:ANDI(imm12, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = BAND(XREGS[rs1], TreatAsSigned(12, imm12))
		end
	end
	function InstructionList:SLLI(funct6, shamt, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = LSHIFT(XREGS[rs1], shamt) -- Signed?
		end
	end
	function InstructionList:SRLI(funct6, shamt, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = RSHIFT(ABS(XREGS[rs1]), ABS(shamt)) -- Unsigned for sure
		end
	end
	function InstructionList:SRAI(funct6, shamt, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = ARSHIFT(XREGS[rs1], shamt)
		end
	end
	function InstructionList:ADD(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] + XREGS[rs2]
		end
	end
	function InstructionList:SUB(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] - XREGS[rs2]
		end
	end
	function InstructionList:SLL(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = LSHIFT(XREGS[rs1], XREGS[rs2])
		end
	end
	function InstructionList:SLT(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] < XREGS[rs2] and 1 or 0
		end
	end
	function InstructionList:SLTU(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned variant of SLT
		if rd ~= 0 then
			XREGS[rd] = ABS(XREGS[rs1]) < ABS(XREGS[rs2]) and 1 or 0
		end
	end
	function InstructionList:XOR(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] ^ XREGS[rs2]
		end
	end
	function InstructionList:SRL(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = RSHIFT(ABS(XREGS[rs1]), ABS(XREGS[rs2]))
		end
	end
	function InstructionList:SRA(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = RSHIFT(XREGS[rs1], XREGS[rs2])
		end
	end
	function InstructionList:OR(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = BOR(XREGS[rs1], XREGS[rs2])
		end
	end
	function InstructionList:AND(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = BAND(XREGS[rs1], XREGS[rs2])
		end
	end
	function InstructionList:FENCE()
		warn("no-op")
		-- no-op
	end
	function InstructionList:ECALL(funct7, rs2, rs1, funct3, rd, opcode)
		return self:RaiseException(EXCEPTION_USER_ECALL + PRIV)
	end
	function InstructionList:EBREAK(funct7, rs2, rs1, funct3, rd, opcode)
		return self:RaiseException(EXCEPTION_BREAKPOINT)
	end

	--------------------------------
	-- RV64I Base Instruction Set --
	--------------------------------
	function InstructionList:AUIPCW(imm, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = PC + TreatAsSigned(20, imm)
		end
	end
	function InstructionList:JALW(offset, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = PC + InstructionSize
		end

		PC = PC + TreatAsSigned(20, offset)
	end
	function InstructionList:JALRW(imm12, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = PC + InstructionSize
		end

		PC = BAND((XREGS[rs1] + TreatAsSigned(12, imm12)), ONEC(1))
	end
	function InstructionList:LWU(imm12, rs1, funct3, rd, opcode)
		local Result = self:load16(XREGS[rs1] + TreatAsSigned(12, imm12))
		if rd ~= 0 then
			XREGS[rd] = Result
		end
	end
	function InstructionList:ADDIW(imm12, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] + TreatAsSigned(12, imm12)
		end
	end
	function InstructionList:SLLIW(funct6, shamt, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = LSHIFT(XREGS[rs1], shamt) -- Signed?
		end
	end
	function InstructionList:SRLIW(funct6, shamt, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = RSHIFT(ABS(XREGS[rs1]), ABS(shamt)) -- Unsigned for sure
		end
	end
	function InstructionList:SRAIW(funct6, shamt, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = ARSHIFT(XREGS[rs1], shamt)
		end
	end
	function InstructionList:ADDW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] + XREGS[rs2]
		end
	end
	function InstructionList:SUBW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] - XREGS[rs2]
		end
	end
	function InstructionList:SLLW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = LSHIFT(XREGS[rs1], XREGS[rs2])
		end
	end
	function InstructionList:SRLW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = RSHIFT(ABS(XREGS[rs1]), ABS(XREGS[rs2]))
		end
	end
	function InstructionList:SRAW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = RSHIFT(XREGS[rs1], XREGS[rs2])
		end
	end

	function InstructionList:LD(imm12, rs1, funct3, rd, opcode)
		local result = self:load64(XREGS[rs1] + TreatAsSigned(12, imm12))
		if rd ~= 0 then
			XREGS[rd] = result
		end
	end
	function InstructionList:SD(imm7, rs2, rs1, funct3, imm5, opcode) -- Uses either imm7 or imm5, don't recall
		self:store64(XREGS[rs1] + TreatAsSigned(7, imm7), XREGS[rs2])
	end

	-------------------------------------------
	-- RV32/RV64 Zifencei Standard Extension --
	-------------------------------------------
	function InstructionList:FENCE_i()
		warn("no-op")
		-- no-op
	end

	----------------------------------------
	-- RV32/RV64 Zicsr Standard Extension --
	----------------------------------------
	function InstructionList:CSRRW(csr, rs1, funct3, rd, opcode)
		return self:csrrwx(rd, XREGS[rs1], csr)
	end
	function InstructionList:CSRRS(csr, rs1, funct3, rd, opcode)
		return self:csrrscx(rd, rs1, csr, XREGS[rs1], true)
	end
	function InstructionList:CSRRC(csr, rs1, funct3, rd, opcode)
		return self:csrrscx(rd, rs1, csr, XREGS[rs1], false)
	end
	function InstructionList:CSRRWI(csr, rs1, funct3, rd, opcode)
		return self:csrrwx(rd, rs1, csr)
	end
	function InstructionList:CSRRSI(csr, rs1, funct3, rd, opcode)
		return self:csrrscx(rd, rs1, csr, rs1, true)
	end
	function InstructionList:CSRRCI(csr, rs1, funct3, rd, opcode)
		return self:csrrscx(rd, rs1, csr, rs1, false)
	end

	------------------------------
	-- RV32M Standard Extension -- I'm worried about the instructions in this block..
	------------------------------
	function InstructionList:MUL(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] * XREGS[rs2]
		end
	end
	function InstructionList:MULH(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			print("ewww icky icky..")
			XREGS[rd] = XREGS[rs1] * XREGS[rs2]
		end
	end
	function InstructionList:MULHSU(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			print("ewww icky icky..")
			XREGS[rd] = XREGS[rs1] * XREGS[rs2]
		end
	end
	function InstructionList:DIV(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then -- NOTE: The way they handle this is a bit more complex.. and that has me worried
			XREGS[rd] = XREGS[rs1] / XREGS[rs2]
		end
	end
	function InstructionList:DIVU(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned Variant of DIV
		if rd ~= 0 then
			XREGS[rd] = ABS(XREGS[rs1]) / ABS(XREGS[rs2])
		end
	end
	function InstructionList:REM(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			-- https://msyksphinz-github.io/riscv-isadoc/html/rvm.html#rem
			XREGS[rd] = XREGS[rs1] % XREGS[rs2] -- I suppose? 
		end
	end
	function InstructionList:REMU(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned variant of REM
		if rd ~= 0 then
			XREGS[rd] = ABS(XREGS[rs1]) % ABS(XREGS[rs2])
		end
	end

	------------------------------
	-- RV64M Standard Extension -- Still worried.
	------------------------------
	function InstructionList:MULW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] * XREGS[rs2]
		end
	end
	function InstructionList:MULHW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			print("HUH??")
			XREGS[rd] = XREGS[rs1] * XREGS[rs2]
		end
	end
	function InstructionList:MULHSUW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			print("these.. don't exist....?")
			XREGS[rd] = XREGS[rs1] * XREGS[rs2]
		end
	end
	function InstructionList:DIVW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			if XREGS[rs2] == 0 then
				XREGS[rd] = -1
			else
				XREGS[rd] = XREGS[rs1] / XREGS[rs2]
			end
		end
	end
	function InstructionList:DIVUW(funct7, rs2, rs1, funct3, rd, opcode) -- Blah blah, unsigned var of divw yeah
		if rd ~= 0 then
			if XREGS[rs2] == 0 then
				XREGS[rd] = -1
			else
				XREGS[rd] = ABS(XREGS[rs1]) / ABS(XREGS[rs2])
			end
		end
	end
	function InstructionList:REMW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = XREGS[rs1] % XREGS[rs2]
		end
	end
	function InstructionList:REMUW(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = ABS(XREGS[rs1]) % ABS(XREGS[rs2])
		end
	end

	------------------------------
	-- RV32A Standard Extension -- Less worried, still worried
	------------------------------
	function InstructionList:LR_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local Address = XREGS[rs1]
		reservation_set = Address
		if rd ~= 0 then
			XREGS[rd] = self:load32(Address)
		end
	end
	function InstructionList:SC_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local Address = XREGS[rs1]
		local Result
		reservation_set = Address

		if Address == reservation_set then
			self:store32(Address, XREGS[rs2])
			Result = 0
		else
			Result = 1
		end

		reservation_set = -1

		if rd ~= 0 then
			XREGS[rd] = Result
		end
	end
	function InstructionList:AMOADD_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local Address = XREGS[rs1]
		local A = self:load32(Address)
		local B = XREGS[rs2]

		self:store32(Address, A + B)

		if rd ~= 0 then
			XREGS[rd] = A
		end
	end
	function InstructionList:AMOXOR_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load32(address)
		local b = XREGS[rs2]

		self:store32(address, a ^ b)

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOAND_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load32(address)
		local b = XREGS[rs2]

		self:store32(address, BAND(a, b))

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOOR_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load32(address)
		local b = XREGS[rs2]

		self:store32(address, BOR(a, b))

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOMIN_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load32(address)
		local b = XREGS[rs2]

		self:store32(address, math.min(a, b))

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOMAX(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load32(address)
		local b = XREGS[rs2]

		self:store32(address, math.max(a, b))

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOMINU_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load32(address)
		local b = XREGS[rs2]

		self:store32(address, ABS(a) > ABS(b) and b or a) -- I assume? Integer.compareUnsigned(a, b) < 0 ? a : b)

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOMAXU_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load32(address)
		local b = XREGS[rs2]

		self:store32(address, ABS(a) < ABS(b) and b or a) -- I assume? Integer.compareUnsigned(a, b) > 0 ? a : b)

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOSWAP_W(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load32(address)
		local b = XREGS[rs2]

		self:store32(address, b) -- I assume? Integer.compareUnsigned(a, b) > 0 ? a : b)

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end

	------------------------------
	-- RV64A Standard Extension --
	------------------------------
	function InstructionList:LR_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local Address = XREGS[rs1]
		reservation_set = Address
		if rd ~= 0 then
			XREGS[rd] = self:load64(Address)
		end
	end
	function InstructionList:SC_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local Address = XREGS[rs1]
		local Result
		reservation_set = Address

		if Address == reservation_set then
			self:store64(Address, XREGS[rs2])
			Result = 0
		else
			Result = 1
		end

		reservation_set = -1

		if rd ~= 0 then
			XREGS[rd] = Result
		end
	end
	function InstructionList:AMOADD_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local Address = XREGS[rs1]
		local A = self:load64(Address)
		local B = XREGS[rs2]

		self:store32(Address, A + B)

		if rd ~= 0 then
			XREGS[rd] = A
		end
	end
	function InstructionList:AMOXOR_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load64(address)
		local b = XREGS[rs2]

		self:store32(address, a ^ b)

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOAND_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load64(address)
		local b = XREGS[rs2]

		self:store64(address, BAND(a, b))

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOOR_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load64(address)
		local b = XREGS[rs2]

		self:store64(address, BOR(a, b))

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOMIN_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load64(address)
		local b = XREGS[rs2]

		self:store64(address, math.min(a, b))

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOMAX_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load64(address)
		local b = XREGS[rs2]

		self:store64(address, math.max(a, b))

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOMINU_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load64(address)
		local b = XREGS[rs2]

		self:store64(address, ABS(a) > ABS(b) and b or a) -- I assume? Integer.compareUnsigned(a, b) < 0 ? a : b)

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOMAXU_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load64(address)
		local b = XREGS[rs2]

		self:store64(address, ABS(a) < ABS(b) and b or a) -- I assume? Integer.compareUnsigned(a, b) > 0 ? a : b)

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end
	function InstructionList:AMOSWAP_D(funct5, X, x, rs2, rs1, funct3, rd, opcode)
		local address = XREGS[rs1]
		local a = self:load64(address)
		local b = XREGS[rs2]

		self:store64(address, b)

		if rd ~= 0 then
			XREGS[rd] = a
		end
	end

	-----------------------------
	-- Privileged Instructions --
	-----------------------------
	function InstructionList:SRET(funct7, rs2, rs1, funct3, rd, opcode)
		if PRIV < PRIVILEGE_S then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end

		if (BAND(mstatus, STATUS_TSR_MASK) ~= 0 and PRIV < PRIVILEGE_M) then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end

		local spp = RSHIFT(ABS(BAND(mstatus, STATUS_SPP_MASK)), STATUS_SPP_SHIFT) -- Previous privilege level.
		local spie = RSHIFT(ABS(BAND(mstatus, STATUS_SPIE_MASK)), STATUS_SPIE_SHIFT) -- Previous interrupt-enable state.
		mstatus = BOR(BAND(mstatus, ONEC(STATUS_SIE_MASK)), LSHIFT(STATUS_SIE_MASK * spie, STATUS_SIE_SHIFT))
		mstatus = BOR(BAND(mstatus, ONEC(LSHIFT(1, spp))), LSHIFT(spie, spp))
		mstatus = BOR(mstatus, STATUS_SPIE_MASK)
		mstatus = BAND(mstatus, STATUS_SPP_MASK)
		mstatus = BAND(mstatus, STATUS_MPRV_MASK)

		self:setPrivlege(spp)

		PC = sepc
		return true -- Exit trace virtual memory access may have changed.
	end
	function InstructionList:MRET(funct7, rs2, rs1, funct3, rd, opcode)
		if PRIV < PRIVILEGE_M then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end

		local mpp = RSHIFT(ABS(BAND(mstatus, STATUS_MPP_MASK)), STATUS_MPP_SHIFT) -- Previous privilege level.
		local mpie = RSHIFT(ABS(BAND(mstatus, STATUS_MPIE_MASK)), STATUS_MPIE_SHIFT) -- Previous interrupt-enable state.
		mstatus = BOR(BAND(mstatus, ONEC(STATUS_MIE_MASK)), LSHIFT(STATUS_MIE_MASK * mpie, STATUS_MIE_SHIFT))
		mstatus = BOR(mstatus, STATUS_MPIE_MASK)
		mstatus = BAND(mstatus, STATUS_MPP_MASK)

		if mpp ~= PRIVILEGE_M then
			mstatus = BAND(mstatus, ONEC(STATUS_MPRV_MASK))
		end

		self:setPrivlege(mpp)

		PC = mepc
		return true -- Exit trace virtual memory access may have changed.
	end
	function InstructionList:WFI(funct7, rs2, rs1, funct3, rd, opcode)
		if PRIV == PRIVILEGE_U then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end
		if BAND(mstatus, STATUS_TW_MASK) ~= 0 and PRIV == PRIVILEGE_S then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end

		if BAND(mip, mie) ~= 0 then
			return false
		end

		waitingForInterrupt = true
		return true
	end
	function InstructionList:SFENCE_VMA(funct7, rs2, rs1, funct3, rd, opcode)
		if PRIV == PRIVILEGE_U then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end
		if BAND(mstatus, STATUS_TVM_MASK) ~= 0 and PRIV == PRIVILEGE_S then
			error("EXCEPTION_ILLEGAL_INSTRUCTION", 2048)
		end

		if rs1 == 0 then
			self:flushTLB()
		else
			self:flushTLB(XREGS[rs1])
		end

		return true
	end

	------------------------------
	-- RV32F Standard Extension --
	------------------------------
	function InstructionList:FLW(imm12, rs1, funct3, rd, opcode)
		FREGS[rd] = INTEGER32_TO_FLOAT32(BAND(self:load32(XREGS[rs1] + TreatAsSigned(12, imm12)), NAN_BOXING_MASK), true) -- I guess true?
		fs = FS_DIRTY
	end
	function InstructionList:FSW(imm7, rs2, rs1, funct3, imm5, opcode)
		if fs == FS_OFF then return end
		self:store32(XREGS[rs1] + TreatAsSigned(7, imm7), FREGS[rs2])
	end
	-- Okay so floats are overall the most concerning so far
	-- We are going to do some of these without the BOR(x, NAN_BOXING_MASK), probably a mistake but thats for future me
	function InstructionList:FMADD_S(rs3, w, rs2, rs1, rm, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1]*FREGS[rs2]+FREGS[rs3]
		fs = FS_DIRTY
	end
	function InstructionList:FMSUB_S(rs3, w, rs2, rs1, rm, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1]*FREGS[rs2]-FREGS[rs3]
		fs = FS_DIRTY
	end
	function InstructionList:FNMADD_S(rs3, w, rs2, rs1, rm, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = -FREGS[rs1]*FREGS[rs2]-FREGS[rs3]
		fs = FS_DIRTY
	end
	function InstructionList:FADD_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] + FREGS[rs2]
		fs = FS_DIRTY
	end
	function InstructionList:FSUB_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] - FREGS[rs2]
		fs = FS_DIRTY
	end
	function InstructionList:FMUL_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] * FREGS[rs2]
		fs = FS_DIRTY
	end
	function InstructionList:FDIV_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] / FREGS[rs2]
		fs = FS_DIRTY
	end
	function InstructionList:FSQRT_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = math.sqrt(FREGS[rs1])
		fs = FS_DIRTY
	end
	function InstructionList:FSGNJ_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		local value = BAND(checkFloat(FREGS[rs1]), ONEC(SIGN_MASK))
		FREGS[rd] = BAND(BOR(value, checkFloat(FREGS[rs2])), BOR(SIGN_MASK, NAN_BOXING_MASK))
		fs = FS_DIRTY
	end
	function InstructionList:FSGNJN_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		local value = BAND(checkFloat(FREGS[rs1]), ONEC(SIGN_MASK))
		FREGS[rd] = BAND(BOR(value, ONEC(checkFloat(FREGS[rs2]))), BOR(SIGN_MASK, NAN_BOXING_MASK))
		fs = FS_DIRTY
	end
	function InstructionList:FSGNJX_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] ^ BOR(BAND(checkFloat(FREGS[rs2]), SIGN_MASK), NAN_BOXING_MASK)
		fs = FS_DIRTY
	end
	function InstructionList:FMIN_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = BOR(math.min(checkFloat(FREGS[rs1]), checkFloat(FREGS[rs2])), NAN_BOXING_MASK)
		fs = FS_DIRTY
	end
	function InstructionList:FMAX_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = BOR(math.max(checkFloat(FREGS[rs1]), checkFloat(FREGS[rs2])), NAN_BOXING_MASK)
		fs = FS_DIRTY
	end
	function InstructionList:FCVT_W_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		local value = FLOAT32_TO_INTEGER32(checkFloat(FREGS[rs1]), true)
		if rd ~= 0 then
			XREGS[rd] = value
		end
	end
	function InstructionList:FCVT_WU_S(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned Variant of FCVT_W_S
		--rm = resolveRoundingMode(rm)
		local value = math.floor(checkFloat(FREGS[rs1]))
		if rd ~= 0 then
			XREGS[rd] = ABS(value)
		end
	end
	function InstructionList:FMV_X_W(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = FREGS[rs1]
		end
	end
	function InstructionList:FEQ_S(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = (checkFloat(FREGS[rs1]) == checkFloat(FREGS[rs2])) and 1 or 0
		end
	end
	function InstructionList:FLT_S(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = (checkFloat(FREGS[rs1]) < checkFloat(FREGS[rs2])) and 1 or 0
		end
	end
	function InstructionList:FLE_S(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = (checkFloat(FREGS[rs1]) <= checkFloat(FREGS[rs2])) and 1 or 0
		end
	end
	function InstructionList:FCLASS_S(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = sClassify(checkFloat(FREGS[rs1]))
		end
	end
	function InstructionList:FCVT_S_W(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = INTEGER32_TO_FLOAT32(BOR(ABS(XREGS[rs1]), NAN_BOXING_MASK), false)
		fs = FS_DIRTY
	end
	function InstructionList:FCVT_S_WU(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned variant of FCVT_S_W
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = INTEGER32_TO_FLOAT32(BOR(XREGS[rs1], NAN_BOXING_MASK), true) -- Same thing except signed
		fs = FS_DIRTY
	end
	function InstructionList:FMV_W_X(funct7, rs2, rs1, funct3, rd, opcode)
		FREGS[rd] = BOR(XREGS[rs1], NAN_BOXING_MASK)
		fs = FS_DIRTY
	end

	------------------------------
	-- RV64F Standard Extension -- So far I am getting less and less confident about this emulator
	------------------------------
	function InstructionList:FCVT_L_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		if rd ~= 0 then
			XREGS[rd] = math.floor(checkFloat(FREGS[rs1])) 
		end
	end
	function InstructionList:FCVT_LU_S(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned Variant of FCVT_L_S
		--rm = resolveRoundingMode(rm)
		if rd ~= 0 then
			XREGS[rd] = ABS(math.floor(checkFloat(FREGS[rs1])) )
		end
	end
	function InstructionList:FCVT_S_L(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		if rd ~= 0 then
			XREGS[rd] = INTEGER64_TO_FLOAT64(BOR(XREGS[rs1], NAN_BOXING_MASK))
		end
		fs = FS_DIRTY
	end
	function InstructionList:FCVT_S_LU(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned Variant of FCVT_S_L
		--rm = resolveRoundingMode(rm)
		if rd ~= 0 then
			XREGS[rd] = ABS(BOR(XREGS[rs1], NAN_BOXING_MASK))
		end
		fs = FS_DIRTY
	end

	------------------------------
	-- RV32D Standard Extension -- Final strech, 2 more instruction groups to go (including this one)
	------------------------------
	function InstructionList:FLD(imm12, rs1, funct3, rd, opcode)
		FREGS[rd] = INTEGER32_TO_FLOAT32(BAND(self:load64(XREGS[rs1] + TreatAsSigned(12, imm12)), NAN_BOXING_MASK))
		fs = FS_DIRTY
	end
	function InstructionList:FSD(imm7, rs2, rs1, funct3, imm5, opcode)
		if fs == FS_OFF then return end
		self:store64(XREGS[rs1] + TreatAsSigned(7, imm7), FREGS[rs2])
	end
	function InstructionList:FMADD_D(rs3, w, rs2, rs1, rm, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1]*FREGS[rs2]+FREGS[rs3]
		fs = FS_DIRTY
	end
	function InstructionList:FMSUB_D(rs3, w, rs2, rs1, rm, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1]*FREGS[rs2]-FREGS[rs3]
		fs = FS_DIRTY
	end
	function InstructionList:FNMADD_D(rs3, w, rs2, rs1, rm, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = -FREGS[rs1]*FREGS[rs2]-FREGS[rs3]
		fs = FS_DIRTY
	end
	function InstructionList:FNMSUB_S(rs3, w, rs2, rs1, rm, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = -FREGS[rs1]*FREGS[rs2]+FREGS[rs3]
		fs = FS_DIRTY
	end
	function InstructionList:FADD_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] + FREGS[rs2]
		fs = FS_DIRTY
	end
	function InstructionList:FSUB_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] - FREGS[rs2]
		fs = FS_DIRTY
	end
	function InstructionList:FMUL_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] * FREGS[rs2]
		fs = FS_DIRTY
	end
	function InstructionList:FDIV_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] / FREGS[rs2]
		fs = FS_DIRTY
	end
	function InstructionList:FSQRT_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = math.sqrt(FREGS[rs1])
		fs = FS_DIRTY
	end
	function InstructionList:FSGNJ_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		local value = BAND(checkFloat(FREGS[rs1]), ONEC(SIGN_MASK))
		FREGS[rd] = BAND(BOR(value, checkFloat(FREGS[rs2])), BOR(SIGN_MASK, NAN_BOXING_MASK))
		fs = FS_DIRTY
	end
	function InstructionList:FSGNJN_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		local value = BAND(checkFloat(FREGS[rs1]), ONEC(SIGN_MASK))
		FREGS[rd] = BAND(BOR(value, ONEC(checkFloat(FREGS[rs2]))), BOR(SIGN_MASK, NAN_BOXING_MASK))
		fs = FS_DIRTY
	end
	function InstructionList:FSGNJX_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = FREGS[rs1] ^ BOR(BAND(checkFloat(FREGS[rs2]), SIGN_MASK), NAN_BOXING_MASK)
		fs = FS_DIRTY
	end
	function InstructionList:FMIN_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = BOR(math.min(checkFloat(FREGS[rs1]), checkFloat(FREGS[rs2])), NAN_BOXING_MASK)
		fs = FS_DIRTY
	end
	function InstructionList:FMAX_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = BOR(math.max(checkFloat(FREGS[rs1]), checkFloat(FREGS[rs2])), NAN_BOXING_MASK)
		fs = FS_DIRTY
	end
	function InstructionList:FCVT_D_S(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		local value = INTEGER32_TO_FLOAT32(checkFloat(FREGS[rs1]))
		if rd ~= 0 then
			XREGS[rd] = value
		end
	end
	function InstructionList:FCVT_WU_D(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned Variant of FCVT_W_S
		--rm = resolveRoundingMode(rm)
		local value = math.floor(checkFloat(FREGS[rs1]))
		if rd ~= 0 then
			XREGS[rd] = ABS(value)
		end
	end
	--function InstructionList:FMV_X_D(funct7, rs2, rs1, funct3, rd, opcode)
	--if rd ~= 0 then
	--	XREGS[rd] = FREGS[rs1]
	--end
	--end
	function InstructionList:FEQ_D(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = (checkFloat(FREGS[rs1]) == checkFloat(FREGS[rs2])) and 1 or 0
		end
	end
	function InstructionList:FLT_D(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = (checkFloat(FREGS[rs1]) < checkFloat(FREGS[rs2])) and 1 or 0
		end
	end
	function InstructionList:FLE_D(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = (checkFloat(FREGS[rs1]) <= checkFloat(FREGS[rs2])) and 1 or 0
		end
	end
	function InstructionList:FCLASS_D(funct7, rs2, rs1, funct3, rd, opcode)
		if rd ~= 0 then
			XREGS[rd] = sClassify(checkFloat(FREGS[rs1]))
		end
	end
	function InstructionList:FCVT_S_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = INTEGER64_TO_FLOAT64(BOR(XREGS[rs1], NAN_BOXING_MASK), true)
		fs = FS_DIRTY
	end
	function InstructionList:FCVT_S_DU(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned variant of FCVT_S_W
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = BOR(ABS(XREGS[rs1]), NAN_BOXING_MASK) -- Same thing except signed
		fs = FS_DIRTY
	end
	function InstructionList:FCVT_W_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		local value = FLOAT64_TO_INTEGER64(checkFloat(FREGS[rs1]), true)
		if rd ~= 0 then
			XREGS[rd] = value
		end
	end
	function InstructionList:FCVT_D_WU(funct7, rs2, rs1, funct3, rd, opcode) -- Unsigned variant of FCVT_S_W
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = BOR(ABS(XREGS[rs1]), NAN_BOXING_MASK) -- Same thing except signed
		fs = FS_DIRTY
	end

	------------------------------
	-- RV64D Standard Extension -- The time is 2 am, Last. Group.
	------------------------------
	function InstructionList:FCVT_L_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		XREGS[rd] = FLOAT64_TO_INTEGER64(FREGS[rs1], true)
	end
	function InstructionList:FCVT_LU_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		XREGS[rd] = FLOAT64_TO_INTEGER64(ABS(FREGS[rs1]), false)
	end
	function InstructionList:FMV_X_D(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		if rd ~= 0 then
			XREGS[rd] = FREGS[rs1]
		end
	end
	function InstructionList:FMV_D_L(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = INTEGER64_TO_FLOAT64(XREGS[rs1], true)
		fs = FS_DIRTY
	end
	function InstructionList:FMV_D_LU(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = INTEGER64_TO_FLOAT64(ABS(XREGS[rs1]), false)
		fs = FS_DIRTY
	end
	function InstructionList:FMV_D_X(funct7, rs2, rs1, funct3, rd, opcode)
		--rm = resolveRoundingMode(rm)
		FREGS[rd] = XREGS[rs1]
		fs = FS_DIRTY
	end

	self.InstructionList = InstructionList
	return self
end

return Module
