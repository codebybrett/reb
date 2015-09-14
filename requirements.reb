REBOL [
	Title: "Requirements"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Specify and test requirements that code should meet.}
]

; -------------------------------------------------------------------------------
;
; Each test can optionally begin with a string description of the requirement,
; stated in the positive sense (the requirement is met if the test returns true).
;
; This format should be compatible with Rebol test format.
;
; -------------------------------------------------------------------------------

either system/version > 2.100.0 [; Rebol3

	throws-error: funct [
		condition [block!] {Bound to error object. Evaluated by ALL.}
		test [block!]
	] [
		if error? err: try test [
			all bind/copy condition in err 'type
		]
	]

	user-error: funct [match [string! block!] test [block!]] [
		if string? match [match: compose [(match) to end]]
		all [
			error? err: try test
			parse err/arg1 match
		]
	]
] [; Rebol2

	throws-error: funct [
		condition [block!] {Bound to error object. Evaluated by ALL.}
		test [block!]
	] [
		if error? err: try test [
			all bind/copy condition in disarm err 'type
		]
	]

	user-error: funct [match [string! block!] test [block!]] [
		if string? match [match: compose [(match) to end]]
		all compose [
			error? err: try test
			err: disarm err
			parse/all err/arg1 match
		]
	]

]

requirements: funct [
	{Test requirements.}
	about
	block [block!] {Series of test blocks. A textual requirement begins the block (optional).}
	/result
] [
	results: new-line/all/skip collect [
		foreach test block [
			value: none
			error? set/any 'value try bind test 'throws-error
			keep all [
				value? 'value
				logic? value
				value
			]
			keep/only either string? test/1 [test/1] [test]
		]
	] true 2

	remove-each [passed id] results [passed]
	all-passed?: empty? results

	if result [return all-passed?]

	either all-passed? [
		compose/only [
			(:about) passed
		]
	] [
		new-line compose/only [
			(:about) TODO
			(new-line/all extract next results 2 true)
		] true
	]
]
