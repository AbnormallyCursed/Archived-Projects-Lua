-- AbnormallyCursed
-- I want to remind you that this is all manually written.
local Module = {}

local modRM_reg8 = {
	[0b000] = "AL",
	[0b001] = "CL",
	[0b010] = "DL",
	[0b011] = "BL",
	[0b100] = "AH",
	[0b101] = "CH",
	[0b110] = "DH",
	[0b111] = "BH",
}
local modRM_reg16 = {
	[0b000] = "AX",
	[0b001] = "CX",
	[0b010] = "DX",
	[0b011] = "BX",
	[0b100] = "SP",
	[0b101] = "BP",
	[0b110] = "SI",
	[0b111] = "DI",
}
local modRM_reg32 = {
	[0b000] = "EAX",
	[0b001] = "ECX",
	[0b010] = "EDX",
	[0b011] = "EBX",
	[0b100] = "ESP",
	[0b101] = "EBP",
	[0b110] = "ESI",
	[0b111] = "EDI",
}
local modRM_regMM = {
	[0b000] = "MM0",
	[0b001] = "MM1",
	[0b010] = "MM2",
	[0b011] = "MM3",
	[0b100] = "MM4",
	[0b101] = "MM5",
	[0b110] = "MM6",
	[0b111] = "MM7",
}
local modRM_regXMM = {
	[0b000] = "XMM0",
	[0b001] = "XMM1",
	[0b010] = "XMM2",
	[0b011] = "XMM3",
	[0b100] = "XMM4",
	[0b101] = "XMM5",
	[0b110] = "XMM6",
	[0b111] = "XMM7",
}
local reg8reversed = {
	["AL"] = 0,
	["BH"] = 1,
	["DH"] = 2,
	["CH"] = 3,
	["AH"] = 4,
	["BL"] = 5,
	["DL"] = 6,
	["CL"] = 7
}
local reg16reversed = {
	["AX"] = 0,
	["DI"] = 1,
	["SI"] = 2,
	["BP"] = 3,
	["SP"] = 4,
	["BX"] = 5,
	["DX"] = 6,
	["CX"] = 7
}
local reg32reversed = {
	["EAX"] = 0,
	["EDI"] = 1,
	["ESI"] = 2,
	["EBP"] = 3,
	["ESP"] = 4,
	["EBX"] = 5,
	["EDX"] = 6,
	["ECX"] = 7
}
-- Table for converting byte numerical to respective bit string
local IIIbitENC = {
	[0b000] = "000",
	[0b001] = "001",
	[0b010] = "010",
	[0b011] = "011",
	[0b100] = "100",
	[0b101] = "101",
	[0b110] = "110",
	[0b111] = "111",
}

-- $ is address, ! is register, & is SIB
local modRM_modrmENC = {
	["00_000"] = "$EAX",
	["01_000"] = "$EAX+disp8",
	["10_000"] = "$EAX+disp32",
	["11_000"] = "!AL,AX,EAX",
	["00_001"] = "$ECX",
	["01_001"] = "$ECX+disp8",
	["10_001"] = "$ECX+disp32",
	["11_001"] = "!CL,CX,ECX",

	["00_010"] = "$EDX",
	["01_010"] = "$EDX+disp8",
	["10_010"] = "$EDX+disp32",
	["11_010"] = "!DL,DX,EDX",
	["00_011"] = "$EBX",
	["01_011"] = "$EBX+disp8",
	["10_011"] = "$EBX+disp32",
	["11_011"] = "!BL,BX,EBX",

	["00_100"] = "&",
	["01_100"] = "&+disp8",
	["10_100"] = "&+disp32",
	["11_100"] = "!AH,SP,ESP",
	["00_101"] = "32-bit Displacement-Only Mode",
	["01_101"] = "$EBP+disp8",
	["10_101"] = "$EBP+disp32",
	["11_101"] = "!CH,BP,EBP",

	["00_110"] = "$ESI",
	["01_110"] = "$ESI+disp8",
	["10_110"] = "$ESI+disp32",
	["11_110"] = "!DH,SI,ESI",
	["00_111"] = "$EDI",
	["01_111"] = "$EDI+disp8",
	["10_111"] = "$EDI+disp32",
	["11_111"] = "!BH,DI,EDI",
}

local MODRM_FormationTable = {
	Size8 = {},
	Size16 = {},
	Size32 = {},
	-- not sure how to do these
	SizeMM = {},
	SizeXMM = {}
}
local SIB_FormationTable = {
	["00"] = {},
	["01"] = {},
	["10"] = {},
}

local function FormModRM(bin, bitenc)
	return tonumber(string.gsub(bin, "_", bitenc), 2)
end

function Module:loadRM(Size: number, MODRM: string, IsReg:boolean)
	if IsReg then
		
	else
		
	end
end

function Module:storeRM(Size: number, MODRM: string, IsReg:boolean)
	if IsReg then
		
	else
		
	end
end

