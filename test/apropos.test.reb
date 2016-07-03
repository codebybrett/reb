REBOL [
	Title: "Apropos - Tests"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Testing.}
]

script-needs [
	%requirements.reb
	%../apropos.reb
]

ctx1: context [

	c1: 1
	value: 1

	ctx2: context [

		c2: 2
		value: 2

		ctx3: context [

			c3: 3
			value: 3
		]
	]
]

requirements %apropos.reb [

	[1 = apropos ctx1 [value]]

	[1 = apropos [ctx1] [value]]

	[1 = apropos (to path! 'ctx1) [value]]

	[2 = apropos 'ctx1/ctx2 [value]]

	[[1 2] = apropos 'ctx1/ctx2 [reduce [c1 value]]]

	[throws-error [id = 'no-value arg1 = 'c1] [apropos/only 'ctx1/ctx2 [reduce [c1 value]]]]

	[[2 3] = apropos [ctx1/ctx2/ctx3 ctx1/ctx2] [reduce [value c3]]]

	[ {Apropos supports frames.}
		f: make frame! :add
		apropos f [value1: 1 value2: 2]
		3 = do f
	]
]
