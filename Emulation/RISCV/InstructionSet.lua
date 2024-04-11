-- All Information is based on:
-- Volume I: https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
-- Volume II: https://riscv.org/wp-content/uploads/2017/05/riscv-privileged-v1.10.pdf

------ 0000
-- MSB ^  ^ LSB (this is just a reminder for myself since I forget it very often)

-- RV32C is going to be unused until further notice, see reason below
-- RV32C greatly changes the way decoding occurs, this CPU has enough stuff slowing it down as it is
-- we don't need to make decoding more complex for an extension that is purely optional to begin with

-- Instruction Formats:
-- Base Formats:

local type_r = { "opcode:7", "rd:5", "funct3:3", "rs1:5", "rs2:5", "funct7:7" }
local type_i = { "opcode:7", "rd:5", "funct3:3", "rs1:5", "imm:12" }
local type_s = { "opcode:7", "imm5:5", "funct3:3", "rs1:5", "rs2:5", "imm7:7" }
local type_u = { "opcode:7", "rd:5", "imm:20" }

-- Extension Formats:
local type_a = { "opcode:7", "rd:5", "funct3:3", "rs1:5", "rs2:5", "x:1", "X:1", "funct5:5" }
local shamt = { "opcode:7", "rd:5", "funct3:3", "rs1:5", "shamt:6", "funct6:6" }
local zicsr = { "opcode:7", "rd:5", "funct3:3", "rs1:5", "csr:12" } 

-- RV32C Quadrant Formats:
local Q_A = {"A:2", "B:3", "C:8", "D:3"}
local Q_B = {"A:2", "B:5", "C:5", "D:1", "E:3"} -- Applies to Quadrant 2 as well
local Q_C = {"A:2", "B:5", "C:3", "D:2", "E:1", "F:3"}
local Q_D = {"A:2", "B:3", "C:2", "D:3", "E:2", "F:1", "G:3"}
local Q_E = {"A:2", "B:11", "C:3"}
local Q_F = {"A:2", "B:5", "C:3", "D:3", "E:3"}
local Q_G = {"A:2", "B:5", "C:6", "D:3"}
local Q_H = {"A:2", "B:3", "C:2", "D:3", "E:3", "F:3"}

