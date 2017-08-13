REBOL [
    Title: "Text Lines"
    Version: 1.0.0
    Rights: {
        Copyright 2015 Brett Handley

        Rebol3 load-next by Chris Ross-Gill.
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Transition load/next from Rebol 2 to Rebol 3.}
]

decode-lines: function [
    {Decode text previously encoded using a line prefix e.g. comments (modifies).}
    text [string!]
    line-prefix [string! block!] {Usually "**" or "//". Matched using parse.}
    indent [string! block!] {Usually "  ". Matched using parse.}
] [
    pattern: compose/only [(line-prefix)]
    if not empty? indent [append pattern compose/only [opt (indent)]]
    line: [pos: pattern rest: (rest: remove/part pos rest) :rest thru newline]
    if not parse? text [any line] [
        fail [{Expected line} (line-of text pos) {to begin with} (mold line-prefix) {and end with newline.}]
    ]
    remove back tail text
    text
]

encode-lines: func [
    {Encode text using a line prefix, e.g. comments (modifies).}
    text [string!]
    line-prefix [string!] {Usually "**" or "//".}
    indent [string!] {Usually "  ".}
    /local bol pos
] [

    ; Note: Preserves newline formatting of the block.

    ; Encode newlines.
    bol: join-of line-prefix indent
    parse text [
        any [
            thru newline pos:
            [newline (pos: insert pos line-prefix) | (pos: insert pos bol)] :pos
        ]
    ]

    ; Indent head if original text did not start with a newline.
    pos: insert text line-prefix
    if not equal? newline :pos/1 [insert pos indent]

    ; Clear indent from tail if present.
    if indent = pos: skip tail text 0 - length indent [clear pos]
    append text newline

    text
]

for-each-line: func [
    {Iterate over text lines.}
    'record [word!] {Word set to metadata for each line.}
    text [string!] {Text with lines.}
    body [block!] {Block to evaluate each time.}
    /local eol
] [

    set/only 'result while [not tail? text] [

        eol: any [
            find text newline
            tail text
        ]

        set record compose [position (text) length (subtract index-of eol index-of text)]
        text: next eol

        do body
    ]

    get/only 'result
]

lines-exceeding: function [
    {Return the line numbers of lines exceeding line-length}
    line-length [integer!]
    text [string!]
] [

    line-list: line: _

    count-line: [
        (
            line: 1 + any [line 0]
            if line-length < subtract index-of eol index-of bol [
                line-list: append any [line-list copy []] line
            ]
        )
    ]

    parse text [
        any [bol: to newline eol: skip count-line]
        bol: skip to end eol: count-line
    ]

    line-list
]

line-of: function [
    {Returns line number of position within text.}
    text [string!]
    position [string! integer!]
] [

    line: _

    if integer? position [
        position: at text position
    ]

    count-line: [(line: 1 + any [line 0])]

    parse copy/part text next position [
        any [to newline skip count-line] skip count-line
    ]

    line
]
