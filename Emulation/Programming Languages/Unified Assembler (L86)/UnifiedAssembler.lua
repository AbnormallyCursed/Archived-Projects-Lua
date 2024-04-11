
--This assembler is considered complete.

--The LAMBDA Architecture is an x86-like architecture, this is the assembly for it, a branch of UASM (Unified Assembler) known as UASM-L
--It uses a control byte scheme, the control byte determines where the operand fetches data from, and where it outputs data to
--This allows for any instruction to have any destination and any source, if you manage to get the "Invalid Control Byte" error:
--you know that you really screwed up.

--Generally this is a normal assembler based on GCC style syntax with the Intel Format
--It is "x86 compatible" meaning you can input most (DEFINITELY not all) programs intended for x86 and it will likely work

--General Notes:
--1. All instructions must end with the statement closure operator ';'
--2. There are 3 Macros
--  .global (tells the assembler to treat an identifier as a global) 
--  .text (tells the assembler to start parsing the code)
--  .data (tells the assembler to start initializing data)
--3. We declare labels like everyone else, an identifier then a colon ':' then the code block
--4. to declare something is an address, surround it with brackets like so: [5] or [0x5] or [0b101]
--5. we can declare segment offset, just like in x86 it is done like so: [registername-here number-here] 
--make the number negative to reverse offset
--6. registers are strange, we support all the general purpose x86 registers such as EAX, but we also have 165
--you can use whichever suits your fancy, if you want to use all 165 just type R then the number of the register like so: R165 or R32
--7. we support size specifiers, we technically support the use of the PTR/ptr keyword/type but it doesn't really do anything 
--(just like in actual x86-64 assembly lol), other than that it's the standard suite, byte-qword etc.



local Lexer = require(script.Lexer)
local BinUtils = require(script["Binary Utilities"])
local arch = script.arch
local floor, insert = math.floor, table.insert
local newBinStr = string.pack
local Module = {}
local DataSizeTypes = {}

