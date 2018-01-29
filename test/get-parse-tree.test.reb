REBOL [
    Title: "Get-Parse-Tree - Tests"
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
    %../get-parse-tree.reb
]

requirements 'get-parse-tree [

    [
        equal? [[root _ _ _ _]] get-parse-tree [][]
    ]

    [
        r: [word!]
        tree: get-parse-tree [parse [x] r] [r]
        all [
            equal? 2 length of tree ; [root child]
            parse tree/2/1 ['rule 'r integer! into ['x] block!] ; Node data
            same? tree/2 tree/2/1/5/1 ; Reference to this node's slot in parent.
        ]
    ]

    [
        tree: get-parse-tree/literal [parse [x] r] [r] [r]
        equal? tree/2/1 'literal
    ]

    [
        tree: get-parse-tree/terminal [parse [x] r] [r] [r]
        equal? tree/2/1 'terminal
    ]

    [
        r1: [r2 r3]
        r2: [word!]
        r3: [integer!]
        tree: get-parse-tree [parse [x 1] r1] [r1 r2 r3]
        all [
            equal? 2 length of tree ; Root has 1 child.
            equal? 3 length of tree/2 ; The child has 2 children.
            equal? 'r1 tree/2/1/2 
            equal? 'r2 tree/2/2/1/2
            equal? 'r3 tree/2/3/1/2
        ]
    ]
]
