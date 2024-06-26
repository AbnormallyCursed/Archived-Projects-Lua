-- AbnormallyCursed and ???
-- This file is a port attempt, credit to whomever made this, this port was a long time ago so I have no idea.

function const(x)
	return setmetatable({}, { __index = x,
		__newindex = function(table, key, value)
			error("Attempt to modify read-only table")
		end,
		__metatable = false
	})
end

local _M = {}
local lshift = bit32.lshift
local rshift = bit32.rshift
local band = bit32.band
local bor = bit32.bor
local bnot = bit32.bnot -- One's complement
local bxor = bit32.bxor

_M.ram = {}

_M.flags = const {
	N = ( lshift(1, 7) ),
	V = ( lshift(1,6) ),
	UNK = ( lshift(1,5) ),
	B = ( lshift(1,4) ),
	D = ( lshift(1,3) ),
	I = ( lshift(1,2) ),
	Z = ( lshift(1,1) ),
	C = ( lshift(1,0) )
}

_M.addrmode = const {
	ILLEGAL = 0,
	IMM = 1,
	ABS = 2,
	ZER = 3,
	IMP = 4,
	ACC = 5,
	REL = 6,
	ABI = 7,
	ZEX = 8,
	ZEY = 9,
	ZIND = 10,
	ABX = 11,
	ABXI = 12,
	ABY = 13,
	INX = 14,
	INY = 15,
	ZPREL = 16
}

_M.optype = const {
	ILLEGAL = 0,
	ADC = 1,
	AND = 2,
	ASL = 3,
	ASL_ACC = 4,
	BCC = 5,
	BCS = 6,
	BEQ = 7,
	BIT = 8,
	BMI = 9,
	BNE = 10,
	BPL = 11,
	BRA = 12,
	BRK = 13,
	BVC = 14,
	BVS = 15,
	CLC = 16,
	CLD = 17,
	CLI = 18,
	CLV = 19,
	CMP = 20,
	CPX = 21,
	CPY = 22,
	DEC = 23,
	DEC_ACC = 24,
	DEX = 25,
	DEY = 26,
	EOR = 27,
	INC = 28,
	INC_ACC = 29,
	INX = 30,
	INY = 31,
	JMP = 32,
	JSR = 33,
	LDA = 34,
	LDX = 35,
	LDY = 36,
	LSR = 37,
	LSR_ACC = 38,
	NOP = 39,
	ORA = 40,
	PHA = 41,
	PHP = 42,
	PHX = 43,
	PHY = 44,
	PLA = 45,
	PLP = 46,
	PLX = 47,
	PLY = 48,
	ROL = 49,
	ROL_ACC = 50,
	ROR = 51,
	ROR_ACC = 52,
	RTI = 53,
	RTS = 54,
	SBC = 55,
	SEC = 56,
	SED = 57,
	SEI = 58,
	STA = 59,
	STX = 60,
	STY = 61,
	STZ = 62,
	TAX = 63,
	TAY = 64,
	TRB = 65,
	TSB = 66,
	TSX = 67,
	TXA = 68,
	TXS = 69,
	TYA = 70,

	BBR = 71,
	BBS = 72,
	RMB = 73,
	SMB = 74,

	WAI = 75,

	-- and the "illegal" opcodes (those that don't officially exist for
	-- the 65c02, but have repeatable results)
	DCP = 76
}

_M.opname = const {
	[_M.optype.ILLEGAL] = "???",
	[_M.optype.ADC] = "ADC",
	[_M.optype.AND] = "AND",
	[_M.optype.ASL] = "ASL",
	[_M.optype.ASL_ACC] = "ASL",
	[_M.optype.BCC] = "BCC",
	[_M.optype.BCS] = "BCS",
	[_M.optype.BEQ] = "BEQ",
	[_M.optype.BIT] = "BIT",
	[_M.optype.BMI] = "BMI",
	[_M.optype.BNE] = "BNE",
	[_M.optype.BPL] = "BPL",
	[_M.optype.BRA] = "BRA",
	[_M.optype.BRK] = "BRK",
	[_M.optype.BVC] = "BVC",
	[_M.optype.BVS] = "BVS",
	[_M.optype.CLC] = "CLC",
	[_M.optype.CLD] = "CLD",
	[_M.optype.CLI] = "CLI",
	[_M.optype.CLV] = "CLV",
	[_M.optype.CMP] = "CMP",
	[_M.optype.CPX] = "CPX",
	[_M.optype.CPY] = "CPY",
	[_M.optype.DEC] = "DEC",
	[_M.optype.DEC_ACC] = "DEC",
	[_M.optype.DEX] = "DEX",
	[_M.optype.DEY] = "DEY",
	[_M.optype.EOR] = "EOR",
	[_M.optype.INC] = "INC",
	[_M.optype.INC_ACC] = "INC",
	[_M.optype.INX] = "INX",
	[_M.optype.INY] = "INY",
	[_M.optype.JMP] = "JMP",
	[_M.optype.JSR] = "JSR",
	[_M.optype.LDA] = "LDA",
	[_M.optype.LDX] = "LDX",
	[_M.optype.LDY] = "LDY",
	[_M.optype.LSR] = "LSR",
	[_M.optype.LSR_ACC] = "LSR",
	[_M.optype.NOP] = "NOP",
	[_M.optype.ORA] = "ORA",
	[_M.optype.PHA] = "PHA",
	[_M.optype.PHP] = "PHP",
	[_M.optype.PHX] = "PHX",
	[_M.optype.PHY] = "PHY",
	[_M.optype.PLA] = "PLA",
	[_M.optype.PLP] = "PLP",
	[_M.optype.PLX] = "PLX",
	[_M.optype.PLY] = "PLY",
	[_M.optype.ROL] = "ROL",
	[_M.optype.ROL_ACC] = "ROL",
	[_M.optype.ROR] = "ROR",
	[_M.optype.ROR_ACC] = "ROR",
	[_M.optype.RTI] = "RTI",
	[_M.optype.RTS] = "RTS",
	[_M.optype.SBC] = "SBC",
	[_M.optype.SEC] = "SEC",
	[_M.optype.SED] = "SED",
	[_M.optype.SEI] = "SEI",
	[_M.optype.STA] = "STA",
	[_M.optype.STX] = "STX",
	[_M.optype.STY] = "STY",
	[_M.optype.STZ] = "STZ",
	[_M.optype.TAX] = "TAX",
	[_M.optype.TAY] = "TAY",
	[_M.optype.TRB] = "TRB",
	[_M.optype.TSB] = "TSB",
	[_M.optype.TSX] = "TSX",
	[_M.optype.TXA] = "TXA",
	[_M.optype.TXS] = "TXS",
	[_M.optype.TYA] = "TYA",
	[_M.optype.BBR] = "BBR",
	[_M.optype.BBS] = "BBS",
	[_M.optype.RMB] = "RMB",
	[_M.optype.SMB] = "SMB",
	[_M.optype.WAI] = "WAI",
	[_M.optype.DCP] = "???",
}

