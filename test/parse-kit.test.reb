REBOL [
	Title: "Parse-Kit - Tests"
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
	%../parse-kit.reb
]

parsing-at-test: requirements 'parsing-at [

	[{Must return next position to succeed.}
		not parse [] parsing-at x []
		not parse [] parsing-at/end x []
	]

	[{Test for tail by default.}
		not parse [] parsing-at x [x]
	]

	[{Can disable tail test.}
		parse [] parsing-at/end x [x]
	]

	[{Return next position to return success.}
		parse [y] parsing-at x [next x]
		parse [y] compose/only [(parsing-at x [x]) skip]
	]

	[{Return none, false, or unset to fail.}
		not parse [y] parsing-at x [none]
		not parse [y] parsing-at x [false]
		not parse [y] parsing-at x [()]
	]
]

requirements %parse-kit.reb [

	['passed = last parsing-at-test]
]
