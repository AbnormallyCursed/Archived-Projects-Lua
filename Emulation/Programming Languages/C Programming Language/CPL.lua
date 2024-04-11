-- C Programming Language v2 By AbnormallyCursed written in pure LuaU
-- TODO?: Support for Variadic Functions, thinking about not doing them at all
-- THIS FILE IS NOWHERE NEAR COMPLETE, BUT NOR IS IT GOING TO BE ADDED ONTO IN THE FUTURE.
-- TODAY IT STANDS AS PoC (Proof of Concept)

local Lexer = require(script.Lexer)
--local UASM = require(script.Parent["Unified Assembler"])

local find = table.find
local insert = table.insert

-- CPL:
local ErrorPointerFormat = [[
    %s | %s
      |%s]]
local function cerror(Text, Format)
	if Format == nil then
		warn(Text)
	else

		warn(string.format(Text, Format))
	end
end

local Module = {}
local GenericTypes = {"int", "float", "double", "char", "long", "short", "unsigned", "signed"}
local ValidTypes = {
	-- Integer Types
	"signed char",
	"unsigned char",
	"char",
	"short int",
	"unsigned short int",
	"int",
	"unsigned int",
	"long int",
	"unsigned long int",
	"long long int",
	"unsigned long long int",
	-- Real Num Types
	"float",
	"double",
	"long double",
	-- Void Types
	"void",
}
local OperatorTranslationTable = {
	-- Arithmetic
	["+"] = "add",
	["-"] = "sub",
	["/"] = "div",
	["%"] = "mod",
	["--"] = "decrement",
	["++"] = "increment",
	-- Logical
	["=="] = "isequal",
	["!="] = "notequal",
	[">"] = "greaterthan",
	["<"] = "lessthan",
	[">="] = "greaterthanorequalto",
	["<="] = "lessthanorequalto",
	["&&"] = "logicalAND",
	["||"] = "logicalOR",
	["!"] = "logicalNOT",
	-- Bitwise
	["&"] = "binaryAND",
	["|"] = "binaryOR",
	["^"] = "binaryXOR",
	["~"] = "binaryONESCOMPLEMENT",
	["<<"] = "binaryLSHIFT",
	[">>"] = "binaryRSHIFT",
}