-- LAMBDA Constant Data:
local RegisterEncodings = {
	['R0'] = 0,
	['R1'] = 1,
	['R2'] = 2,
	['R3'] = 3,
	['R4'] = 4,
	['R5'] = 5,
	['R6'] = 6,
	['R7'] = 7,
	['R8'] = 8,
	['R9'] = 9,
	['R10'] = 10,
	['R11'] = 11,
	['R12'] = 12,
	['R13'] = 13,
	['R14'] = 14,
	['R15'] = 15,
	['R16'] = 16,
	['R17'] = 17,
	['R18'] = 18,
	['R19'] = 19,
	['R20'] = 20,
	['R21'] = 21,
	['R22'] = 22,
	['R23'] = 23,
	['R24'] = 24,
	['R25'] = 25,
	['R26'] = 26,
	['R27'] = 27,
	['R28'] = 28,
	['R29'] = 29,
	['R30'] = 30,
	['R31'] = 31,
	['R32'] = 32,
	['R33'] = 33,
	['R34'] = 34,
	['R35'] = 35,
	['R36'] = 36,
	['R37'] = 37,
	['R38'] = 38,
	['R39'] = 39,
	['R40'] = 40,
	['R41'] = 41,
	['R42'] = 42,
	['R43'] = 43,
	['R44'] = 44,
	['R45'] = 45,
	['R46'] = 46,
	['R47'] = 47,
	['R48'] = 48,
	['R49'] = 49,
	['R50'] = 50,
	['R51'] = 51,
	['R52'] = 52,
	['R53'] = 53,
	['R54'] = 54,
	['R55'] = 55,
	['R56'] = 56,
	['R57'] = 57,
	['R58'] = 58,
	['R59'] = 59,
	['R60'] = 60,
	['R61'] = 61,
	['R62'] = 62,
	['R63'] = 63,
	['R64'] = 64,
	['R65'] = 65,
	['R66'] = 66,
	['R67'] = 67,
	['R68'] = 68,
	['R69'] = 69,
	['R70'] = 70,
	['R71'] = 71,
	['R72'] = 72,
	['R73'] = 73,
	['R74'] = 74,
	['R75'] = 75,
	['R76'] = 76,
	['R77'] = 77,
	['R78'] = 78,
	['R79'] = 79,
	['R80'] = 80,
	['R81'] = 81,
	['R82'] = 82,
	['R83'] = 83,
	['R84'] = 84,
	['R85'] = 85,
	['R86'] = 86,
	['R87'] = 87,
	['R88'] = 88,
	['R89'] = 89,
	['R90'] = 90,
	['R91'] = 91,
	['R92'] = 92,
	['R93'] = 93,
	['R94'] = 94,
	['R95'] = 95,
	['R96'] = 96,
	['R97'] = 97,
	['R98'] = 98,
	['R99'] = 99,
	['R100'] = 100,
	['R101'] = 101,
	['R102'] = 102,
	['R103'] = 103,
	['R104'] = 104,
	['R105'] = 105,
	['R106'] = 106,
	['R107'] = 107,
	['R108'] = 108,
	['R109'] = 109,
	['R110'] = 110,
	['R111'] = 111,
	['R112'] = 112,
	['R113'] = 113,
	['R114'] = 114,
	['R115'] = 115,
	['R116'] = 116,
	['R117'] = 117,
	['R118'] = 118,
	['R119'] = 119,
	['R120'] = 120,
	['R121'] = 121,
	['R122'] = 122,
	['R123'] = 123,
	['R124'] = 124,
	['R125'] = 125,
	['R126'] = 126,
	['R127'] = 127,
	['R128'] = 128,
	['R129'] = 129,
	['R130'] = 130,
	['R131'] = 131,
	['R132'] = 132,
	['R133'] = 133,
	['R134'] = 134,
	['R135'] = 135,
	['R136'] = 136,
	['R137'] = 137,
	['R138'] = 138,
	['R139'] = 139,
	['R140'] = 140,
	['R141'] = 141,
	['R142'] = 142,
	['R143'] = 143,
	['R144'] = 144,
	['R145'] = 145,
	['R146'] = 146,
	['R147'] = 147,
	['R148'] = 148,
	['R149'] = 149,
	['R150'] = 150,
	['R151'] = 151,
	['R152'] = 152,
	['R153'] = 153,
	['R154'] = 154,
	['R155'] = 155,
	['R156'] = 156,
	['R157'] = 157,
	['R158'] = 158,
	['R159'] = 159,
	['R160'] = 160,
	['R161'] = 161,
	['R162'] = 162,
	['R163'] = 163,
	['R164'] = 164,
	['R165'] = 165,
	["RBX"] = 1,
	["RCX"] = 2,
	["RDX"] = 3,
	["RBP"] = 4,
	["RSI"] = 5,
	["RDI"] = 6,
	["RSP"] = 7,
	["RAX"] = 8,
	["EBX"] = 9,
	["ECX"] = 10,
	["EDX"] = 11,
	["EBP"] = 12,
	["ESI"] = 13,
	["EDI"] = 14,
	["ESP"] = 15,
	["EAX"] = 16,
	["BX"] = 17,
	["CX"] = 18,
	["DX"] = 19,
	["BP"] = 20,
	["SI"] = 21,
	["DI"] = 22,
	["SP"] = 23,
	["AX"] = 24,
	["AL"] = 25,
	["BL"] = 26,
	["CL"] = 27,
	["DL"] = 28,
	["BPL"] = 29,
	["SIL"] = 30,
	["DIL"] = 31,
	["SPL"] = 32
}

