-- some of my more lazy coding but that's because I am in misery, tired, and this is highly complex
local Rerubi = require(script.Parent.Rerubi)
local Compiler = require(script.Parent["Lua 5.1"])

local ImportedGlobals = {
	_G, game, script, getfenv, setfenv, workspace,
	getmetatable, setmetatable, loadstring, coroutine,
	rawequal, typeof, print, math, warn, error,  pcall,
	xpcall, select, rawset, rawget, ipairs, pairs,
	next, Rect, Axes, os, time, Faces, unpack, string, Color3,
	newproxy, tostring, tonumber, Instance, TweenInfo, BrickColor,
	NumberRange, ColorSequence, NumberSequence, ColorSequenceKeypoint,
	NumberSequenceKeypoint, PhysicalProperties, Region3int16,
	Vector3int16, require, table, type, wait,
	Enum, UDim, UDim2, Vector2, Vector3, Region3, CFrame, Ray, spawn, delay, task, assert =
	-- SET:	
	{}, nil, nil, getfenv, setfenv, nil,
	getmetatable, setmetatable, nil, coroutine,
	rawequal, nil, print, math, warn, error,  pcall,
	xpcall, select, rawset, rawget, ipairs, pairs,
	next, Rect, Axes, os, time, table.unpack, string, nil,
	newproxy, tostring, tonumber, nil, nil, nil,
	nil, nil, nil, nil,
	nil, nil, nil,
	nil, nil, table, type, task.wait,
	nil, nil, nil, nil, nil, nil, nil, nil, task.defer, task.delay, task, function(cond, errMsg) return cond or error(errMsg or "assertion failed!", 2) end;
}
local RAM = setmetatable({}, {
	__index = function(self, Index)
		return self[Index]
	end,
	__newindex = function(self, Index, Value)
		rawset(self, Index, Value)
	end,
})

local ExceptionHandlers = {}
local ThreadIdentities = {}
local GlobalAllocation = 0
local CoreCount = 2

local Cores = setmetatable({}, {
	__newindex = function(t, key, val)
		assert(typeof(val) == "thread")
		if key > 2 or key <= 0 then
			error("attempt to access a non-existent processor core")
		end
		
		rawset(t, key, val)
	end,
})

local function StartProgram(thread, coren)
	Cores[coren] = thread
	task.defer(thread)
	return thread
end

local function StopProgram(coren)
	local thread = Cores[coren]
	local newthread = coroutine.create(ThreadIdentities[thread])
	ThreadIdentities[newthread] = ThreadIdentities[thread]
	ThreadIdentities[thread] = nil
	task.cancel(thread)
	return newthread
end

local function RaiseException(excep_name)
	StartProgram(ExceptionHandlers[excep_name], 1)
end

local function SanitizeSuperStack(SuperStack)
	local DataFreed = 0
	table.remove(SuperStack, 1)
	
	for _,v in SuperStack do
		if not (v or v[1]) then
			continue
		end
		
		if v[1] == "SuperStack" then
			SanitizeSuperStack(v)
		else
			DataFreed += v[2]
			for i = v[1], v[2] do
				RAM[i] = nil
			end
		end
	end
	
	return DataFreed
end

-- disgusting:
local function call_safe(callback, exception_name, ...)
	local t = table.pack(...)
	xpcall(function()
		callback(table.unpack(t))
		end, function()
		RaiseException(exception_name)
	end)
end

local function LoadProgram(MachineCode, StartLocation, AllocatedSpace)
	print(MachineCode:len())
	local StoredStartLocation = StartLocation
	local AllocationStartLocation = 0
	StartLocation = GlobalAllocation+StartLocation
	local InternalStack = {}
	local script_env = table.clone(ImportedGlobals)
	
	local MasterController = {
		Strt = StartLocation,
		Size = #MachineCode,
		RAM = RAM,
	}
	
	local function SanitizeStackEntry(Key)
		if not (InternalStack or InternalStack[Key] or InternalStack[Key][1]) then -- this force of evil is not one to be trifled with
			return true
		end

		if InternalStack[Key][1] == "SuperStack" then
			SanitizeSuperStack(InternalStack[Key])
		else
			if InternalStack[Key][2] then
				for i = InternalStack[Key][1], InternalStack[Key][2] do
					RAM[i] = nil
				end
			else
				return
			end
		end
	end
	
	local function StorePrimitive(Key, Data)
		local s,e = pcall(function()
			if type(Data) == "number" then
				if (StartLocation-AllocationStartLocation)+8 > AllocatedSpace then
					RaiseException("segmentation_fault")
				end
				InternalStack[Key] = {StartLocation, 8}
				
				for _,v in string.pack("n", Data):split() do
					RAM[StartLocation] = v
					StartLocation += 1
				end
			elseif type(Data) == "string" then
				if (StartLocation-AllocationStartLocation)+Data:len() > AllocatedSpace then
					RaiseException("segmentation_fault")
				end
				InternalStack[Key] = {StartLocation, Data:len()}

				for _,v in Data:split("") do
					RAM[StartLocation] = v
					StartLocation += 1
				end
			elseif type(Data) == "boolean" then
				if (StartLocation-AllocationStartLocation)+1 > AllocatedSpace then
					RaiseException("segmentation_fault")
				end
				InternalStack[Key] = {StartLocation, 1}
				RAM[StartLocation] = Data and 0 or 1
				StartLocation += 1
			elseif type(Data) == "table" then
				-- metatables could easily pose a security flaw, gonna ignore for now :3
				local SuperStack = {"SuperStack"}
				local TablePointer = 2
				local StoredInternalStack = table.clone(InternalStack)
				InternalStack[Key] = SuperStack
				InternalStack = SuperStack

				for _,v in Data do
					StorePrimitive(TablePointer, v)
					TablePointer += 1
				end

				InternalStack = StoredInternalStack
			elseif type(Data) == "userdata" then
				if not MasterController.OperatingSystemPrivilege then
					error()
				end
			elseif Data == nil then
				StartLocation -= SanitizeStackEntry(Key)
			end
		end)
		
		if not s then
			RaiseException("segmentation_fault")
		end
	end
	
	MasterController.SetData = StorePrimitive
	
	for _,v in MachineCode:split("") do
		RAM[StartLocation] = v
		StartLocation += 1
	end
	
	function MasterController.wipedata()
		for i in InternalStack do
			SanitizeStackEntry(i)
		end
	end
	
	function MasterController.wipe_program()
		for i = StoredStartLocation, StartLocation do
			RAM[i] = nil
		end
		GlobalAllocation-=StartLocation
	end
	
	function MasterController.OS_GENV_INDEX(index)
		if MasterController.OperatingSystemPrivilege then
			setmetatable(ImportedGlobals, {__index = index})
		else
			error("Access Denied")
		end
	end
	
	MasterController.call_safe = call_safe
	GlobalAllocation = StartLocation+AllocatedSpace
	AllocationStartLocation = StartLocation
	local Func = Rerubi(MachineCode, script_env, MasterController)
	local NewThread = coroutine.create(Func)
	ThreadIdentities[NewThread] = Func
	
	return NewThread, script_env
end

local NewProgram = LoadProgram(Compiler([[
print("lOL!")
]]), 0, 128)

StartProgram(NewProgram, 1)