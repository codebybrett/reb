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
        value: 1
        all [
            tail? do-next 'value []
            not set? 'value
        ]
    ]

    [
        all [
            [2] = do-next 'value [1 2]
            1 = value
        ]
    ]
]
