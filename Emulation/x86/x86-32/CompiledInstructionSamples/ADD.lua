return {[0x83] = function(self)
local Size1 = self:GetSizeOSA()		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 8		self:select(2, Size2)
		

			
				local op1 = ISREG and self.reg[REG] or self:load(MODRM)
	local op2 = self:loadnext2()
	local RESULT = op1+op2
				if ISREG then
			    self.reg[REG] = RESULT
			else
			    self:store(MODRM, RESULT)
			end
			
	
end,
[0x81] = function(self)
local Size1 = self:GetSizeOSA()		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = self:GetSizeOSA()		self:select(2, Size2)
		

			
				local op1 = ISREG and self.reg[REG] or self:load(MODRM)
	local op2 = self:loadnext2()
	local RESULT = op1+op2
				if ISREG then
			    self.reg[REG] = RESULT
			else
			    self:store(MODRM, RESULT)
			end
			
	
end,
[0x80] = function(self)
local Size1 = 8		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 8		self:select(2, Size2)
		

			
				local op1 = ISREG and self.reg[REG] or self:load(MODRM)
	local op2 = self:loadnext2()
	local RESULT = op1+op2
				if ISREG then
			    self.reg[REG] = RESULT
			else
			    self:store(MODRM, RESULT)
			end
			
	
end,
[0x02] = function(self)
local Size1 = 8		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 8		self:select(2, Size2)
		

			
				local op1 = self.reg[REG]
	local op2 = ISREG and self.reg[REG] or self:load(MODRM)
	local RESULT = op1+op2
	self.reg[REG] = RESULT
	
end,
[0x03] = function(self)
local Size1 = self:GetSizeOSA()		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = self:GetSizeOSA()		self:select(2, Size2)
		

			
				local op1 = self.reg[REG]
	local op2 = ISREG and self.reg[REG] or self:load(MODRM)
	local RESULT = op1+op2
	self.reg[REG] = RESULT
	
end,
[0x00] = function(self)
local Size1 = 8		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = 8		self:select(2, Size2)
		

			
				local op1 = ISREG and self.reg[REG] or self:load(MODRM)
	local op2 = self.reg[REG]
	local RESULT = op1+op2
				if ISREG then
			    self.reg[REG] = RESULT
			else
			    self:store(MODRM, RESULT)
			end
			
	
end,
[0x01] = function(self)
local Size1 = self:GetSizeOSA()		self:select(1, Size1)
		local REG, MODRM, ISREG = self.modrm[self:loadnext8()]()

local Size2 = self:GetSizeOSA()		self:select(2, Size2)
		

			
				local op1 = ISREG and self.reg[REG] or self:load(MODRM)
	local op2 = self.reg[REG]
	local RESULT = op1+op2
				if ISREG then
			    self.reg[REG] = RESULT
			else
			    self:store(MODRM, RESULT)
			end
			
	
end,
}
