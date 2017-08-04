REBOL [
    Title: "date - Tests"
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
    %../date.reb
]

requirements 'date [

    [
        equal? "2017-08-01" date/as/excel 1-Aug-2017
    ]

    [
        equal? "2017-08-01 10:00:00" date/as/excel 1-Aug-2017/10:00
    ]

    [
        equal? "20170801T130000+10:00" date/as/iso8601 1-Aug-2017/13:00+10:00
    ]

    [
        equal? "2017-08-01T13:00:00+10:00" date/as/w3c 1-Aug-2017/13:00+10:00
    ]

    [
        equal? 1-Aug-2017/3:00 date/as/utc 1-Aug-2017/13:00+10:00
    ]

    [
        equal? 31-Jul-2017/19:00-8:00 date/as/zone -8:00 1-Aug-2017/13:00+10:00
    ]

    [
        equal? date/from/iso8601 date/as/iso8601 d: 1-aug-2017 d
    ]

    [
        equal? 1-Aug-2017 date/from/unspecified "20170801"
    ]

    [
        equal? 1-Aug-2017 date/from/unspecified "1 aug 2017"
    ]

    [
        equal? date/from/w3c date/as/w3c d: 1-aug-2017 d
    ]

    [
        equal? date/from/w3c date/as/w3c d: 1-aug-2017 d
    ]

    [
        date/is/leap-year? 1-aug-2016
    ]

    [
        equal? 31-Aug-2017 date/of/month/end 1-Aug-2017
    ]

    [
        equal? 1-Aug-2017 date/of/month/start 1-Aug-2017
    ]
]
