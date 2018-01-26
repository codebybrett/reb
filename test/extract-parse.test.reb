REBOL [
    Title: "Extract-Parse - Tests"
    Version: 1.0.0
    Rights: {
        Copyright 2018 Brett Handley
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
    %../extract-parse.reb
]

grammar: context [
    expression: [term any [[add | subtract] term]]
    term: [number any [[multiply | divide] number]]
    add: [#"+"]
    subtract: [#"-"]
    multiply: [#"*"]
    divide: [#"/"]
    number: [some digit]
    digit: charset {0123456789}
]

rules: exclude words-of grammar [digit]

tree: get-parse-tree [parse {1+2*3-4} grammar/expression] rules

requirements 'extract-parse [

    [
        equal? extract-parse tree [_
            [expression
                [term
                    [number "1"]
                ]
                [add "+"]
                [term
                    [number "2"]
                    [multiply "*"]
                    [number "3"]
                ]
                [subtract "-"]
                [term
                    [number "4"]
                ]
            ]
        ]
    ]
]