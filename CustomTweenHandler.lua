-- AbnormallyCursed, March 2024
-- Custom Tween Handler for using PivotTo on Models

local Module = {}

function Module:TweenHandler()
	self.ModelTweens = {}
	self.TweenSafety = {}
	local Active = false
	local TweenService = self.Services.TweenService
	local TweenGetAlpha = self.Services.TweenService.GetValue
	local Cache = {}
	local Connection
	
	for _,v in Enum.EasingStyle:GetEnumItems() do
		Cache[v.Name] = {}
		for _,x in Enum.EasingDirection:GetEnumItems() do
			Cache[v.Name][x.Name] = {}
		end
	end
	
	local function GetAlpha(Value, EasingStyle, EasingDirection)
		local TargetCache = Cache[EasingStyle.Name][EasingDirection.Name]
		local Result = TargetCache[Value]
		
		if Result == nil then
			Result = TweenGetAlpha(TweenService, Value, EasingStyle, EasingDirection)
			TargetCache[Value] = Result
		end
		
		return Result
	end
	
	local function RenderStepped(delta)
		for _,v in self.ModelTweens do
			if v.Length == nil then continue end
			local Alpha = GetAlpha(1 - v.Length ^ delta, v.EasingStyle, v.EasingDirection)
			local NewCF = v.LastCF:Lerp(v.Goal, Alpha)
			v.Target:PivotTo(NewCF)
			
			if os.clock()-v.StartTime >= v.Time+delta then
				table.remove(self.ModelTweens, v.Index)
				table.clear(v)
				if #self.ModelTweens == 0 then
					self:StopModelTween()
				end
				continue
			end
			v.LastCF = NewCF
		end
	end
	
	function self:StartModelTween()
		if Active == true then
			return
		end
		Active = true
		Connection = self.Services.RunService.RenderStepped:Connect(RenderStepped)
	end
	
	function self:StopModelTween()
		if Active == false then
			return
		end
		Active = false
		Connection:Disconnect()
	end
	
	function self:CancelTween(OperationID)
		table.clear(self.ModelTweens[OperationID])
		self.ModelTweens[OperationID] = nil
	end
	
	function self:TweenModel(Table): number
		if self.TweenSafety[Table.Target] and self.ModelTweens[self.TweenSafety[Table.Target]] then
			self:CancelTween(self.TweenSafety[Table.Target])
		end
		Table.Index = #self.ModelTweens+1
		Table.Time = Table.Length
		Table.Length = Table.Length/86400
		Table.StartTime = os.clock()
		table.insert(self.ModelTweens, Table)
		self:StartModelTween()
		self.TweenSafety[Table.Target] = Table.Index
		return Table.Index
	end
	
end

return Module
