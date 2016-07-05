REBOL [
	Title: "All Tests"
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
]

tests: read %./
remove-each test tests [not parse? test [thru %.test.reb]]

requirements %_all.tests.reb map-each test tests [
	compose ['passed = last do (test)]
]
