-- AbnormallyCursed
-- 8/15/2023

local Module = {}
local SUB = string.sub
function ReverseTable(t)
	local reversedTable = {}
	local itemCount = #t
	for k, v in ipairs(t) do
		reversedTable[itemCount + 1 - k] = v
	end
	return reversedTable
end

function Module:StartInstructionProcessor()
	local Data = require(script["Instruction Set"])
	local OpcodeGroups = {}

	for InstructionName, Instruction in Data do
		local Format = ReverseTable(Instruction.format)
		local Checks = ReverseTable(Instruction.requires)
		local TargetOpcode
		local Lengths = {}
		local CheckList = {}
		local NameEnds = {}
		local NameLengths = {}
		local LastFormatName = ""

		for i,v in ipairs(Format) do
			local FormatItemSplit = v:split(":")
			local FormatName = FormatItemSplit[1]

			Lengths[i] = tonumber(FormatItemSplit[2])
			NameLengths[FormatName] = Lengths[i]

			if i == 1 then
				NameEnds[FormatName] = Lengths[i]
			else
				NameEnds[FormatName] = NameEnds[LastFormatName] + Lengths[i]
			end

			LastFormatName = FormatName
		end

		local CheckPointer = 1
		local Last = 1

		for _,Check in ipairs(Checks) do
			local CheckSplit = Check:split("=")
			if CheckSplit[1] == "opcode" then
				TargetOpcode = CheckSplit[2]
				continue
			end

			local TargetLength = NameLengths[CheckSplit[1]]
			local NameEnd = NameEnds[CheckSplit[1]]
			local NameStart = (NameEnd-TargetLength)+1

			CheckList[CheckPointer] = {}
			CheckList[CheckPointer][1] = NameStart
			CheckList[CheckPointer][2] = NameEnd
			CheckList[CheckPointer][3] = CheckSplit[2]
			CheckPointer += 1
			continue
		end

		local TargetGroup = OpcodeGroups[TargetOpcode]
		if TargetGroup == nil then
			OpcodeGroups[TargetOpcode] = {}
			TargetGroup = OpcodeGroups[TargetOpcode]
		end

		TargetGroup[#TargetGroup+1] = {Lengths, CheckList, InstructionName}
	end

	function self:decode(InstructionString: number)
		local BinaryInstruction = self:EncodeToBinary("I", InstructionString)
		local Group = OpcodeGroups[BinaryInstruction:sub(26,32)]
		if Group == nil then
			self:RaiseException(2)
			return
		end
		local Instruction = nil
		local Operands = {}

		for _,OpcodeGroup in Group do
			local IsInstruction = true

			for _,Check in OpcodeGroup[2] do
				if BinaryInstruction:sub(Check[1], Check[2]) ~= Check[3] then
					IsInstruction = false
					break
				end
			end

			if IsInstruction then
				Instruction = OpcodeGroup
				break
			end
		end

		if Instruction then
			for _,v in Instruction[1] do
				Operands[#Operands+1] = tonumber(string.sub(BinaryInstruction,1, v), 2)
				BinaryInstruction = string.sub(BinaryInstruction, v+1, BinaryInstruction:len())
			end

			print(Instruction[3])
			return self.InstructionList[Instruction[3]](self, unpack(Operands))
		end

		if Instruction then
			warn("Something odd occured during decoding instruction:", Instruction[3])
			print("Instruction String:", InstructionString.." / 0x"..string.format("%X", InstructionString, 2))
			print("Operands:", Operands)
			return
		end

		error("Could not decode the following instruction: 0x"..string.format("%X", InstructionString, 2))
	end
end

return Module
