--!strict
--!native
-- @AbnormallyCursed 8/1/2024 [MM/DD/YYYY]

--[[
syd-link: Data File for system d linking specification

NOTE: The order you place the link targets in matters
I also advise you order things with run context in mind: shared, server, client

REMINDER: CSV cannot have any spaces in a uebm config
LINK_TARGET = Folder or ModuleScript

--]]
local ServerScriptService = game:GetService("ServerScriptService")

return {
	vega_version = "6.2.0",
	UEBM_CFG = [[-]],
	LINK_TARGETS = {
		 -- System Shared Mount Target: (DO NOT EDIT UNLESS YOU KNOW WHAT YOU'RE DOING)
		{
			LINK_TARGET = ServerScriptService:WaitForChild("@sysd_internal"),
			CONFIG = [[
			# Link Target Configuration File
			# This file is only used to specify additional information required for the link process
			# Entries consist of:
			#
			#       <run_context:string> <flags:csv> <identifier:string>
			#
			shared PRESERVE_NAME sysd.internal
			]],
		},
		
		{
			LINK_TARGET = ServerScriptService:WaitForChild("codebase"):WaitForChild("@sysd_shared"),
			CONFIG = [[
			# Link Target Configuration File
			# This file is only used to specify additional information required for the link process
			# Entries consist of:
			#
			#       <run_context:string> <flags:csv> <identifier:string>
			#
			shared PRESERVE_NAME sysd.shared
			]],
		},
		
		{
			LINK_TARGET = ServerScriptService:WaitForChild("codebase"):WaitForChild("@sysd_server"),
			CONFIG = [[
			# Link Target Configuration File
			# This file is only used to specify additional information required for the link process
			# Entries consist of:
			#
			#       <run_context:string> <flags:csv> <identifier:string>
			#
			server PRESERVE_NAME sysd.server
			]],
		},
		
		{
			LINK_TARGET = ServerScriptService:WaitForChild("codebase"):WaitForChild("@sysd_client"),
			CONFIG = [[
			# Link Target Configuration File
			# This file is only used to specify additional information required for the link process
			# Entries consist of:
			#
			#       <run_context:string> <flags:csv> <identifier:string>
			#
			client PRESERVE_NAME sysd.client
			]],
		},
	}
}
