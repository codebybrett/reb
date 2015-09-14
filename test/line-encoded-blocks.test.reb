REBOL [
	Title: "Line Encoded Blocks - Tests"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
]

script-needs [
	%requirements.reb
	%../line-encoded-blocks.reb
]

encode-lines-test: requirements 'encode-lines [

	[quote {**^/} = encode-lines {} {**} {  }]
	[quote {**  x^/} = encode-lines {x} {**} {  }]
	[quote {**  x^/**^/} = encode-lines {x^/} {**} {  }]
	[quote {**^/**  x^/} = encode-lines {^/x} {**} {  }]
	[quote {**^/**  x^/**^/} = encode-lines {^/x^/} {**} {  }]
	[quote {**  x^/**    y^/**      z^/} = encode-lines {x^/  y^/    z} {**} {  }]
]

decode-lines-test: requirements 'decode-lines [

	[quote {} = decode-lines {**^/} {**} {  } ]
	[quote {x} = decode-lines {**  x^/} {**} {  } ]
 	[quote {x^/} = decode-lines {**  x^/**^/} {**} {  } ]
	[quote {^/x} = decode-lines {**^/**  x^/} {**} {  } ]
	[quote {^/x^/} = decode-lines {**^/**  x^/**^/} {**} {  } ]
	[quote {x^/  y^/    z} = decode-lines {**  x^/**    y^/**      z^/} {**} {  } ]
]

requirements %line-encoded-blocks.reb [

	['passed = last encode-lines-test]
	['passed = last decode-lines-test]
]