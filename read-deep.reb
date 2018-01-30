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
    {Iterative read deep.}
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
    {Return files and folders using recursive read strategy.}
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

;; Tree result.
;; Note: Could be processed by visit-tree.
;; TODO: How to handle context of the paths, if wanting to linearise it.

read-tree: function [
    {Return a tree from a deep read.}
    path [file! url!]
][

    recurse: function [
        path
    ][

        tree: read path
        
        insert/only tree last split-path path 

        for i 2 length? tree 1 [
            item: pick tree i
            if #"/" = last item [
                poke tree i recurse join-of path :item
            ]
        ]

        new-line/all tree true
    ]

    tree: recurse path

    poke tree 1 clean-path path ; A useful first path value.

    new-line tree true
]

; Want differnt flavours of file tree.


read-tree-seq: function [
    {Process next node in queue, building queue with new nodes to grow.}
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
]

folder-structure-seq: function [
    {Process next node in queue, building queue with new nodes to grow.}
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
            data: reduce [source x]
            insert/only queue child: reduce [data]
        ][
            child: x
        ]
        child
    ]
    append node child-nodes
    new-line/all next node true
]

file-tree: function [
    {Return a tree from a deep read.}
    root [file! url!] "Seed path."
    /strategy {Allows Queue building to be overridden.}
    take [function!] {TAKE next item from queue, building the queue as necessary.}
][

    take: default [:read-tree-seq]

    tree: reduce [
        reduce [%./ root]
    ]
    
    queue: reduce [tree]

    while [not tail? queue][
        take queue
    ]

    tree
]


;; To what extent is this a grow-tree operation and is seeding the queue
;; so specialised that it needs a dedicated file tree function?

;; How to write a sequence which returns a read deep list from  one of the
;; above two file trees?