local UASM_CTRL_BYTE_CONV_DATA = {
	["A:128/A:128"] = 50,
	["A:128/A:16"] = 47,
	["A:128/A:32"] = 48,
	["A:128/A:64"] = 49,
	["A:128/A:8"] = 46,
	["A:128/I:128"] = 45,
	["A:128/I:16"] = 42,
	["A:128/I:32"] = 43,
	["A:128/I:64"] = 44,
	["A:128/I:8"] = 41,
	["A:128/R:128"] = 55,
	["A:128/R:16"] = 52,
	["A:128/R:32"] = 53,
	["A:128/R:64"] = 54,
	["A:128/R:8"] = 51,
	["A:128/S:128"] = 60,
	["A:128/S:16"] = 57,
	["A:128/S:32"] = 58,
	["A:128/S:64"] = 59,
	["A:128/S:8"] = 56,
	["A:16/A:16"] = 8,
	["A:16/A:8"] = 7,
	["A:16/I:16"] = 6,
	["A:16/I:8"] = 5,
	["A:16/R:16"] = 10,
	["A:16/R:8"] = 9,
	["A:16/S:16"] = 12,
	["A:16/S:8"] = 11,
	["A:32/A:16"] = 17,
	["A:32/A:32"] = 18,
	["A:32/A:8"] = 16,
	["A:32/I:16"] = 14,
	["A:32/I:32"] = 15,
	["A:32/I:8"] = 13,
	["A:32/R:16"] = 20,
	["A:32/R:32"] = 21,
	["A:32/R:8"] = 19,
	["A:32/S:16"] = 23,
	["A:32/S:32"] = 24,
	["A:32/S:8"] = 22,
	["A:64"] = 188,
	["A:64/A:16"] = 30,
	["A:64/A:32"] = 31,
	["A:64/A:64"] = 32,
	["A:64/A:8"] = 29,
	["A:64/I:16"] = 26,
	["A:64/I:32"] = 27,
	["A:64/I:64"] = 28,
	["A:64/I:8"] = 25,
	["A:64/R:16"] = 34,
	["A:64/R:32"] = 35,
	["A:64/R:64"] = 36,
	["A:64/R:8"] = 33,
	["A:64/S:16"] = 38,
	["A:64/S:32"] = 39,
	["A:64/S:64"] = 40,
	["A:64/S:8"] = 37,
	["A:8/A:8"] = 2,
	["A:8/I:8"] = 1,
	["A:8/R:8"] = 3,
	["A:8/S:8"] = 4,
	["I:64"] = 192,
	["O:16"] = 182,
	["O:32"] = 183,
	["O:64"] = 184,
	["O:8"] = 181,
	["R:128/A:128"] = 110,
	["R:128/A:16"] = 107,
	["R:128/A:32"] = 108,
	["R:128/A:64"] = 109,
	["R:128/A:8"] = 106,
	["R:128/I:128"] = 105,
	["R:128/I:16"] = 102,
	["R:128/I:32"] = 103,
	["R:128/I:64"] = 104,
	["R:128/I:8"] = 101,
	["R:128/R:128"] = 115,
	["R:128/R:16"] = 112,
	["R:128/R:32"] = 113,
	["R:128/R:64"] = 114,
	["R:128/R:8"] = 111,
	["R:128/S:128"] = 120,
	["R:128/S:16"] = 117,
	["R:128/S:32"] = 118,
	["R:128/S:64"] = 119,
	["R:128/S:8"] = 116,
	["R:16/A:16"] = 68,
	["R:16/A:8"] = 67,
	["R:16/I:16"] = 66,
	["R:16/I:8"] = 65,
	["R:16/R:16"] = 70,
	["R:16/R:8"] = 69,
	["R:16/S:16"] = 72,
	["R:16/S:8"] = 71,
	["R:32/A:16"] = 77,
	["R:32/A:32"] = 78,
	["R:32/A:8"] = 76,
	["R:32/I:16"] = 74,
	["R:32/I:32"] = 75,
	["R:32/I:8"] = 73,
	["R:32/R:16"] = 80,
	["R:32/R:32"] = 81,
	["R:32/R:8"] = 79,
	["R:32/S:16"] = 83,
	["R:32/S:32"] = 84,
	["R:32/S:8"] = 82,
	["R:64"] = 196,
	["R:64/A:16"] = 90,
	["R:64/A:32"] = 91,
	["R:64/A:64"] = 92,
	["R:64/A:8"] = 89,
	["R:64/I:16"] = 86,
	["R:64/I:32"] = 87,
	["R:64/I:64"] = 88,
	["R:64/I:8"] = 85,
	["R:64/R:16"] = 94,
	["R:64/R:32"] = 95,
	["R:64/R:64"] = 96,
	["R:64/R:8"] = 93,
	["R:64/S:16"] = 98,
	["R:64/S:32"] = 99,
	["R:64/S:64"] = 100,
	["R:64/S:8"] = 97,
	["R:8/A:8"] = 62,
	["R:8/I:8"] = 61,
	["R:8/R:8"] = 63,
	["R:8/S:8"] = 64,
	["S:128/A:128"] = 170,
	["S:128/A:16"] = 167,
	["S:128/A:32"] = 168,
	["S:128/A:64"] = 169,
	["S:128/A:8"] = 166,
	["S:128/I:128"] = 165,
	["S:128/I:16"] = 162,
	["S:128/I:32"] = 163,
	["S:128/I:64"] = 164,
	["S:128/I:8"] = 161,
	["S:128/R:128"] = 175,
	["S:128/R:16"] = 172,
	["S:128/R:32"] = 173,
	["S:128/R:64"] = 174,
	["S:128/R:8"] = 171,
	["S:128/S:128"] = 180,
	["S:128/S:16"] = 177,
	["S:128/S:32"] = 178,
	["S:128/S:64"] = 179,
	["S:128/S:8"] = 176,
	["S:16/A:16"] = 128,
	["S:16/A:8"] = 127,
	["S:16/I:16"] = 126,
	["S:16/I:8"] = 125,
	["S:16/R:16"] = 130,
	["S:16/R:8"] = 129,
	["S:16/S:16"] = 132,
	["S:16/S:8"] = 131,
	["S:32/A:16"] = 137,
	["S:32/A:32"] = 138,
	["S:32/A:8"] = 136,
	["S:32/I:16"] = 134,
	["S:32/I:32"] = 135,
	["S:32/I:8"] = 133,
	["S:32/R:16"] = 140,
	["S:32/R:32"] = 141,
	["S:32/R:8"] = 139,
	["S:32/S:16"] = 143,
	["S:32/S:32"] = 144,
	["S:32/S:8"] = 142,
	["S:64"] = 200,
	["S:64/A:16"] = 150,
	["S:64/A:32"] = 151,
	["S:64/A:64"] = 152,
	["S:64/A:8"] = 149,
	["S:64/I:16"] = 146,
	["S:64/I:32"] = 147,
	["S:64/I:64"] = 148,
	["S:64/I:8"] = 145,
	["S:64/R:16"] = 154,
	["S:64/R:32"] = 155,
	["S:64/R:64"] = 156,
	["S:64/R:8"] = 153,
	["S:64/S:16"] = 158,
	["S:64/S:32"] = 159,
	["S:64/S:64"] = 160,
	["S:64/S:8"] = 157,
	["S:8/A:8"] = 122,
	["S:8/I:8"] = 121,
	["S:8/R:8"] = 123,
	["S:8/S:8"] = 124
}

