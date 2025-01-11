--!strict
--!native
-- real emac.
local halt
local halt_assert
local read_flags
local read_csv
local load_uebm_cfg
local load_cfg_table
local sysd_unified = {}

do 
	local wrap = coroutine.wrap
	halt = function(stop_code)
		wrap(function()
			sysd_unified = type(sysd_unified) == "table" and sysd_unified or {}
			sysd_unified.post_panic = sysd_unified.post_panic or wrap
			pcall(sysd_unified.post_panic, wrap)
			warn("[sysd/uebm] [FATAL] - The system is going down NOW!")

			if typeof(stop_code) ~= "number" then
				stop_code = 0
			end

			stop_code = math.floor(stop_code) % 256

			local hex_code: string = string.format("%X", stop_code)

			if string.len(hex_code) == 1 then
				hex_code = "0"..hex_code
			end

			local halt_txt: string = `[SYSD_SYSTEM_HALT] - STOP CODE: {hex_code}`

			for _,player: Player in game:GetService("Players"):GetChildren() do
				if player.ClassName == "Player" then
					player:Kick(halt_txt)
				end
			end

			error(halt_txt)
		end)()
	end
end

read_flags = function(flags: string)
	local csv = read_csv(flags:upper(), false)
	local result = {}

	for _,v in csv do
		result[v] = true
	end

	return result
end


read_csv = function(csv: string, preserve_whitespace: boolean)
	if not preserve_whitespace then
		csv = csv:gsub("%s+", "")
	end

	return csv:split(",")
end

load_uebm_cfg = function(cfg: string, ...)
	local args: {[number]: string} = {...}
	local result: {[string]: any} = {}
	cfg = cfg:gsub("#.-\n","")

	local match_sets = {}
	local set_ptr = 1
	local ctr = 0
	local max_ctr = #args

	for s: string in string.gmatch(cfg, "[%w%p]+") do
		ctr += 1
		match_sets[set_ptr] = match_sets[set_ptr] or {}

		match_sets[set_ptr][ctr] = s

		if ctr == max_ctr then
			set_ptr += 1
		end
	end

	for _,set in match_sets do		
		for i,v in args do
			local s = set[i] or ""
			local split_arg:{string} = v:split(":")
			local arg_name:string, arg_type:string = split_arg[1], split_arg[2]

			if arg_type == "boolean" then
				result[arg_name] = s:lower() == "true"
			elseif arg_type == "number" then
				result[arg_name] = tonumber(s)
			elseif arg_type == "string" then
				result[arg_name] = s
			elseif arg_type == "csv" then
				result[arg_name] = read_csv(s, true)
			elseif arg_type == "flags" then
				result[arg_name] = read_flags(s)
			end
		end
	end

	return result
end

load_cfg_table = function(cfg: string, arg_type, dontGsub)
	cfg = cfg:gsub("#.-\n","")
	cfg = dontGsub == true and cfg or cfg:gsub("%s+", "")
	local result: {[string]: any} = {}
	
	for a:string?,b:string? in string.gmatch(cfg,"(.+)=(.+)\n") do
		if not a or not b then continue end
		
		if arg_type == "boolean" then
			result[a] = b:lower() == "true"
		elseif arg_type == "number" then
			result[a] = tonumber(b)
		elseif arg_type == "string" then
			result[a] = b
		elseif arg_type == "csv" then
			result[a] = read_csv(b, true)
		elseif arg_type == "flags" then
			result[a] = read_flags(b)
		end
	end
	
	return result
end

halt_assert = function(cond, stop_code)
	if not cond then
		halt(stop_code)
	end
end

return {
	sysd_unified = sysd_unified,
	halt = halt,
	halt_assert = halt_assert,
	read_flags = read_flags,
	read_csv = read_csv,
	load_uebm_cfg = load_uebm_cfg
}
