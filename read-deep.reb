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

;; read-deep provide convenience over read-deep-seq.
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
        append result :path ; Possible void.
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