local INSTRUCTION_ENCODE = {
	["ADD"] = 1,
	["AND"] = 8,
	["CALL"] = 34,
	["CMP"] = 33,
	["DIV"] = 5,
	["HLT"] = 35,
	["IDIV"] = 7,
	["IMUL"] = 6,
	["INT"] = 38,
	["INT1"] = 37,
	["INT3"] = 39,
	["INTO"] = 36,
	["IRET"] = 40,
	["JBE"] = 25,
	["JC"] = 23,
	["JE"] = 21,
	["JGE"] = 28,
	["JLE"] = 29,
	["JMP"] = 16,
	["JNBE"] = 26,
	["JNC"] = 24,
	["JNE"] = 22,
	["JNGE"] = 27,
	["JNLE"] = 30,
	["JNO"] = 18,
	["JNP"] = 32,
	["JNS"] = 20,
	["JO"] = 17,
	["JP"] = 31,
	["JS"] = 19,
	["MOV"] = 3,
	["MUL"] = 4,
	["NOT"] = 11,
	["OR"] = 9,
	["POP"] = 43,
	["PUSH"] = 42,
	["RET"] = 41,
	["SAL"] = 14,
	["SAR"] = 12,
	["SHL"] = 15,
	["SHR"] = 13,
	["SUB"] = 2,
	["XOR"] = 10,
}
local registersizes = {
	["RBX"] = 64,
	["RCX"] = 64,
	["RDX"] = 64,
	["RBP"] = 64,
	["RSI"] = 64,
	["RDI"] = 64,
	["RSP"] = 64,
	["RAX"] = 64,
	["EBX"] = 32,
	["ECX"] = 32,
	["EDX"] = 32,
	["EBP"] = 32,
	["ESI"] = 32,
	["EDI"] = 32,
	["ESP"] = 32,
	["EAX"] = 32,
	["BX"] = 16,
	["CX"] = 16,
	["DX"] = 16,
	["BP"] = 16,
	["SI"] = 16,
	["DI"] = 16,
	["SP"] = 16,
	["AX"] = 16,
	["AL"] = 8,
	["BL"] = 8,
	["CL"] = 8,
	["DL"] = 8,
	["BPL"] = 8,
	["SIL"] = 8,
	["DIL"] = 8,
	["SPL"] = 8
}

