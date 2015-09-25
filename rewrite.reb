REBOL [
	Title: "Structure matching and rewriting engine"
	File: %rewrite.reb
	Purpose: {
        Implements a structure matching and rewriting engine using
        PARSE.
    }
	Author: "Gabriele Santilli"
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
	Date: 23-Aug-2015
	Version: 2.0.0
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
	]
]

; -------------------------------------------------------------------------------------------------------------
;
; Search
;
;	Deep search using parse rule.
;
; Rewrite
;
;	Rewrite text or block (recursively) using search pattern as parse rule and replacemnt as compose block.
;
;	Place the word DEBUG before each search pattern you want debugged.
;
; -------------------------------------------------------------------------------------------------------------


either system/version > 2.100.0 [; R3

	; Brett Handley: Create R3 version of match to guard the INTO.

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
		if result [result] ; Failure returns none.
	]

] [

	search: func [
		"Search data recursively to satisfy a parse rule."
		data [block! string!] "Data to search."
		rule [block!] "PARSE rule to use as pattern"
		/all {Match every occurrence of pattern. Returns position after last match. Default is to stop at first match.}
		/case {Uses case-sensitive comparison.}
		/local
		result recurse position guard parse*
	] [
		result: false
		either all [
			recurse: either block? data [[
					some [
						rule result:
						|
						into recurse
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
			guard: none
			recurse: either block? data [[
					some [position:
						opt [rule (result: position guard: [end skip])]
						guard [into recurse | skip]
					]
				]] [[
					some [position:
						opt [rule (result: position guard: [end skip])]
						guard skip
					]
				]]
		]
		either case [parse/all/case data recurse] [parse/all data recurse]
		if result [result] ; Failure returns none.
	]

]

rewrite: func [
	"Apply a list of rewrite rules to data"
	data [block! string!] "Data to change"
	rules [block!] "List of rewrite rules"
	/pause "Pause rewriting process at each pass." pause-body [block!] {Evaluate at each pause.}
	/debug {Override default debug function.} debug-fn [function!] {Takes a single argument.}
	/local
	rules* replace mk1 mk2 event pattern production dbg do-debug
] [
	if empty? rules [return data]
	if not debug [
		debug-fn: func [edit] [
			print [
				{^/------ rewrite -----} newline
				{target:} mold edit/target newline
				{replace:} mold edit/replace
			]
		]
	]
	do-debug: func [] compose [
		(:debug-fn) compose/deep/only [
			target (copy/part mk1 mk2)
			replace (replace)
			length (subtract index? mk2 index? mk1)
			position (mk1)
		]
	]
	rules*: make block! 16
	parse rules [
		any [
			(dbg: false) opt ['debug (dbg: true)] set pattern skip set production skip
			(
				event: if dbg [[do-debug]]

				insert insert/only insert/only tail rules* pattern make paren! compose/only [
					event: (event)
					replace: compose/deep (production)
				] '|
			)
		]
	]
	remove back tail rules*
	until [
		if pause [do pause-body ask "? "]
		not search/all data [mk1: rules* mk2: (do event change/part mk1 replace mk2) :mk1]
	]
	data
]