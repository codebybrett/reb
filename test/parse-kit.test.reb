REBOL [
	Title: "parse-Kit - Tests"
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
		not parse? [] parsing-at x []
		not parse? [] parsing-at/end x []
	]

	[{Test for tail by default.}
		not parse? [] parsing-at x [x]
	]

	[{Can disable tail test.}
		parse? [] parsing-at/end x [x]
	]

	[{Return next position to return success.}
		parse? [y] parsing-at x [next x]
		parse? [y] compose/only [(parsing-at x [x]) skip]
	]

	[{Return blank, false, or unset to fail.}
		not parse? [y] parsing-at x [_]
		not parse? [y] parsing-at x [false]
		not parse? [y] parsing-at x [()]
	]
]

requirements %parse-kit.reb [

	['passed = last parsing-at-test]

	[blank? after [skip] {}]
	[tail? after [skip] {x}]
	
	[
		f: 1
		[x 1 x] = impose 'f [x f x]
	]
]
