REBOL [
	Title: "Do-Next"
	Version: 1.0.0
	Rights: {
		Copyright 2016 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Evaluate a single expression.}
    Comment: {DO/Next in Rebol 2 and Rebol 3 are different but equally awkward to use.}
]


do-next: function [
    {Evaluate next expression in a block of source code. State as an object.}
	source [block! string!]
    words [block!] {Words to be set to expression value and source position.}
][

    value: any [to-value first words 'value]
    position: any [to-value second words 'position]

    set/any value do/next source position
]

