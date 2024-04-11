local EEPROM = require(script.Parent.EEPROM)

return function(Computer: Instance)
	local CurrentCoroutine = nil
	local function PowerOn()
		CurrentCoroutine = coroutine.create(EEPROM)
		coroutine.resume(CurrentCoroutine, Computer)
	end
	local function PowerOff()
		coroutine.close(CurrentCoroutine)
		CurrentCoroutine = nil
		Computer.SurfaceGui:ClearAllChildren()
	end
	
	Computer.PowerState.Changed:Connect(function(Value)
		if Value then
			PowerOn()
		else
			PowerOff()
		end
	end)
	
	if Computer.PowerState.Value then
		PowerOn()
	end
end