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

; The original motivations for requirement in R2 were:
; * to locate an assertion in code
; * to positively state the condition that is expected in English
; * to provide a postively stated error message when the condition fails
;   by reusing the description (ASSERT not being end user friendly).
; * allow automated extraction of requirements from scripts
;
; I don't think REQUIREMENT has lived up to these goals, but it is an interesting
; experiment to reflect upon.
;
; One problem is that the description gets muddied with code to produce a useful error message.
; Another point is that FAIL has been introduced in Ren-c which has implications for REQUIREMENT.
; It may be that REQUIREMENT should have a description, a condition and a failure reason.
;
; Require is a nicer name, which is why I haven't used it, it could easily
; become a built in function.


requirement: function [
	{Requires and documents a condition that must be true, else throw an error.}
	description [string! block!]
	conditions [block!]
] [
	any [
		all conditions
		fail description
	]
]