REBOL [
    Title: "parse-Kit - Tests"
    Version: 1.0.0
    Rights: {
        Copyright 2015 Brett Handley
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
    %../parse-kit.reb
]

parsing-at-test: requirements 'parsing-at [

    [{Must return next position to succeed.}
        not parse? [] parsing-at x []
        not parse? [] parsing-at/end x []
    ]

    [{Test for tail by default.}
        not parse? [] parsing-at x [x]
    ]

    [{Can disable tail test.}
        parse? [] parsing-at/end x [x]
    ]

    [{Return next position to return success.}
        parse? [y] parsing-at x [next x]
        parse? [y] compose/only [(parsing-at x [x]) skip]
    ]

    [{Return blank, false, or unset to fail.}
        not parse? [y] parsing-at x [_]
        not parse? [y] parsing-at x [false]
        not parse? [y] parsing-at x [()]
    ]
]

parsing-deep-test: requirements 'parsing-deep [

    [
        all [
             parse? [] parsing-deep []
            parse? [x] parsing-deep [word!]
            parse? [1 x] parsing-deep [word!]
            parse? [1 [x]] parsing-deep [word!]
            false? parse? [1 [x] 2] parsing-deep [word!]
            false? parse? [1 [x] 2 [x]] parsing-deep [word!]
        ]
    ]
]

parsing-thru-test: requirements 'parsing-thru [

    [
        all [
            false? parse? [] parsing-thru ['x]
            parse? [x] parsing-thru ['x]
            parse? [1 2 x] parsing-thru ['x]
        ]
    ]

    [
        thru-x-or-y: parsing-thru ['x | 'y]
        parse? [1 x 1 y] [2 thru-x-or-y]
    ]
]

parsing-to-test: requirements 'parsing-to [

    [
        all [
            false? parse? [] parsing-thru ['x]
            parse? [1 2 x] parsing-thru ['x]
        ]
    ]

    [
        to-x-or-y: parsing-to ['x | 'y]
        parse [1 1 1 x 1 1 y] [2 [to-x-or-y skip]]
    ]
]

parsing-matched-test: requirements 'parsing-matched [

    [
        parse? [x y] parsing-matched result [
            [2 skip]
            [2 word!]
            ['x 'y]
        ] [
            if all map-each pos result [tail? pos] [
                result/1 ; Return first position as success.
            ]
        ]
    ]

]

parsing-earliest-test: requirements 'parsing-earliest [

    [
        all [
            false? parse? [] parsing-earliest []
            parse? [x] parsing-earliest [skip]
        ]
    ]

    [
        earliest: parsing-earliest [integer! word!] 
        parse? [x 1] [earliest skip]
    ]
]


impose-test: requirements 'impose [

    [
        f: 1
        equal? [x 1 x] impose 'f copy [x f x]
    ]
]

after-test: requirements 'after [

    [blank? after [skip] {}]
    [tail? after [skip] {x}]
]

rule-modification-tests: requirements 'rule-modification-tests [

    [
        rule: [skip]
        restore-rule 'rule
        equal? [skip] rule
    ]

    [
        rule: [skip]
        equal? reduce [_ true] collect [
            on-parsing 'rule func [block] [keep second block]
            parse [x] rule
        ]
    ]

    [
        restore-rule 'rule
        equal? [skip] rule
    ]
]

get-parse-test: requirements 'get-parse-test [

    [
        equal? [root _ [type root position _ length _]] get-parse [][]
    ]

    [
        r: [word!]
        tree: get-parse [parse [x] r] [r]
        all [
            equal? 4 length tree ; [name parent properties child]
            equal? tree/4/1 'r ; Node name.
            equal? tree/4/3 [type rule position [x] length 1] ; Node properties.
        ]
    ]

    [
        tree: get-parse/literal [parse [x] r] [r] [r]
        equal? tree/4/3 [type literal position [x] length 1]
    ]

    [
        tree: get-parse/terminal [parse [x] r] [r] [r]
        equal? tree/4/3 [type terminal position [x] length 1]
    ]

    [
        r1: [r2 r3]
        r2: [word!]
        r3: [integer!]
        tree: get-parse [parse [x 1] r1] [r1 r2 r3]
        all [
            equal? 4 length tree ; [name parent properties child]
            equal? tree/4/1 'r1 ; Node name.
            equal? 5 length tree/4 ; [name parent properties child1 child2]
            equal? tree/4/4/1 'r2 ; Node name.
            equal? tree/4/5/1 'r3 ; Node name.
        ]
    ]
]

requirements %parse-kit.reb [

    ['passed = last parsing-at-test]
    ['passed = last parsing-deep-test]
    ['passed = last parsing-thru-test]
    ['passed = last parsing-to-test]
    ['passed = last parsing-earliest-test]
    ['passed = last impose-test]
    ['passed = last after-test]
    ['passed = last rule-modification-tests]
    ['passed = last get-parse-test]
]
