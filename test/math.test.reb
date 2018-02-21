REBOL [
    Title: "Math Tests"
    Rights: {
        Copyright 2016 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Test MATH.}
]

script-needs [
	%requirements.reb
    %../math.reb
]

requirements 'math [

    [
        user-error {Expected an expression.} [math []]
    ]

    [
        user-error {Expected an expression.} [math [1 - +]]
    ]

    [
        user-error {Expected argument or unary operators + or -.} [math [{x}]]
    ]

    [
        user-error {Expected a single expression.} [math [1 2]]
    ]

    [{Single value.}
        1 = math [1]
    ]

    [{Complex expression.}
        19 = math [1 + 2 * 3 ** 2]
    ]

    [{Grouped expressions.}
        9 = math [(1 + 2) * 3]
    ]

    [{Translation with words and paths.}
        [add (multiply 3 o/x) w] = math/only [(3 * o/x) + w]
    ]

    [{Blocks interpreted by DO dialect.}
        3 = math [1 + [either true [2][3]]]
    ]
]