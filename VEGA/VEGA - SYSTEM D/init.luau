--!strict
--!native

--[[
Init Flags and their meanings

link flags:
nrq: "no require", skips the module entirely
e: "exclude", does not link the module nor does it pre-process it, however the data is stored in a table in the root
nl: "no link", does not link module keys into the root, instead it will link IDENTIFIER = MODULE_DATA:
    where "IDENTIFIER" must be a key in the module named "sysd_identifier" otherwise the module is excluded
dr: "data return", tells the preprocessor to execute the located "main" function and then link the table result it returns 
mt: "multi thread", runs as a multithreaded function
t: "thread", creates a new thread to run the function in
fl: "fast link", links fast, invalidates all flags, even the exclusion flag, can be used in conjunction with the "fm" flag
	also invalidates all other link-process features like "main" functions, and ONLY accepts a table

mount flags:
mr: "mount recursive", tells the preprocessor to do a "deep mount" instead of the normal "shallow mount": THIS CAN BREAK THINGS
     also not compatible with flags: "nm"
nm: "no merge", tells the preprocessor to not merge when an identifier collision of type table is detected
	NOTE: you can also define this flag inside the table itself, and do not worry the preprocessor will automatically remove it
ac: "allow collision", only applicable on non-table type indexes, when true, when an index collision is found it overrides the key
fm: "fast mount", skips all checks, and therein invalidates all other flags, does what it says; mounts fast, might be unsafe
	worth noting that it also has no other features like merging, so when using you need to manually do all of that

--]]

