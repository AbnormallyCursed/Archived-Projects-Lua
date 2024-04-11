local language = {
	keyword = {
		-- All keywords recognized by ANSI C89:
		["auto"] = "keyword",
		["break"] = "keyword",
		["case"] = "keyword",
		["char"] = "keyword",
		["const"] = "keyword",
		["continue"] = "keyword",
		["default"] = "keyword",
		["define"] = "keyword",
		["do"] = "keyword",
		["double"] = "keyword",
		["else"] = "keyword",
		["enum"] = "keyword",
		["extern"] = "keyword",
		["float"] = "keyword",
		["for"] = "keyword",
		["goto"] = "keyword",
		["if"] = "keyword",
		["ifdef"] = "keyword",
		["ifndef"] = "keyword",
		["include"] = "keyword",
		["int"] = "keyword",
		["long"] = "keyword",
		["register"] = "keyword",
		["return"] = "keyword",
		["short"] = "keyword",
		["signed"] = "keyword",
		["sizeof"] = "keyword",
		["static"] = "keyword",
		["struct"] = "keyword",
		["switch"] = "keyword",
		["typedef"] = "keyword",
		["union"] = "keyword",
		["unsigned"] = "keyword",
		["void"] = "keyword",
		["volatile"] = "keyword",
		["while"] = "keyword",
		-- GNU, C99 and our keyword extensions:
		["__asm"] = "keyword",
	},

	builtin = {
		
	},

	libraries = {

	},
}

return language