_M.opcodes = {
	[0x00] = { _M.optype.BRK    , _M.addrmode.IMP    , 7 },
	[0x01] = { _M.optype.ORA    , _M.addrmode.INX    , 6 }, -- e.g. "ORA ($44,X)" [2]
	[0x02] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x03] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x04] = { _M.optype.TSB    , _M.addrmode.ZER    , 5 }, -- [2]
	[0x05] = { _M.optype.ORA    , _M.addrmode.ZER    , 3 }, -- e.g. "ORA $44" [2]
	[0x06] = { _M.optype.ASL    , _M.addrmode.ZER    , 5 }, -- [2]
	[0x07] = { _M.optype.RMB    , _M.addrmode.ZER    , 5 },
	[0x08] = { _M.optype.PHP    , _M.addrmode.IMP    , 3 },
	[0x09] = { _M.optype.ORA    , _M.addrmode.IMM    , 2 }, -- e.g. "ORA #$44"
	[0x0A] = { _M.optype.ASL_ACC, _M.addrmode.ACC    , 2 },
	[0x0B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x0C] = { _M.optype.TSB    , _M.addrmode.ABS    , 6 },
	[0x0D] = { _M.optype.ORA    , _M.addrmode.ABS    , 4 },
	[0x0E] = { _M.optype.ASL    , _M.addrmode.ABS    , 6 },
	[0x0F] = { _M.optype.BBR    , _M.addrmode.ZPREL  , 5 },
	[0x10] = { _M.optype.BPL    , _M.addrmode.REL    , 2 }, -- [8]
	[0x11] = { _M.optype.ORA    , _M.addrmode.INY    , 5 }, -- e.g. "ORA ($44),Y" [2,3]
	[0x12] = { _M.optype.ORA    , _M.addrmode.ZIND   , 5 }, -- [2]
	[0x13] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x14] = { _M.optype.TRB    , _M.addrmode.ZER    , 5 }, -- [2]
	[0x15] = { _M.optype.ORA    , _M.addrmode.ZEX    , 4 }, -- e.g. "ORA $44,X" [2]
	[0x16] = { _M.optype.ASL    , _M.addrmode.ZEX    , 6 }, -- [2]
	[0x17] = { _M.optype.RMB    , _M.addrmode.ZER    , 5 },
	[0x18] = { _M.optype.CLC    , _M.addrmode.IMP    , 2 },
	[0x19] = { _M.optype.ORA    , _M.addrmode.ABY    , 4 }, -- e.g. "ORA $4400,Y" [3]
	[0x1A] = { _M.optype.INC_ACC, _M.addrmode.ACC    , 2 },
	[0x1B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x1C] = { _M.optype.TRB    , _M.addrmode.ABS    , 6 }, -- [3]
	[0x1D] = { _M.optype.ORA    , _M.addrmode.ABX    , 4 }, -- e.g. "ORA $4400,X"
	[0x1E] = { _M.optype.ASL    , _M.addrmode.ABX    , 6 }, -- [6]
	[0x1F] = { _M.optype.BBR    , _M.addrmode.ZPREL  , 5 },
	[0x20] = { _M.optype.JSR    , _M.addrmode.ABS    , 6 },
	[0x21] = { _M.optype.AND    , _M.addrmode.INX    , 6 }, -- [2]
	[0x22] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x23] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x24] = { _M.optype.BIT    , _M.addrmode.ZER    , 3 }, -- [2]
	[0x25] = { _M.optype.AND    , _M.addrmode.ZER    , 3 }, -- [2]
	[0x26] = { _M.optype.ROL    , _M.addrmode.ZER    , 5 }, -- [2]
	[0x27] = { _M.optype.RMB    , _M.addrmode.ZER    , 5 },
	[0x28] = { _M.optype.PLP    , _M.addrmode.IMP    , 4 },
	[0x29] = { _M.optype.AND    , _M.addrmode.IMM    , 2 },
	[0x2A] = { _M.optype.ROL_ACC, _M.addrmode.ACC    , 2 },
	[0x2B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x2C] = { _M.optype.BIT    , _M.addrmode.ABS    , 4 },
	[0x2D] = { _M.optype.AND    , _M.addrmode.ABS    , 4 },
	[0x2E] = { _M.optype.ROL    , _M.addrmode.ABS    , 6 },
	[0x2F] = { _M.optype.BBR    , _M.addrmode.ZPREL  , 5 },
	[0x30] = { _M.optype.BMI    , _M.addrmode.REL    , 2 }, -- [8]
	[0x31] = { _M.optype.AND    , _M.addrmode.INY    , 5 }, -- [2,3]
	[0x32] = { _M.optype.AND    , _M.addrmode.ZIND   , 5 }, -- [2]
	[0x33] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x34] = { _M.optype.BIT    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0x35] = { _M.optype.AND    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0x36] = { _M.optype.ROL    , _M.addrmode.ZEX    , 6 }, -- [2]
	[0x37] = { _M.optype.RMB    , _M.addrmode.ZER    , 5 },
	[0x38] = { _M.optype.SEC    , _M.addrmode.IMP    , 2 },
	[0x39] = { _M.optype.AND    , _M.addrmode.ABY    , 4 }, -- [3]
	[0x3A] = { _M.optype.DEC_ACC, _M.addrmode.ACC    , 2 }, -- [2]
	[0x3B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x3C] = { _M.optype.BIT    , _M.addrmode.ABX    , 4 }, -- [3]
	[0x3D] = { _M.optype.AND    , _M.addrmode.ABX    , 4 }, -- [3]
	[0x3E] = { _M.optype.ROL    , _M.addrmode.ABX    , 6 }, -- [6]
	[0x3F] = { _M.optype.BBR    , _M.addrmode.ZPREL  , 5 },
	[0x40] = { _M.optype.RTI    , _M.addrmode.IMP    , 6 },
	[0x41] = { _M.optype.EOR    , _M.addrmode.INX    , 6 }, -- [2]
	[0x42] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x43] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x44] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x45] = { _M.optype.EOR    , _M.addrmode.ZER    , 3 }, -- [2]
	[0x46] = { _M.optype.LSR    , _M.addrmode.ZER    , 5 }, -- [2]
	[0x47] = { _M.optype.RMB    , _M.addrmode.ZER    , 5 },
	[0x48] = { _M.optype.PHA    , _M.addrmode.IMP    , 3 },
	[0x49] = { _M.optype.EOR    , _M.addrmode.IMM    , 2 },
	[0x4A] = { _M.optype.LSR_ACC, _M.addrmode.ACC    , 2 },
	[0x4B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x4C] = { _M.optype.JMP    , _M.addrmode.ABS    , 3 },
	[0x4D] = { _M.optype.EOR    , _M.addrmode.ABS    , 4 },
	[0x4E] = { _M.optype.LSR    , _M.addrmode.ABS    , 6 },
	[0x4F] = { _M.optype.BBR    , _M.addrmode.ZPREL  , 5 },
	[0x50] = { _M.optype.BVC    , _M.addrmode.REL    , 2 }, -- [8]
	[0x51] = { _M.optype.EOR    , _M.addrmode.INY    , 5 }, -- [2,3]
	[0x52] = { _M.optype.EOR    , _M.addrmode.ZIND   , 5 },
	[0x53] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x54] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x55] = { _M.optype.EOR    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0x56] = { _M.optype.LSR    , _M.addrmode.ZEX    , 6 }, -- [2]
	[0x57] = { _M.optype.RMB    , _M.addrmode.ZER    , 5 }, 
	[0x58] = { _M.optype.CLI    , _M.addrmode.IMP    , 2 }, 
	[0x59] = { _M.optype.EOR    , _M.addrmode.ABY    , 4 }, -- [3]
	[0x5A] = { _M.optype.PHY    , _M.addrmode.IMP    , 3 }, 
	[0x5B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x5C] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x5D] = { _M.optype.EOR    , _M.addrmode.ABX    , 4 }, -- [3]
	[0x5E] = { _M.optype.LSR    , _M.addrmode.ABX    , 6 }, -- [6]
	[0x5F] = { _M.optype.BBR    , _M.addrmode.ZPREL  , 5 }, 
	[0x60] = { _M.optype.RTS    , _M.addrmode.IMP    , 6 }, 
	[0x61] = { _M.optype.ADC    , _M.addrmode.INX    , 6 }, -- [2]
	[0x62] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x63] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x64] = { _M.optype.STZ    , _M.addrmode.ZER    , 3 }, -- [2]
	[0x65] = { _M.optype.ADC    , _M.addrmode.ZER    , 3 }, -- [2]
	[0x66] = { _M.optype.ROR    , _M.addrmode.ZER    , 5 }, -- [2]
	[0x67] = { _M.optype.RMB    , _M.addrmode.ZER    , 5 }, 
	[0x68] = { _M.optype.PLA    , _M.addrmode.IMP    , 4 }, 
	[0x69] = { _M.optype.ADC    , _M.addrmode.IMM    , 2 }, 
	[0x6A] = { _M.optype.ROR_ACC, _M.addrmode.ACC    , 2 }, -- [2]
	[0x6B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x6C] = { _M.optype.JMP    , _M.addrmode.ABI    , 6 }, 
	[0x6D] = { _M.optype.ADC    , _M.addrmode.ABS    , 4 }, 
	[0x6E] = { _M.optype.ROR    , _M.addrmode.ABS    , 6 }, 
	[0x6F] = { _M.optype.BBR    , _M.addrmode.ZPREL  , 5 }, 
	[0x70] = { _M.optype.BVS    , _M.addrmode.REL    , 2 }, -- [8]
	[0x71] = { _M.optype.ADC    , _M.addrmode.INY    , 5 }, -- [2,3]
	[0x72] = { _M.optype.ADC    , _M.addrmode.ZIND   , 5 }, -- [2]
	[0x73] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x74] = { _M.optype.STZ    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0x75] = { _M.optype.ADC    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0x76] = { _M.optype.ROR    , _M.addrmode.ZEX    , 6 }, -- [2]
	[0x77] = { _M.optype.RMB    , _M.addrmode.ZER    , 5 }, 
	[0x78] = { _M.optype.SEI    , _M.addrmode.IMP    , 2 }, 
	[0x79] = { _M.optype.ADC    , _M.addrmode.ABY    , 4 }, -- [3]
	[0x7A] = { _M.optype.PLY    , _M.addrmode.IMP    , 4 }, 
	[0x7B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x7C] = { _M.optype.JMP    , _M.addrmode.ABXI   , 6 }, -- e.g. "JMP (ABS, X)"
	[0x7D] = { _M.optype.ADC    , _M.addrmode.ABX    , 4 }, -- Absolute,X    ADC $4400,X [3]
	[0x7E] = { _M.optype.ROR    , _M.addrmode.ABX    , 6 }, -- [6]
	[0x7F] = { _M.optype.BBR    , _M.addrmode.ZPREL  , 5 },
	[0x80] = { _M.optype.BRA    , _M.addrmode.REL    , 3 }, -- [8]
	[0x81] = { _M.optype.STA    , _M.addrmode.INX    , 6 }, -- [2]
	[0x82] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x83] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x84] = { _M.optype.STY    , _M.addrmode.ZER    , 3 }, -- [2]
	[0x85] = { _M.optype.STA    , _M.addrmode.ZER    , 3 }, -- [2]
	[0x86] = { _M.optype.STX    , _M.addrmode.ZER    , 3 }, -- [2]
	[0x87] = { _M.optype.SMB    , _M.addrmode.ZER    , 5 },
	[0x88] = { _M.optype.DEY    , _M.addrmode.IMP    , 2 },
	[0x89] = { _M.optype.BIT    , _M.addrmode.IMM    , 2 },
	[0x8A] = { _M.optype.TXA    , _M.addrmode.IMP    , 2 },
	[0x8B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x8C] = { _M.optype.STY    , _M.addrmode.ABS    , 4 },
	[0x8D] = { _M.optype.STA    , _M.addrmode.ABS    , 4 },
	[0x8E] = { _M.optype.STX    , _M.addrmode.ABS    , 4 },
	[0x8F] = { _M.optype.BBS    , _M.addrmode.ZPREL  , 5 },
	[0x90] = { _M.optype.BCC    , _M.addrmode.REL    , 2 }, -- [8]
	[0x91] = { _M.optype.STA    , _M.addrmode.INY    , 6 }, -- [2]
	[0x92] = { _M.optype.STA    , _M.addrmode.ZIND   , 5 }, -- [2]
	[0x93] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x94] = { _M.optype.STY    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0x95] = { _M.optype.STA    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0x96] = { _M.optype.STX    , _M.addrmode.ZEY    , 4 }, -- [2]
	[0x97] = { _M.optype.SMB    , _M.addrmode.ZER    , 5 },
	[0x98] = { _M.optype.TYA    , _M.addrmode.IMP    , 2 },
	[0x99] = { _M.optype.STA    , _M.addrmode.ABY    , 5 },
	[0x9A] = { _M.optype.TXS    , _M.addrmode.IMP    , 2 }, -- [2]
	[0x9B] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0x9C] = { _M.optype.STZ    , _M.addrmode.ABS    , 4 },
	[0x9D] = { _M.optype.STA    , _M.addrmode.ABX    , 5 },
	[0x9E] = { _M.optype.STZ    , _M.addrmode.ABX    , 5 },
	[0x9F] = { _M.optype.BBS    , _M.addrmode.ZPREL  , 5 },
	[0xA0] = { _M.optype.LDY    , _M.addrmode.IMM    , 2 },
	[0xA1] = { _M.optype.LDA    , _M.addrmode.INX    , 6 }, -- [2]
	[0xA2] = { _M.optype.LDX    , _M.addrmode.IMM    , 2 },
	[0xA3] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xA4] = { _M.optype.LDY    , _M.addrmode.ZER    , 3 }, -- [2]
	[0xA5] = { _M.optype.LDA    , _M.addrmode.ZER    , 3 }, -- [2]
	[0xA6] = { _M.optype.LDX    , _M.addrmode.ZER    , 3 }, -- [2]
	[0xA7] = { _M.optype.SMB    , _M.addrmode.ZER    , 5 },
	[0xA8] = { _M.optype.TAY    , _M.addrmode.IMP    , 2 },
	[0xA9] = { _M.optype.LDA    , _M.addrmode.IMM    , 2 },
	[0xAA] = { _M.optype.TAX    , _M.addrmode.IMP    , 2 },
	[0xAB] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xAC] = { _M.optype.LDY    , _M.addrmode.ABS    , 4 },
	[0xAD] = { _M.optype.LDA    , _M.addrmode.ABS    , 4 },
	[0xAE] = { _M.optype.LDX    , _M.addrmode.ABS    , 4 },
	[0xAF] = { _M.optype.BBS    , _M.addrmode.ZPREL  , 5 },
	[0xB0] = { _M.optype.BCS    , _M.addrmode.REL    , 2 }, -- [8]
	[0xB1] = { _M.optype.LDA    , _M.addrmode.INY    , 5 }, -- [2,3]
	[0xB2] = { _M.optype.LDA    , _M.addrmode.ZIND   , 5 }, -- [2]
	[0xB3] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xB4] = { _M.optype.LDY    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0xB5] = { _M.optype.LDA    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0xB6] = { _M.optype.LDX    , _M.addrmode.ZEY    , 4 }, -- [2]
	[0xB7] = { _M.optype.SMB    , _M.addrmode.ZER    , 5 },
	[0xB8] = { _M.optype.CLV    , _M.addrmode.IMP    , 2 },
	[0xB9] = { _M.optype.LDA    , _M.addrmode.ABY    , 4 }, -- [3]
	[0xBA] = { _M.optype.TSX    , _M.addrmode.IMP    , 2 },
	[0xBB] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xBC] = { _M.optype.LDY    , _M.addrmode.ABX    , 4 }, -- [3]
	[0xBD] = { _M.optype.LDA    , _M.addrmode.ABX    , 4 }, -- [3]
	[0xBE] = { _M.optype.LDX    , _M.addrmode.ABY    , 4 }, -- [3]
	[0xBF] = { _M.optype.BBS    , _M.addrmode.ZPREL  , 5 },
	[0xC0] = { _M.optype.CPY    , _M.addrmode.IMM    , 2 },
	[0xC1] = { _M.optype.CMP    , _M.addrmode.INX    , 6 }, -- [2]
	[0xC2] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xC3] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 }, -- fixme -- cycle count of this illegal instruction?
	[0xC4] = { _M.optype.CPY    , _M.addrmode.ZER    , 3 }, -- [2]
	[0xC5] = { _M.optype.CMP    , _M.addrmode.ZER    , 3 }, -- [2]
	[0xC6] = { _M.optype.DEC    , _M.addrmode.ZER    , 5 }, -- [2]
	[0xC7] = { _M.optype.SMB    , _M.addrmode.ZER    , 5 },
	[0xC8] = { _M.optype.INY    , _M.addrmode.IMP    , 2 },
	[0xC9] = { _M.optype.CMP    , _M.addrmode.IMM    , 2 },
	[0xCA] = { _M.optype.DEX    , _M.addrmode.IMP    , 2 },
	[0xCB] = { _M.optype.WAI    , _M.addrmode.IMP    , 2 },
	[0xCC] = { _M.optype.CPY    , _M.addrmode.ABS    , 4 },
	[0xCD] = { _M.optype.CMP    , _M.addrmode.ABS    , 4 },
	[0xCE] = { _M.optype.DEC    , _M.addrmode.ABS    , 6 },
	[0xCF] = { _M.optype.BBS    , _M.addrmode.ZPREL  , 5 },
	[0xD0] = { _M.optype.BNE    , _M.addrmode.REL    , 2 }, -- [8]
	[0xD1] = { _M.optype.CMP    , _M.addrmode.INY    , 5 }, -- [2,3]
	[0xD2] = { _M.optype.CMP    , _M.addrmode.ZIND   , 5 }, -- [2]
	[0xD3] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xD4] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xD5] = { _M.optype.CMP    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0xD6] = { _M.optype.DEC    , _M.addrmode.ZEX    , 6 }, -- [2]
	[0xD7] = { _M.optype.SMB    , _M.addrmode.ZER    , 5 },
	[0xD8] = { _M.optype.CLD    , _M.addrmode.IMP    , 2 },
	[0xD9] = { _M.optype.CMP    , _M.addrmode.ABY    , 4 }, -- [3]
	[0xDA] = { _M.optype.PHX    , _M.addrmode.IMP    , 3 },
	[0xDB] = { _M.optype.DCP    , _M.addrmode.ABY    , 2 }, -- fixme -- cycle count of this illegal instruction?
	[0xDC] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xDD] = { _M.optype.CMP    , _M.addrmode.ABX    , 4 }, -- [3]
	[0xDE] = { _M.optype.DEC    , _M.addrmode.ABX    , 6 }, -- [6]
	[0xDF] = { _M.optype.BBS    , _M.addrmode.ZPREL  , 5 },
	[0xE0] = { _M.optype.CPX    , _M.addrmode.IMM    , 2 },
	[0xE1] = { _M.optype.SBC    , _M.addrmode.INX    , 6 }, -- [2]
	[0xE2] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xE3] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xE4] = { _M.optype.CPX    , _M.addrmode.ZER    , 3 }, -- [2]
	[0xE5] = { _M.optype.SBC    , _M.addrmode.ZER    , 3 }, -- [2]
	[0xE6] = { _M.optype.INC    , _M.addrmode.ZER    , 5 }, -- [2]
	[0xE7] = { _M.optype.SMB    , _M.addrmode.ZER    , 5 },
	[0xE8] = { _M.optype.INX    , _M.addrmode.IMP    , 2 },
	[0xE9] = { _M.optype.SBC    , _M.addrmode.IMM    , 2 },
	[0xEA] = { _M.optype.NOP    , _M.addrmode.IMP    , 2 },
	[0xEB] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xEC] = { _M.optype.CPX    , _M.addrmode.ABS    , 4 },
	[0xED] = { _M.optype.SBC    , _M.addrmode.ABS    , 4 },
	[0xEE] = { _M.optype.INC    , _M.addrmode.ABS    , 6 },
	[0xEF] = { _M.optype.BBS    , _M.addrmode.ZPREL  , 5 },
	[0xF0] = { _M.optype.BEQ    , _M.addrmode.REL    , 2 }, -- [8]
	[0xF1] = { _M.optype.SBC    , _M.addrmode.INY    , 5 }, -- [2,3]
	[0xF2] = { _M.optype.SBC    , _M.addrmode.ZIND   , 5 }, -- [2]
	[0xF3] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xF4] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xF5] = { _M.optype.SBC    , _M.addrmode.ZEX    , 4 }, -- [2]
	[0xF6] = { _M.optype.INC    , _M.addrmode.ZEX    , 6 }, -- [2]
	[0xF7] = { _M.optype.SMB    , _M.addrmode.ZER    , 5 },
	[0xF8] = { _M.optype.SED    , _M.addrmode.IMP    , 2 },
	[0xF9] = { _M.optype.SBC    , _M.addrmode.ABY    , 4 }, -- [3]
	[0xFA] = { _M.optype.PLX    , _M.addrmode.IMP    , 4 },
	[0xFB] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xFC] = { _M.optype.ILLEGAL, _M.addrmode.ILLEGAL, 2 },
	[0xFD] = { _M.optype.SBC    , _M.addrmode.ABX    , 4 }, -- [3]
	[0xFE] = { _M.optype.INC    , _M.addrmode.ABX    , 6 }, -- [6]
	[0xFF] = { _M.optype.BBS    , _M.addrmode.ZPREL  , 5 }
}
-- cycle count footnotes:                                                       
--   2: Add 1 cycle if low byte of Direct Page Register is non-zero                  
--   3 Add 1 cycle if adding index crosses a page boundary                           
--   6 Add 1 cycle if 65C02 and page boundary crossed                                
--   8 Add 1 cycle if branch taken crosses page boundary on 6502, 65C02, or 65816's
--     6502 emulation mode (e=1)                                                       

