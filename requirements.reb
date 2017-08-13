REBOL [
    Title: "Requirements"
    Version: 1.0.0
    Rights: {
        Copyright 2015 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Specify and test requirements that code should meet.}
]

; -------------------------------------------------------------------------------
;
; Each test can optionally begin with a string description of the requirement,
; stated in the positive sense (the requirement is met if the test returns true).
;
; This format should be compatible with Rebol test format.
;
; -------------------------------------------------------------------------------

throws-error: function [
    condition [block!] {Bound to error object. Evaluated by ALL.}
    test [block!]
] [
    to-value if error? err: try test [
        all bind/copy condition in err 'type
    ]
]

user-error: function [match [string! block!] test [block!]] [
    if string? match [match: compose [(match) to end]]
    all [
        error? set/only 'err try test
        string? err/message
        parse err/message match
    ]
]

requirements: function [
    {Test requirements.}
    about
    block [block!] {Series of test blocks. A textual requirement begins the block (optional).}
    /result
] [
    results: new-line/all/skip collect [
        for-each test block [
            if not block? test [
                fail [{Test must be a block. Got: } (mold test)]
            ]
            value: _
            error? set/only 'value try bind test 'throws-error
            keep all [
                set? 'value
                logic? value
                value
            ]
            keep/only either string? test/1 [test/1] [test]
        ]
    ] true 2

    remove-each [passed id] results [passed]
    all-passed?: empty? results

    if result [return all-passed?]

    either all-passed? [
        compose/only [
            (:about) passed
        ]
    ] [
        new-line compose/only [
            (:about) TODO
            (new-line/all extract next results 2 true)
        ] true
    ]
]