return function(
	link_table:{[number]:{o:ModuleScript,c:{[string]:any}}},
	boot_message:(text:string)->unknown,
	vega_gui:any
)
	local task_wait: (number?) -> number = task.wait
	local coroutine_wrap: <A..., R...>((A...) -> (R...)) -> (A...) -> (R...) = coroutine.wrap
	local coroutine_create: <A..., R...>((A...) -> (R...)) -> thread = coroutine.create
	local coroutine_resume: <A..., R...>(thread, A...) -> (boolean, R...) = coroutine.resume
	local coroutine_close: (thread) -> (boolean, any) = coroutine.close
	local wrap: <A..., R...>((A...) -> (R...)) -> (A...) -> (R...) = coroutine.wrap
	local read_module: (any) -> any = require;
	local clock: () -> number = os.clock;
	local start_time: number = clock();
	local table_link: (data_result: any, flags: {[string]:any}) -> nil;
	local table_mount: (link_table: {[string]: any}, flags: {[string]:any}) -> nil;
	
	local exclusions: {[number]: any} = {};
	local exclusion_ptr: number = 0;
	local root_table: { [string]: any } = {sysd_exclusions = exclusions, sysd_vega_gui = vega_gui, INIT_STATUS = "ONGOING", init_encountered_error = false};
	local calls_identifier_lst: { [({[string]:any}) -> nil]: string } = {};
	local calls_multi_thread: {[number]: ({[string]:any}) -> nil} = {};
	local calls_single_thread: {[number]: ({[string]:any}) -> nil} = {};
	local c_multi_ptr: number = 0
	local c_single_ptr: number = 0
	
	table_mount = function(link_table: {[string]: any}, flags: {[string]:any})
		if flags.fm then
			for key, value in link_table do
				root_table[key] = value;
			end;
		else
			for key, value in link_table do
				local is_table = typeof(value) == "table";

				if is_table and flags.mr then
					table_mount(value, flags);
					continue;
				end;

				-- Index Collision
				if root_table[key] then
					if is_table and not (flags.nm or value.nm) then
						local category = root_table[key];

						for sub_key, sub_value in value do
							category[sub_key] = sub_value;
						end;

						continue;
					else
						if flags.ac then
							root_table[key] = value;
						else
							boot_message(`[<font color="rgb(255,200,0)"><b> WARN </b></font>] index overwrite collision found at key '{key}'`);
						end;

						continue;
					end;
				end;

				if is_table and value.nm then
					value.nm = nil;
				end;

				root_table[key] = value;
			end;
		end;
	end;
	
	table_link = function(data_result: any, flags: {[string]:any})
		local result_type: string = type(data_result);
		
		-- Flag Override
		if result_type == "table" then
			if data_result.flags then
				for flag_name, value in data_result.flags do
					flags[flag_name] = value;
				end;
			end;
			
			-- Fast Link
			if flags.fl then
				table_mount(data_result, flags);
				return;
			end;
		end;
		
		-- Exclude
		if flags.e or (result_type == "table" and flags.nl and data_result.sysd_identifier == nil) then
			warn("nl fail")
			print(data_result)
			exclusion_ptr += 1;
			exclusions[exclusion_ptr] = data_result;
			return;
		end;

		-- No Link
		if flags.nl and result_type == "table" then
			warn("nl success")
			root_table[data_result.sysd_identifier] = data_result;
			return;
		end;

		-- Function Setup
		local main_func;

		if result_type == "function" then
			main_func = data_result;
			
			-- Data Return
			if flags.dr then
				data_result = data_result(root_table);
				
				if typeof(data_result) == "table" then
					table_link(data_result, flags);
					return;
				end;
			end;
		end;

		if result_type == "table" and data_result.main then
			main_func = data_result.main;
			data_result.main = nil
		end;
		
		if flags.t then
			main_func = wrap(main_func);
		end;
		
		if flags.mt then
			calls_multi_thread[c_multi_ptr] = main_func;
			c_multi_ptr += 1
		else
			calls_single_thread[c_single_ptr] = main_func;
			c_single_ptr += 1
		end;
		
		if result_type == "table" then
			table_mount(data_result, flags);
			if main_func and typeof(data_result.startup_identifier) == "table" then
				calls_identifier_lst[main_func] = data_result.startup_identifier;
			end;
		end;
	end;
	
	local s,e = pcall(function()
		for _,v in ipairs(link_table) do
			local flags: {[string]:any} = v.c.flags;
			
			-- No Require
			if flags.nrq then
				continue;
			end;
			
			local data_result: any = read_module(v.o);
			table_link(data_result, flags);
		end;
		
		local CLOSURE_YIELD_THRESHOLD_SECONDS: number = 2;

		local detect_initializer_yielding = function(function_name: string): ()
			task_wait(CLOSURE_YIELD_THRESHOLD_SECONDS);
			boot_message(""..`[<font color="rgb(255,200,0)"><b> WARN </b></font>]`.." [Initializer yield detected]\n\t\tFunction name: " .. function_name .. "\n\t\t(>" .. tostring(CLOSURE_YIELD_THRESHOLD_SECONDS) .. " second yield threshold exceeded, consider running this function in a separate thread)");
		end;

		local call_initializer_function = function(closure: (...any) -> (...any), function_name: string | number): ()
			local yield_detection_thread: thread = coroutine_create(detect_initializer_yielding)
			coroutine_resume(yield_detection_thread, function_name)
			local run_state: boolean, call_return: string? = pcall(closure, root_table)
			coroutine_close(yield_detection_thread)

			if run_state then
				boot_message(`[<font color="rgb(0,255,0)"><b>  OK  </b></font>] Started {function_name}`);
			else
				root_table.init_encountered_error = true
				boot_message(`[<font color="rgb(255,0,0)"><b>FAILED</b></font>] Failed to start {function_name}\n\t\t {call_return :: string}`)
			end;
		end;

		local run_initializer_function = function(...)
			coroutine_wrap(call_initializer_function)(...);
		end;
		
		local sequential_init_table: {[number]: string} = root_table.initialize_order;
		print(sequential_init_table, root_table)
		
		if sequential_init_table == nil or root_table.sysd_init_container == nil then
			root_table.init_encountered_error = true
			boot_message(`[<font color="rgb(255,0,0)"><b>FAILED</b></font>] Failed to start init:\n\t\t NO INIT TABLE FOUND`);
		end;
		
		if root_table.vega_entry then
			run_initializer_function(root_table.vega_entry, "VEGA pre-init");
		end;
		
		local pre_init: {[string]: ({[string]: any}) -> nil} = root_table.ls_pre_init;
		
		if pre_init then
			for name, callback in pre_init do
				run_initializer_function(callback, name);
			end;
		end;
		
		for _,seq_init: string in sequential_init_table do
			if root_table.sysd_init_container[seq_init] == nil then
				root_table.init_encountered_error = true
				boot_message(`[<font color="rgb(255,0,0)"><b>FAILED</b></font>] Failed to start {seq_init}:\n\t\t FUNCTION NOT FOUND IN ROOT.sysd_init_container`);
				continue;
			end;
			
			run_initializer_function(root_table.sysd_init_container[seq_init], seq_init);
		end
		
		for _,v in calls_single_thread do
			local name: string = calls_identifier_lst[v] or "Unknown Single Threaded Call";
			v(root_table);
		end;
		
		if root_table.RunThread == nil then
			boot_message(`[<font color="rgb(255,200,0)"><b> WARN </b></font>] {#calls_multi_thread} multi-threaded initializers skipped due multi-threading not starting'`);
			return 0;
		end;
		
		for _,v in calls_multi_thread do
			local name: string = calls_identifier_lst[v] or "Unknown Multi Threaded Call";
			root_table:RunThread(v);
		end;
		
		return 0;
	end);
	
	if s == false then
		root_table.init_encountered_error = true
		boot_message(`[<font color="rgb(255,0,0)"><b>FAILED</b></font>] Failed to start init:\n\t\t {e}`);
		root_table.INIT_STATUS = "FAILED"
	else
		boot_message(`[<font color="rgb(0,255,0)"><b>  OK  </b></font>] vega startup process completed`);
		boot_message(`Initialization completed! Time Taken: {(clock()-start_time)*1000}ms`);
		root_table.INIT_STATUS = "COMPLETED"
	end;
end
