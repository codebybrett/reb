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

    [did files: read-deep %../]
    [did find files %read-deep.reb]
    [did find files %test/read-deep.test.reb]
]


file-tree-test: requirements 'folder-tree [

    [
        %./ = first file-tree %./
    ]

    [
        did find file-tree %./ %read-deep.test.reb
    ]
]


read-tree-test: requirements 'folder-tree [

    [
        [%./ %"" %./] = first read-tree %./
    ]

    [
        did find/only read-tree %./ [[%./ %"" %read-deep.test.reb]]
    ]
]

requirements %read-deep.reb [

    ['passed = last read-deep-test]
    ['passed = last file-tree-test]
    ['passed = last read-tree-test]
]