function Module:StartModRM()
	local ScaleValue = 1
	local CTR = 0
		
	for n, BinaryValue in {"00", "01", "10", "11"} do
		local Formation = BinaryValue

		if n ~= 1 then
			ScaleValue *= 2
		end

		for _,Bit_ENC in IIIbitENC do
			local Index = tonumber(Bit_ENC, 2)

			if Index == 4 then
				warn("illegal")
				continue
			end

			Formation ..= Bit_ENC
			Bit_ENC = nil

			for _,Bit_ENC in IIIbitENC do
				local Base = tonumber(Bit_ENC, 2)
				CTR += 1
				Formation ..= Bit_ENC
				
				SIB_FormationTable["01"][tonumber(Formation, 2)] = function(Displacement)
					return (Displacement + self.reg8[Base] + self.reg32[Index]) * ScaleValue
				end
				
				SIB_FormationTable["10"][tonumber(Formation, 2)] = function(Displacement)
					return (Displacement + self.reg32[Base] + self.reg32[Index]) * ScaleValue
				end
				
				if Base == 5 then
					SIB_FormationTable["00"][tonumber(Formation, 2)] = function()
						return (self.reg32[Base] + self.reg32[Index]) * ScaleValue
					end
				else
					SIB_FormationTable["00"][tonumber(Formation, 2)] = function(Displacement)
						return (Displacement + self.reg32[Index]) * ScaleValue
					end
				end
			end
		end
	end
	
	print("GUH!")
	print(CTR)
	
	for binary, value in modRM_modrmENC do
		if value == "32-bit Displacement-Only Mode" then
			-- not supported right now
			
			for _,Bit_ENC in IIIbitENC do
				MODRM_FormationTable.Size8[FormModRM(binary, Bit_ENC)] = function()
					error("32-bit Displacement-Only Mode: currently not supported")
				end

				MODRM_FormationTable.Size16[FormModRM(binary, Bit_ENC)] = function()
					error("32-bit Displacement-Only Mode: currently not supported")
				end

				MODRM_FormationTable.Size32[FormModRM(binary, Bit_ENC)] = function()
					error("32-bit Displacement-Only Mode: currently not supported")
				end
			end
		else
			local Prefix = string.sub(value, 1,1)

			if Prefix == "$" then
				local Data = string.split(value:sub(2, value:len()), "+")
				local Register = reg32reversed[Data[1]]

				if Data[2] then
					local Offset = tonumber(Data[2])
					local LoadFunc = Offset == "disp8" and self["loadnext8"] or self["loadnext32"]
					
					for _,Bit_ENC in IIIbitENC do
						local RealBIT_ENC = tonumber(Bit_ENC, 2)

						MODRM_FormationTable.Size8[FormModRM(binary, Bit_ENC)] = function()
							return RealBIT_ENC, self.reg32[Register]+LoadFunc(self)
						end

						MODRM_FormationTable.Size16[FormModRM(binary, Bit_ENC)] = function()
							
							return RealBIT_ENC, self.reg32[Register]+LoadFunc(self)
						end

						MODRM_FormationTable.Size32[FormModRM(binary, Bit_ENC)] = function()
							return RealBIT_ENC, self.reg32[Register]+LoadFunc(self) 
						end
					end
				else
					for _,Bit_ENC in IIIbitENC do
						local RealBIT_ENC = tonumber(Bit_ENC, 2)

						MODRM_FormationTable.Size8[FormModRM(binary, Bit_ENC)] = function()
							return RealBIT_ENC, self.reg32[Register]
						end

						MODRM_FormationTable.Size16[FormModRM(binary, Bit_ENC)] = function()
							return RealBIT_ENC, self.reg32[Register]
						end

						MODRM_FormationTable.Size32[FormModRM(binary, Bit_ENC)] = function()
							return RealBIT_ENC, self.reg32[Register]
						end
					end
				end

			elseif Prefix == "!" then
				local Data = string.split(value:sub(2,8), ",")
				local r8 = reg8reversed[Data[1]]
				local r16 = reg16reversed[Data[2]]
				local r32 = reg32reversed[Data[3]]

				for _,Bit_ENC in IIIbitENC do
					local RealBIT_ENC = tonumber(Bit_ENC, 2)

					MODRM_FormationTable.Size8[FormModRM(binary, Bit_ENC)] = function()
						return RealBIT_ENC, r8, true
					end

					MODRM_FormationTable.Size16[FormModRM(binary, Bit_ENC)] = function()
						return RealBIT_ENC, r16, true
					end

					MODRM_FormationTable.Size32[FormModRM(binary, Bit_ENC)] = function()
						return RealBIT_ENC, r32, true
					end
				end

			elseif Prefix == "&" then
				if value == "&" then
					-- MOD 00, Zero Byte Disp
					local TargetTable = SIB_FormationTable["00"]
					
					for _,Bit_ENC in IIIbitENC do
						local RealBIT_ENC = tonumber(Bit_ENC, 2)

						MODRM_FormationTable.Size8[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE]()
						end

						MODRM_FormationTable.Size16[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE]()
						end

						MODRM_FormationTable.Size32[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE]()
						end
					end
										
				elseif value == "&+disp8" then
					-- MOD 01, One Byte Disp
					local TargetTable = SIB_FormationTable["01"]
					
					for _,Bit_ENC in IIIbitENC do
						local RealBIT_ENC = tonumber(Bit_ENC, 2)

						MODRM_FormationTable.Size8[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE](self:loadnext8())
						end

						MODRM_FormationTable.Size16[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE](self:loadnext8())
						end

						MODRM_FormationTable.Size32[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE](self:loadnext8())
						end
					end
					
				elseif value == "&+disp32" then
					-- MOD 10, Four Byte Disp
					local TargetTable = SIB_FormationTable["10"]
					
					for _,Bit_ENC in IIIbitENC do
						local RealBIT_ENC = tonumber(Bit_ENC, 2)

						MODRM_FormationTable.Size8[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE](self:loadnext32())
						end

						MODRM_FormationTable.Size16[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE](self:loadnext32())
						end

						MODRM_FormationTable.Size32[FormModRM(binary, Bit_ENC)] = function()
							local SIB_BYTE = self:loadnext8()
							return RealBIT_ENC, TargetTable[SIB_BYTE](self:loadnext32())
						end
					end
					
				end
			end
		end
	end
	
	self.modrm8 = MODRM_FormationTable.Size8
	self.modrm16 = MODRM_FormationTable.Size16
	self.modrm32 = MODRM_FormationTable.Size32
	print(self.modrm8, self.modrm16, self.modrm32)
end

return Module
