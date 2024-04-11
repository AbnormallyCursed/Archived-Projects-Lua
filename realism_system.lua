-- AbnormallyCursed, 10/10/2023
-- System for replicating the functionality of the "Project Zomboid" Moodle and General Health System

local Module = {}
local wait = task.wait
local clamp = math.clamp
local abs = math.abs
local floor = math.floor
local random = math.random

-- TODO: Windchill
-- TODO: A lot of the more advanced temperature stuff, one thing is specified for hunger "Body heat generation decreased"
--       Addendum: Body Heat generation is a major thing with over 19 entries, implementation recommended!
-- TODO: For sickness, there are factors that cause effects to vary. For example, if the sickness is from poisoning damage occurs, else no.

--[[

NOTE:
a LOT of implementations of stuff are NOT defined in pzwiki, you will have to study how the game treats x and y for these cases
as well as come up with your own idea of what the effect/s should be for a given circumstance

--]]

function Module:StartRealismEngine()
	local RealismEngine = {
		PlayerData = {},
		Settings = {
			SecondLength = 0.1,
			DoDaylightCycle = true,
		},
	}
	
	local Lighting = self.Services.Lighting
	local Players = self.Services.Players
	local HttpService = self.Services.HttpService
	local DisabledMoodles = {}
	
	self.RealismEngine = RealismEngine
	self.DisabledMoodles = DisabledMoodles
	
	-- // World Stuff
	local EngineEpoch = 0
	local SecondLength = RealismEngine.Settings.SecondLength
	
	-- // Player Stuff
	local function NewBodyPart()
		local BodyPart = {
			Bleeding = false,
			Burn = false,
			DeepWound = false,
			Fracture = false,
			LodgedBullet = false,
			LodgedGlassShard = false,
			Scratched = false,
			Lacerated = false,
			Infection = false,
			Destroyed = false,
			Health = 100, -- For destruction, also other effects if applicable
			BleedingSeverity = 0,
		}
		
		return BodyPart
	end
	
	Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAdded:Connect(function(Character)
			RealismEngine.PlayerData[Player.UserId] = {
				WalkSpeedBase = 16,
				RunSpeedBase = 18,
				SprintSpeedBase = 26,
				RealWalkSpeed = 0,
				RealRunSpeed = 0,
				RealSprintSpeed = 0,
				Health = {
					BodyParts = {
						Head = NewBodyPart(),
						Neck = NewBodyPart(),
						UpperTorso = NewBodyPart(),
						LowerTorso = NewBodyPart(),
						-----------------------------
						RightUpperArm = NewBodyPart(),
						LeftUpperArm = NewBodyPart(),
						RightForearm = NewBodyPart(),
						LeftForearm = NewBodyPart(),
						---------------------------
						RightThigh = NewBodyPart(),
						LeftThigh = NewBodyPart(),
						RightShin = NewBodyPart(),
						LeftShin = NewBodyPart(),
						RightFoot = NewBodyPart(),
						LeftFoot = NewBodyPart(),
					},
				},
				States = {
					Health = 100,
					Endurance = 0,
					CoreBodyTemp = 37, -- CELSIUS
					Boredom = 0,
					ColdStrength = 0,
					Sickness = 0,
					CarryWeight = 0,
					BodyWetness = 0,
					Windchill = 0,
					Hunger = 0,
					Thirst = 0,
					Stress = 0,
					Fatigue = 0,
					Unhappiness = 0,
					-- Non Moodle Stuff
					MeleeDamage = 0,
					AttackSpeed = 0,
					TripChance = 0,
					ClimbChance = 0,
					WalkSpeed = 100,
					RunSpeed = 100,
					SprintSpeed = 100,
					TimedActionModifier = 0,
					MaximumCarryWeight = 8,	
					-- (not sure about this one) PowerWalkEnabled = true,
					FallDamageMultiplier = 0,
					CriticalChance = 0,
					PainFactor = 0,
				},
				MinMax = { -- If any state is unfilled, it will be assumed minimum is 0 and maximum is 100
					CoreBodyTemp = {-100,100},
				},
				Moods = {
					Bleeding = "N/A",
					Bored = "N/A",
					Cold = "N/A",
					Endurance = "N/A",
					HeavyLoad = "N/A",
					Hyperthermia = "N/A",
					Hypothermia = "N/A",
					Wet = "N/A",
					Windchill = "N/A",
					Hungry = "N/A",
					Injured = "N/A",
					Pain = "N/A",
					Panic = "N/A",
					Sick = "N/A",
					Stress = "N/A",
					Thirst = "N/A",
					Tired = "N/A",
					Unhappy = "N/A",
				},
				SprintEnabled = true,
				RunEnabled = true,
				VeryHeavyItemsUsable = true,
				SleepEnabled = true,
			}
			
			local PlayerData = RealismEngine.PlayerData[Player.UserId]
			local Moodles = {}
			PlayerData.MoodlePrototypes = Moodles
			
			-- QOL Functions!:
			local function rwMood(Name, Value)
				if Value then
					PlayerData.Moods[Name] = Value
				else
					return PlayerData.Moods[Name]
				end
			end
			
			local function ReadStateModified(str: string)
				local Modifier = 0
				
				for _,v in Moodles do
					for Name, Effect in v.PassiveEffects do
						if Name == str then
							Modifier += Effect
						end
					end
				end
				
				return PlayerData.States[str]+Modifier
			end
			local function NewMoodle(Category: string, Callback, Callback2) -- Moodle Creator Function
				if table.find(DisabledMoodles, Category) then
					return
				end
				local Controller = {
					ActiveEffects = {},
					PassiveEffects = {},
					SprintEnabled = true,
					RunEnabled = true,
					VeryHeavyItemsUsable = true,
					SleepEnabled = true,
				}
				
				function Controller:set(str: string)
					PlayerData.Moods[Category] = str
				end
				
				if type(Callback2) == "function" then
					function Controller:Update()
						table.clear(Controller.ActiveEffects)
						table.clear(Controller.PassiveEffects)
						Controller.SprintEnabled = true
						Controller.RunEnabled = true
						Controller.VeryHeavyItemsUsable = true
						Callback(Controller, Callback2())
					end
				else
					function Controller:Update()
						table.clear(Controller.ActiveEffects)
						table.clear(Controller.PassiveEffects)
						Controller.SprintEnabled = true
						Controller.RunEnabled = true
						Controller.VeryHeavyItemsUsable = true
						Callback(Controller, ReadStateModified(Callback2))
					end
				end
				
				Moodles[Category] = Controller
			end
			local function ConstrainedStateIncrement(Name, Value)
				local MinMax = PlayerData.MinMax[Name]
				local Min, Max = 0, 100
				
				if MinMax then
					Min, Max = unpack(MinMax)
				end
				
				PlayerData.States[Name] = clamp(PlayerData.States[Name]+Value, Min, Max)
			end
			
			function PlayerData:ConstrainedStateIncrement(Name, Value)
				return ConstrainedStateIncrement(Name, Value)
			end
			function PlayerData:NewMoodle(Category: string, Callback, Callback2)
				return NewMoodle(Category, Callback, Callback2)
			end
			function PlayerData:ReadStateModified(str)
				return ReadStateModified(str)
			end
			
			-- Moodle Stuff:
			NewMoodle("Bleeding", function(Controller, Amount)
				if Amount > 10 and Amount < 50 then
					Controller:set("Minor Bleeding")
					if ReadStateModified("Hunger") > 0 then
						Controller.ActiveEffects.Health = -0.004
					end
				elseif Amount >= 50 and Amount < 75 then
					Controller:set("Bleeding")
					Controller.ActiveEffects.Health = -0.01
				elseif Amount >= 75 and Amount < 100 then
					Controller:set("Severe Bleeding")
					Controller.ActiveEffects.Health = -0.04
				elseif Amount >= 100 then
					Controller:set("Massive Blood Loss")
					Controller.ActiveEffects.Health = -0.08
				end
			end, function()
				local BleedingTally = 0
				for _,v in PlayerData.Health.BodyParts do
					if v.Bleeding then
						BleedingTally += v.BleedingSeverity
					end
				end
				return BleedingTally
			end)
			
			NewMoodle("Bored", function(Controller, Amount)
				if Amount >= 25 and Amount < 50 then
					Controller:set("Getting Bored")
				elseif Amount >= 50 and Amount < 75 then
					Controller:set("Bored")
					Controller.ActiveEffects.Unhappiness = 0.004
				elseif Amount >= 75 and Amount < 90 then
					Controller:set("Very Bored")
					Controller.ActiveEffects.Unhappiness = 0.01
				elseif Amount >= 90 then
					Controller:set("Extremely Bored")
					Controller.ActiveEffects.Unhappiness = 0.08
				end
			end, "Boredom")
			
			NewMoodle("Cold", function(Controller, Amount)
				if Amount >= 20 then
					Controller:set("Runny Nose")
				elseif Amount >= 40 then
					Controller:set("The Sniffles")
				elseif Amount >= 60 then
					Controller:set("You Have A Cold")
				elseif Amount >= 80 then
					Controller:set("You Have A Nasty Cold")
				end
			end, "ColdStrength")
			
			NewMoodle("Endurance", function(Controller, EnduranceValue)
				if EnduranceValue >= 25 and EnduranceValue < 50 then
					Controller:set("Moderate Exertion")
					Controller.PassiveEffects.MeleeDamage = -50
					Controller.PassiveEffects.AttackSpeed = -7
					Controller.PassiveEffects.WalkSpeed = -19
					Controller.PassiveEffects.RunSpeed = -19
					Controller.PassiveEffects.SprintSpeed = -19
					Controller.PassiveEffects.ClimbChance = -5
					Controller.PassiveEffects.TripChance = 10
				elseif EnduranceValue >= 50 and EnduranceValue < 75 then
					Controller:set("High Exertion")
					Controller.PassiveEffects.MeleeDamage = -80
					Controller.PassiveEffects.AttackSpeed = -14
					Controller.PassiveEffects.TripChance = 20
					Controller.PassiveEffects.WalkSpeed = -37
					Controller.PassiveEffects.RunSpeed = -37
					Controller.PassiveEffects.SprintSpeed = -37
					Controller.PassiveEffects.ClimbChance = -10
				elseif EnduranceValue >= 75 and EnduranceValue < 90 then
					Controller:set("Excessive Exertion")
					Controller.PassiveEffects.MeleeDamage = -80
					Controller.PassiveEffects.AttackSpeed = -21
					Controller.PassiveEffects.TripChance = 30
					Controller.PassiveEffects.WalkSpeed = -56
					Controller.PassiveEffects.RunSpeed = -56
					Controller.PassiveEffects.SprintSpeed = -56
					Controller.PassiveEffects.ClimbChance = -15
				elseif EnduranceValue >= 90 then
					print("huh?")
					Controller:set("Exhausted")
					Controller.PassiveEffects.MeleeDamage = -95
					Controller.PassiveEffects.AttackSpeed = -28
					Controller.PassiveEffects.TripChance = 40
					Controller.PassiveEffects.WalkSpeed = -75
					Controller.PassiveEffects.RunSpeed = -75
					Controller.PassiveEffects.SprintSpeed = -75
					Controller.PassiveEffects.ClimbChance = -20
				end
			end, "Endurance")
			
			NewMoodle("Heavy Load", function(Controller, CarryWeightValue)
				local MaximumCarryWeight = ReadStateModified("MaximumCarryWeight")
				
				if CarryWeightValue > MaximumCarryWeight and CarryWeightValue <= MaximumCarryWeight+25 then
					Controller:set("Fairly Heavy Load")
					Controller.PassiveEffects.TripChance = 13
					Controller.PassiveEffects.CriticalChance = -5
					Controller.PassiveEffects.AttackSpeed = -7
					Controller.PassiveEffects.ClimbChance = -8
					Controller.PassiveEffects.WalkSpeed = -19
					Controller.PassiveEffects.RunSpeed = -19
					Controller.PassiveEffects.SprintSpeed = -19
				elseif CarryWeightValue > MaximumCarryWeight+25 and CarryWeightValue <= MaximumCarryWeight+50 then
					Controller:set("Heavy Load")
					Controller.PassiveEffects.TripChance = 26
					Controller.PassiveEffects.CriticalChance = -10
					Controller.PassiveEffects.AttackSpeed = -14
					Controller.PassiveEffects.ClimbChance = -16
					Controller.PassiveEffects.WalkSpeed = -37
					Controller.PassiveEffects.RunSpeed = -37
					Controller.PassiveEffects.SprintSpeed = -37
				elseif CarryWeightValue > MaximumCarryWeight+50 and CarryWeightValue <= MaximumCarryWeight+75 then
					Controller:set("Very Heavy Load")
					Controller.PassiveEffects.TripChance = 39
					Controller.PassiveEffects.CriticalChance = -15
					Controller.PassiveEffects.AttackSpeed = -21
					Controller.PassiveEffects.ClimbChance = -24
					Controller.PassiveEffects.WalkSpeed = -56
					Controller.PassiveEffects.RunSpeed = -56
					Controller.PassiveEffects.SprintSpeed = -56
				elseif CarryWeightValue > MaximumCarryWeight+75 then
					Controller:set("Extremely Heavy Load")
					Controller.PassiveEffects.TripChance = 52
					Controller.PassiveEffects.CriticalChance = -20
					Controller.PassiveEffects.AttackSpeed = -28
					Controller.PassiveEffects.ClimbChance = -32
					Controller.PassiveEffects.WalkSpeed = -75
					Controller.PassiveEffects.RunSpeed = -75
					Controller.PassiveEffects.SprintSpeed = -75
				end
			end, "CarryWeight")
			
			NewMoodle("Hyperthermia", function(Controller, CoreBodyTempValue)
				if CoreBodyTempValue > 37.5 and CoreBodyTempValue <= 39 then
					Controller:set("Unpleasantly Hot")
					Controller.ActiveEffects.Thirst = 0.02
				elseif CoreBodyTempValue > 39 and CoreBodyTempValue <= 40 then
					Controller:set("Overheated")
					Controller.ActiveEffects.Thirst = 0.04
					Controller.ActiveEffects.Fatigue = 0.03
					Controller.PassiveEffects.AttackSpeed = -34
					Controller.PassiveEffects.SprintSpeed = -14
					Controller.PassiveEffects.RunSpeed = -14
					Controller.PassiveEffects.WalkSpeed = -14
				elseif CoreBodyTempValue > 40 and CoreBodyTempValue <= 41 then
					Controller:set("Sunstruck")
					Controller.ActiveEffects.Thirst = 0.06
					Controller.ActiveEffects.Fatigue = 0.05
					Controller.PassiveEffects.AttackSpeed = -67
					Controller.PassiveEffects.SprintSpeed = -27
					Controller.PassiveEffects.RunSpeed = -27
					Controller.PassiveEffects.WalkSpeed = -27
				elseif CoreBodyTempValue > 41 then
					Controller:set("Hyperthermic")
					Controller.ActiveEffects.Thirst = 0.06
					Controller.ActiveEffects.Fatigue = 0.05
					Controller.PassiveEffects.AttackSpeed = -90
					Controller.PassiveEffects.SprintSpeed = -75
					Controller.PassiveEffects.RunSpeed = -75
					Controller.PassiveEffects.WalkSpeed = -75
				end
			end, "CoreBodyTemp")
			
			NewMoodle("Hypothermia", function(Controller, CoreBodyTempValue)
				if CoreBodyTempValue < 36.5 and CoreBodyTempValue >= 35 then
					Controller:set("Chilly")					
				elseif CoreBodyTempValue < 35 and CoreBodyTempValue >= 30 then
					Controller:set("Cold")
					Controller.PassiveEffects.AttackSpeed = -34
					Controller.PassiveEffects.SprintSpeed = -27
					Controller.PassiveEffects.RunSpeed = -27
					Controller.PassiveEffects.WalkSpeed = -75
				elseif CoreBodyTempValue < 30 and CoreBodyTempValue >= 25 then
					Controller:set("Freezing")
					Controller.PassiveEffects.AttackSpeed = -67
					Controller.PassiveEffects.SprintSpeed = -54
					Controller.PassiveEffects.RunSpeed = -54
					Controller.PassiveEffects.WalkSpeed = -54
				elseif CoreBodyTempValue < 25 then
					Controller:set("Hypothermic")
					Controller.PassiveEffects.AttackSpeed = -90
					Controller.PassiveEffects.SprintSpeed = -75
					Controller.PassiveEffects.RunSpeed = -75
					Controller.PassiveEffects.WalkSpeed = -75
				end
			end, "CoreBodyTemp")
			
			NewMoodle("Wet", function(Controller, WetnessValue)
				if WetnessValue >= 15 and WetnessValue < 40 then
					Controller:set("Damp")
				elseif WetnessValue >= 40 and WetnessValue < 70 then
					Controller:set("Wet")
				elseif WetnessValue >= 70 and WetnessValue < 90 then
					Controller:set("Soaking")
				elseif WetnessValue >= 90 then
					Controller:set("Drenched")
				end
			end, "BodyWetness")
			
			-- Define Wetness Here
			
			NewMoodle("Hungry", function(Controller, HungerValue)
				if HungerValue > 15 and HungerValue < 25 then
					Controller:set("Peckish")
				elseif HungerValue >= 25 and HungerValue <= 45 then
					Controller:set("Hungry")
					Controller.PassiveEffects.MaximumCarryWeight = -1
				elseif HungerValue > 45 and HungerValue <= 70 then
					Controller:set("Very Hungry")
					Controller.PassiveEffects.MaximumCarryWeight = -2
				elseif HungerValue > 70 then
					Controller:set("Starving")
					Controller.PassiveEffects.MaximumCarryWeight = -1
					Controller.ActiveEffects.Health = -0.05
				elseif HungerValue <= 0 and HungerValue > -15 then 
					Controller.PassiveEffects.MaximumCarryWeight = 2
					Controller:set("Satiated")
				elseif HungerValue <= -15 and HungerValue > -40 then
					Controller.PassiveEffects.MaximumCarryWeight = 2
					Controller:set("Well Fed")
				elseif HungerValue <= -40 and HungerValue > -70 then
					Controller.PassiveEffects.MaximumCarryWeight = 2
					Controller:set("Stuffed")
				elseif HungerValue <= -70 then
					Controller.PassiveEffects.MaximumCarryWeight = 2
					Controller:set("Full to Bursting")
				end
			end, "Hunger")
			
			NewMoodle("Injured", function(Controller, HealthValue)
				if HealthValue < 80 and HealthValue >= 60 then
					Controller:set("Discomfort")
				elseif HealthValue < 60 and HealthValue >= 40 then
					Controller:set("Injured")
					Controller.PassiveEffects.MaximumCarryWeight = -1
				elseif HealthValue < 40 and HealthValue >= 25 then
					Controller:set("Severe Injuries")
					Controller.PassiveEffects.MaximumCarryWeight = -2
				elseif HealthValue < 25 then
					Controller:set("Critical Injuries")
					Controller.PassiveEffects.MaximumCarryWeight = -3
				end
			end, "Health")
			
			NewMoodle("Pain", function(Controller, Amount)
				if Amount >= 25 and Amount < 50 then
					Controller:set("Minor Pain")
					Controller.PassiveEffects.TripChance = 5
					Controller.PassiveEffects.ClimbChance = -5
				elseif Amount >= 50 and Amount < 75 then
					Controller:set("Pain")
					Controller.PassiveEffects.TripChance = 10
					Controller.PassiveEffects.ClimbChance = -10
					Controller.SleepEnabled = false
				elseif Amount >= 75 and Amount < 90 then
					Controller:set("Severe Pain")
					Controller.PassiveEffects.TripChance = 15
					Controller.PassiveEffects.ClimbChance = -15
					Controller.SleepEnabled = false
				elseif Amount >= 90 then
					Controller:set("Agony")
					Controller.PassiveEffects.TripChance = 20
					Controller.PassiveEffects.ClimbChance = -20
					Controller.SleepEnabled = false
				end
			end, "PainFactor")
			
			NewMoodle("Panic", function(Controller, Type)
				Controller:set(Type)

				if Type == "Slight Panic" then
					Controller.PassiveEffects.CriticalChance = -1.3
				elseif Type == "Panic" then
					Controller.PassiveEffects.CriticalChance = -2.6
					Controller.PassiveEffects.MeleeDamage = -5
				elseif Type == "Strong Panic" then
					Controller.PassiveEffects.CriticalChance = -3.9
					Controller.PassiveEffects.MeleeDamage = -15
				elseif Type == "Extreme Panic" then
					Controller.PassiveEffects.CriticalChance = -5.2
					Controller.PassiveEffects.MeleeDamage = -30
				end
			end, function() -- Again.
				
			end)
			
			NewMoodle("Sick", function(Controller, Amount)
				if Amount >= 25 and Amount < 50 then
					Controller:set("Queasy")
				elseif Amount >= 50 and Amount < 75 then
					Controller:set("Nauseous")
					Controller.PassiveEffects.MaximumCarryWeight = -1
				elseif Amount >= 75 and Amount < 90 then
					Controller:set("Sick")
					Controller.PassiveEffects.MaximumCarryWeight = -2
				elseif Amount >= 90 then
					Controller:set("Fever")
					Controller.PassiveEffects.MaximumCarryWeight = -3
				end
			end, "Sickness")
			
			NewMoodle("Stress", function(Controller, Amount)
				if Amount >= 25 and Amount < 50 then
					Controller:set("Anxious")
				elseif Amount >= 50 and Amount < 75 then
					Controller:set("Agitated")
					Controller.ActiveEffects.Unhappiness = 0.02
					Controller.PassiveEffects.MeleeDamage = -5
				elseif Amount >= 75 and Amount < 90 then
					Controller:set("Stressed")
					Controller.ActiveEffects.Unhappiness = 0.03
					Controller.PassiveEffects.MeleeDamage = -10
				elseif Amount >= 90 then
					Controller:set("Nervous Wreck")
					Controller.ActiveEffects.Unhappiness = 0.045
					Controller.PassiveEffects.MeleeDamage = -15
				end
			end, "Stress")
			
			NewMoodle("Thirst", function(Controller, Amount)
				if Amount > 13 and Amount < 25 then
					Controller:set("Slightly Thirsty")
				elseif Amount >= 25 and Amount <= 70 then
					Controller:set("Thirsty")
					Controller.PassiveEffects.MaximumCarryWeight = -1
				elseif Amount >= 70 and Amount <= 85 then
					Controller:set("Parched")
					Controller.PassiveEffects.MaximumCarryWeight = -2
				elseif Amount >= 85 then
					Controller:set("Dying of Thirst")
					Controller.PassiveEffects.MaximumCarryWeight = -2
					Controller.ActiveEffects.Health = -0.06 -- I would say dying of thirst is more deadly than dying of hunger initially
				end
			end, "Thirst")
			
			NewMoodle("Tired", function(Controller, Amount)
				if Amount >= 60 and Amount < 70 then
					Controller:set("Drowsy")
					Controller.PassiveEffects.MeleeDamage = -50
				elseif Amount >= 70 and Amount < 80 then
					Controller:set("Tired")
					Controller.PassiveEffects.MeleeDamage = -80
				elseif Amount >= 80 and Amount < 90 then
					Controller:set("Very Tired")
					Controller.PassiveEffects.MeleeDamage = -90
				elseif Amount >= 90 then
					Controller:set("Ridiculously Tired")
					Controller.PassiveEffects.MeleeDamage = -95
				end
			end, "Fatigue")
			
			NewMoodle("Unhappy", function(Controller, Amount)
				if Amount > 20 and Amount <= 45 then
					Controller:set("Feeling a little sad")
				elseif Amount > 45 and Amount <= 60 then
					Controller:set("Getting a tad weepy")
				elseif Amount > 60 and Amount <= 80 then
					Controller:set("Depressed")
				elseif Amount > 80 then
					Controller:set("Severely Depressed")
				end
			end, "Unhappiness")
			
			local function CalculatePrecentage(Percentage, Value)
				return (Percentage/100)*Value
			end
			
			-- Debug:
			--[[local Container = Player.PlayerGui:WaitForChild("debug_ui"):WaitForChild("container")
			local Container2 = Player.PlayerGui:WaitForChild("debug_ui"):WaitForChild("container2")
			local Template = game.ServerStorage.template
			for i,v in PlayerData.States do
				local t = Template:Clone()
				t.Name = i
				t.Text = i..": "..v
				t.Parent = Container
			end
			
			for i,v in PlayerData.Moods do
				local t = Template:Clone()
				t.Name = i
				t.Text = i..": "..tostring(v)
				t.Parent = Container2
			end]]
			
			-- Character Clock:
			local Humanoid = Character:WaitForChild("Humanoid")
			
			while wait(SecondLength) do
				
				if RealismEngine.Settings.DoDaylightCycle then
					Lighting.ClockTime += 0.0003
				end
				
				EngineEpoch += 1
				self.EngineEpoch = EngineEpoch
				
				for _,v in PlayerData.Moods do
					v = "N/A"
				end

				-- Handle Moodles & their effects if any are active:
				PlayerData.SprintEnabled = true
				PlayerData.RunEnabled = true
				PlayerData.VeryHeavyItemsUsable = true

				for _,v in Moodles do
					v:Update()
					for Name, Effect in v.ActiveEffects do
						ConstrainedStateIncrement(Name, Effect)
						if Name == "Health" then
							pcall(function()
								Humanoid:TakeDamage(math.abs(Effect))
							end)
						end
					end
					if v.SprintEnabled == false then
						PlayerData.SprintEnabled = false
					end
					if v.RunEnabled == false then
						PlayerData.RunEnabled = false
					end
					if v.VeryHeavyItemsUsable == false then
						PlayerData.VeryHeavyItemsUsable = false
					end
				end

				-- Progression:
				ConstrainedStateIncrement("Fatigue", 0.01)
				-- Even lower perhaps, every 5 (ingame) minutes your fatigue would increase by 3
				-- 5 ingame minutes is equal to 30 IRL seconds (300 Clock Cycles)

				ConstrainedStateIncrement("Hunger", 0.02)
				ConstrainedStateIncrement("Thirst", 0.04)
				pcall(function()
					
				end)
				--[[for i,v in PlayerData.States do
					Container[i].Text = i..": "..v
				end
				for i,v in PlayerData.Moods do
					Container2[i].Text = i..": "..tostring(v)
				end]]
				
			end
		end)
	end)
	
	function RealismEngine:GetPlayer(Player: number)
		return RealismEngine.PlayerData[Player]
	end
end

return Module
