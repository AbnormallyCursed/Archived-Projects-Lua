local function LIO(o1, o2) -- Logical Inclusive OR
	return bit32.bor(o1, o2)
end

--[[
HOW TO USE THE INSTRUCTION COMPILER:

[1] 'Operand SET Protocol'
Syntax: "__OPERAND1_SET__: variable_identifier ;"
- where 'variable_identifier' is the source that goes into the destination for example
in a MOV instruction this is the data that you would be moving to a given destination
- the number after OPERAND specifies which operand you are targeting
- !!! THE SPACES ARE INCLUDED

[2] 'Operand GET Protocol'
Syntax: "local Operand1 = __OPERAND1_GET__"
- Replacement macro, quite literally just 1:1 replacement, no syntax
- the number after OPERAND specifies which operand you are targeting

--]]

-- reminder: destination to source
-- we're not doing bitwise yet as that's complicated

return {
	["ADD"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local RESULT = op1+op2
	__OPERAND1_SET__: RESULT ;
	]],
	-- we're not doing anything for this one
	["ADC"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local RESULT = op1+op2
	__OPERAND1_SET__: RESULT ;
	]],
	--
	["SUB"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local RESULT = op1-op2
	__OPERAND1_SET__: RESULT ;
	]],
	["MUL"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local RESULT = math.abs(op1*op2)
	__OPERAND1_SET__: RESULT ;
	]],
	["IMUL"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local RESULT = op1*op2
	__OPERAND1_SET__: RESULT ;
	]],
	["DIV"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local RESULT = math.abs(op1/op2)
	__OPERAND1_SET__: RESULT ;
	]],
	["IDIV"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local RESULT = op1/op2
	__OPERAND1_SET__: RESULT ;
	]],
	["INC"] = [[
	local op1 = __OPERAND1_GET__
	__OPERAND1_SET__: op1+1 ;
	]],
	["DEC"] = [[
	local op1 = __OPERAND1_GET__
	__OPERAND1_SET__: op1-1 ;
	]],
	["MOV"] = [[
	local op2 = __OPERAND2_GET__
	__OPERAND1_SET__: op2 ;
	]],
	["PUSH"] = [[
	local op1 = __OPERAND1_GET__
	self.reg[0b100] -= 1
	self:store(self.reg[0b100], op1)
	]],
	["POP"] = [[
	__OPERAND1_SET__: self:load(self.reg[0b100]) ;
	self.reg[0b100] += 1
	]],
	["RET"] = [[
	self.InstructionPointer = self:load(self.reg[0b100])
	self.reg[0b100] += 1
	]],
	["CALL"] = [[
	local op1 = __OPERAND1_GET__
	self.reg[0b100] -= 1
	self:store(self.reg[0b100], self.InstructionPointer)
	self.InstructionPointer = op1
	]],
	["SBB"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local result = op1-(op2+self.CF)
	__OPERAND1_SET__: result ;
	]],
	["CMP"] = [[
	local op1 = __OPERAND1_GET__
	local op2 = __OPERAND2_GET__
	local result = op1-op2
	self:UpdateStatusFlags(result)
	__OPERAND1_SET__: result ;
	]],
	["JMP"] = [[
	local op1 = __OPERAND1_GET__
	self.InstructionPointer = op1
	]],
	-- JMP Block (automatically generated since I am LAZY)
	['JO'] = [[if self:CheckCOND(0) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JNO'] = [[if self:CheckCOND(1) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JS'] = [[if self:CheckCOND(2) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JNS'] = [[if self:CheckCOND(3) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JE'] = [[if self:CheckCOND(4) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JNE'] = [[if self:CheckCOND(5) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JC'] = [[if self:CheckCOND(6) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JNC'] = [[if self:CheckCOND(7) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JBE'] = [[if self:CheckCOND(8) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JNBE'] = [[if self:CheckCOND(9) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JNGE'] = [[if self:CheckCOND(10) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JGE'] = [[if self:CheckCOND(11) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JLE'] = [[if self:CheckCOND(12) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JNLE'] = [[if self:CheckCOND(13) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JP'] = [[if self:CheckCOND(14) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],

	['JNP'] = [[if self:CheckCOND(15) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],
	['NOP'] = [[if self:CheckCOND(15) then
local op1 = __OPERAND1_GET__
 self.InstructionPointer = op1
 end]],
	
}
