REBOL [
	Title: "Line Encoded Blocks"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Encode and Decode Rebol blocks across formatted lines.}
]

script-needs [
	%load-next.reb
	%parse-kit.reb
]

decode-lines: funct [
	{Decode text previously encoded using a line prefix e.g. comments (modifies).}
	text [string!]
	line-prefix [string!] {Usually "**" or "//".}
	indent [string!] {Usually "  ".}
] [
	if not parse/all text [any [line-prefix thru newline]][
		do make error! reform [{decode-lines expects each line to begin with} mold line-prefix { and finish with a newline.}]
	]
	insert text newline
	replace/all text join newline line-prefix newline
	if not empty? indent [
		replace/all text join newline indent newline
	]
	remove text
	remove back tail text
	text
]

encode-lines: func [
	{Encode text using a line prefix (e.g. comments).}
	text [string!]
	line-prefix [string!] {Usually "**" or "//".}
	indent [string!] {Usually "  ".}
	/local bol pos
] [

	; Note: Preserves newline formatting of the block.

	; Encode newlines.
	replace/all text newline rejoin [newline line-prefix indent]

	; Indent head if original text did not start with a newline.
	pos: insert text line-prefix
	if not equal? newline pos/1 [insert pos indent]

	; Clear indent from tail if present.
	if indent = pos: skip tail text 0 - length? indent [clear pos]
	append text newline

	text
]

load-until-blank: funct [
	{Load rebol values from text until double newline.}
	text [string!]
	/next {Return values and next position.}
][

	wsp: compose [some (charset { ^-})]

	rebol-value: parsing-at x [
		res: any [attempt [load-next x] []]
		if not empty? res [second res]
	]

	terminator: [opt wsp newline opt wsp newline]

	not-terminator: parsing-unless terminator
	; Could be replaced with Not in Rebol 3 parse.

	rule: [
		some [not-terminator rebol-value]
		opt [1 2 newline] position: to end
	]

	if parse/all text rule [
		values: load copy/part text position
		reduce [values position]
	]
]

mold-contents: func [
	{Mold block without the outer brackets (a little different to MOLD/ONLY).}
	block [block! paren!]
	/local string bol
][

	string: mold block

	either parse/all string [
		skip copy bol [newline some #" "] to end
	][
		replace/all string bol newline
	][
	]
	remove string
	take/last string

	string
]

