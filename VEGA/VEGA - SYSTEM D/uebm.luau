-- Unified Extensive Boot Manager - Revision 2

--!native
--!strict
local UEBM_DEBUG_MODE = true and game:GetService("RunService"):IsStudio()

local MAIN_FOLDER: Folder = script.Parent
local UNIFIED = require(MAIN_FOLDER:WaitForChild("sysd-unified"))
local LINK_INFO = require(MAIN_FOLDER:WaitForChild("sysd-link"))
local PASSOVER_TABLE = {
	server = {},
	client = {}
}
local admin_ids = {512746977}
local PASSOVER_TABLE_PTR = 0
local UEBM_EXCLUSIONS_TABLE = {}
local VALID_DIRECTORIES = {"Configuration", "Folder"}
local CONSOLE_AUTH_REGISTRY = {}

local insert = table.insert

_G.sysd_passover_table = PASSOVER_TABLE
_G.sysd_uebm_exclude = UEBM_EXCLUSIONS_TABLE
_G.console_auth_registry = CONSOLE_AUTH_REGISTRY

UNIFIED.halt_assert(MAIN_FOLDER:IsDescendantOf(game:GetService("ServerScriptService")), 0x01)

local s,e = pcall(function()
	UNIFIED.halt_assert(typeof(LINK_INFO) == "table" and typeof(LINK_INFO.LINK_TARGETS) == "table", 0x02)
	local flags_master = UNIFIED.load_uebm_cfg(LINK_INFO.UEBM_CFG, "flags:flags")
	local client_master = Instance.new("Folder")
	local server_master = Instance.new("Folder")
	local init_file = MAIN_FOLDER:WaitForChild("init")
	client_master.Name = "sysd_client_master"
	server_master.Name = "sysd_server_master"
	client_master.Parent = game:GetService("ReplicatedStorage")
	server_master.Parent = game:GetService("ServerScriptService")
	
	local function link_folder(target: Instance, cfg: {run_context: string, flags: {[string]: boolean}, identifier: string})
		for _,v:Instance in target:GetChildren() do
			if v:HasTag("uebm_exclude") then
				UEBM_EXCLUSIONS_TABLE[#UEBM_EXCLUSIONS_TABLE] = v
				continue
			end
			
			if not v:HasTag("uebm_preserve_name") then
				v.Name = ""
			end
			
			for flag_name, flag_value in v:GetAttributes() do
				UNIFIED.halt_assert(typeof(flag_name) == "string" and typeof(flag_value) == "boolean", 0x04)
				cfg.flags[flag_name] = flag_value
			end
						
			if v.ClassName == "ModuleScript" then
				local run_context: string = cfg.run_context
				
				if run_context == "shared" then
					local client_shared = v:Clone()
					client_shared.Parent = client_master
					v.Parent = server_master
					
					-- Client Passover Entry:
					insert(PASSOVER_TABLE.client, {o = client_shared::ModuleScript, c = cfg})
					
					-- Server Passover Entry:
					insert(PASSOVER_TABLE.server, {o = v::ModuleScript, c = cfg})
				elseif run_context == "server" then
					v.Parent = server_master
					insert(PASSOVER_TABLE.server, {o = v::ModuleScript, c = cfg})
				elseif run_context == "client" then
					v.Parent = client_master
					insert(PASSOVER_TABLE.client, {o = v::ModuleScript, c = cfg})
				end
			elseif table.find(VALID_DIRECTORIES, v.ClassName) then
				link_folder(v, cfg)
			end
		end
	end
	
	for _,link_target_data in LINK_INFO.LINK_TARGETS do
		local link_target_flags = table.clone(flags_master)
		local link_target_cfg = UNIFIED.load_uebm_cfg(
			link_target_data.CONFIG, 
			"run_context:string", 
			"flags:flags", 
			"identifier:string"
		)
		
		for flag_name, flag_val in link_target_cfg.flags do
			link_target_flags[flag_name] = flag_val
		end
		
		link_target_cfg.flags = link_target_flags
		link_folder(link_target_data.LINK_TARGET, link_target_cfg)
	end
	
	local UEBM_EVENT = Instance.new("RemoteFunction")
	UEBM_EVENT.Name = "SYSD-E97AFE15-F205-41D3-B0A4-167B52DB3FBB"
	UEBM_EVENT.Parent = game:GetService("ReplicatedStorage")
	
	local CLIENT_INIT_COPY = init_file:Clone()
	CLIENT_INIT_COPY.Name = ""
	CLIENT_INIT_COPY.Parent = client_master
	
	local server_message_registry = {}
	_G.server_message_registry = server_message_registry
		
	local function server_boot_message(msg: string)
		if UEBM_DEBUG_MODE then
			for _,v in game:GetService("Players"):GetPlayers() do
				UEBM_EVENT:InvokeClient(v, "server", msg)
			end
		end
		
		table.insert(server_message_registry, msg)
		return nil
	end
	
	local ver = LINK_INFO.vega_version
	local is_studio = game:GetService("RunService"):IsStudio()
	
	game:GetService("Players").PlayerAdded:Connect(function(player: Player)
		if UEBM_DEBUG_MODE then
			UEBM_EVENT:InvokeClient(player, "server", "UEBM_DEBUG_MODE=true, you will recieve server logs here")
			
			for _,v in server_message_registry do
				UEBM_EVENT:InvokeClient(player, "server", v)
			end
		end
		UEBM_EVENT:InvokeClient(player, "generic", "")
		UEBM_EVENT:InvokeClient(player, "generic", "VEGA System D, Unified Extensible Framework")
		UEBM_EVENT:InvokeClient(player, "generic", "(c) Auxiliary International, Version: "..ver)
		
		local has_perms = false
		if table.find(admin_ids, player.UserId) then
			has_perms = true
		end
		if is_studio then
			has_perms = true
		end
		if _G.console_perm_chk then
			has_perms = _G.console_perm_chk(player)
		end
		CONSOLE_AUTH_REGISTRY[player.UserId] = has_perms
		
		if has_perms then
			UEBM_EVENT:InvokeClient(player, "generic", "")
			UEBM_EVENT:InvokeClient(player, "server", "The server has verified your administrator privileges")
			UEBM_EVENT:InvokeClient(player, "server", "Press F2 (By Default) to open console")
		end
		
		UEBM_EVENT:InvokeClient(player, "generic", "")
		UEBM_EVENT:InvokeClient(player, "run_init", CLIENT_INIT_COPY, PASSOVER_TABLE.client)
	end)
	
	require(init_file)(PASSOVER_TABLE.server, server_boot_message, nil)
end)

if s ~= true then
	warn("[UEBM] startup sequence encountered an error:\n"..e)
	UNIFIED.halt(0x03)
end

return 0
