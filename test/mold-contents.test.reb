REBOL [
	Title: "Mold-Contents - Tests"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
]

script-needs [
	%requirements.reb
	%../mold-contents.reb
]

mold-contents-common: requirements 'mold-contents-common [

	[quote {} = mold-contents []]

	[quote {1} = mold-contents [1]]

	[quote {^/1^/} = mold-contents new-line [1] true]
]

either system/version > 2.100.0 [; Rebol3

	mold-contents-specific: requirements 'mold-contents-specific [

		[quote {1^/    2 3^/} = mold-contents [1
				2 3]
		]
	]

] [; Rebol2

	mold-contents-specific: requirements 'mold-contents-specific [

		[quote {1 ^/    2 3^/} = mold-contents [1
				2 3]
		]
	]
]

requirements %mold-contents.reb [

	['passed = last mold-contents-common]
	['passed = last mold-contents-specific]
]

