REBOL [
	Title: "Set-Words-Of"
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

either system/version > 2.100.0 [; R3

	; Brett Handley: Create R3 version to guard the INTO.

	set-words-of: function [
		"Returns items in a block of type set-word!."
		block [block!]
		/deep {Recurse into blocks to find set-words.}
	] [

		if not deep [
			RETURN map-each w block [either set-word? :w [w][()]]
		]

		unique collect [
			parse block rule: [
				any [
					set word set-word! (keep word)
					| and any-block! into rule
					| skip
				]
			]
		]

	]

] [

	set-words-of: function [
		"Returns items in a block of type set-word!."
		block [block!]
		/deep {Recurse into blocks to find set-words.}
	] [

		if not deep [
			RETURN remove-each w copy block [not set-word? :w]
		]

		unique collect [
			parse block rule: [
				any [
					set word set-word! (keep word)
					| into rule
					| skip
				]
			]
		]

	]

]
