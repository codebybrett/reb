REBOL [
    Title: "rewrite - Tests"
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
    %../rewrite.reb
]


search-test: requirements 'search [

    [
        [] = search [] []
    ]

    [
        [x] = search [x] [skip]
    ]

    [
        [z] = search [x [y [z]]] ['z]
    ]

    [
        [y [z]] = search [x [y [z]]] ['y]
    ]

    [
        [x y z] = collect [
            search/all [x [y [z]]] [
                p: word! (keep :p/1)
            ]
        ]
    ]
]

rewrite-test: requirements 'rewrite [

    [
        [] = rewrite [] []
    ]

    [
        [] = rewrite [] [['x][]]
    ]

    [
        [z] = rewrite [x] [['x][y] ['y][z]]
    ]

    [
        [y] = rewrite/once [x] [['x][y] ['y][z]]
    ]
]

requirements %rewrite.reb [

    ['passed = last search-test]
    ['passed = last rewrite-test]
]

