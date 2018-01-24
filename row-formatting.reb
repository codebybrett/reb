REBOL [
	Title: "Row Formatting"
	File: %row-formatting.reb
	Purpose: "Formats."
	Version: 3.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	History: [
		1.0.0 [7-Dec-2014 "Initial version." "Brett Handley"]
		1.1.0 [15-Feb-2015 "Modify excel-text to output date and datetime properly." "Brett Handley"]
		3.0.0 [24-Jun-2017 "Move to GitHub." "Brett Handley"]
		; GitHub now tracks history.
	]
]

script-needs [
	%binding.reb
	%separators.reb
	%date.reb
	%copy-source.reb
]

value-types?: function [
	block [block!] {Get's types of values.}
][
	map-each value block [type-of/word :value]
]

pad: (function [length value] [head insert/dup value: form value #"0" length - length of value])

excel-text: function [
	{Emit excel text.}
	delim [char!] "The cell delimiter used in the data, usually either a tab or comma."
	data [block! object!] {A block of blocks or object supporting iterator interface (/next, /tail?).}
][
	qc: charset unspaced [delim {"'}]
	cell-format: func [value] [
		if blank? :value [value: {}]
		if date? :value [value: date/as/excel value]
		if not string? :value [value: form :value]
		if find value qc [value: head insert append replace/all copy value {"} {""} {"} {"}]
		value
	]
	row-format: func [value [block!]] [
		cells-as-text: map-each x value [cell-format :x]
		join-of unspaced interpose delim cells-as-text lf
	]
	result: copy {}
	either block? data [
		for-each row data [append result row-format row]
	][
		iterate data [append result row-format data/value]
	]
	result
]

sqlencoder: binding/custom/object [
	value type value-list
	type-list
	name-list name-encoding
	column.prefix column.suffix
] copy-source/deep [

	column.prefix: _
	column.suffix: _

	value: _
	type: _

	value-list: function [
		values [block!]
	][
		result: copy []
		for-each x values [append result reduce [{, } value :x]]
		remove result ; First seperator.
		unspaced result
	]

	type-list: function [
		types [block!]
	][
		map-each x types [type :x]
	]

	name-list: function [
		names [block!]
	][
		result: copy []
		for-each x names [append result reduce [{, } name-encoding :x]]
		remove result ; First separator.
		unspaced result
	]

	name-encoding: function [name][
		unspaced [
			any [column.prefix {}]
			form :name
			any [column.suffix {}]
		]
	]

	create: function [
		table-name [string!]
		names [block!]
		types [block!]
	] [
		types: type-list types
		field-list: copy []
		repeat i length? names [
			name: names/:i
			type: types/:i
			append field-list reduce [{, } name-encoding :name]
			if found? type [append field-list reduce [#" " form :type]]
		]
		remove field-list; First separator.
		unspaced ["create table " table-name " (" field-list ");"]
	]

	insert: function [
		table-name [string!]
		values [block!]
		/column names [block!]
	] [
		names: either column [compose [{ (} (name-list names) {)}]][[]]
		unspaced compose [{insert into } (table-name) (names) { values (} (value-list values) {);}]
	]

]

odbc-sql: make sqlencoder [

	column.prefix: #"["
	column.suffix: #"]"

	type: function [
		type [word!] {REBOL type as word!.}
	] [
		switch/default :type [
			integer! [{NUMBER}]
			decimal! [{NUMBER}]
			number! [{NUMBER}]
			money! [{CURRENCY}]
			logic! [{LOGICAL}]
			date! [{DATETIME}]
			string! [{TEXT}]
		] [{TEXT}]
	]

	value: function [
		value
	] [

		switch/default type-of :value [
			#[datatype! integer!] [form value]
			#[datatype! decimal!] [form value]
			#[datatype! logic!] [form value]
			#[datatype! date!] [
				unspaced [
					{#} form value/year
					"-" either value/month < 10 ["0"] [""] form value/month
					"-" either value/day < 10 ["0"] [""] form value/day
					either set? 'value/time [join-of " " form value/time] [""] {#}
				]
			]
			#[datatype! blank!] ["null"]
			#[datatype! string!] [unspaced [{'} (replace/all copy value {'} {''}) {'}]]
		] [
			; For everything else - just insert it as REBOL syntax for now.
			unspaced [{'} (replace/all mold value {'} {''}) {'}]
		]
	]
]

sqlite-sql: make sqlencoder [

	type: function [
		type [word!] {REBOL type as word!.}
	] [
		switch/default :type [
			integer! [{INTEGER}]
			decimal! [{REAL}]
			number! [{NUMERIC}]
			money! [{REAL}]
			logic! [{INTEGER}]
			date! [{TEXT}]
			string! [{TEXT}]
		] [{TEXT}]
	]

	value: function [
		value
	] [

		switch/default type-of :value [
			#[datatype! integer!] [form value]
			#[datatype! decimal!] [form value]
			#[datatype! logic!] [form either value [1] [0]]
			#[datatype! date!] [
				unspaced [
					{'} form value/year
					"-" either value/month < 10 ["0"] [""] form value/month
					"-" either value/day < 10 ["0"] [""] form value/day
					either set? 'value/time [join-of " " form value/time] [""] {'}
				]
			]
			#[datatype! blank!] ["null"]
			#[datatype! string!] [unspaced [{'} (replace/all copy value {'} {''}) {'}]]
		] [
			; For everything else - just insert it as REBOL syntax for now.
			unspaced [{'} (replace/all mold value {'} {''}) {'}]
		]
	]
]