_M.getParam = {
	[_M.addrmode.ILLEGAL] = function(self) return nil end,
	[_M.addrmode.IMP] = function(self) return nil end,
	[_M.addrmode.ACC] = function(self) return nil end,
	[_M.addrmode.IMM] = function(self) 
		-- Immediate: the next byte @ PC
		local param = self.pc
		self.pc = band((self.pc + 1), 0xFFFF)
		return param
	end,
	[_M.addrmode.ABS] = function(self)
		-- Absolute: the address referred to is in the next 2 bytes @ PC
		local p = bor(self:readmem(self.pc), lshift(band(self:readmem((self.pc+1), 0xFFFF)), 8))
		self.pc = band((self.pc + 2), 0xFFFF)
		return p
	end,
	[_M.addrmode.ABX] = function(self)
		-- absolute indexed, based on X
		local p = bor(self:readmem(self.pc), lshift(band(self:readmem((self.pc+1), 0xFFFF), 8))) + self.X
		self.pc = band((self.pc + 2), 0xFFFF)
		return p
	end,
	[_M.addrmode.ABXI] = function(self)
		-- Indirect absolute indexed, based on X
		local p = bor(self:readmem(self.pc, (lshift(self:readmem(band(self.pc+1, 0xFFFF)), 8)))) + self.X
		p = bor(self:readmem(p), (lshift(self:readmem(band((p+1), 0xFFFF)), 8)))
		self.pc = band((self.pc + 2), 0xFFFF)
		return p
	end,
	[_M.addrmode.REL] = function(self)
		-- Relative

		-- Have to convert this from an unsigned byte to a signed byte.
		-- Values are from -128 to +127.
		local p = self:unsignedToSigned(self:readmem(self.pc))
		self.pc = band((self.pc + 1), 0xFFFF)
		p = (p + band(self.pc, 0xFFFF))
		return p
	end,
	[_M.addrmode.ZPREL] = function(self)
		-- Two params - zero page and relative
		local p = self:readmem(self.pc) -- a zero-page memory location
		self.pc = band((self.pc + 1), 0xFFFF)

		-- Again, have to convert from unsigned byte to signed byte
		local zprelParam2 = self:unsignedToSigned(self:readmem(self.pc))

		self.pc = band((self.pc + 1), 0xFFFF)
		zprelParam2 = band((zprelParam2 + self.pc), 0xFFFF)
		return p, zprelParam2
	end,
	[_M.addrmode.ABI] = function(self)
		-- Absolute indirect
		local a = bor(self:readmem(self.pc), lshift(self:readmem((self.pc+1), 0xFFFF), 8))
		self.pc = band((self.pc + 2), 0xFFFF)
		local param = a
		param = bor(self:readmem(a), lshift( band(self:readmem((a+1), 0xFFFF) ), 8))
		return param
	end,
	[_M.addrmode.ZEX] = function(self)
		local param = band((self:readmem(self.pc) + self.X), 0xFF)
		self.pc = band((self.pc + 1), 0xFFFF)
		return param
	end,
	[_M.addrmode.ZER] = function(self)
		-- zero-page
		local param = self:readmem(self.pc)
		self.pc = band((self.pc + 1), 0xFFFF)
		return param
	end,
	[_M.addrmode.ZEY] = function(self)
		-- Zero-page, indexed by Y
		local param = band((self:readmem(self.pc) + self.Y), 0xFF)
		self.pc = band((self.pc + 1), 0xFFFF)
		return param
	end,
	[_M.addrmode.ABY] = function(self)
		-- Absolute indexed, based on Y
		local param = bor(self:readmem(self.pc), band(lshift(self:readmem((self.pc+1), 0xFFFF), 8))) + self.Y
		self.pc = band((self.pc + 2), 0xFFFF)
		return param
	end,
	[_M.addrmode.INY] = function(self)
		-- Indirect indexed Y - refers to zero-page memory by one byte
		local zpL = self:readmem(self.pc)
		self.pc = band((self.pc + 1), 0xFFFF)
		local zpH = band((zpL + 1), 0xFFFF)
		local param = band((bor(self:readmem(zpL), lshift( self:readmem(zpH), 8 )) + self.Y), 0xFFFF)
		return param
	end,
	[_M.addrmode.INX] = function(self)
		local zpL = band((self:readmem(self.pc) + self.X), 0xFF)
		self.pc = band((self.pc + 1), 0xFFFF)
		local zpH = band((zpL + 1), 0xFFFF)
		local param = (bor(self:readmem(zpL), (lshift(self:readmem(zpH), 8))))
		return param
	end,
	[_M.addrmode.ZIND] = function(self)
		local a = self:readmem(self.pc)
		local param
		if (a == 0xFF) then
			-- wrap-around zero-page
			param = bor(self:readmem(0xFF), lshift(self:readmem(0x00), 8))
		else
			param = bor(self:readmem(a), lshift(band(self:readmem((a+1), 0xFFFF)), 8))
		end
		self.pc = band((self.pc + 1), 0xFFFF)
		return param
	end,
}

