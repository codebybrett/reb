REBOL [
	Title: "Tree"
    Rights: {
        Copyright 2018 Brett Handley
    }
	License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
	Author: "Brett Handley"
	Purpose: "A tree structure."
]

; In this tree structure:
;
; - A tree node consists of data and zero or many child tree nodes.
; - The first value in a block node is the node data,
;   subsequent items are the child nodes.
; - Every node that contains other nodes is a block.
; - If one needs a node type it will need to be part of the data, unless it
;   it can be represented by the node type itself.
; - Nodes which do not contain other nodes and whose data is not a block or paren,
;   may be represented by the value itself as an abbreviation of the tree.


visit-tree: function [
    {Visit each tree node evaluating it.}
    root [block!] {[data child1 child2 ...]}
    eval [block! function!] {Block or function to evaluate each NODE.}
    /strategy {Allows sequence to visit tree to be overridden.}
    sequence [function!] {TAKE item from queue, building the queue as necessary.}
][
    unless strategy [
        sequence: function [
            {Iterative top down tree visit.}
            queue [block!] {Represents the seqence. Seed with node.}
        ][
            node: take queue
            if block? node [insert queue next node]
            node
        ]
    ]

    if block? :eval [
        eval: func [node] eval
    ]

    queue: reduce [root]

    while [not tail? queue][
        eval sequence queue
    ]

    tree
]

pretty-tree: function [
    {Applies new-line to tree.}
    tree [block!] {[data child1 child2 ...]}
][
    visit-tree tree [
        new-line/all next node true
    ]
]
