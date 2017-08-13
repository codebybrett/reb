REBOL [
    Title: "rowsets - Tests"
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
    %../rowsets.reb
]


players: [
    words [name score]
    rows [
        [{Tom}   4]
        [{Dick}  9]
        [{Harry} 7]
    ]
]

requirements 'rowset [

    [{Select}
        players = rowset/query [
			select * from x players
		]
    ]

    [{Where}
        result: rowset/query [
			select * where [score = 7] from x players
		]
        all [
            1 = length? result/rows
            result/rows/1/1 = {Harry}
        ]
    ]

    [{Join}
		result: rowset/query [
			select [
				w: x/name
				l: y/name
				s: x/score * 10
			]
			join [
				x/score < y/score
				x/name <> y/name
			]
			from x players
			from y players
		]
        all [
            [w l s] = result/words
            3 = length? result/rows
        ]
    ]

    [{Simple series}
		result: rowset/query [
			select [x: x + 10]
			from-series s [x y] [1 2 3 4 5 6]
		]
        all [
            [x] = result/words
            3 = length? result/rows
        ]
    ]

    [
        user-error {rowset.row cannot use Y. Y is not a rowset source.} [
            rowset/query [
                select [z: rowset.row y] from x players
            ]
        ]
    ]

    [
        user-error {Duplicate aliases used} [
            rowset/query [
                join [] from x players from x players
            ]
        ]
    ]

    [
         user-error {No select columns} [
             rowset/query [
                 select [1] from x players
             ]
         ]
    ]
]
