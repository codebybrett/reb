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
        not parse [] parsing-at x []
        not parse [] parsing-at/end x []
    ]

    [{Test for tail by default.}
        not parse [] parsing-at x [x]
    ]

    [{Can disable tail test.}
        did parse [] parsing-at/end x [x]
    ]

    [{Return next position to return success.}
        did parse [y] parsing-at x [next x]
        did parse [y] compose/only [(parsing-at x [x]) skip]
    ]

    [{Return blank, false, or unset to fail.}
        not parse [y] parsing-at x [_]
        not parse [y] parsing-at x [false]
        not parse [y] parsing-at x [()]
    ]
]

parsing-deep-test: requirements 'parsing-deep [

    [
        all [
            did parse [] parsing-deep []
            did parse [x] parsing-deep [word!]
            did parse [1 x] parsing-deep [word!]
            did parse [1 [x]] parsing-deep [word!]
            not parse [1 [x] 2] parsing-deep [word!]
            not parse [1 [x] 2 [x]] parsing-deep [word!]
        ]
    ]
]

parsing-thru-test: requirements 'parsing-thru [

    [
        all [
            not parse [] parsing-thru ['x]
            did parse [x] parsing-thru ['x]
            did parse [1 2 x] parsing-thru ['x]
        ]
    ]

    [
        thru-x-or-y: parsing-thru ['x | 'y]
        did parse [1 x 1 y] [2 thru-x-or-y]
    ]
]

parsing-to-test: requirements 'parsing-to [

    [
        all [
            not parse [] parsing-to ['x]
            to-x: parsing-to ['x]
            did parse [1 2 x] [to-x skip]
        ]
    ]

    [
        to-x-or-y: parsing-to ['x | 'y]
        parse [1 1 1 x 1 1 y] [2 [to-x-or-y skip]]
    ]
]

parsing-matched-test: requirements 'parsing-matched [

    [
        did parse [x y] parsing-matched result [
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
            not parse [] parsing-earliest []
            did parse [x] parsing-earliest [skip]
        ]
    ]

    [
        earliest: parsing-earliest [integer! word!] 
        did parse [x 1] [earliest skip]
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

requirements %parse-kit.reb [

    ['passed = last parsing-at-test]
    ['passed = last parsing-deep-test]
    ['passed = last parsing-thru-test]
    ['passed = last parsing-to-test]
    ['passed = last parsing-earliest-test]
    ['passed = last impose-test]
    ['passed = last after-test]
    ['passed = last rule-modification-tests]
]
