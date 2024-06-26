-- This file was automatically generated by the x86-32 Instruction Compiler v1

return {[0xC6] = function(self)
local Size1 = 8		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 8		self:select(2, Size2)
		

			
				local op2 = self:loadnext2()
				if ISREG then
			    self.reg[REG] = op2
			else
			    self:store(MODRM, op2)
			end
			
	
end,
[0xC7] = function(self)
local Size1 = self:GetSizeOSA()		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = self:GetSizeOSA()		self:select(2, Size2)
		

			
				local op2 = self:loadnext2()
				if ISREG then
			    self.reg[REG] = op2
			else
			    self:store(MODRM, op2)
			end
			
	
end,
[0x8B] = function(self)
local Size1 = self:GetSizeOSA()		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = self:GetSizeOSA()		self:select(2, Size2)
		

			
				local op2 = ISREG and self.reg[REG] or self:load(MODRM)
	self.reg[REG] = op2
	
end,
[0x8C] = function(self)
local Size1 = 16		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 16		self:select(2, Size2)
		

			
				local op2 = self.sreg[REG]
	self:store(MODRM, op2)
	
end,
[0xB8] = function(self)
local Size1 = self:GetSizeOSA()		self:select(1, Size1)
		

local Size2 = self:GetSizeOSA()		self:select(2, Size2)
		

			
				local op2 = self:loadnext2()
	error('illegal')
	
end,
[0x8A] = function(self)
local Size1 = 8		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 8		self:select(2, Size2)
		

			
				local op2 = ISREG and self.reg[REG] or self:load(MODRM)
	self.reg[REG] = op2
	
end,
[0xB0] = function(self)
local Size1 = 8		self:select(1, Size1)
		

local Size2 = 8		self:select(2, Size2)
		

			
				local op2 = self:loadnext2()
	error('illegal')
	
end,
[0x89] = function(self)
local Size1 = self:GetSizeOSA()		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = self:GetSizeOSA()		self:select(2, Size2)
		

			
				local op2 = self.reg[REG]
				if ISREG then
			    self.reg[REG] = op2
			else
			    self:store(MODRM, op2)
			end
			
	
end,
[0x8E] = function(self)
local Size1 = 16		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 16		self:select(2, Size2)
		

			
				local op2 = ISREG and self.reg[REG] or self:load(MODRM)
	self.sreg[REG] = op2
	
end,
[0x88] = function(self)
local Size1 = 8		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 8		self:select(2, Size2)
		

			
				local op2 = self.reg[REG]
				if ISREG then
			    self.reg[REG] = op2
			else
			    self:store(MODRM, op2)
			end
			
	
end,
}
