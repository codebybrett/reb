REBOL [
    Title: "Read-Deep Tests"
    Rights: {
        Copyright 2018 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Test READ-DEEP.}
]

script-needs [
	%requirements.reb
    %../read-deep.reb
]


read-deep-test: requirements 'read-deep [

    [
        files: read-deep %../
        all [
            did find files %read-deep.reb
            did find files %test/read-deep.test.reb
        ]
    ]
]


folder-tree-test: requirements 'folder-tree [
    [did find folder-tree %./ %read-deep.test.reb]
    [did find/only folder-tree/full %./ [[%./ %read-deep.test.reb]]]
]


requirements %read-deep.reb [

    ['passed = last read-deep-test]
    ['passed = last folder-tree-test]
]