REBOL [
    Title: "Extract Parse"
    Rights: {
        Copyright 2018 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: "Extracting data from parse trees."
]

script-needs [
    %get-parse-tree.reb
]

extract-parse: function [
    {Extract rules and data structure from a tree returned by get-parse-tree.}
    tree [block!] {[data child1 child2 ...] (modifies.)}
][
    visit-tree tree [
        properties: node/1
        either all [
            1 = length of node
            len: properties/3
            pos: properties/4
        ] [
            data: reduce [properties/2 copy/part pos len]
        ] [
            data: properties/2
        ]
        change node data
    ]
]