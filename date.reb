REBOL [
	Title: "Date"
	File: %date.reb
	Purpose: "Date calculations and conversions."
	Version: 3.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
	History: [
		1.0.0 [14-Dec-2014 "Initial version." "Brett Handley"]
		1.1.0 [01-Jan-2015 "Add /as/iso8601, /from/iso8601." "Brett Handley"]
		1.2.0 [15-Feb-2015 "Add /as/excel." "Brett Handley"]
		1.2.1 [11-Sep-2015 "Fix reversionary bugs." "Brett Handley"]
		3.0.0 [24-Jun-2017 "Move to GitHub and remove old script manager." "Brett Handley"]
		; GitHub now tracks history.
	]
]

script-needs [
	%binding.reb
]

digit: charset {0123456789}

date: binding/custom/object [parser] copy-source/deep [

	advance: binding/custom/object [] [

		until: function [
			{Advance date until condition.}
			condition [block!] {Evaluated by ANY. DATE is bound.}
			date [date!]
			/next delta [integer! time! function!] {Advance by number of days or time, or next date from date function. Default is 1 day.}
		] [
			if not found? :delta [delta: 1]
			if not function? :delta [delta: compose [add (delta)]]
			until compose/deep [
				date: (:delta) date
				any [(bind condition 'date)]
			]
			date
		]

		while: function [
			{Advance date while condition.}
			condition [block!] {Evaluated by all. DATE is bound.}
			date [date!]
			/next delta [integer! time! function!] {Advance by number of days or time, or next date from date function. Default is 1 day.}
		] [
			if not found? :delta [delta: 1]
			if not function? :delta [delta: compose [add (delta)]]
			while compose/only [all (bind/copy condition 'date)] compose [date: (:delta) date]
			date
		]

	]

	as: make object! [

		excel: function [
			{MS Excel Date Time Format string from Date.}
			date [date!]
		] [
			pad: (function [length value] [head insert/dup value: form value #"0" length - length? value])
			string: join-all [form date/year #"-" pad 2 date/month #"-" pad 2 date/day]
			if time: get 'date/time [
				second: decimal: _
				parse form time/second [copy second [to #"." | to end] opt [copy decimal to end]]
				if parse decimal [#"." some #"0"] [decimal: {}]
				append string join-all [
					" " pad 2 time/hour #":" pad 2 time/minute #":" pad 2 second decimal
				]
			]
			string
		]

		iso8601: function [
			{ISO 8601 Date Time Format string from Date.}
			date [date!]
			/extended {Use extended format.}
		] [
			pad: (function [length value] [head insert/dup value: form value #"0" length - length? value])
			either extended [dsep: {-} tsep: {:}][dsep: {} tsep: {}]
			string: join-all [form date/year dsep pad 2 date/month dsep pad 2 date/day]
			if time: get 'date/time [
				second: decimal: _
				parse form time/second [copy second [to #"." | to end] opt [copy decimal to end]]
				if parse decimal [#"." some #"0"] [decimal: {}]
				append string join-all [
					"T" pad 2 time/hour tsep pad 2 time/minute tsep pad 2 second decimal
					either 0:00 = zone: date/zone [#"Z"] [
						join-all [either positive? zone ["+"] ["-"] pad 2 zone/hour #":" pad 2 zone/minute]
					]
				]
			]
			string
		]

		yyyymmdd: function [
			{YYYYMMDD format date.}
			date [date!]
		] [
			join-all [
				date/year
				either 10 > date/month [{0}][{}]
				date/month
				either 10 > date/day [{0}][{}]
				date/day
			]
		]

		w3c: function [
			{W3C Date Time Format string from Date.}
			date [date!]
		] [
			iso8601/extended date
		]

		utc: function [
			{Returns UTC datetime for date.}
			date [date!]
		] [
			date/zone: 00:00
			date
		]

		zone: function [
			{Returns datetime adjusted for time zone.}
			zone [time!]
			date [date!]
		] [
			if blank? get 'date/time [date/time: 0:00] ; Avoid bug.
			new: date - date/zone + zone
			new/zone: zone
			new
		]

	]

	from: make object! [

		iso8601: function [
			{Date from ISO 8601 Date Time Format string. RUDIMENTARY AT PRESENT.}
			string [string!]
		] [
			date: time: zone: _
			if parse string [
				[copy year 4 digit opt #"-" copy month 2 digit opt #"-" copy day 2 digit]
				(date: to date! join-all [year {-} month {-} day])
				opt [pos:
					#"T" (hour: minute: {00} second: decimal: {})
					[copy hour 1 2 digit opt #":" copy minute 2 digit
					opt [pos:
						opt #":" copy second 2 digit
						opt [copy decimal [#"." some digit]]]
					] pos:
					(date/time: to time! join-all [hour #":" minute #":" second #"." decimal])
					opt [
						[
							#"z" (zone: 0:00)
							| copy zone [[#"+" | #"-"] 1 2 digit #":" 2 digit]
						] pos:
						(date/zone: to time! zone)
					]
				]
			] [date]
		]

		unspecified: function [
			{Attempt to parse date from unspecified date format string.}
			string [string!]
		] [
			if parse string parser/grammar/rule [
				parser/date
			]
		]

		w3c: function [
			{Date from W3C Date Time Format string.}
			string [string!]
		] [
			iso8601 string
		]

		wmi: function [
			{Date from Windows WMI Time Format string.}
			string [string!]
		] [
			date: time: zone: _
			if parse string [
				[copy year 4 digit copy month 2 digit copy day 2 digit]
				(date: to date! join-all [year {-} month {-} day])
				(hour: minute: {00} second: decimal: {})
				[copy hour 2 digit copy minute 2 digit copy second 2 digit #"." decimal 6 digit]
				(date/time: to time! join-all [hour #":" minute #":" second #"." decimal])
				copy zone [opt [#"+" | #"-"] some digit] ; Minutes difference from GMT.
				(date/zone: to time! 60 * to integer! zone)
			] [date]
		]

	]

	is: binding/custom/object [] [

		leap-year?: func [
			{Returns true if year is a leap year.}
			year [date! integer!] {Year specified by as four digit integer or date.}
		] [
			; Calculation as per http://tools.ietf.org/html/rfc3339
			if date? year [year: year/year]
			all [
				0 = mod year 4
				any [
					0 != mod year 100
					0 = mod year 400
				]
			]
		]

	]

	of: make object! [

		month: make object! [

			end: func [
				{Return date of last day in the month for date.} date [date!]] [
				subtract to date! reduce [1 date/month + 1 date/year] 1
			]

			start: func [
				{Return date of first day in the month for date.} date [date!]] [
				to date! reduce [1 date/month date/year]
			]

		]

	]

	parser: context [

		; Parsing multiple formats of date.

		dte-dd: _
		dte-mm: _
		dte-yr: _
		date: _

		reset-date: func [][
			dte-dd:
			dte-mm:
			dte-yr:
			date: _
		]

		emit-date: func [][
			dte-dd: to integer! dte-dd
			dte-mm: to integer! dte-mm
			dte-yr: to integer! dte-yr
			date: to date! reduce [dte-yr dte-mm dte-dd]
		]

		charsets: context [
			digit: charset {0123456789}
			sep: charset {-_. }
			csep: charset {-_.}
		]

		grammar: context bind [

			dd: [copy dte-dd [[#"0" | #"1" | #"2" | #"3"] digit]]
			dy: [copy dte-dd digit]
			mm: [copy dte-mm [[#"0" | #"1"] digit]]

			day: [
				[
					{Mon}
					| {Tue} opt {s}
					| {Wed} opt {nes}
					| {Thu} opt {rs}
					| {Fri}
					| {Sat} opt {ur}
					| {Sun}
				 ] opt {day}
			]

			month: [
				{Jan} opt {uary} (dte-mm: 1)
				| {Feb} opt {ruary} (dte-mm: 2)
				| {Mar} opt {ch} (dte-mm: 3)
				| {Apr} opt {il} (dte-mm: 4)
				| {May} (dte-mm: 5)
				| {Jun} opt {e} (dte-mm: 6)
				| {Jul} opt {y} (dte-mm: 7)
				| {Aug} opt {ust} (dte-mm: 8)
				| {Sep} opt {tember} (dte-mm: 9)
				| {Oct} opt {ober} (dte-mm: 10)
				| {Nov} opt {ember} (dte-mm: 11)
				| {Dec} opt {ember} (dte-mm: 12)
			]

			yyyy: [copy dte-yr [["20" | "19"] 2 digit]]

			yyyymmdd: [
				(reset-date) [
					yyyy [mm dd | csep mm csep dd]
				] (emit-date)
			]

			flex-date: [
				opt [day {, }]
				[
					dd csep mm csep yyyy ; 01.03.2016
					| [dd | dy] opt sep month opt sep yyyy ; 1 Jul 2016
				] (emit-date)
			]

			rule: [
				[flex-date | yyyymmdd]
			]

		] charsets

	]

	rewrite: func [
		{Rewrite dates within text (needs search from rewrite.r).}
		text [any-string!]
		format [function! word!] {Date formatting function, or word defined in date/as}
		/local p1 p2
	][

		if word? :format [
			format: get in date/as format
		]

		search/all text bind [
			p1: grammar/rule p2: (
				p1: change/part p1 format date p2
			) :p1
		] date/parser

		text
	]
]