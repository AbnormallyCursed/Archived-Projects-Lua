-- This is an old version of a tree system intended to essentially replace the ROBLOX metatable, the modern version can only be shown upon request.
-- This is considered archaic and is likely broken.

--[[
# gTree: General/Game Tree System
@ AbnormallyCursed, 2/11/2024
--]]

local Module = {}

function Module:StartTree(StartList)
	-- Initialization:
	local CollectionService = self.Services.CollectionService
	local GetTags = CollectionService.GetTags
	local GetAttributes = game.GetAttributes
	local wait = task.wait
	local clock = os.clock
	
	-- Tree System Variables:
	local gTree = {ChildPointer = 1, Children = {}} -- Directory tree similar to DataModel using the node system
	local gNodes = {} -- Actual Nodes, the index is a node address the value is the node table
	local pNodes = {} -- Pointer Nodes, the index is an instance the value is the node's addr
	local tDict = {} -- List Of Tagged Nodes
	local tDictPtr = {} -- Pointer Storage for Tagged Nodes
	local FreeNodes = {} -- List of Pointers to Free Nodes
	local NodePointer = 1
	local FreeNodePointer = 0
	local Mount
	self.gTree = gTree 
	self.gNodes = gNodes 
	self.LookupNodes = pNodes
	self.Tags = tDict
	
	-- API-Replacements:
	
	-- @WaitForChild
	-- 1st Return RETURNS THE ACTUAL INSTANCE, USE WaitForNode IF YOU WANT THE NODE DIRECTLY
	-- 2nd Return returns the address of the node if applicable
	local function WaitForChild(self, ChildName: string, TimeOut: number)
		local Child = self.INST:WaitForChild(ChildName, TimeOut)
		return Child, pNodes[Child]
	end
	
	-- Custom-API:
	
	-- @WaitForNode
	-- Yields for a node to be created under another node with ChildName name
	-- This function does not include the WaitForChild TimeOut argument due to optimization
	local function WaitForNode(self, ChildName: string)
		repeat
			wait()
			local trgt = self[ChildName]

			if trgt then
				return trgt
			end
		until false
	end
	
	local function ReadDataTarget(self, Target)
		if Target.ClassName == "ModuleScript" then
			print("THE AGONY")
			--self[tostring(Target)] = require(Target)
		elseif Target.ClassName == "Configuration" then
			for _, Value in Target:GetDescendants() do
				if Value:IsA("ValueBase") then
					self[tostring(Value)] = Value.Value
				end
			end
		elseif Target:IsA("ValueBase") then
			self[tostring(Target)] = Target.Value
		else
			return
		end

		Target.Destroy(Target)
	end

	-- @ReadData
	-- Function that transforms data in tags, attributes, instance values, modulescripts into readable properties under the instance
	-- Select target argument to merge a configuration folder, modulescript (Must be instance not node)
	-- Set target argument to be a true boolean to allow it to auto-Read
	-- AUTO ReadING: Auto Reading will search for any valid data-structure children under an instance and Read them
	-- NOTE: If an Instance Target is specified, standard Tag & Attribute Reading will not occur: Use Auto-Read instead
	-- Instance Target Reading is intended for whenever something was not there prior is now there and needs to be Readed.
	
	-- This Merges Data Into the InstanceTable, only problem is that you can NOT re-Read these mediums of data
	-- After the data-instances are Readed they are destroyed, you are to use the nodes in order to set and get data: not the instances
	
	local function ReadData(self, Target)
		if Target then
			if Target == true then
				-- Auto-Read:
				for _,v in self.INST:GetChildren() do
					ReadDataTarget(self, v)
				end
			else
				-- Instance-Target-Read:
				ReadDataTarget(self, Target)
				return
			end
		end
		
		for _,v in GetTags(CollectionService, self.INST) do
			self[v] = true
			
			if not tDict[v] then
				tDict[v] = {}
				tDictPtr[v] = 0
			end
			
			tDictPtr[v] += 1
			tDict[v][tDictPtr[v]] = self
		end

		for Name, Value in GetAttributes(self.INST) do
			self[Name] = Value
		end
	end
	
	-- Tree System Functions:
	
	-- @Unmount
	-- Unmounts an object from the tree
	local function Unmount(self)
		if self.ChildAddedWarden then
			self.ChildAddedWarden:Disconnect()
			self.ChildRemovingWarden:Disconnect()
		end
		
		pNodes[self.INST] = nil
		self:PushCache(self.INST)
		self.INST.Parent = nil
		FreeNodePointer += 1
		FreeNodes[FreeNodePointer] = self.ADDR
		gNodes[self.ADDR] = nil
		
		for i,v in self do
			if type(v) == "table" and i ~= "Children" then
				Unmount(v)
			end
		end
		
		table.clear(self)
	end
	
	-- @Mount
	-- Core of the system, forms a General Tree of all descendants of a specified target and creates nodes.
	Mount = function(parent, Target: Instance, Recursive: boolean)
		parent = parent or gTree
		local InstanceName = tostring(Target)
		local RealType = type(parent[InstanceName])
		print(RealType)
		print(parent, InstanceName)
		
		if RealType ~= "table" and RealType ~= "nil" then
			return error("failed to mount: node name cannot be the same as a property or function within the node table: "..InstanceName)
		end
		
		local InstanceTable = {
			-- Custom Defaults:
			ADDR = FreeNodes[FreeNodePointer] or NodePointer, -- The address of the node
			INST = Target, -- The actual instance
			Children = {},
			ChildPointer = 1,
			WaitForNode = WaitForNode,
			ReadData = ReadData,
			Mount = Mount,
			Unmount = Unmount,
			
			-- Property Replacements:
			Parent = parent,
			Name = InstanceName,
			ClassName = Target.ClassName,
			-- Function Replacements:
			WaitForChild = WaitForChild,
		}
		
		-- Main Initialization:
		if FreeNodes[FreeNodePointer] then
			FreeNodes[FreeNodePointer] = nil
			FreeNodePointer -= 1
			if FreeNodePointer < 1 then
				FreeNodePointer = 1
			end
		else
			gNodes[NodePointer] = InstanceTable
			pNodes[Target] = InstanceTable
			NodePointer += 1
		end
		
		if parent[InstanceName] == nil then
			parent[InstanceName] = InstanceTable
			parent = InstanceTable
		end
		
		parent.Children[parent.ChildPointer] = InstanceTable
		parent.ChildPointer += 1
		
		-- Data Reading:
		if self:CheckDataQualification(InstanceTable) then
			ReadData(InstanceTable, true)
		end
		
		-- Modification Warden:
		if self:WardenQualification(InstanceTable) then
			InstanceTable.ChildAddedWarden = Target.ChildAdded:Connect(function(Child)
				Mount(InstanceTable, Child)
			end)
			InstanceTable.ChildRemovingWarden = Target.ChildRemoved:Connect(function(Child)
				Unmount(InstanceTable, Child) -- It is up to the programmer to re-mount
			end)
			
			Target:GetPropertyChangedSignal("Parent"):Connect(function(lol)
				pNodes[Target.Parent]:Mount(Target)
			end)
		end
		
		-- Recursive:
		if Recursive then
			for _,v in Target:GetChildren() do
				local Tree = Mount(parent, v, Recursive)
				InstanceTable.Children[InstanceTable.ChildPointer] = Tree
				InstanceTable.ChildPointer += 1
			end
		end
		
		return InstanceTable
	end
	
	-- Tree System Startup:
	for _, Target in StartList do
		Mount(nil, Target, true)
	end
end

return Module