function Module:GenerateSyntaxTree(Source: string)
	local Navigator = Lexer.navigator()
	local Source = Source
	local Type = nil
	local Name = nil
	local MasterSyntaxTree = {}
	local VariableList = {}
	local FunctionList = {}
	
	-- Here we have main initialization and cleaning as well as additions to the systems such as the navigator
	local ParseList = {}
	local Navigator = Navigator
	-- The following variables are recycles of CPL v1 and are essential to the iterate system
	local LineList = string.split(Source, "\n")
	local CurrentLine = 1
	local cppDefinitions = {}
	local OffsetTable = {}
	local cppKey = ""
	local cppMaxStep = 0
	local cppDefineStep = 0
	local cppDefinition = false
	local ParseNewFunction -- Setup here so it can be called by ParseFunction()
	local IF_BLOCK_POINTER = 0
	
	-- Setup Parse List:
	for LineNumber, Line in ipairs(LineList) do
		Navigator:SetSource(Line)
		for Position,Token in next, Navigator.TokenCache do
			if Token[1] == "comment" then
				table.remove(Navigator.TokenCache, Position)
			end
		end

		repeat Type, Name = Navigator.Next()
			if Name == nil then continue end
			table.insert(ParseList, {Type, Name})
		until Name == nil

		--table.insert(ParseList, {"break","linebreak"})
		-- We split this iterator function by every line break so at the end of 
		-- said iterator function we can assume there is a line break
	end

	-- Initialize Navigator and use ParseList:
	Navigator._RealIndex = 0
	Navigator._UserIndex = 0
	table.clear(Navigator.TokenCache)
	Navigator._ScanThread = coroutine.create(function()
		for _, TokenAndSource in ParseList do
			Navigator._RealIndex += 1
			Navigator.TokenCache[Navigator._RealIndex] = TokenAndSource
			coroutine.yield(table.unpack(TokenAndSource))
		end
	end)

	local function Iterate(DontGsub, IgnoreBreak)
		if not cppDefinition then
			Type, Name = Navigator.Next()
		else
			if cppDefineStep > cppMaxStep then
				cppDefinition = false
				Type, Name = Navigator.Next()
			else
				Type, Name = unpack(cppDefinitions[cppKey][cppDefineStep])
				cppDefineStep += 1
			end
		end
		if Name == nil then return nil end
		if Type == "identifier" and cppDefinitions[Name] then
			cppDefinition = true
			cppKey = Name
			cppMaxStep = #cppDefinitions[Name]
			Type, Name = unpack(cppDefinitions[Name][1])
			cppDefineStep = 2
		end
		if not DontGsub then
			Name = Name:gsub("%s+", "") 
		end
		if OffsetTable[Name] then
			OffsetTable[Name] = OffsetTable[Name] + 1
		else
			OffsetTable[Name] = 1
		end
		if Type == "break" then
			CurrentLine += 1
			local Last = Navigator.TokenCache[Navigator._RealIndex-1]
			if Last and Last[2] == [[\]] or IgnoreBreak then
				Iterate()
			end
		end
	end

	local function CompilerError(String, OccurenceOffset, ...)
		local DeclarationOffset = OffsetTable[String]
		local OccurenceCounter = 0
		local OccurenceStart,OccurenceEnd

		for _, Line in ipairs(LineList) do
			local function IterateInLine(Offset)
				local Start,End = string.find(Line, String, Offset) -- Offset ensures the NEXT occurence is found
				if Start == nil then return end -- There is no occurence in this line, skip
				local CurrentOccurence = string.sub(Line, Start, End)

				if CurrentOccurence == String then
					OccurenceCounter += 1
				end

				-- Peek to next iteration to see if another occurence can be found within the line
				if (Line:find(String, End) ~= nil and string.sub(Line, Line:find(String, End)) == String) 
					and OccurenceCounter ~= DeclarationOffset then
					Offset = End
					local iStart, iEnd = IterateInLine(End)
					if (iStart ~= nil and string.sub(Line,iStart,iEnd) == String) and OccurenceCounter == DeclarationOffset then
						return iStart, iEnd
					end
				end

				if OccurenceCounter == DeclarationOffset then
					return Start, End
				end
			end

			OccurenceStart, OccurenceEnd = IterateInLine(0)		
			if OccurenceStart ~= nil then
				break
			end
		end
		if OccurenceStart == nil then
			cerror("Failed to FindCurrentOccurenceOf '%s'", String)
			return
		end

		local moeHelper = {...}
		if moeHelper[1] == nil then
			moeHelper = "could not print error"
		else
			moeHelper = moeHelper[1]
			if #moeHelper > 2 then
				moeHelper = string.format(...)
			end
		end

		OccurenceStart += OccurenceOffset
		local ActualError = string.format("%s:%s:%s: error: ", "program", CurrentLine, OccurenceStart)..moeHelper
		local ActualPointer = ""
		for i = 1,OccurenceStart-1 do
			ActualPointer = ActualPointer.." "
		end
		ActualPointer = ActualPointer.."^"
		local ErrorPointer = string.format(ErrorPointerFormat, CurrentLine, LineList[CurrentLine], ActualPointer)
		print(ErrorPointer)
		cerror(ActualError)
	end
	local function cassert(COND, ...)
		if not COND then
			CompilerError(...)
		end
	end
	local function GetType()
		assert(find(GenericTypes, Name), "FATAL: GetType must be performed whilst on a type token")
		local TypeFormation = ""
		repeat 
			Iterate()
			if not (find(GenericTypes, Name) and Type == "keyword") then
				break
			end
			TypeFormation ..= Name.." "
		until Name == nil

		return TypeFormation:sub(1, #TypeFormation-1)
	end
	local function ParseNumber()
		return tonumber(Name)
	end
	local function ParseString()
		return tostring(Name)
	end
	local function ParseValue(ClosingOperator)
		ClosingOperator = ClosingOperator or ";"
		local DataList = {}
		local CloseIsValid = false -- Safety for occurences like someone doing "int test = ;"
		local function PushStep(Data)
			DataList[#DataList+1] = Data
		end
		
		local function StepFormation()
			local Data = {}
			
			if Type == "string" then
				insert(Data, "string")
				insert(Data, ParseString())
				PushStep(Data)
				CloseIsValid = true
				return StepFormation()
			elseif Type == "number" then
				insert(Data, "number")
				insert(Data, ParseNumber())
				PushStep(Data)
				CloseIsValid = true
				return StepFormation()
			elseif Type == "identifier" then
				insert(Data, "variable")
				insert(Data, Name)
				PushStep(Data)
				CloseIsValid = true
				return StepFormation()
			elseif Type == "operator" then
				if Name == "*" then
					-- Special case required due to multiplication operator conflicting with the pointer operator
					local PeekType, PeekName = Navigator.Peek(-1)
					if PeekType == "operator" and PeekName == "=" then
						insert(Data, "pointer")
						Iterate()
						cassert(Type == "identifier", Name, 0, "Expected type 'identifier' got '%s'", Type)
						insert(Data, Name)
						PushStep(Data)
						CloseIsValid = true
						return StepFormation()
					else
						insert(Data, "mul")
						CloseIsValid = false
						return StepFormation()
					end
				elseif Name == "&" then
					-- Special case required due to binary AND operator conflicting with the address operator
					local PeekType, PeekName = Navigator.Peek(-1)
					if PeekType == "operator" and PeekName == "=" then
						insert(Data, "address")
						Iterate()
						cassert(Type == "identifier", Name, 0, "Expected type 'identifier' got '%s'", Type)
						insert(Data, Name)
						PushStep(Data)
						CloseIsValid = true
						return StepFormation()
					else
						insert(Data, "binaryAND")
						CloseIsValid = false
						return StepFormation()
					end
				elseif Name == ClosingOperator then
					if CloseIsValid then
						return
					else
						CompilerError(Name, 0, "Close is not valid / did not expect ';' at '%s'", Name)
					end
				elseif Name:find("%(") then
					insert(Data, "isolate_open")
					return StepFormation()
				elseif Name:find("%)") then
					insert(Data, "isolate_close")
					return StepFormation()
				else
					local OperatorTranslation = OperatorTranslationTable[Name]
					if OperatorTranslation then
						insert(Data, OperatorTranslation)
						CloseIsValid = false
						return StepFormation()
					else
						CompilerError(Name, 0, "Unexpected operator during value parsing, got '%s'", Name)
					end
				end
			end
		end
		
		StepFormation()
		print(Name)
		assert(Name == ClosingOperator and CloseIsValid, "FATAL: Close is not valid or reached end of assignment without ';'/'{'")
		return DataList
	end
	local function ParseFunction(FunctionName)
		cassert(FunctionName ~= nil, Name, 0, "Functions require identifier")
		local Data = {}
		local VariadicDeclared = false
		local ArgumentCount = 0
		if Name:find("%)") then
			Data[1] = {
				Type = "void",
			}
			ArgumentCount = 1
			return Data
		end
		local function ParseArgument()
			Iterate()
			local ArgumentData = {}
			
			if Type == "keyword" then
				cassert(Name ~= "static", Name, 0, "storage class specified for parameter '%s'", FunctionName)
				if Name == "const" then
					ArgumentData.IsConst = true
					Iterate()
				end
				
				if find(GenericTypes, Name) then
					ArgumentData.DataType = GetType()
					if not find(ValidTypes, ArgumentData.DataType) then
						CompilerError(Name, 0, "Invalid Data Type '%s'", ArgumentData.DataType)
					else
						CompilerError(Name, 0, "Invalid Type '%s'", Name)
					end
				end
				if Type == "keyword" then
					Iterate()
				end
				cassert(Type == "identifier" or Type == "operator", Name, 0, "expected operator or identifier got '%s'", Type)
				
				if Name == "," then
					Data[#Data+1] = ArgumentData
					ParseArgument()
				elseif Name == ")" then
					Data[#Data+1] = ArgumentData
					return
				end
				
			end
		end
		ParseArgument()
		cassert(Name == ")", Name, 0, "Expected closing ')' after parameter-list got '%s'", Name)
		Iterate()
		cassert(Name == ";" or Name:find("{"), Name, 0, "Expected ';', '{' got '%s'", Name)
		FunctionList[FunctionName] = Data 
		if Name == ";" then
			return { Data, {} } -- Declaration
		elseif Name == "{" then
			return { Data, ParseNewFunction(true) } -- Definition
		else
			warn("empty function definition '"..FunctionName.."'")
			return { Data, {} }
		end
	end
	ParseNewFunction = function(IsInFunction)
		local SyntaxTree = {}
		local function ProgramPush(Data)
			SyntaxTree[#SyntaxTree+1] = Data
		end
		
		repeat 
			Iterate()
			if IsInFunction and Name == "}" then
				return SyntaxTree
			end
			if Type == "keyword" then
				-- Variable & Function Parsing:
				if find(GenericTypes, Name) or Name == "void" or Name == "static" or Name == "const" then
					local SpecificationData = {}
					if Name == "static" then
						Iterate()
						SpecificationData.IsStatic = true
					end
					if Name == "const" then
						Iterate()
						SpecificationData.IsConst = true
					end
					if Name == "static" then
						Iterate()
						SpecificationData.IsStatic = true
					end
					SpecificationData.DataType = GetType()
					
					if not find(ValidTypes, SpecificationData.DataType) then
						CompilerError(Name, 0, "Invalid Data Type '%s'", SpecificationData.DataType)
					end
					
					Iterate()
					if Type == "operator" and Name == ";" then
						SpecificationData.DefinitionType = "variable"
						warn("warning: useless type name in empty declaration")
						continue
					end

					local function ReadDefiniton()
						if Type == "operator" and Name == "*" then
							SpecificationData.PointerToVariable = true
							Iterate()
						end
						if Type == "identifier" then
							SpecificationData.DefinitionName = Name
							VariableList[Name] = SpecificationData
							Iterate()
						end
						if Type == "operator" then
							if Name == Name:find("%(") then
								assert(SpecificationData.DefinitionType ~= "variable", "how?: attempted declaring function whilst type variable")
								SpecificationData.DefinitionType = "function"
								SpecificationData.FunctionDefinition = ParseFunction(SpecificationData.DefinitionName)
								ProgramPush(SpecificationData)
								return
							elseif Name == "=" then
								SpecificationData.DefinitionType = "variable"
								Iterate()
								SpecificationData.ValueInitialization = ParseValue()
								if Name == ";" or Name == "," then
									ProgramPush(SpecificationData)
									return
								end
							elseif Name == ";" then
								SpecificationData.DefinitionType = "variable"
								ProgramPush(SpecificationData)
								return
							elseif Name == "," then
								ReadDefiniton()
								return
							end
						end
					end
					ReadDefiniton()
					if SpecificationData.DefinitionType == "function" then
						return
					end
					cassert(Name == ";", 0, "expected ';' got '%s'", Name)
				elseif Name == "if" then
					Iterate()
					cassert(Name:find("%("), "expected opening ( on if statement")
					ProgramPush({"if", ParseValue(), ParseFunction("IF_BLOCK_"..string.format("%X", IF_BLOCK_POINTER))})
					IF_BLOCK_POINTER += 1
					continue
				end
			end
		until Type == nil or Name == nil
		
		print(SyntaxTree)
		return SyntaxTree
	end
	
	ParseNewFunction(false)
	return MasterSyntaxTree
end

return Module
