local cModule = {}

local NewPass = ""
for i=1,4 do
	Add = tostring(math.random(1,9))
	NewPass = NewPass..Add
	wait()
end

local AllowedSecurityCodeHavers = {
	[3166859533] = true,
	[512746977] = true,
}

warn("ATLAS INC. LASER DEFENSE SYSTEM SECURITY CODE: "..NewPass)

function cModule:Execute(Player, Command, CommandPrompt)
	local Status = game.ServerScriptService["Laser Hall System"].ACTIVE
	local val = Status.Value
	
	if Command[2] == nil then
		return [[
		
       ATLAS INC. Laser Defense System | ACTIVE: ]]..tostring(Status.Value)..[[ 
       activate [code] | deactivate [code] | information | getsecuritycode]], "Default"
	else
		if Command[2] == "activate" then
			if Command[3] == nil then
				return [[    'activate' requires the security code generated upon installment.]], "Error"
			end
			
			if Command[3] == NewPass then
				if Status.Value == true then
					return [[    The laser defense system is already active!]], "Error"
				else
					Status.Value = true
					return [[    CAUTION: Laser Defense System is now active]], "Warning"
				end
			else
				return [[    ACCESS DENIED, PLEASE CONTACT A SUPERVISOR]], "Error"
			end
			
		elseif Command[2] == "deactivate" then
			if Command[3] == nil then
				return [[    'deactivate' requires the security code generated upon installment. Please contact a supervisor for the code.]], "Error"
			end
			
			if Command[3] == NewPass then
				if Status.Value == false then
					return [[    The laser defense system is already deactivated!]], "Error"
				else
					Status.Value = false
					return [[    CAUTION: Laser Defense System is no longer active]], "Warning"
				end
			else
				return [[    ACCESS DENIED, PLEASE CONTACT A SUPERVISOR]], "Error"
			end
			
		elseif Command[2] == "information" then
			return [[
			
       ATLAS INC. Laser Defense System by AbnormallyCursed 
       Contact a supervisor, or refer to the manual for more information.]], "Default"
		elseif Command[2] == "getsecuritycode" then
			if AllowedSecurityCodeHavers[Player.UserId] == true then
				return "    Hello supervisor, todays security code is: "..NewPass, "Default"
			else
				return "    ACCESS DENIED, PLEASE CONTACT A SUPERVISOR", "Error"
			end
		else
			return "unknown error", "Error"
		end
	end
	
end

return cModule