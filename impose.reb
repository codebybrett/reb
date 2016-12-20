REBOL [
    Title: "Impose"
    rights: {
        Copyright 2016 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {A simple templating function.}
]

; Motivation:
;	Compose is useful but painful when you Want to have a group as part of your output structure.
;   A templating approach where a word represents a target for replacement is a simple way to get a desired structure.
;   For more complex needs, REWRITE is probably better.

impose: function [
	{Selectively replace specific words contained by a block by a value.}
	symbol [word! block! object!] {Word(s) denoting expressions.}
	block [block! group!] {Block to modify.}
	/using evaluate [function!] {Function taking a word, returning value of that word.}
	/only {Insert series values as is.}
][

	; Block of symbols.
	symbol: compose [(either object? symbol [words-of symbol][symbol])]

	; Default evaluator.
	if not using [
		evaluate: function [word][
			if any-series? value: get word [
				value: copy value
			]
			:value
		]
	]

	; Match against symbols.
	match: remove collect [
		for-each word symbol [
			keep '|
			keep to lit-word! word
			keep/only to group! compose/only [value: evaluate (to lit-word! word)]
		]
	]

	; Define the replacement.
	action: either only [
		[p1: change/only p1 :value]
	][
		[p1: change/part p1 :value 1]
	]

	; Deep search and replace.
	rule: compose/deep/only [
		some [
			p1: match (to group! action) :p1
			| into rule
			| skip
		]
	]

	parse block rule

	block
]
