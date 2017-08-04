REBOL [
	Title: "Requirement"
	File: %requirement.r
	Purpose: "Code checking."
	Version: 3.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	History: [
		1.0.0 [7-Dec-2014 "Initial version." "Brett Handley"]
		3.0.0 [24-Jun-2017 "Move to GitHub." "Brett Handley"]
		; GitHub now tracks history.
	]
]


requirement: function [
	{Requires and documents a condition that must be true, else throw an error.}
	[catch]
	description [string! block!]
	conditions [block!]
] [
	any [
		all conditions
		fail description
	]
]