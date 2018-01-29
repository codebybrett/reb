REBOL [
    Title: "Read-Deep Tests"
    Rights: {
        Copyright 2018 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Test READ-DEEP.}
]

script-needs [
	%requirements.reb
    %../read-deep.reb
]

requirements 'read-deep [

    [
        files: read-deep %../
        all [
            did find files %read-deep.reb
            did find files %test/read-deep.test.reb
        ]
    ]
]