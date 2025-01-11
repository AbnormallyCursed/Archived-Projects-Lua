--!strict
--!native
local vega_loader = script;
script = nil;

do
	local wrap = coroutine.wrap;
	local REQUIRE = require;
	local game = game;
	local vega_gui: any;
	
	wrap(function()
		local StarterGui: StarterGui = game:GetService("StarterGui"):: StarterGui;
		local Player: Player = game:GetService("Players").LocalPlayer::Player;
		local ReplicatedFirst: ReplicatedFirst = game:GetService("ReplicatedFirst"):: ReplicatedFirst;
		vega_gui = vega_loader:WaitForChild("vega_gui"):: ScreenGui;
		vega_gui.Parent = Player:WaitForChild("PlayerGui");
		ReplicatedFirst:RemoveDefaultLoadingScreen();
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false);
	end)()
	wrap(function()
		local uebm_twc_console: RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("SYSD-E97AFE15-F205-41D3-B0A4-167B52DB3FBB");
		local clock = os.clock;
		local t = clock();

		local get_header = function()
			return tostring(clock()-t);
		end;
		
		local main_message = function(msg: string)
			local new_object = vega_gui.Storage.Main:Clone();
			new_object.Parent = vega_gui.MainContainer;
			new_object.Text = msg;
			new_object.Visible = true;
			return new_object;
		end;
		
		main_message(`[{get_header()}] VEGA Client Loading Process Started - waiting for a response from the server...`);
		
		uebm_twc_console.OnClientInvoke = function(header, arg1, arg2)
			if header == "run_init" then
				local s,e = pcall(function()
					REQUIRE(arg1)(arg2, main_message, vega_gui);
				end);
				
				if not s then
					main_message(`[<font color="rgb(255,0,0)">FAILED</font>] Failed to start client-init`);
				end;
			elseif header == "generic" then
				main_message(arg1);
			elseif header == "server" then
				main_message("[SERVER] "..arg1);
			end;
			return 0;
		end;
	end)();
end
