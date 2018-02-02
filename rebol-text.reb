REBOL [
    Title: "Rebol Text Parsing"
    Rights: {
        Copyright 2018 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: "Parse rebol text."
]

script-needs [
    %parse-kit.reb
    %get-parse-tree.reb
    %trees.reb
]

rebol-text: context [

    rules: [
        nl: [newline]
        ws: [some [#" " | #"^-"]]
        cmt: [some [#";" [to newline | to end]]]
        blkb: [#"["]
        blke: [#"]"]
        grpb: [#"("]
        grpe: [#")"]
        value: [skip (if error? try [set [val p2] load-next p1][
            fail [{rebol-text - error near:} (mold copy/part p1 100)]]) :p2]
        block: [blkb sequence blke]
        group: [grpb sequence grpe]
        sequence: [
            any [
                p1:
                nl
                | ws | cmt
                | block | group
                | not [#"]" | #")" ] value
            ]
        ]
    ]

    load-next: function [
        {Load the next value. Return block with value and new position.}
        string [string!]
    ][
        out: transcode/next to binary! string
        out/2: skip string subtract length-of string length-of to string! out/2
        out
    ] ; by @rgchris.

    parser: function [
        {Returns a parser for rebol text.}
    ][
        context [
            p1: p2: val: token: _
            grammar: context bind copy rules 'val
            valid?: function [text][
                parse text grammar/sequence
            ]
        ]
    ]

    tokenise: function [
        {Return the tokens of rebol text.}
        text [string!] {REBOL Text String.}
    ][
        ;; tokeniser
    ]

    tree: function [
        {Return tree structure of rebol text.}
        text [string!] {REBOL Text String.}
    ][

        parsing: parser
        do in parsing [
            ast: get-parse-tree/terminal/literal [valid? text]
                bind [block group] grammar
                bind [value cmt ws] grammar
                bind [nl] grammar
        ]

        visit-tree ast [
            either block? node [
                data: node/1
            ][
                data: node
            ]
            switch data/1 [
                rule [
                    if blank? data/2 [
                        ; Root node: overall text is an implied block.
                        data/2: in parsing/grammar 'block
                    ]
                    new-data: data/2
                    append clear data new-data
                ]
                terminal [
                    new-data: reduce [data/2 copy/part data/4 data/3]
                    append clear data new-data
                ]
                literal [
                    new-data: data/2
                    append clear data new-data
                ]
            ]
            clear at data 4
        ]

        pretty-tree ast
    ]
]

