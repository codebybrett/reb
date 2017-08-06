REBOL [
    Title: "row-formatting - Tests"
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
    %../row-formatting.reb
]

requirements %row-formatting.reb [
    [
        equal? {} excel-text tab []
    ]
    [
        equal? {^/} excel-text tab [[]]
    ]
    [
        equal? {x^/} excel-text tab [[x]]
    ]
    [
        equal? {x^/} excel-text tab [[x]]
    ]
    [
        equal? "test^/" excel-text tab [["test"]]
    ]
    [
        equal? "test^-x^/" excel-text tab [["test" x]]
    ]
    [
        equal? "x^/y^/" excel-text tab [[x] [y]]
    ]
    [
        equal? {blank^-
word^-x
string^-test
date^-2017-08-01
}
        excel-text tab compose/deep [
            [blank (blank)]
            [word x]
            [string "test"]
            [date 1-Aug-2017]
        ]
    ]

    [
        equal? "insert into test values (#2017-08-01#, 1, 'x');"
        odbc-sql/insert "test" [1-Aug-2017 1 x]
    ]

    [
        equal? "insert into test values ('2017-08-01', 1, 'x');"
        sqlite-sql/insert "test" [1-Aug-2017 1 x]
    ]
]
