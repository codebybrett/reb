REBOL [
    Title: "Get Parse Tree"
    Rights: {
        Copyright 2018 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: "Parse trees."
]

; ---------------------------------------------------------------------------------------------------------------------
; Notes:
;
;   get-parse-tree
;
;       Returns a tree representing the path PARSE takes through specified parse rules.
;
;       The tree has this structure:
;
;           node: [data child1 child2 ... childn]
;           data: [type word length position parent-slot]
;
;           The parent-slot is the slot in the parent that refers to this node.
;
;           The root node represents the rule argument given to parse.
;
;       Only those rules that are specified are returned, in that sense it is closer
;       to an abstract syntax tree.
;
;
; ---------------------------------------------------------------------------------------------------------------------

script-needs [
    %parse-kit.reb
    %trees.reb
]

get-parse-tree: function [
    {Returns a PARSE tree for specified rules. Check the result of Parse to determine validity.}
    body [block!] {Invoke Parse on your input.}
    rules [block! object!] {Block of words or object. Each word must identify a Parse rule.}
    /literal {Identify literals (must be constant). Saves memory/faster).} literals [block! object!] {Block of words or object.}
    /terminal {Identify terminals (variable length). Avoids stack usage.} terminals [block! object!] {Block of words or object.}
    /nocomplete {Don't complete rules after early Parse exit (Parse's RETURN keyword), returns current emit position.}
    /error error-state [word!] {Set error-state word if an error occurs. Useful for debugging rules.}
] [

    ; ----------------------------------------
    ; Initialise.
    ; ----------------------------------------

    for-each arg [rules terminals literals] [
        if object? def: get/only arg [def: bind words-of :def :def]
        set arg any [:def copy []]
    ]

    node: context [type: name: length: position: parent: _]
    matched: _

    ; ----------------------------------------
    ; Embed rules event code into the parse rules.
    ; ----------------------------------------

    ; Define event function for rules (non-terminals)

    do-rule-event: func [
        rule.evt
    ] bind [

        type: 'rule

        set [name matched position] rule.evt

        either blank? matched [

            ; Starting to test this rule.
            ; output points to tail of parent.
            ; Add rule node. Push.

            insert/only output output: reduce [
                compose/only [(type) (name) (_) (position) (output)]
            ]
            output: tail output ; Place to write first child.
        ] [

            ; Pop. output indexes just completed child.

            output: pick first head output 5

            either matched [
                length: subtract index-of position index-of output/1/1/4 ; Length
                output/1/1/3: length

                output: next output ; Accept tree node.
            ] [

                remove output ; Reject tree node.
            ]
        ]

    ] node

    ; Embed calls to rule event function.

    for-each rule rules [
        restore-rule :rule ; In case last run was stopped unexpectedly.
        on-parsing :rule :do-rule-event
    ]


    ; ----------------------------------------
    ; Embed terminals event code into the parse rules.
    ; ----------------------------------------

    use [start-position] [

        ; Define event function for terminals.

        do-terminal-event: func [
            terminal.evt
        ] bind [

            set [name matched position] terminal.evt

            either blank? matched [

                ; Starting to test this rule.
                start-position: :position

            ] [

                if matched [

                    length: subtract index-of position index-of start-position ; Length
                    position: start-position ; Input position

                    output: insert/only output compose/only [terminal (name) (length) (position) (output)]
                ]
            ]

        ] node

    ]

    ; Embed calls to event function.

    for-each terminal terminals [
        restore-rule terminal ; In case last run was stopped unexpectedly.
        on-parsing :terminal :do-terminal-event
    ]

    ; ----------------------------------------
    ; Embed literals event code into the parse rules.
    ; ----------------------------------------

    ; Define event function for literals.

    do-literal-event: func [
        literal.evt
    ] bind [

        set [name length position] literal.evt

        output: insert/only output compose/only [literal (name) (length) (position) (output)]

    ] node

    ; Embed calls to event function.

    for-each literal literals [
        restore-rule literal ; In case last run was stopped unexpectedly.
        on-parsing/literal :literal :do-literal-event
    ]

    ; ----------------------------------------
    ; Do the parse.
    ; ----------------------------------------

    output: tail reduce [compose [root (_) (_) (_) (_)]]
    try-result: _
    if error [set :error-state _]
    if error? set/only 'try-result try [do body] [
        if error [
            set :error-state compose/only [
                tree (output)
            ] 
        ]
    ]

    ; If we are not back to root level then parse terminated early (RETURN keyword).
    ; Auto complete the outstanding rules.
    if not nocomplete [
        ; Complete the unfinished rules.
        while [
            node: head output
            block? node/1/5
        ] [
            do-rule-event reduce [node/1 true node/1/4]
        ]
    ]

    ; ----------------------------------------
    ; Cleanup and Return result
    ; ----------------------------------------

    ;
    ; Restore original parse rule definitions.

    for-each arg [rules terminals literals] [
        for-each rule get arg [
            restore-rule rule
        ]
    ]

    ;
    ; Provide extra error information.

    trace-result: compose/only [
        out (output)
    ]

    if error? get/only 'try-result [
        if error [
            set :error-state compose [
                error (get :error-state)
                (trace-result)
            ]
        ]
        do :try-result
    ] ; Re-raise errors.

    either nocomplete [trace-result] [head trace-result/out]
]
