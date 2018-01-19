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
    root [file! url!]
    /full {Includes root path and retains full paths instead returning relative paths.}
    /into {Insert into a buffer instead (returns position after insert)}
    result [block!] {The buffer series (modified)}
    /strategy {Allows Queue building to be overridden.}
    take [function!] {TAKE next item from queue, building the queue as necessary.}
][
    unless into [result: make block! []]
    unless strategy [take: :read-deep-seq]

    queue: reduce [root]

    while [not tail? queue][
        path: take queue
        append result :path ; Possible void.
    ]

    unless full [
        remove result ; No need for root in result.
        len: length of root
        foreach path result [
            remove/part path len
        ]
    ]

    unless tail? result [new-line/all result true]
    either into [tail result] [result]
]
