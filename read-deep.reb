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


;; Builds a tree suitable for storing attributes.
;; - One can compose/deep this tree to yield a concise file tree.
;; It is not clear that this sequence idea composes convienently.
;; E.g. Should void DATA or SOURCE be a filter for nodes - may want to exclude some results.
;;      Should void CHILD be a filter - need to avoid reads on some folders.
;;      - and of course every child is a node
;; It's possible to not take the first item from the queue and just rewrite it
;; allowing a following sequence function to take it. One could chain these, but
;; then there will be two different type of queue processing functions, ones that perform a
;; take and those that just poke the first item.
;; And Should read by wrapped by attempt for specific situations?

grow-read-tree: function [
    {Grow next tree node in queue, where each node represents a file or folder.}
    return: [block!]
    queue [block!]
] [

    node: take queue

    ; Take node as input.
    data: node/1
    if not equal? #"/" last data/2 [
        fail ["Expected queue of folders got:" mold data/2]
    ]

    source: either %./ = data/1 [data/2][join-of data/1 data/2]

    ; Finalise folder data.
    ; ...

    ; Add node children.
    child-nodes: map-each x read source [
        data: reduce [source x]
        either equal? #"/" last x [
            child: reduce [as group! data]
            insert/only queue child ; Only folder nodes are queued.
        ][
            child: as group! data
        ]
        child
    ]
    append node child-nodes
    new-line/all next node true

    node ; return current work item.
]


read-tree: function [
    {Return a concise tree from a deep read.}
    root [file! url!] "Seed path."
][

    tree: reduce [
        as group! reduce [%"" root]
    ]

    take: :grow-read-tree
   
    queue: reduce [tree]

    while [not tail? queue][
        take queue
    ]

    tree
]


;; Builds a concise tree suitable for displaying folder structure.
;; - This can also be obtained by using compose/deep on read-tree,
;;   but this version does less work.
;;

grow-file-tree: function [
    {Grow next tree node in queue, where each node represents a file or folder.}
    return: [block!]
    queue [block!]
] [

    node: take queue

    ; Take node as input.
    data: node/1
    if not equal? #"/" last data/2 [
        fail ["Expected queue of folders got:" mold data/2]
    ]

    source: either %./ = data/1 [data/2][join-of data/1 data/2]

    ; Finalise folder data.
    poke node 1 data/2

    ; Add node children.
    child-nodes: map-each x read source [
        either equal? #"/" last x [
            data: reduce [source x]
            child: reduce [as group! data]
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


file-tree: function [
    {Return a concise tree from a deep read.}
    root [file! url!] "Seed path."
][

    tree: reduce [
        reduce [%"" root]
    ]

    take: :grow-file-tree
   
    queue: reduce [tree]

    while [not tail? queue][
        take queue
    ]

    tree
]
