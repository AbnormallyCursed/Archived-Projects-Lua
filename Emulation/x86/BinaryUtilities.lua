-- AbnormallyCursed
-- This file has the longest history within my emulation projects and it ahs been modified many times over the years
-- it is a complete suite full of utilities for dealing with binary numbers.
local floor,insert = math.floor, table.insert

function basen(n,b)
	n = floor(n)
	if not b or b == 10 then return tostring(n) end
	local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local t = {}
	local sign = ""
	if n < 0 then
		sign = "-"
		n = -n
	end
	repeat
		local d = (n % b) + 1
		n = floor(n / b)
		insert(t, 1, digits:sub(d,d))
	until n == 0
	return sign .. table.concat(t,"")
end

--[[
Advanced Binary Number System

Format Types:
(Some may not work if they do not align onto the 8 bit pattern)
Based off of the Lua 5.3 Reference:
Primary Format Types:
(d: double, f: float, i: signed int, I: unsigned int)
For further uses: https://www.lua.org/manual/5.3/manual.html#6.4.2

--]]

local Module = {}

Module.basen = basen

function Module:EncodeToBinary(Format, Number)
	local binaryStr = string.pack(Format, Number) -- get the float as bytes
	local stringStream = "" -- output variable

	for i=1, #binaryStr do -- setup iterator function based on amount of bytes
		local c = string.byte(binaryStr:sub(i,i)) -- get the ASCII decimal code of the given byte
		local byte = basen(c,2) -- convert ascii decimal to base2 (binary)
		while (#byte ~= 8) do
			byte = "0"..byte -- ensures the result follows an 8 bit pattern
		end
		stringStream = byte..stringStream  -- formation
	end

	return stringStream
end

function Module:DecodeFromBinary(Format, BinaryStream)
	local String = string.split(BinaryStream, "") -- Gets all bits as an array in the binary string
	local ByteCollection = {} -- Where we collect the bits to form bytes
	local BytePointer = 1 -- Pointer to tell what byte the system is on
	local DecodedBinary = "" -- Output

	for i = 1, #String do -- Iterate by length of string
		local Bit = String[i] -- Get the current bit sequentially
		if not ByteCollection[BytePointer] then
			ByteCollection[BytePointer] = "" -- Initializes byte
		end
		ByteCollection[BytePointer] ..= Bit -- adds a bit to the byte
		if i == 8*BytePointer then -- ensures we are always positioned on the proper byte
			BytePointer += 1
		end
	end

	for _,v in next, ByteCollection do
		DecodedBinary ..= string.char(tonumber(v, 2)) -- get the literal ASCII byte and collect it
	end

	-- 1: Reverse the ASCII byte string so endianness aligns
	-- 2: Unpack the ASCII byte string with format argument to return result
	return string.unpack(Format, string.reverse(DecodedBinary))
end

function Module:NewEncoding(Decimal, Length)
	-- Init:
	assert(Length < 65, "Encoding length must be 64 bits or lower")
	local BitLength = string.sub("0000000000000000000000000000000000000000000000000000000000000000", 1,Length)
	if Decimal == 0 then return BitLength end -- Roblox for some reason does not like processing 0 binary
	
	-- Conversion:
	local Binary = self:EncodeToBinary("L", Decimal)
	local BinLen = Binary:len()

	if Length < 1 or BinLen > Length then
		error("out of range")
	else
		if BinLen ~= Length then
			-- ALWAYS use least significant bits
			local MaskedNull = string.sub("00000", 1, Length-BinLen).."%s"					
			Binary = string.format(MaskedNull, Binary)
		end
	end
	
	return Binary
end

function Module:BinaryToHex(BINARY)
	return string.format("%X", tonumber(BINARY, 2))
end
-- Numbering Shortcuts:
function Module:EncodeFloat32(Input: number)
	return self:EncodeToBinary("f", Input)
end
function Module:EncodeFloat64(Input: number)
	return self:EncodeToBinary("d", Input)
end
function Module:DecodeFloat32(Input: string)
	return self:DecodeFromBinary("f", Input)
end
function Module:DecodeFloat64(Input: string)
	return self:DecodeFromBinary("d", Input)
end

return Module
