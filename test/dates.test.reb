REBOL [
    Title: "Proposed Date Behaviour"
    Version: 1.0.0
    Rights: {
        Copyright 2017 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
]

script-needs [
    %requirements.reb
]


requirements %dates.test.reb [

    ;
    ; Setup.

    [
        date-111: 7-aug-2017/03:00+10:00 ; DateTimeZone
        date-110: 7-aug-2017/03:00 ; DateTime
        date-100: 7-aug-2017 ; DateOnly
        true
    ]

    ;
    ; Basic date tests.

    [d: date-111 same? d date-111]
    [d: date-110 same? d date-110]
    [d: date-100 same? d date-100]

    [same? date-111/date date-100]
    [same? date-110/date date-100]
    [same? date-100/date date-100]
    [same? date-111/date date-100/date]
    [same? date-111/time date-110/time]

    [set? 'date-111/time]
    [set? 'date-110/time]
    [set? 'date-111/zone]
    [not set? 'date-110/zone]
    [not set? 'date-100/zone]
    [not set? 'date-100/time]

    [not equal? date-110 date-100]
    [not equal? date-111 date-100]

    ;
    ; Math

    [0 = subtract date-111 date-111]
    [0 = subtract date-110 date-110]
    [0 = subtract date-100 date-100]
    [error? try [subtract date-111 date-110]]
    [error? try [subtract date-110 date-100]]

    [0:00 = difference date-111 date-111]
    [0:00 = difference date-110 date-110]
    [error? try [difference date-111 date-110]]
    [error? try [difference date-110 date-100]]
    [error? try [difference date-100 date-100]]

    [date-100 <= date-100]
    [date-110 <= date-110]
    [date-111 <= date-111]

    [error? try [date-111 <= date-110]]
    [error? try [date-110 <= date-100]]

    ;
    ; Mappings

    [date-111/utc/zone = 0:00]
    [error? try [date-110/utc]]
    [error? try [date-100/utc]]

    [error? [date-111/local/zone]]

    [
        d: make date-110 [zone: date-111/zone]
        same? d date-111
    ]

    [
        d: make date-100 [time: date-110/time]
        same? d date-110
    ]

    [
        d: make date-100 [time: date-111/time zone: date-111/zone]
        same? d date-111
    ]

    ;
    ; Date field mutation tests.

    [ ; Clear zone - no date adjustment.
        d: date-111
        d/zone: ()
        same? d date-110
    ]

    [ ; Clear time and zone - no date adjustment.
        d: date-111
        d/time: ()
        same? d date-100
    ]

    [ ; Set time - no adjustment performed.
        d: date-111
        d/time: d/time + 0:00
        same? d date-111
    ]

    [ ; Set time - no adjustment performed.
        d: date-110
        d/time: d/time + 0:00
        same? d date-110
    ]

    [ ; Set time.
        d: date-100
        d/time: date-110/time
        same? d date-110
    ]

    [ ; Set zone.
        d: date-111
        d/zone: date-111/zone
        same? d date-111
    ]

    [ ; Set zone.
        d: date-110
        d/zone: date-111/zone
        same? d date-111
    ]

    [ ; Set zone without time.
        d: date-100
        error? try [d/zone: 10:00]
    ]
]
