REBOL [
	Title: "Custom Binding"
	File: %binding.reb
	Author: "Brett Handley"
	web: http://www.codeconscious.com
	Version: 3.0.0
	Purpose: "Some functions to manipulate word bindings."
	Comment: {
		/Custom is useful where your object words clash with system words (e.g first, next, etc.).
	}
	License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
	History: [
		1.0.0 [6-Nov-2014 "Initial version." "Brett Handley"]
		3.0.0 [24-Jun-2017 "Move to GitHub." "Brett Handley"]
		; GitHub now tracks history.
	]
]

binding: make object! [

	first: function [
		{Bind first element of block or path (modifies) to known.}
		known {A reference to the target context. (Type: any-word object port).}
		block [any-block!]
	] [
		; Supports Rebol2 and Rebol 3.
		word: bind reduce [block/1] :known
		change block word/1
		block
	]

	custom: make object! [

		object: function [
			{Makes object by binding specific object words (not all) in the specification.}
			words [block!] {Object member words to be bound.}
			block [block!] {Object specification (modifed).}
		] [
			block: copy block
			words: collect [
				keep 'self
				foreach x words [if any-word? :x [keep to-word :x]]
			]

			; Create new object.
			remove-each x spec: copy block [not set-word? :x]
			object: make object! append spec 'blank

			; Bind field set-words in object specification.
			binding/set-words object block

			; Bind specified fields and field/paths in specification.
			binding/replace/deep bind words object block

			; Evaluate specification.
			do block
			object
		]

	]

	local: function [
		{Returns words bound to local context.}
		words [word! block!]
	] [
		words: compose [(words)]
		use words compose/only [(words)]
	]

	replace: function [
		{Replaces binding of specific words in a block (modifies).}
		words [block! word!] {Words with the desired bindings.}
		block [any-block!] {Block to modify.}
		/deep {Bind paths and recurses through sub blocks.}
		/where condition [block!] {Evaluated by ALL. WORD and POSITION is bound.}
	] [
		if not where [condition: [true]]
		words: compose [(:words)]
		use [word position] [
			condition: bind/copy condition 'word
			match: copy [
				position:
				[any-word! (guard: either all [
							w: find words to word! :position/1
							word: :position/1
							all condition
						] [_] [[end skip]])] guard (first :w/1 position)
			]
			if deep [
				append match [
					| any-block! :position into rule ; Note that any-block! (and therefore Rule) will match paths.
				]
			]
		]
		rule: compose/deep [
			any [(match) | skip]
		]
		parse block rule
		block
	]

	set-words: function [
		{Binds set-words in a block (modifies), but not deep.}
		known {A reference to the target context. (Type: any-word object port).}
		block [any-block!]
	] [
		parse block [any [x: set-word! (first known x) | skip]]
		block
	]

]