-- Each of these operations returns the number of additional cycles
-- (above baseline, which are stored in the opcodes[] table). Each
-- takes an optional three parameters (the first two of which came
-- from the getParam[] table function, and the third is the opcode
-- so BIT, BBR, BBS can get meta-info).
_M.operations = {
	[_M.optype.CLD] = function(self)
		self.F = band(self.F, bnot(self.flags.D))
		return 0
	end,
	[_M.optype.LDX] = function(self, param)
		self.X = self:readmem(param)
		self:setnz(self.X)
		return 0
	end,
	[_M.optype.TXS] = function(self)
		self.sp = self.X
		return 0
	end,
	[_M.optype.LDA] = function(self, param)
		self.A = self:readmem(param)
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.STA] = function(self, param)
		self:writemem(param, self.A)
		return 0
	end,
	[_M.optype.JSR] = function(self, param)
		self:pushS16(band((self.pc-1), 0xFFFF))
		self.pc = param
		return 0
	end,
	[_M.optype.RTS] = function(self, param)
		self.pc = band((self:popS16()+1), 0xFFFF)
		return 0
	end,
	[_M.optype.PHA] = function(self, param)
		self:pushS8(self.A)
		return 0
	end,
	[_M.optype.INX] = function(self)
		self.X = band((self.X + 1), 0xFF)
		self:setnz(self.X)
		return 0
	end,
	[_M.optype.BNE] = function(self, param)
		if ((band(self.F, self.flags.Z)) == 0x00) then
			self.pc = param
			return 1
		end
		return 0
	end,
	[_M.optype.BVS] = function(self, param)
		if ((band(self.F, self.flags.V)) ~= 0x00) then
			self.pc = param
			return 1
		end
		return 0
	end,
	[_M.optype.BRK] = function(self)
		self:brk()
		return 0
	end,
	[_M.optype.PHP] = function(self)
		self:pushS8(bor(self.F, self.flags.B))
		return 0
	end,
	[_M.optype.DEY] = function(self)
		self.Y = band((self.Y - 1), 0xFF)
		if (self.Y < 0) then self.Y = 0xFF end
		self:setnz(self.Y)
		return 0
	end,
	[_M.optype.CMP] = function(self, param)
		local tmp = self.A - self:readmem(param)
		self:setcnz(tmp)
		return 0
	end,
	[_M.optype.BEQ] = function(self, param)
		if (band(self.F, self.flags.Z) ~= 0x00) then
			self.pc = param
			return 1
		end
		return 0
	end,
	[_M.optype.TXA] = function(self)
		self.A = self.X
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.TYA] = function(self)
		self.A = self.Y
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.ASL_ACC] = function(self)
		if (band(self.A, 0x80) ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		self.A = band((lshift(self.A, 1)), 0xFF)
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.ORA] = function(self, param)
		self.A = bor(self.A, self:readmem(param))
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.JMP] = function(self, param)
		self.pc = param
		return 0
	end,
	[_M.optype.DEX] = function(self, param)
		self.X = band((self.X - 1), 0xFF)
		self:setnz(self.X)
		return 0
	end,
	[_M.optype.LDY] = function(self, param)
		self.Y = self:readmem(param)
		self:setnz(self.Y)
		return 0
	end,
	[_M.optype.NOP] = function(self) return 0 end,
	[_M.optype.WAI] = function(self) return 0 end,
	[_M.optype.TAX] = function(self)
		self.X = self.A
		self:setnz(self.X)
		return 0
	end,
	[_M.optype.BPL] = function(self, param)
		if (band(self.F, self.flags.N) == 0x00) then
			self.pc = param
			return 1
		end
		return 0
	end,
	[_M.optype.CLC] = function(self)
		self.F = band(self.F, bnot(self.flags.C))
		return 0
	end,
	[_M.optype.EOR] = function(self, param)
		self.A = bxor(self.A, bnot(self:readmem(param)))
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.CPY] = function(self, param)
		local tmp = self.Y - self:readmem(param)
		self:setcnz(tmp)
		return 0
	end,
	[_M.optype.TSX] = function(self, param)
		self.X = self.sp
		self:setnz(self.X)
		return 0
	end,
	[_M.optype.LSR_ACC] = function(self)
		if (band(self.A, 0x01) ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		self.A = rshift(self.A, 1)
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.BCC] = function(self, param)
		if (band(self.F, self.flags.C) == 0x00) then
			self.pc = param
			return 1
		end
		return 0
	end,
	[_M.optype.PLA] = function(self)
		self.A = self:popS8()
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.AND] = function(self, param)
		self.A = band(self.A, self:readmem(param))
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.CPX] = function(self, param)
		local tmp = self.X - self:readmem(param)
		self:setcnz(tmp)
		return 0
	end,
	[_M.optype.BCS] = function(self, param)
		if (band(self.F, self.flags.C) ~= 0x00) then
			self.pc = param
			return 1
		end
		return 0
	end,
	[_M.optype.BMI] = function(self, param)
		if (band(self.F, self.flags.N) ~= 0x00) then
			self.pc = param
			return 1
		end
		return 0
	end,
	[_M.optype.TAY] = function(self)
		self.Y = self.A
		self:setnz(self.Y)
		return 0
	end,
	[_M.optype.PLP] = function(self)
		self.F = bor(self:popS8(), self.flags.UNK) -- What's this flag?
		return 0
	end,
	[_M.optype.BVC] = function(self, param)
		if (band(self.F, self.flags.V) == 0x00) then
			self.pc = param
			return 1
		end
		return 0
	end,
	[_M.optype.INY] = function(self)
		self.Y = band((self.Y + 1), 0xFF)
		self:setnz(self.Y)
		return 0
	end,
	[_M.optype.STX] = function(self, param)
		self:writemem(param, self.X)
		return 0
	end,
	[_M.optype.RTI] = function(self)
		self.F = self:popS8()
		self.pc = self:popS16()
		return 0
	end,
	[_M.optype.SEC] = function(self)
		self.F = bor(self.F, self.flags.C)
		return 0
	end,
	[_M.optype.CLI] = function(self)
		self.F = band(self.F, bnot(self.flags.I))
		return 0
	end,
	[_M.optype.SEI] = function(self)
		self.F = bor(self.F, self.flags.I)
		return 0
	end,
	[_M.optype.SED] = function(self)
		self.F = bor(self.F, self.flags.D)
		return 0
	end,
	[_M.optype.CLV] = function(self)
		self.F = band(self.F, bnot(self.flags.V))
		return 0
	end,
	[_M.optype.STY] = function(self, param)
		self:writemem(param, self.Y)
		return 0
	end,
	[_M.optype.BIT] = function(self, param, _, opcode)
		local mode = self.opcodes[opcode][2]

		local m = self:readmem(param)
		local v = band(self.A, m)
		if (v == 0) then
			self.F = bor(self.F, self.flags.Z)
		else
			self.F = band(self.F, bnot(self.flags.Z))
		end
		if (mode ~= self.addrmode.IMM) then
			if ((( band(v, 0x80) ) ~= 0x00) or (( band(m, 0x80) ) ~= 0x00)) then
				self.F = bor(self.F, self.flags.N)
			else
				self.F = band(self.F, bnot(self.flags.N))
			end
			if (band(m, 0x40) ~= 0x00) then
				self.F = bor(self.F, self.flags.V)
			else
				self.F = band(self.F, bnot(self.flags.V))
			end
		end
		return 0
	end,
	[_M.optype.TRB] = function(self, param)
		local m = self:readmem(param)
		local v = band(self.A, m)
		m = band(m, bnot(self.A))
		self:writemem(param, m)
		if (v == 0) then
			self.F = bor(self.F, self.flags.Z)
		else
			self.F = band(self.F, bnot(self.flags.Z))
		end
		return 0
	end,
	[_M.optype.TSB] = function(self, param)
		local m = self:readmem(param)
		local v = band(self.A, m)
		m = bor(m, self.A)
		self:writemem(param, m)
		if (v == 0) then
			self.F = bor(self.F, self.flags.Z)
		else
			self.F = band(self.F, bnot(self.flags.Z))
		end
		return 0
	end,
	[_M.optype.ROL_ACC] = function(self)
		local v = band(lshift(self.A, 1), 0xFF)
		if (band(self.F, self.flags.C) ~= 0x00) then
			v = bor(v, 0x01)
		end
		if (band(self.A, 0x80) ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(v, 0x01))
		end
		self.A = v
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.ROR_ACC] = function(self)
		local v = rshift(self.A, 1)
		if (band(self.F, self.flags.C) ~= 0x00) then
			v = bor(v, 0x80)
		end
		if (band(self.A, 0x01) ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		self.A = v
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.ASL] = function(self, param)
		local v = self:readmem(param)
		if (band(v, 0x80) ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		v = band((lshift(v, 1)), 0xFF)
		if (band(v, 0x80) ~= 0x00) then
			self.F = bor(self.F, self.flags.N)
		else
			self.F = band(self.F, bnot(self.flags.N))
		end
		if (v == 0) then
			self.F = bor(self.F, self.flags.Z)
		else
			self.F = band(self.F, bnot(self.flags.Z))
		end
		self:writemem(param, v)
		return 0
	end,
	[_M.optype.LSR] = function(self, param)
		local v = self:readmem(param)
		if (band(v, 0x01) ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		v = rshift(v, 1)
		if (band(v, 0x80) ~= 0x00) then
			self.F = bor(self.F, self.flags.N)
		else
			self.F = band(self.F, bnot(self.flags.N))
		end
		if (v == 0) then
			self.F = bor(self.F, self.flags.Z)
		else
			self.F = band(self.F, bnot(self.flags.Z))
		end
		self:writemem(param, v)
		return 0
	end,
	[_M.optype.ROL] = function(self, param)
		local m = self:readmem(param)
		local v = band(lshift(m, 1), 0xFF)
		if (band(self.F, self.flags.C) ~= 0x00) then
			v = bor(v, 0x01)
		end
		if (band(m, 0x80) ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		if (band(v, 0x80) ~= 0x00) then
			self.F = bor(self.F, self.flags.N)
		else
			self.F = band(self.F, bnot(self.flags.N))
		end
		if (v == 0) then
			self.F = bor(self.F, self.flags.Z)
		else
			self.F = band(self.F, bnot(self.flags.Z))
		end
		self:writemem(param, v)
		return 0
	end,
	[_M.optype.ROR] = function(self, param)
		local m = self:readmem(param)
		local v = rshift(m, 1)
		if (band(self.F, self.flags.C) ~= 0x00) then
			v = bor(v, 0x80)
		end
		if (band(m, 0x01) ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		self:setnz(v)
		self:writemem(param, v)
		return 0
	end,
	[_M.optype.INC] = function(self, param)
		local v = band((self:readmem(param) + 1), 0xFF)
		self:setnz(v)
		self:writemem(param, v)
		return 0
	end,
	[_M.optype.DEC] = function(self, param)
		local v = band((self:readmem(param) - 1), 0xFF)
		self:setnz(v)
		self:writemem(param,v)
		return 0
	end,
	[_M.optype.DCP] = function(self, param)
		-- Not a real opcode; one of the 65c02 side-effect "illegal" opcodes
		local v = band((self:readmem(param)-1), 0xFF)
		self:setnz(v)
		self:writemem(param, v)

		local tmp = self.A - v
		self:setcnz(tmp)
		return 0
	end,
	[_M.optype.SBC] = function(self, param)
		local ret = 0 -- number of additional cycles
		local B = bxor(self:readmem(param), bnot(0xFF))
		local Cin = band(self.F, self.flags.C)
		local Cout -- expected carry out
		local Vout -- expected oVerflow out
		local Aout -- expected accumulator out

		if (band(self.F, self.flags.D) == 0x00) then
			-- Simple Bin mode. Same as ADC's bin mode.

			Aout = self.A + B + Cin
			Vout = band((bxor(self.A, Aout)), band(bxor(B, Aout), 0x80))
			Cout = (Aout >= 0x100) and 1 or 0
			self.A = band(Aout, 0xFF)
		else
			-- Emulating decimal mode's handling of
			-- invalid BCD values is tricky.
			ret = 1

			-- FIXME: This can probably be optimized;
			-- this passes all 6502 decimal mode tests,
			-- but is seemingly doing a lot of the same
			-- work twice

			-- First calculate the V and C flags
			Aout = band(self.A, 0x0F) + band(B, 0x0F) + Cin
			if (Aout < 0x10) then
				Aout = band((Aout - 0x06), 0x0F)
			end
			Aout = Aout + band(self.A, 0xF0) + band(B, 0xF0)
			Vout = band(bxor(self.A, Aout), band(bxor(B, Aout), 0x80))
			if (Aout < 0x100) then
				Aout = band((Aout + 0xa0), 0xFF)
			end

			Cout = (Aout >= 0x100) and 1 or 0

			-- Calculate the actual A output
			B = self:readmem(param)
			local AL = band(self.A, 0x0F) - band(B, 0x0F) + (Cin - 1)
			Aout = self.A - B + Cin - 1
			if (Aout < 0) then Aout = Aout - 0x60 end
			if (AL < 0) then Aout = Aout - 0x06 end

			self.A = band(Aout, 0xFF)
		end

		if (Cout ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		if (Vout ~= 0x00) then 
			self.F = bor(self.F, self.flags.V)
		else
			self.F = band(self.F, bnot(self.flags.V))
		end

		self:setnz(self.A)

		return ret
	end,
	[_M.optype.ADC] = function(self, param)
		local ret = 0 -- number of additional cycles
		local B = self:readmem(param)
		local Cin = band(self.F, self.flags.C)
		local Cout -- expected carry out
		local Vout -- expected oVerflow out
		local Aout -- expected accumulator out

		if (band(self.F, self.flags.D) == 0x00) then

			-- Simple Bin mode. Thank goodness.

			Aout = self.A + B + Cin
			-- 'v' is described really well here:
			--    http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html

			-- Overflow means "answer does not fit in to a signed byte".
			--
			-- If bits A7 and B7 are not the same, then there's never overflow.
			-- 
			-- If the signs of the two are the same,
			-- but the sign of the output is different,
			-- then overflow obviously happened. Both of these do that...
			--			   Vout = (((self.A ~ B) & 0x80) == 0x00) and ((Aout ~ B) & 0x80) or 0
			Vout = band(bxor(self.A, Aout), band(bxor(B, Aout), 0x80))

			Cout = (Aout >= 0x100) and 1 or 0
			self.A = band(Aout, 0xFF)
		else
			-- Complex Dec mode. 
			-- Per
			-- http://www.6502.org/tutorials/decimal_mode.html.
			ret = 1

			-- Done with the V flag processing. Calculate Aout and Cout.
			Aout = band(self.A, 0x0F) + band(B, 0x0F) + Cin
			local tmpOverflow = 0
			if (Aout >= 0x0A) then
				tmpOverflow = 0x10
				Aout = band((Aout + 0x06), 0x0F)
			end
			Aout = bor(Aout, band(self.A, 0xF0))
			Aout = Aout + band(B, 0xF0) + tmpOverflow

			-- Overflow for BCD mode is calculated
			-- here, before rolling over the high
			-- nybble. If both A and B have the same
			-- sign, and the sign for Aout is different
			-- than A and B, then overflow happened.

			Vout = 0
			if ( band(bxor(self.A, B), 0x80) == 0x00 ) then
				-- A and B are of the same sign
				if (band(bor(self.A, Aout), 0x80) ~= 0x00) then
					-- A/B have a different sign from C, so it overflowed
					Vout = 1
				end
			end

			-- Back to calculating the resultant A and C
			if (Aout >= 0xA0) then
				Aout = Aout + 0x60
				Cout = 1
			else
				Cout = 0
			end

			self.A = band(Aout, 0xFF)
		end

		if (Cout ~= 0x00) then
			self.F = bor(self.F, self.flags.C)
		else
			self.F = band(self.F, bnot(self.flags.C))
		end
		if (Vout ~= 0x00) then 
			self.F = bor(self.F, self.flags.V)
		else
			self.F = band(self.F, bnot(self.flags.V))
		end

		self:setnz(self.A)

		return ret
	end,
	[_M.optype.PHX] = function(self)
		self:pushS8(self.X)
		return 0
	end,
	[_M.optype.PHY] = function(self)
		self:pushS8(self.Y)
		return 0
	end,
	[_M.optype.PLY] = function(self)
		self.Y = self:popS8()
		self:setnz(self.Y)
		return 0
	end,
	[_M.optype.PLX] = function(self)
		self.X = self:popS8()
		self:setnz(self.X)
		return 0
	end,
	[_M.optype.BRA] = function(self, param)
		self.pc = param
		return 0
	end,
	[_M.optype.BBR] = function(self, param, zprelParam2, m)
		-- the bit to test is encoded in the opcode [m].
		local btt = lshift(1, band(rshift(m, 4), 0x07))
		local v = self:readmem(param) -- zero-page memory location to test
		if (band(v, btt) == 0x00) then
			self.pc = zprelParam2
		end
		return 0
	end,
	[_M.optype.BBS] = function(self, param, zprelParam2, m)
		local btt = lshift(1, band(rshift(m, 4), 0x07))
		local v = self:readmem(param)
		if (band(v, btt) ~= 0x00) then
			self.pc = zprelParam2
		end
		return 0
	end,
	[_M.optype.INC_ACC] = function(self)
		self.A = band((self.A + 1), 0xFF)
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.DEC_ACC] = function(self)
		self.A = band((self.A - 1), 0xFF)
		self:setnz(self.A)
		return 0
	end,
	[_M.optype.STZ] = function(self, param)
		self:writemem(param, 0x00)
		return 0
	end,
	[_M.optype.RMB] = function(self, param, _, m)
		-- The bit to test is encoded in the opcode [m].
		local btt = lshift(1, band(rshift(m, 4), 0x07))
		self:writemem(param, band(self:readmem(param), bnot(btt)))
		return 0
	end,
	[_M.optype.SMB] = function(self, param, _, m)
		local btt = lshift(1, band(rshift(m, 4), 0x07))
		self:writemem(param, bor(self:readmem(param), btt))
		return 0
	end,
	[_M.optype.ILLEGAL] = function(self, _, _, m)
		-- Treat these all as NOPs. Also emulate the 
		-- 65C02 behavior...
		if (m == 0x02 or m == 0x22 or m == 0x42 or m == 0x62 or m == 0x82 or
			m == 0xC2 or m == 0xE2 or m == 0x44 or m == 0x54 or m == 0xd4 or
			m == 0xf4) then
			self.pc = band((self.pc + 1), 0xFFFF)
		end
		if (m == 0x5c or m == 0xdc or m == 0xfc) then
			self.pc = band((self.pc + 2), 0xFFFF)
		end

		return 0
	end,
}

function _M:new()
	local ret = { A = 0,
		X = 0,
		Y = 0,
		F = 0,
		irqPending = false,
		pc = 0x0000,
		sp = 0x00,
		cycles = 0,
		realtimeProcessing = false,
	}
	setmetatable(ret, { __index = _M })

	return ret
end

function _M:init()
	self.A = 0
	self.X = 0
	self.Y = 0
	self.F = bor(self.flags.Z, self.flags.UNK)
	self.irqPending = false

	self.sp = 0xFD
	self.cycles = 6
end

function _M:nmi()
	self.F = bor(self.F, bnot(self.flags.B)) -- clear Break flag

	self:pushS16(self.pc)
	self:pushS8(self.F)
	self.F = bor(self.F, 0x20) -- FIXME: what flag is this?
	self.pc = bor(self:readmem(0xFFFA), lshift(self:readmem(0xFFFB), 8))

	self.cycles = self.cycles + 2
end

function _M:rst()
	self.cycles = self.cycles + 3
	self.sp = self.sp - 3
	self.pc = bor(self:readmem(0xFFFC), lshift(self:readmem(0xFFFD), 8))
	self.cycles = self.cycles + 2
end

function _M:brk()
	self.pc = band((self.pc + 1), 0xFFFF)
	self:pushS16(self.pc)
	self:pushS8(bor(self.F, self.flags.B))
	self.F = band(self.F, bnot(self.flags.D))
	self.F = bor(self.F, self.flags.I)
	self.pc = bor(self:readmem(0xFFFE), lshift(self:readmem(0xFFFF), 8))
	self.cycles = self.cycles + 2
end

function _M:irq()
	if (band(self.F, self.flags.I) ~= 0) then
		-- If interrupts are disabled, then do nothing
		return
	end

	self:pushS16(self.pc)
	self.F = band(self.F, bnot(self.flags.B))
	self:pushS8(self.F)
	self.F = bor(self.F, self.flags.I)
	self.pc = bor(self:readmem(0xFFFE), lshift(self:readmem(0xFFFF), 8))
	self.cycles = self.cycles + 2
end

function _M:pushS8(b)
	self:writemem(0x100 + self.sp, b)
	self.sp = band((self.sp - 1), 0xFF)
end

function _M:pushS16(w)
	self:pushS8(band(rshift(w, 8), 0xFF))
	self:pushS8(band(w, 0xFF))
end

function _M:popS8()
	self.sp = band((self.sp + 1), 0xFF)
	return self:readmem(0x100 + self.sp)
end

function _M:popS16()
	local lsb = self:popS8()
	local msb = self:popS8()
	return bor(lshift(msb, 8), lsb)
end

function _M:setnz(param)
	if (band(param, 0x80) == 0x00) then
		self.F = band(self.F, bnot(self.flags.N))
	else
		self.F = bor(self.F, self.flags.N)
	end
	if (param == 0x00) then
		self.F = bor(self.F, self.flags.Z)
	else
		self.F = band(self.F, bnot(self.flags.Z))
	end
end

-- tmp is an UNSIGNED 16-bit number; used in a few CMP-like operations in
-- mid-calcuation
function _M:setcnz(tmp)
	if (tmp >= 0 and tmp < 0x100) then
		self.F = bor(self.F, self.flags.C)
	else
		self.F = band(self.F, bnot(self.flags.C))
	end
	if (band(tmp, 0xFF) == 0x00) then
		self.F = bor(self.F, self.flags.Z)
	else
		self.F = band(self.F, bnot(self.flags.Z))
	end
	if (band(tmp, 0x80) ~= 0x00) then
		self.F = bor(self.F, self.flags.N)
	else
		self.F = band(self.F, bnot(self.flags.N))
	end
end

function _M:step()
	if (self.irqPending) then
		self.irqPending = false
		self:irq()
	end

	local m = self:readmem(self.pc)
	self.pc = band((self.pc + 1), 0xFFFF)

	local opcode = self.opcodes[m]

	-- Look at the addressing mode to determine the parameter
	local param, zprelParam2 = self.getParam[opcode[2]](self)

	-- Initialize a counter for the number of cycles this run
	local cyclesThisStep = opcode[3]

	-- Perform the opcode's operations
	cyclesThisStep = cyclesThisStep + self.operations[opcode[1]](self, param, zprelParam2, m)

	self.cycles = self.cycles + cyclesThisStep

	return cyclesThisStep
end

function _M:readmem(a)
	return self.ram[a] or 0
end

function _M:writemem(a,v)
	self.ram[a] = v
end

function _M:unsignedToSigned(v)
	if (band(v, 0x80) == 0x00) then return v end
	return -(bxor(v, 0xFF) + 1)
end

return _M
