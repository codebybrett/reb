REBOL [
	Title: "rewrite - Tests"
	Version: 1.0.0
	Rights: {
		Copyright 2016 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Testing.}
]

script-needs [
	%requirements.reb
	%../rewrite.reb
]

requirements 'rewrite [

	[
        [] = rewrite [] []
        [] = rewrite [] [['x][]]
        [z] = rewrite [x] [['x][y] ['y][z]]
        [y] = rewrite/once [x] [['x][y] ['y][z]]
	]
]
