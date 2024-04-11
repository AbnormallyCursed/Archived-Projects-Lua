local WAIT = task.wait
local MRANDOM = math.random
local CLAMP = math.clamp
local TICK = tick
local SUB = string.sub

return function(self)
	if self == nil then return end
	for _,Module in script.Parent:GetDescendants() do
		if Module.ClassName == "ModuleScript" and not Module:IsDescendantOf(script.Parent.Ignore) then
			for i,v in require(Module) do
				self[i] = v
			end
		end
	end
	
	local NewFrame = Instance.new("Frame")
	NewFrame.Parent = self.Screen
	NewFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
	NewFrame.Size = UDim2.new(1, 0, 1, 0)
	NewFrame.Name = "Background"
	self.CLI_OUT = self.cliclone:Clone()
	self.CLI_OUT.Parent = self.Screen
	self.CLI_OUT.Size = UDim2.new(1, 0, 0.97, 0)
	self.Ignore = script.Parent.Ignore
	
	-- Linux Boot Handler:
	spawn(function()
		local Blinker = self:NewLabel("_")
		Blinker.Parent = self.CLI_OUT.Parent
		Blinker.Position = UDim2.new(0, 0, 0.97, 0)
		while WAIT(0.5) do
			Blinker.Visible = false
			WAIT(0.5)
			Blinker.Visible = true
		end
	end)
	local start = TICK()
	for i,v in self.Messages do
		WAIT(self.Time[i] or 0)
		self:NewLabel(string.format(v, SUB(TICK()-start, 1,8)))
		self.CLI_OUT.CanvasPosition += Vector2.new(0,9999)
	end
	
	self.CLI_OUT.Size = UDim2.new(1, 0, 1, 0)
	self:ClearAllLabels()
	self:NewLabel("")
	self:NewLabel("ODIN Linux 5.19.7-odin1-1.0 (tty1)")
	self:NewLabel("")
	self:NewLabel("localhost login: root (automatic login)")
	self:NewLabel("")
	self:InitializeCommandLine()
	self:SetInputPromptName("root@localhost")
	self:NewInputPrompt()
	self:StartFileSystem()
	self:StartMain()
end