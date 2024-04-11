local m = {physicalMemory = {}}
local Module = m.physicalMemory
local NULL = string.char(0)
local UNPACK = string.unpack
local PACK = string.pack

local L2BTT = {
	[0] = 1,
	[1] = 2,
	[2] = 4,
	[3] = 8,
}
local ByteToFormat = {
	[1] = "B",
	[2] = "H",
	[4] = "I",
	[8] = "L",
}

Module.supportsFetch = true

local function createMemoryDevice(MemoryStart, MemoryEnd, OnREAD, OnWRITE)
	local memorytable
	
	if OnREAD and OnWRITE then
		memorytable = setmetatable({}, {
			__index = function(Table, Index)
				local Result = OnREAD(Index) or NULL
				Table[Index] = Result
				return Result
			end,
			__newindex = OnWRITE
		})
	else
		if OnREAD or OnWRITE then
			error("OnREAD and OnWRITE must [BOTH] be defined on mapped memory")
		end
		memorytable = setmetatable({}, {
			__index = function(Table, Index)
				Table[Index] = NULL
				return NULL
			end,
		})
	end
	
	return {MemoryStart, MemoryEnd, {
		start = MemoryStart,
		device = {
			supportsFetch = true,
			load = function(address, sizelog2)
				address = address - 1
				local result = ""
				local Size = L2BTT[sizelog2]
				
				for i = 1, Size do
					result ..= memorytable[address+i]
				end
								
				return UNPACK(ByteToFormat[Size], result)
			end,
			store = function(address, value, sizelog2)
				address = address - 1
				local Size = L2BTT[sizelog2]
				local Pack = PACK(ByteToFormat[Size], value):split()
				
				for i = 1, Size do
					memorytable[address+i] = Pack[i]
				end
			end,
		},
		address = MemoryStart,
		MemoryTable = memorytable
	}}
end

local MemoryDevsAddressStart = {}
local TaggedDevices = {}

function m:CreateMemoryMappedDevice(DeviceTag: string, RangeStart: number, RangeEnd: number, OnREAD, OnWRITE)
	local DeviceIndex = #MemoryDevsAddressStart+1
	TaggedDevices[DeviceTag] = DeviceIndex
	MemoryDevsAddressStart[DeviceIndex] = createMemoryDevice(RangeStart, RangeEnd, OnREAD, OnWRITE)
	return MemoryDevsAddressStart[DeviceIndex]
end
function m:GetMemoryMappedDevice(DeviceTag: string)
	return MemoryDevsAddressStart[TaggedDevices[DeviceTag]]
end
function m:RemoveMemoryMappedDevice(DeviceTag: string)
	MemoryDevsAddressStart[TaggedDevices[DeviceTag]] = nil
end

function Module:load(pteAddress, pteSizeLog2)
	return self:getMemoryRange(pteAddress).device.load(pteAddress, pteSizeLog2)
end

function Module:store(pteAddress, pte, pteSizeLog2)
	return self:getMemoryRange(pteAddress).device.store(pteAddress, pte, pteSizeLog2)
end

function Module:getMemoryRange(physicalAddress)
	for _,address in MemoryDevsAddressStart do
		if physicalAddress >= address[1] and physicalAddress <= address[2] then
			return address[3]
		else
			  warn("no implementation")
		end
	end
end

function Module:setDirty(range, offset)
	  warn("no implementation")
end

return m
