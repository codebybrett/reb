REBOL [
    Title: "Find-Same"
    Version: 1.0.0
    Rights: {
        Copyright 2015 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Find value in series using SAME?.}
]


find-same: func [
    {Finds a value in a block using SAME? function.}
    block [block!]
    value
    /local pos result
][
    while [found? pos: find/only block :value][
        if same? :pos/1 :value [result: pos break]
        block: next pos
    ]
    result
]
