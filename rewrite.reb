REBOL [
    Title: "Structure matching and rewriting engine"
    File: %rewrite.reb
    Purpose: {
        Implements a structure matching and rewriting engine using
        PARSE.
    }
    Author: ["Gabriele Santilli" "Brett Handley"]
    EMail: giesse@rebol.it
    License: {

        Copyright (c) 2006, Gabriele Santilli
        All rights reserved.

        Copyright on modifications (C) Brett Handley
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions
        are met:

        * Redistributions of source code must retain the above copyright
          notice, this list of conditions and the following disclaimer. 
          
        * Redistributions in binary form must reproduce the above
          copyright notice, this list of conditions and the following
          disclaimer in the documentation and/or other materials provided
          with the distribution. 

        * The names of Gabriele Santilli and Brett Handley may not be used to
          endorse or promote products derived from this software without
          specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
        "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
        LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
        FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
        COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
        INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
        BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
        CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
        LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
        ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
        POSSIBILITY OF SUCH DAMAGE.
    }
    Date: 05-Jul-2016
    Version: 2.4.0
    History: [
        17-May-2006 1.1.0 "History start"
        17-May-2006 1.2.1 "First version"
        18-Aug-2013 1.2.2 "Supports Rebol 3. [Brett Handley]"
        25-Mar-2015 1.3.0 {Match now returns faster by returing first matched input position instead of True
                               so it can be used like a find. Use /All for previous behaviour. [Brett Handley]}
        13-Jul-2015 2.0.0 "Rename Match to Search. Add case refinement for Rebol2. [Brett Handley]"
        23-Aug-2015 2.1.0 {Add DEBUG keyword for tracing rewrites (place before search pattern).
                               Replace /trace with /pause. [Brett Handley]}
        25-Sep-2015 2.1.1 {File name changed to rewrite.reb. [Brett Handley]}
        30-Sep-2015 2.2.0 {Rewrite/once specifies a single pass.
                           Rewrite/only prevents reprocessing of a replacement in same pass. [Brett Handley]}
        13-Oct-2015 2.3.0 {Modify to work with Ren/C future bridge (r2r3-future.r).}
        05-Jul-2016 2.4.0 {Reaname /trace to /trace, remove copy behaviour. Allow global trace setting.}
    ]
]

; -------------------------------------------------------------------------------------------------------------
;
; Search
;
;   Deep search (depth first) using parse rule.
;
; Rewrite
;
;   Rewrite text or block (recursively) using search pattern as parse rule and replacement as compose block.
;
;   By default, repeatedly does a top down search and replace until no more occurrences are found.
;
;   Use /once to single top down search and replace pass.
;
;   Use /only to prevent a replacement being immediately reprocessed by continuing the search after the
;   replacement. The replacement will be reprocessed in the next pass.
;
;   By combining /once and /only replacements can be made that would ordinarily cause an infinite loop.
;   E.g:
;
;       rewrite [x] [ ['x][y] ['y]['x]] ; Causes an infinite loop.
;
;       rewrite/once/only [x] [ ['x][y] ['y]['x]] ; One replacement only.
;
;   Place the word trace before each search pattern you want traced. Alternatively
;   use trace on to turn on tracing for all rules until the next trace off.
;
; -------------------------------------------------------------------------------------------------------------


search: func [
    "Search data recursively to satisfy a parse rule."
    data [block! string!] "Data to search."
    rule [block!] "PARSE rule to use as pattern"
    /all {Match every occurrence of pattern. Returns position after last match. Default is stop at first match.}
    /local
    result recurse position
] [
    result: false
    either all [
        recurse: either block? data [[
                some [
                    rule result:
                    |
                    and any-block! into recurse
                    |
                    skip
                ]
            ]] [[
                some [
                    rule result:
                    |
                    skip
                ]
            ]]
    ] [
        recurse: either block? data [[
                some [position:
                    rule (result: position) return (true)
                    |
                    and any-block! into recurse
                    |
                    skip
                ]
            ]] [[
                some [position:
                    rule (result: position) return (true)
                    |
                    skip
                ]
            ]]
    ]
    parse data recurse
    to-value if result [result] ; Failure returns none.
]


rewrite: func [
    "Apply a list of rewrite rules to data"
    data [block! string!] "Data to change"
    rules [block!] "List of rewrite rules"
    /trace {Override default trace function.} trace-fn [function!] {Takes a single argument.}
    /once {Only one full top down search and replace pass is performed.}
    /only {Replacements are not reprocessed in the same pass.}
    /pause "Pause rewriting process at each pass." pause-body [block!] {Evaluate at each pause.}
    /local
    search-pattern new mk1 mk2 event pattern production trc-mode trc do-trace process edit
] [

    if empty? rules [return data]

    if not trace [
        trace-fn: func [edit] [
            print [
                {^/------ rewrite -----} newline
                {old:} mold copy/part edit/position edit/length newline
                {new:} mold edit/new
            ]
        ]
    ]

    do-trace: func [] compose [
        (:trace-fn) compose/deep/only [
            new (new)
            length (subtract index-of mk2 index-of mk1)
            position (mk1)
        ]
    ]

    search-pattern: make block! 16

    parse rules [
        (trc-mode: false)
        any [
            'trace ['on | 'true] (trc-mode: true)
            | 'trace ['off | 'false] (trc-mode: false)
            | (trc: trc-mode) opt ['trace (trc: true)] set pattern skip set production skip (

                event: to-value if trc [[do-trace]]

                insert insert/only insert/only tail search-pattern pattern make paren! compose/only [
                    event: (event)
                    new: compose/deep (production)
                ] '|
            )
        ]
    ]
    remove back tail search-pattern

    edit: either only [
        quote (do event mk1: change/part mk1 new mk2)
    ][
        quote (do event change/part mk1 new mk2)
    ]

    process: either once [:do][:until]

    process [
        if pause [do pause-body ask "? "]
        not search/all data [mk1: search-pattern mk2: edit :mk1]
    ]

    data
]
