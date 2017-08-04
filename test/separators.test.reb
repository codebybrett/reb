REBOL [
    Title: "separators - Tests"
    Version: 1.0.0
    Rights: {
        Copyright 2017 Brett Handley
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
    %../separators.reb
]

requirements %separators.reb [

    [
        [x x] = bookend 'x []
    ]

    [
        [x y x] = bookend 'x [y]
    ]

    [
        [] = interpose 'x []
    ]

    [
        [y] = interpose 'x [y]
    ]

    [
        [y x z] = interpose 'x [y z]
    ]

    [
        [[]] = separate ['x] []
    ]

    [
        [[y]] = separate ['x] [y]
    ]

    [
        [[y y]] = separate ['x] [y y]
    ]

    [
        [[y y] [y]] = separate ['x] [y y x y]
    ]

    [
        [[y x y] [y]] = separate [2 'x] [y x y x x y]
    ]
]
