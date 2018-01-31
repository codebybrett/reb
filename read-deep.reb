REBOL [
    Title: "Read-deep"
    Rights: {
        Copyright 2018 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: "Recursive READ strategies."
]

;; read-deep-seq aims to be as simple as possible. I.e. relative paths
;; can be derived after the fact.  It uses a state to next state approach
;; which means client code can use it iteratively which is useful to avoid
;; reading the full tree up front, or for sort/merge type routines.
;; The root (seed) path is included as the first result.
;; Output can be made relative by stripping the root (seed) path from
;; each returned file.
;;

read-deep-seq: function [
    {Process next file in queue, adding next steps to queue.}
    queue [block!]
][
    item: take queue

    if equal? #"/" last item [
        insert queue map-each x read item [join-of item x]
    ]

    item
]

;; read-deep provides convenience over read-deep-seq.
;;

read-deep: function [
    {Read file or url including subfolders.}
    root [file! url! block!]
    /full {Includes root path and retains full paths instead returning relative paths.}
    /strategy {Allows Queue building to be overridden.}
    take [function!] {TAKE next item from queue, building the queue as necessary.}
][
    take: default [:read-deep-seq]

    result: make block! []

    queue: compose [(root)]

    while [not tail? queue][
        path: take queue
        append result :path ; Voids filtered out.
    ]

    unless full [
        remove result ; No need for root in result.
        len: length of root
        for i 1 length of result 1 [
            ; Strip off root path from locked paths.
            poke result i copy skip result/:i len
        ]
    ]

    result
]

;; Builds a tree suitable for adding attributes.
;; Node data contains the read argument and an item returned from the read.

grow-read-tree: function [
    {Grow next tree node in queue, where each node represents a file or folder.}
    return: [<opt> block!]
    queue [block!]
] [

    node: take queue

    ; Take node as input.
    data: node/1
    source: either %./ = data/1 [data/2][join-of data/1 data/2]

    ; Add any node children.
    if equal? #"/" last source [

        ; Add node children.
        child-nodes: map-each x read source [
            data: reduce [source x]
            reduce [data] ; New node.
        ]
        append node child-nodes
        new-line/all next node true

        ; Process children next.
        insert queue child-nodes
    ]

    node ; return current work item.
]

;; Builds a concise tree suitable for displaying structure.
;;

grow-file-tree: function [
    {Grow next tree node in queue, where each node represents a file or folder.}
    return: [<opt> block!]
    queue [block!]
] [

    node: take queue

    ; Take node as input.
    data: node/1
    if not equal? #"/" last data/2 [
        fail ["Expected queue of folders only."]
    ]

    source: either %./ = data/1 [data/2][join-of data/1 data/2]

    ; Finalise folder data.
    poke node 1 data/2

    ; Add node children.
    child-nodes: map-each x read source [
        either equal? #"/" last x [
            data: reduce [source x] ; Node data.
            child: reduce [data] ; Child node.
            insert/only queue child ; Only folder nodes are queued.
        ][
            child: x
        ]
        child
    ]
    append node child-nodes
    new-line/all next node true

    node ; return current work item.
]

;; Build a folder tree.
;;

folder-tree: function [
    {Return a folder tree from a deep read.}
    root [file! url!] "Seed path."
    /full {Returns a tree suitable for attributes.}
][

    take: either full [:grow-read-tree] [:grow-file-tree]

    tree: reduce [
        reduce [%./ root]
    ]
    
    queue: reduce [tree]

    while [not tail? queue][
        take queue
    ]

    tree
]
