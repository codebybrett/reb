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
; - Nodes which do not contain other nodes and whose data is not a block or paren,
;   may be represented by the value itself as an abbreviation of the tree.
; - If one needs a node type it will need to be part of the data, unless it
;   it can be represented by the value type used as the node.


tree-seq: function [
    {Iterative top down tree visit.}
    queue [block!] {Represents the seqence. Seed with root node.}
][
    node: take queue
    if block? node [insert queue next node]
    node
]


visit-tree: function [
    {Process each tree node.}
    root [block!] {[data child1 child2 ...]}
    eval [block! function!] {Block or function to evaluate each NODE.}
    /strategy {Allows sequence to visit tree to be overridden.}
    take [function!] {TAKE item from queue, building the queue as necessary.}
][
    take: default [:tree-seq]

    if block? :eval [
        eval: func [node] eval
    ]

    queue: reduce [root]

    while [not tail? queue][
        eval take queue
    ]

    root
]

pretty-tree: function [
    {Applies new-line to tree.}
    tree [block!] {[data child1 child2 ...]}
][
    visit-tree tree [
        if block? :node [
            new-line/all next node true
        ]
    ]

    tree
]