local UASM_CONV_TYPE_TABLE = {
	["address"] = "A",
	["immediate"] = "I",
	["register"] = "R",
	["Register Offset"] = "S",
}

local function ErrorWithFormat(msg, ...)
	error(string.format(msg, ...))
end
local function GetMinimumBitSize(n: number)
	local MinimumBits = math.floor(math.log(n, 2)) + 1
	
	if MinimumBits <= 8 then
		return 8
	elseif MinimumBits <= 16 then
		return 16
	elseif MinimumBits <= 32 then
		return 32
	elseif MinimumBits <= 64 then
		return 64
	elseif MinimumBits <= 128 then
		return 128
	else
		error("Bit Size not supported: "..MinimumBits)
	end
end

function Module:Assemble(Source, Architecture, GlobalTable)
	if not GlobalTable then
		GlobalTable = {}
	end
	
	-- Syntax Tree Generation:
	local Toolchain = require(arch[Architecture])
	local Navigator = Lexer.navigator(Toolchain.asmlang)
	local DataDeclarations = GlobalTable.GlobalData or {}
	local GlobalNames = GlobalTable.GlobalNames or {}
	local Token, Content
	Navigator:SetSource(Source)

	local function iterate(DontGsub: boolean)
		Token, Content = Navigator.Next()
		print(Token, Content)
		if Token == "identifier" and DataDeclarations[Content] then
			Token, Content = unpack(DataDeclarations[Content])
		end
		if not Token or not Content then return end
		if not DontGsub then
			Content = Content:gsub("%s+", "")
		end
	end
	local function HandleNumber()
		assert(Token == "number", "HandleNumber expected current token to be a number")
		local HandledNumber = tonumber(Content)
		
		if string.sub(Content, 1, 2) == "0b" then
			HandledNumber = tonumber(string.sub(Content, 3, Content:len()), 2)
		elseif string.sub(Content, 1, 2) == "0x" then
			HandledNumber = tonumber(Content, 10)
		end
		
		return HandledNumber
	end

	-- Function that reads the operands for a given instruction and returns a tree of data
	-- for easier instruction building on multiple different architectures
	local function OperandREAD()
		local OperandData = {}
		local Ptr = 1

		repeat 
			iterate()
			if Token == nil or Content == nil then break end
			if Token == "instruction" then ErrorWithFormat("expected ';' after instruction declaration") end
			if Token == "operator" and Content == ";" then break end
			local lower = string.lower(Content)
			
			if not OperandData[Ptr] then
				OperandData[Ptr] = {}
			end
			local OpDataTrgt = OperandData[Ptr]

			if Token == "keyword" then -- size specifiers will not support registers as operands, at least for now

				if lower == "byte" then
					OpDataTrgt["size"] = 8
				elseif lower == "word" then
					OpDataTrgt["size"] = 16
				elseif lower == "dword" then
					OpDataTrgt["size"] = 32
				elseif lower == "qword" then
					OpDataTrgt["size"] = 64
				else
					ErrorWithFormat("expected operand size specifier got '%s'", Content)
				end
				iterate()
				
				lower = string.lower(Content)
				if lower == "ptr" then
					iterate()
				end
				
				if Token == "number" or (Token == "operator" and Content == "[") then
					if Token == "number" then
						OpDataTrgt["value"] = HandleNumber()
						OpDataTrgt["type"] = "immediate"
					else
						iterate()
						
						if Token == "register" then
							OpDataTrgt["type"] = "Register Offset"
							OpDataTrgt["value"] = Content:upper()
							OpDataTrgt["size"] = 64
							
							iterate()
							
							if Content:find("]") then
								OpDataTrgt["OffsetNum"] = 0
							elseif Token == "number" then
								OpDataTrgt["OffsetNum"] = HandleNumber()
							else
								ErrorWithFormat("expected operator or number at '%s'", Content)
							end
						elseif Token == "number" then
							OpDataTrgt["value"] = HandleNumber()
							OpDataTrgt["type"] = "address"
						end
						if Content:find("]") then
							continue
						end
						iterate()
						if not Content:find("]") then
							ErrorWithFormat("Expected closing ']' after address")
						end
					end
				else
					ErrorWithFormat("expected number or operator for operand after '%s' got '%s' at '%s'",
						lower, Token, Content)
				end
			elseif Token == "number" then
				OpDataTrgt["type"] = "immediate"
				OpDataTrgt["value"] = HandleNumber()
				OpDataTrgt["size"] = GetMinimumBitSize(OpDataTrgt["value"])
			elseif Token == "register" then
				if Content:sub(1,2) == "cr" then
					OpDataTrgt["size"] = 64
				else
					if registersizes[Content:upper()] == nil then
						ErrorWithFormat("Register does not exist '%s'", Content)
					end
					OpDataTrgt["size"] = 64 -- they're literally all hardcoded to 64 bit
				end
				
				OpDataTrgt["type"] = "register"
				OpDataTrgt["value"] = RegisterEncodings[Content:upper()]
			elseif Token == "operator" then
				print(Content)
				if Content == "," then
					Ptr += 1
					continue
				elseif Content == ";" then
					break
				else
					error("icky operator type, it is not a , or ;")
				end
			elseif Token == "identifier" then -- we assume identifier = label
				OpDataTrgt["type"] = "label"
				OpDataTrgt["value"] = Content -- we cannot set the value of the label yet
			elseif Token == "instruction" then
				ErrorWithFormat("expected ';' after operand got '%s'", Content)
			end
		until Token == nil or Content == nil
		
		return OperandData
	end
	
	local SyntaxTree = {Instructions = {},}
	local Section = "none"
	local DataOutput = {}
	
	repeat 
		iterate()
		if Content == nil then break end
		
		if Content == "." then
			iterate()
			if Content == "text" then
				Section = "text"
			elseif Content == "data" then
				Section = "data"
			elseif Content == "global" then
				iterate()
				GlobalNames[Content] = true
			end
		end
		
		if Section == "text" then
			if Token == "instruction" then
				print("A")
				local InstructionName = Content
				if Navigator.Peek(1) == "instruction" then
					continue
				end

				SyntaxTree.Instructions[#SyntaxTree.Instructions+1] = {InstructionName, OperandREAD()}
			elseif Token == "identifier" and Navigator.Peek(1) == "operator" then
				SyntaxTree.Instructions[#SyntaxTree.Instructions+1] = {"LABEL", Content}
			end
		elseif Section == "data" then
			if Token == "data" then
				if Content == "string" then
					iterate()
					if Token ~= "identifier" then
						ErrorWithFormat("expected identifier after string definition got '%s'", Content)
					end
					local Name = Content
					iterate()
					if Token ~= "string" then
						ErrorWithFormat("expected string definition after identifier got '%s'", Content)
					end
					
					local RealString = Token:sub(2, Token:len()-1)
					local StringREAD = RealString:split("")
					DataDeclarations[Name] = {"number", tostring(#DataOutput+1)}
					
					for i = 1, #StringREAD do
						DataOutput[#DataOutput+1] = string.byte(StringREAD[i])
					end
				end
			else
				--ErrorWithFormat("expected data declaration got '%s'", Content)
			end
		end
		
	until Token == nil or Content == nil
	
	print("Syntax Tree Generation Complete")
	Navigator:Destroy()
	
	local TextOutput = {}
	local LabelAddresses = GlobalTable.GlobalLabels or {}
	local LabelOperandInit = {}
		
	if Architecture == "LAMBDA" then	
		print(SyntaxTree)
		for _,Branch in SyntaxTree.Instructions do
			if Branch[1] ~= "LABEL" then
				-- Opcode Handling & Operand/Ctrl Byte Initialization:
				local InstructionUppercase = Branch[1]:upper()
				local Instruction = INSTRUCTION_ENCODE[Branch[1]:upper()]
				
				assert(InstructionUppercase)
				assert(Instruction, "Could not encode instruction: "..InstructionUppercase)
				
				TextOutput[#TextOutput+1] = Instruction
				
				local OperandData = {}
				local ControlByteString = ""
				
				-- Control Byte Handling:
				for _,Operand in Branch[2] do
					if Operand["type"] == "label" then
						-- The assembler pretty readily assumes label is always Type O, 64 bit
						-- For precise offsets we use Type S segmentation offset anyways
						TextOutput[#TextOutput+1] = 0xB8 -- 64 bit Type O (Offset) Byte
						continue
					else
						assert(Operand["type"], "No Operand Type Found")
						assert(Operand["size"], "No Operand Size Found")
						ControlByteString ..= UASM_CONV_TYPE_TABLE[Operand["type"]]
						ControlByteString ..= ":"..tostring(Operand["size"])
					end
					
					ControlByteString ..= "/"
				end
				
				if ControlByteString ~= "" then
					ControlByteString = string.sub(ControlByteString, 1, ControlByteString:len()-1)
					local ControlByteResult = UASM_CTRL_BYTE_CONV_DATA[ControlByteString]
					
					if ControlByteResult then
						TextOutput[#TextOutput+1] = ControlByteResult
					else
						error("FATAL: Invalid Control Byte: "..ControlByteString)
					end
				end
				
				-- Operand Handling:
				for _,Operand in Branch[2] do
					if Operand["type"] == "label" then
						TextOutput[#TextOutput+1] = 0
						LabelOperandInit[#LabelOperandInit] = {#TextOutput, Operand["value"]}
					elseif Operand["type"] == "Register Offset" then
						TextOutput[#TextOutput+1] = RegisterEncodings[Operand["value"]]
						TextOutput[#TextOutput+1] = tonumber(Operand["OffsetNum"])
					else
						TextOutput[#TextOutput+1] = tonumber(Operand["value"])
					end
				end
			else
				TextOutput[#TextOutput+1] = 0 -- NO-OP
				LabelAddresses[Branch[2]] = #TextOutput
			end
		end
		
		for _,labelinit in LabelOperandInit do
			TextOutput[labelinit[1]] = LabelAddresses[labelinit[2]]
		end
		
		if not GlobalTable.GlobalData then
			GlobalTable.GlobalData = {}
		end
		if not GlobalTable.GlobalLabels then
			GlobalTable.GlobalLabels = {}
		end
		
		for Name in GlobalNames do
			if DataDeclarations[Name] then
				GlobalTable.GlobalData[Name] = DataDeclarations[Name]
			end
			if LabelAddresses[Name] then
				GlobalTable.GlobalLabels[Name] = LabelAddresses[Name]
			end
		end
	end
	
	print(TextOutput)
	return {TextOutput, DataOutput, GlobalTable}
end

function Module:BulkAssemble(SourceFiles, Architecture)
	if typeof(SourceFiles) == "string" then
		return {Module:Assemble(SourceFiles, Architecture)}
	elseif typeof(SourceFiles) == "table" then
		local Output = {}
		assert(SourceFiles[1] ~= nil, "Index 1 is nil or table is not an array")
		for i = 1, #SourceFiles do
			table.insert(Output, Module:Assemble(SourceFiles[i], Architecture))
		end
		return Output
	else
		error("UASM: Invalid Source File Type")
	end
end

function Module:FileAssemble(ASMFile: Instance, Architecture: string)
	assert(typeof(ASMFile) == "Instance" and ASMFile.ClassName == "ModuleScript", "Invalid Assembler Source File")
	if ASMFile.Name:find(".s") then
		local Data = require(ASMFile)
		assert(type(Data) == "string", "Invalid Assembler Source File: must return a string")
		local AssembledBinary = Module:Assemble(Data, Architecture)
		local NewFile = Instance.new("ModuleScript")
		NewFile.Parent = ASMFile.Parent
		NewFile.Name = string.sub(ASMFile.Name, 1, ASMFile.Name:len()-2)..".o"
		NewFile.Source = "return { "
		
		for _,v in ipairs(AssembledBinary[1]) do
			NewFile.Source ..= "{ "..v.." },"
		end
		NewFile.Source ..= " }"
	else
		error("file does not end in .s")
	end
end

return Module
