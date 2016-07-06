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

	[void? do-next [] []]

	[equal? 1 do-next [1 2] []]

	[
        do-next [] [value rest]
        all [
            void? get/any 'value
            tail? rest
        ]
    ]

	[
        do-next [1 2] [value rest]
        all [
            equal? value 1
            equal? rest [2]
        ]
    ]
]
