REBOL [
	Title: "Environment"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Provide environment for scripts.}
]

; -----------------------------------------------------------------------------
;
; env
;
;	Defines an environment for scripts.
;
;
; script-needs
;
;	Script-Needs is intended to be metadata for a script.
;	Each script should use script-needs only once near the top of the script.
;
; -----------------------------------------------------------------------------


;
; TODO:
;
;	* Refresh file from url other than reb. Need a manifest?
;


env: context [

	master: https://raw.githubusercontent.com/codebybrett/reb/master/

	base: either find [url!] type?/word system/script/args [
		system/script/args
	][
		what-dir
	]

	log: func [message] [print mold new-line/all compose/only message false]
	log: none

	log [env (compose [base (base) master (master)])]

	scripts: context [

		used: make block! []

		refresh: funct [
			{Refresh each script in base directory.}
		] [

			files: read base
			remove-each file files [not parse/all file [thru %.reb]]

			foreach file files [
				log [refresh (file)]
				write base/:file read master/:file
			]
		]
	]

	conditions?: func [
		{Return true if the conditions are met. See script-environment.}
		conditions [block!]
	] [
		all bind/copy conditions facts
	]

	facts: context [
		rebol3: (system/version > 2.100.0)
		rebol2: (system/version < 2.100.0)
		view: found? find form system/product {view}
	]

	run: funct [
		{Run a script.}
		file [file! url!]
		/local path name
	] [

		set [path name] split-path file

		failed: make block! []

		read-script: func [file][
			if not find failed file [
				script: context [
					name: file
					text: attempt [
						append failed file
						log [read (file)]
						read file
					]
				]
			]
			script/text
		]

		either any [url? path path = %./] [

			; Search for file if not already used.

			if not find scripts/used name [

				any [
					read-script name
					read-script base/:name
					if url? file [read-script file]
					read-script master/:name
				]
			]
		] [

			; Specific file - run each time.

			get-script file
		]

		either script/text [

			file: clean-path script/name
			log [run true (file)]

			do script/text
			def: compose [
				file (file)
			]
			insert position: tail scripts/used reduce [name def]
			new-line position true
		][

			log [run false (script/name)]
		]

		file
	]

]


script-needs: funct [
	{Runs each script listed. Accepts mulitple files. A block preceeding a file is a predicate to be evaluated by script-environment?.}
	needs [file! block!]
	/local script
] [
	needs: compose [(:needs)]
	if not parse needs [
		any [
			pos: (pred: true) opt [set pred block! (pred: env/conditions? pred)]
			set script [file! | url!] (if pred [env/run :script])
		]
	] [make error! rejoin [{Could not parse script-needs near: } copy/part pos 40]]
]

env/base
