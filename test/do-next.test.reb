REBOL [
	Title: "do-next - Tests"
	Version: 1.0.0
	Rights: {
		Copyright 2016 Brett Handley
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
	%../do-next.reb
]

requirements 'do-next [

	[
        state: do-next []
        all [
            void? get/any in state 'value
            tail? state/rest
        ]
    ]

	[
        state: do-next [1 2]
        [1 [2]] = reduce bind [value rest] state
    ]
]