--// Instruction Definitions:
return {
	--// RV32I Base Instruction Set
	LUI = {
		format = type_u,
		requires = { "opcode=0110111" }
	},
	AUIPC = {
		format = type_u,
		requires = { "opcode=0010111" }
	},
	JAL = {
		format = type_u,
		requires = { "opcode=1101111" }
	},
	JALR = {
		format = type_i,
		requires = { "opcode=1100111", "funct3=000" }
	},
	BEQ = {
		format = type_i,
		requires = { "opcode=1100011", "funct3=000" }
	},
	BNE = {
		format = type_i,
		requires = { "opcode=1100011", "funct3=001" }
	},
	BLT = {
		format = type_i,
		requires = { "opcode=1100011", "funct3=100" }
	},
	BGE = {
		format = type_i,
		requires = { "opcode=1100011", "funct3=101" }
	},
	BLTU = {
		format = type_i,
		requires = { "opcode=1100011", "funct3=110" }
	},
	BGEU = {
		format = type_i,
		requires = { "opcode=1100011", "funct3=111" }
	},
	LB = {
		format = type_i,
		requires = { "opcode=0000011", "funct3=000" }
	},
	LH = {
		format = type_i,
		requires = { "opcode=0000011", "funct3=001" }
	},
	LW = {
		format = type_i,
		requires = { "opcode=0000011", "funct3=010" }
	},
	LBU = {
		format = type_i,
		requires = { "opcode=0000011", "funct3=100" }
	},
	LHU = {
		format = type_i,
		requires = { "opcode=0000011", "funct3=101" }
	},
	SB = {
		format = type_s,
		requires = { "opcode=0100011", "funct3=000" }
	},
	SH = {
		format = type_s,
		requires = { "opcode=0100011", "funct3=001" }
	},
	SW = {
		format = type_s,
		requires = { "opcode=0100011", "funct3=010" }
	},
	ADDI = {
		format = type_i,
		requires = { "opcode=0010011", "funct3=000" }
	},
	SLTI = {
		format = type_i,
		requires = { "opcode=0010011", "funct3=010" }
	},
	SLTIU = {
		format = type_i,
		requires = { "opcode=0010011", "funct3=011" }
	},
	XORI = {
		format = type_i,
		requires = { "opcode=0010011", "funct3=100" }
	},
	ORI = {
		format = type_i,
		requires = { "opcode=0010011", "funct3=110" }
	},
	ANDI = {
		format = type_i,
		requires = { "opcode=0010011", "funct3=111" }
	},
	ADD = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=000", "funct7=0000000" }
	},
	SUB = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=000", "funct7=0100000" }
	},
	SLL = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=010", "funct7=0000000" }
	},
	SLT = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=011", "funct7=0000000" }
	},
	SLTU = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=011", "funct7=0000000" }
	},
	XOR = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=100", "funct7=0000000" }
	},
	SRL = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=101", "funct7=0000000" }
	},
	SRA = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=101", "funct7=0100000" }
	},
	OR = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=110", "funct7=0000000" }
	},
	AND = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=111", "funct7=0000000" }
	},
	-- These 3 instructions mostly have a throw-away format, although there may be a reason to check all, I wouldn't know right now
	FENCE = {
		format = { "opcode:7", "A:5", "funct3:3" },
		requires = { "opcode=0001111", "funct3=000" }
	},
	ECALL = {
		format = { "opcode:7", "A:5", "B:3", "C:5", "D:12" },
		requires = { "opcode=1110011", "D=000000000000" }
	},
	EBREAK = {
		format = { "opcode:7", "A:5", "B:3", "C:5", "D:12" },
		requires = { "opcode=1110011", "D=000000000001" }
	},
	
	--// RV64I Base Instruction Set
	AUIPCW = {
		format = type_u,
		requires = { "opcode=0010111" } -- Conflicts with AUIPC
	},
	JALW = {
		format = type_u,
		requires = { "opcode=1101111" }
	},
	JALRW = {
		format = type_i,
		requires = { "opcode=1100111", "funct3=000" }
	},
	LWU = {
		format = type_i,
		requires = { "opcode=0000011", "funct3=110" }
	},
	LD = {
		format = type_i,
		requires = { "opcode=0000011", "funct3=011" }
	},
	SD = {
		format = type_s,
		requires = { "opcode=0100011", "funct3=011" }
	},
	SLLI = {
		format = shamt,
		requires = { "opcode=0010011", "funct3=001", "funct6=000000" }
	},
	SRLI = {
		format = shamt,
		requires = { "opcode=0010011", "funct3=101", "funct6=000000" }
	},
	SRAI = {
		format = shamt,
		requires = { "opcode=0010011", "funct3=101", "funct6=010000" }
	},
	ADDIW = {
		format = type_i,
		requires = { "opcode=0011011", "funct3=000" }
	},
	SLLIW = {
		format = type_r,
		requires = { "opcode=0011011", "funct3=001", "funct7=0000000" }
	},
	SRLIW = {
		format = type_r,
		requires = { "opcode=0011011", "funct3=101", "funct7=0000000" }
	},
	SRAIW = {
		format = type_r,
		requires = { "opcode=0011011", "funct3=101", "funct7=0100000" }
	},
	ADDW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=000", "funct7=0000000" }
	},
	SUBW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=000", "funct7=0100000" }
	},
	SLLW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=001", "funct7=0000000" }
	},
	SRLW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=101", "funct7=0000000" }
	},
	SRAW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=101", "funct7=0100000" }
	},
	
	--// RV32/RV64 Zifencei Standard Extension
	FENCE_i = {
		format = { "opcode:7", "A:5", "funct3:3" },
		requires = { "opcode=0001111", "funct3=001" }
	},
	
	--// RV32/RV64 Zicsr Standard Extension
	CSRRW = {
		format = zicsr,
		requires = { "opcode=1110011", "funct3=001" }
	},
	CSRRS = {
		format = zicsr,
		requires = { "opcode=1110011", "funct3=010" }
	},
	CSRRC = {
		format = zicsr,
		requires = { "opcode=1110011", "funct3=011" }
	},
	CSRRWI = {
		format = zicsr,
		requires = { "opcode=1110011", "funct3=101" }
	},
	CSRRSI = {
		format = zicsr,
		requires = { "opcode=1110011", "funct3=110" }
	},
	CSRRCI = {
		format = zicsr,
		requires = { "opcode=1110011", "funct3=111" }
	},
	
	--// RV32M Standard Extension
	MUL = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=000", "funct7=0000001" }
	},
	MULH = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=001", "funct7=0000001" }
	},
	MULHSU = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=010", "funct7=0000001" }
	},
	MULHU = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=011", "funct7=0000001" }
	},
	DIV = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=100", "funct7=0000001" }
	},
	DIVU = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=101", "funct7=0000001" }
	},
	REM = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=110", "funct7=0000001" }
	},
	REMU = {
		format = type_r,
		requires = { "opcode=0110011", "funct3=111", "funct7=0000001" }
	},
	
	--// RV64M Standard Extension
	MULW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=000", "funct7=0000001" }
	},
	DIVW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=100", "funct7=0000001" }
	},
	DIVUW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=101", "funct7=0000001" }
	},
	REMW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=110", "funct7=0000001" }
	},
	REMUW = {
		format = type_r,
		requires = { "opcode=0111011", "funct3=111", "funct7=0000001" }
	},
	
	--// RV32A Standard Extension
	LR_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "rs2=00000", "funct5=00010" }
	},
	SC_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "funct5=00011" }
	},
	AMOSWAP_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "funct5=00001" }
	},
	AMOADD_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "funct5=00000" }
	},
	AMOOR_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "funct5=01000" }
	},
	AMOMIN_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "funct5=10000" }
	},
	AMOMAX_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "funct5=10100" }
	},
	AMOMINU_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "funct5=11000" }
	},
	AMOMAXU_W = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=010", "funct5=11100" }
	},
	
	--// RV64A Standard Extension
	LR_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "rs2=00000", "funct5=00010" }
	},
	SC_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "funct5=00011" }
	},
	AMOSWAP_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "funct5=00001" }
	},
	AMOADD_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "funct5=00000" }
	},
	AMOOR_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "funct5=01000" }
	},
	AMOMIN_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "funct5=10000" }
	},
	AMOMAX_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "funct5=10100" }
	},
	AMOMINU_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "funct5=11000" }
	},
	AMOMAXU_D = {
		format = type_a,
		requires = { "opcode=0101111", "funct3=011", "funct5=11100" }
	},
	
	--// RV32F Standard Extension
	FLW = {
		format = type_i,
		requires = { "opcode=0000111", "funct3=010" }
	},
	FSW = {
		format = type_s,
		requires = { "opcode=0100111", "funct3=010" }
	},
	FMADD_S = {
		format = { "opcode:7", "rd:5", "rm:3", "rs1:5", "rs2:5", "w:2", "rs3:5" },
		requires = { "opcode=1000011", "w=00" }
	},
	FMSUB_S = {
		format = { "opcode:7", "rd:5", "rm:3", "rs1:5", "rs2:5", "w:2", "rs3:5" },
		requires = { "opcode=1000111", "w=00" }
	},
	FNMADD_S = {
		format = { "opcode:7", "rd:5", "rm:3", "rs1:5", "rs2:5", "w:2", "rs3:5" },
		requires = { "opcode=1001111", "w=00" }
	},
	FNMSUB_S = {
		format = { "opcode:7", "rd:5", "rm:3", "rs1:5", "rs2:5", "w:2", "rs3:5" },
		requires = { "opcode=1001011", "w=00" }
	},
	FADD_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0000000" }
	},
	FSUB_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0000100" }
	},
	FMUL_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0001000" }
	},
	FDIV_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0001100" }
	},
	FSQRT_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0101100", "rs2=00000" }
	},
	FSGNJ_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "funct7=0010000" }
	},
	FSGNJN_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=001", "funct7=0010000" }
	},
	FSGNJX_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=010", "funct7=0010000" }
	},
	FMIN_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "funct7=0010100" }
	},
	FMAX_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=001", "funct7=0010100" }
	},
	FCVT_W_S = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00000", "funct7=1100000" }
	},
	FCVT_WU_S = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00001", "funct7=1100000" }
	},
	FMV_X_W = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "rs2=00000", "funct7=1110000" }
	},
	FEQ_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=010", "funct7=1010000" }
	},
	FLT_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=001", "funct7=1010000" }
	},
	FLE_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "funct7=1010000" }
	},
	FCLASS_S = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=001", "rs2=00000", "funct7=1110000" }
	},
	FCVT_S_W = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00000", "funct7=1101000" }
	},
	FCVT_S_WU = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00001", "funct7=1101000" }
	},
	FMV_W_X = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "rs2=00000", "funct7=1111000" }
	},
	
	--// RV64F Standard Extension
	FCVT_L_S = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00010", "funct7=1100000" }
	},
	FCVT_LU_S = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00011", "funct7=1100000" }
	},
	FCVT_S_L = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00010", "funct7=1101000" }
	},
	FCVT_S_LU = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00011", "funct7=1101000" }
	},
	
	--// RV32D Standard Extension
	FLD = {
		format = type_i,
		requires = { "opcode=0000111", "funct3=011" }
	},
	FSD = {
		format = type_s,
		requires = { "opcode=0100111", "funct3=011" }
	},
	FMADD_D = {
		format = { "opcode:7", "rd:5", "rm:3", "rs1:5", "rs2:5", "w:2", "rs3:5" },
		requires = { "opcode=1000011", "w=01" }
	},
	FMSUB_D = {
		format = { "opcode:7", "rd:5", "rm:3", "rs1:5", "rs2:5", "w:2", "rs3:5" },
		requires = { "opcode=1000111", "w=01" }
	},
	FNMADD_D = {
		format = { "opcode:7", "rd:5", "rm:3", "rs1:5", "rs2:5", "w:2", "rs3:5" },
		requires = { "opcode=1001111", "w=01" }
	},
	FNMSUB_D = {
		format = { "opcode:7", "rd:5", "rm:3", "rs1:5", "rs2:5", "w:2", "rs3:5" },
		requires = { "opcode=1001011", "w=01" }
	},
	FADD_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0000001" }
	},
	FSUB_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0000101" }
	},
	FMUL_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0001001" }
	},
	FDIV_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0001101" }
	},
	FSQRT_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct7=0101101", "rs2=00000" }
	},
	FSGNJ_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "funct7=0010001" }
	},
	FSGNJN_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=001", "funct7=0010001" }
	},
	FSGNJX_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=010", "funct7=0010001" }
	},
	FMIN_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "funct7=0010101" }
	},
	FMAX_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=001", "funct7=0010101" }
	},
	FCVT_W_D = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00000", "funct7=0100000" }
	},
	FCVT_WU_D = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00001", "funct7=0100001" }
	},
	FEQ_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=010", "funct7=1010001" }
	},
	FLT_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=001", "funct7=1010001" }
	},
	FLE_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "funct7=1010001" }
	},
	FCLASS_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=001", "rs2=00000", "funct7=1110001" }
	},
	FCVT_D_W = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00000", "funct7=1101001" }
	},
	FCVT_D_WU = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00001", "funct7=1101001" }
	},
	
	--// RV64D Standard Extension
	FCVT_L_D = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00010", "funct7=1100001" }
	},
	FCVT_LU_D = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00011", "funct7=1100001" }
	},
	FCVT_D_L = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00010", "funct7=1101001" }
	},
	FCVT_D_LU = {
		format = type_r,
		requires = { "opcode=1010011", "rs2=00011", "funct7=1101001" }
	},
	FMV_D_X = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "rs2=00000", "funct7=1111001" }
	},
	FMV_X_D = {
		format = type_r,
		requires = { "opcode=1010011", "funct3=000", "rs2=00000", "funct7=1110001" }
	},
	
	--// Privileged Instructions
	SRET = {
		format = type_r,
		requires = { "opcode=1110011", "rd=00000", "funct3=000", "rs1=00000", "rs2=00010", "funct7=0001000" }
	},
	MRET = {
		format = type_r,
		requires = { "opcode=1110011", "rd=00000", "funct3=000", "rs1=00000", "rs2=00010", "funct7=0011000" }
	},
	WFI = {
		format = type_r,
		requires = { "opcode=1110011", "rd=00000", "funct3=000", "rs1=00000", "rs2=00101", "funct7=0001000" }
	},
	SFENCE_VMA = {
		format = type_r,
		requires = { "opcode=1110011", "rd=00000", "funct3=000", "funct7=0001001" }
	},
	
	-- // Custom Instructions
	-- not currently applicable
	
	--// RV32C Standard Extension
	--// The most complex extension or: how I learned to stop worrying and hate writing the RISC-V instruction set
	
	-- Quadrant 0
	--[[illegal1 = { -- Defined illegal instruction
		format = Q_A,
		requires = { "A=00", "B=000", "C=00000000", "D=000" },
	},
	illegal2 = { -- Reserved
		format = Q_A,
		requires = { "A=00", "C=00000000", "D=000" },
	},
	C_ADDI4SPN = {
		format = Q_A,
		requires = { "A=00", "D=000" }
	},
	C_FLD = {
		format = Q_H,
		requires = { "A=00", "F=001" }
	},
	C_LW = {
		format = Q_H,
		requires = { "A=00", "F=010" }
	},
	C_LD = {
		format = Q_H,
		requires = { "A=00", "F=011" }
	},
	C_FSD = {
		format = Q_H,
		requires = { "A=00", "F=101" }
	},
	C_SW = {
		format = Q_H,
		requires = { "A=00", "F=110" }
	},
	C_SD = {
		format = Q_H,
		requires = { "A=00", "F=111" }
	},
	
	-- Quadrant 1
	nop1 = { -- Hint, needed to make next two instructions unambiguous.
		format = Q_B,
		requires = { "A=01", "B=00000", "C=00000", "D=0", "E=000" }
	},
	nop2 = { -- Defined NOP
		format = Q_B,
		requires = { "A=01", "C=00000", "E=000" }
	},
	nop3 = { -- Hint
		format = Q_B,
		requires = { "A=01", "B=00000", "D=0", "E=000" }
	},
	C_ADDI = {
		format = Q_B,
		requires = { "A=01", "E=000" }
	},
	C_ADDIW = {
		format = Q_B,
		requires = { "A=01", "E=001" }
	},
	nop4 = { -- Hint
		format = Q_B,
		requires = { "A=01", "C=00000", "E=010" }
	},
	C_LI = { -- ADDI?
		format = Q_B,
		requires = { "A=01", "E=010" }
	},
	illegal3 = { -- Reserved
		format = Q_B,
		requires = { "A=01", "B=00000", "C=00010", "D=0", "E=011" }
	},
	C_ADDI16SP = { -- ADDI?
		format = Q_B,
		requires = { "A=01", "C=00010",  "E=011" }
	},
	nop5 = { -- Hint
		format = Q_B,
		requires = { "A=01", "C=00000", "E=011" }
	},
	CLUI = {
		format = Q_B,
		requires = { "A=01", "E=011" }
	},
	C_SRLI = {
		format = Q_C,
		requires = { "A=01", "D=00", "F=100" }
	},
	nop6 = { -- Hint
		format = Q_C,
		requires = { "A=01", "B=00000", "D=00", "E=0", "F=100" }
	},
	C_SRAI = {
		format = Q_C,
		requires = { "A=01", "D=01", "F=100" }
	},
	C_ANDI = {
		format = Q_C,
		requires = { "A=01", "D=10", "F=100" }
	},
	C_SUB = {
		format = Q_D,
		requires = { "A=01", "C=00", "E=11", "F=0", "G=100" }
	},
	C_XOR = {
		format = Q_D,
		requires = { "A=01", "C=01", "E=11", "F=0", "G=100" }
	},
	C_OR = {
		format = Q_D,
		requires = { "A=01", "C=10", "E=11", "F=0", "G=100" }
	},
	C_AND = {
		format = Q_D,
		requires = { "A=01", "C=11", "E=11", "F=0", "G=100" }
	},
	C_SUBW = {
		format = Q_D,
		requires = { "A=01", "C=00", "E=11", "F=1", "G=100" }
	},
	C_ADDW = {
		format = Q_D,
		requires = { "A=01", "C=01", "E=11", "F=1", "G=100" }
	},
	C_J = {
		format = Q_E,
		requires = { "A=01", "C=101" }
	},
	C_BEQZ = {
		format = Q_F,
		requires = { "A=01", "E=110" }
	},
	C_BNEZ = {
		format = Q_F,
		requires = { "A=01", "E=111" }
	},
	
	-- Quadrant 2
	-- Note: instructions in this quadrant have potential of conflicting due to the strange method of identification
	-- Might need to have a specialized system for decoding Quadrant 2 instructions
	nop7 = { -- Hint
		format = Q_B,
		requires = { "A=10", "C=0000", "E=000" }
	},
	C_SLLI = {
		format = Q_B,
		requires = { "A=10", "E=000" }
	},
	C_FLDSP = {
		format = Q_B,
		requires = { "A=10", "E=001" }
	},
	illegal4 = { -- Reserved
		format = Q_B,
		requires = { "A=10", "C=00000", "E=010" }
	},
	C_LWSP = {
		format = Q_B,
		requires = { "A=10", "E=010" }
	},
	illegal5 = { -- Reserved
		format = Q_B,
		requires = { "A=10", "C=00000", "E=011" }
	},
	C_LDSP = {
		format = Q_B,
		requires = { "A=10", "E=011" }
	},
	illegal6 = { -- Reserved
		format = Q_B,
		requires = { "A=10", "B=00000", "C=00000", "D=0", "E=100" }
	},
	C_JR = {
		format = Q_B,
		requires = { "A=10", "B=00000", "D=0", "E=100" }
	},
	nop8 = {
		format = Q_B,
		requires = { "A=10", "C=00000", "D=0", "E=100" }
	},
	C_MV = {
		format = Q_B,
		requires = { "A=10", "D=0", "E=100" }
	},
	C_EBREAK = {
		format = Q_B,
		requires = { "A=10", "B=00000", "C=00000", "D=1", "E=100" }
	},
	C_JALJAR = {
		format = Q_B,
		requires = { "A=10", "B=00000", "D=1", "E=100" }
	},
	nop9 = { -- Hint
		format = Q_B,
		requires = { "A=10", "C=00000", "D=1", "E=100" }
	},
	C_ADD = {
		format = Q_B,
		requires = { "A=10", "D=1", "E=100" }
	},
	C_FSDSP = {
		format = Q_G,
		requires = { "A=10", "D=101" }
	},
	C_SWSP = {
		format = Q_G,
		requires = { "A=10", "D=110" }
	},
	C_SDSP = {
		format = Q_G,
		requires = { "A=10", "D=111" }
	}]]
}
