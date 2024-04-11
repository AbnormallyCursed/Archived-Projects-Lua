--[[
	Writer: AbnormallyCursed
	Date: 9/10/2021
	
	Description:
	The Serverside aspect of the Game's Terminal system.
--]]

----------------------------------------------------------------------------------------------------------------------------------------|
-- V A R I A B L E S -------------------------------------------------------------------------------------------------------------------|
----------------------------------------------------------------------------------------------------------------------------------------|
-- #Default Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- #Nucleus (Standalone Class)
local Nucleus = require(ReplicatedStorage.Nucleus)

-- #API Overrides
local require = Nucleus._require

-- #Nucleus Modules
local IsAuthorized = require("IsAuthorized")

-- #Instances
local InvokeCommand = Nucleus:GetRemoteFunction("InvokeCommand")
local CommandList = script.Parent["Command List"]

----------------------------------------------------------------------------------------------------------------------------------------|
-- M A I N   S C R I P T ---------------------------------------------------------------------------------------------------------------|
----------------------------------------------------------------------------------------------------------------------------------------|

InvokeCommand.OnServerInvoke = function(Player, Command, CommandPrompt)
	local SplitCommand = Command:split(" ")
	local CommandFolder = CommandList:FindFirstChild(SplitCommand[1])
	
	if CommandFolder == nil then
		return {
			Message = "The command '"..SplitCommand[1].."' is not recognized as an internal or external command",
			Type = "Error",
		}
	end
	
	local Command = require(CommandFolder.Command)
	local Execute, Type = Command:Execute(Player, SplitCommand, CommandPrompt)
	
	if Execute ~= nil then
		return {
			Message = Execute,
			Type = Type,
		}
	end
	
end