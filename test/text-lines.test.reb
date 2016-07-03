REBOL [
	Title: "Text Lines - Tests"
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
	%../text-lines.reb
]

encode-lines-test: requirements 'encode-lines [

	[quote {**^/} = encode-lines {} {**} {  }]
	[quote {**  x^/} = encode-lines {x} {**} {  }]
	[quote {**  x^/**^/} = encode-lines {x^/} {**} {  }]
	[quote {**^/**  x^/} = encode-lines {^/x} {**} {  }]
	[quote {**^/**  x^/**^/} = encode-lines {^/x^/} {**} {  }]
	[quote {**  x^/**    y^/**      z^/} = encode-lines {x^/  y^/    z} {**} {  }]
	[quote "**^/**^/**^/" = encode-lines {^/^/} {**} {  }]
]

decode-lines-test: requirements 'decode-lines [

	[quote {} = decode-lines {} {**} {} ]
	[quote {} = decode-lines {**^/} {**} {  } ]
	[quote {x} = decode-lines {**  x^/} {**} {  } ]
 	[quote {x^/} = decode-lines {**  x^/**^/} {**} {  } ]
	[quote {^/x} = decode-lines {**^/**  x^/} {**} {  } ]
	[quote {^/x^/} = decode-lines {**^/**  x^/**^/} {**} {  } ]
	[quote {x^/  y^/    z} = decode-lines {**  x^/**    y^/**      z^/} {**} {  } ]
	[quote {^/^/} = decode-lines "**^/**  ^/**^/" {**} {  }]
	[quote {^/^/} = decode-lines "**^/**^/**^/" {**} {  }]
]

lines-exceeding-test: requirements 'lines-exceeding [

	[blank? lines-exceeding 0 {}]
	[blank? lines-exceeding 1 {}]
	[[1] = lines-exceeding 0 {x}]
	[[2] = lines-exceeding 0 {^/x}]
]

line-of-test: requirements 'line-of [

	[blank? line-of {} 0]
	[1 = line-of {x} 1]
	[1 = line-of {x^/} 2]
	[2 = line-of {x^/y} 3]
]

requirements %text-lines.reb [

	['passed = last encode-lines-test]
	['passed = last decode-lines-test]
	['passed = last lines-exceeding-test]
	['passed = last line-of-test]
]