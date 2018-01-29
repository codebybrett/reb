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

    [quote {**^/} = encode-lines copy {} {**} {  }]
    [quote {**  x^/} = encode-lines copy {x} {**} {  }]
    [quote {**  x^/**^/} = encode-lines copy {x^/} {**} {  }]
    [quote {**^/**  x^/} = encode-lines copy {^/x} {**} {  }]
    [quote {**^/**  x^/**^/} = encode-lines copy {^/x^/} {**} {  }]
    [quote {**  x^/**    y^/**      z^/} = encode-lines copy {x^/  y^/    z} {**} {  }]
    [quote "**^/**^/**^/" = encode-lines copy {^/^/} {**} {  }]
]

decode-lines-test: requirements 'decode-lines [

    [quote {} = decode-lines copy {} {**} {} ]
    [quote {} = decode-lines copy {**^/} {**} {  } ]
    [quote {x} = decode-lines copy {**  x^/} {**} {  } ]
    [quote {x^/} = decode-lines copy {**  x^/**^/} {**} {  } ]
    [quote {^/x} = decode-lines copy {**^/**  x^/} {**} {  } ]
    [quote {^/x^/} = decode-lines copy {**^/**  x^/**^/} {**} {  } ]
    [quote {x^/  y^/    z} = decode-lines copy {**  x^/**    y^/**      z^/} {**} {  } ]
    [quote {^/^/} = decode-lines copy "**^/**  ^/**^/" {**} {  }]
    [quote {^/^/} = decode-lines copy "**^/**^/**^/" {**} {  }]
]

lines-exceeding-test: requirements 'lines-exceeding [

    [blank? lines-exceeding 0 {}]
    [blank? lines-exceeding 1 {}]
    [[1] = lines-exceeding 0 {x}]
    [[2] = lines-exceeding 0 {^/x}]
]

text-line-of-test: requirements 'text-line-of [

    [blank? text-line-of {}]
    [1 = text-line-of {x}]
    [1 = text-line-of next {x^/}]
    [2 = text-line-of next next {x^/y}]
    [2 = text-line-of next next {x^/y^/z}]
    [2 = text-line-of next next next {x^/y^/}]
    [2 = text-line-of next next next {x^/y^/z}]
]

requirements %text-lines.reb [

    ['passed = last encode-lines-test]
    ['passed = last decode-lines-test]
    ['passed = last lines-exceeding-test]
    ['passed = last text-line-of-test]
]