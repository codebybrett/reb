REBOL [
    Title: "Impose Tests"
    Rights: {
        Copyright 2016 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Test Impose.}
]


script-needs [
	%requirements.reb
    %../impose.reb
]

requirements 'impose [

    [
        x: 1
        [structure (1)] = impose 'x [structure (x)]
    ]

    [
        [w 1 2] = impose context [x: 1 y: 2] [w x y]
    ]

    [
        [[1] [[2]]] = impose context [x: 1 y: 2] [[x] [[y]]]
    ]

    [
        o: context [
            x: [1 + y]
            y: [x - 2]
        ]
        [1 + [x - 2]] = impose/only o impose o [x]
    ]
]
