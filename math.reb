REBOL [
    Title: "Math"
    Rights: {
        Copyright 2016 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Implement a simple Math function that supports precedence using a Pratt parser.}
]

math: function [
    {Evaluate math expression with standard precedence.}
    expression [block! paren!]
    /only {Translate the expression only.}
] [

    recurse: func [
        {Parses expression at binding power and above.}
        rbp [integer!] {Right Binding Power.}
        /opt {Expression is optional.}
        /local
        left ; Accumulation variable.
        this ; Token whose code is executing.
        code ; Code of the token to evaluate.
        lbp ; Left binding power of token.
    ][

        unset [left]

        if tail? expression [
            do make error! {Expected an expression.}
        ]

        this: first expression

        code: to-value case [

            '- = :this [
                [negate (recurse 100)]
            ]

            '+ = this [
                [(recurse 100)]
            ]

            any [
                number? :this
                word? :this
                path? :this
            ] [
                [(:this)]
            ]

            paren? :this [
                [(to paren! math/only :this)]
            ]

            block? :this [
                [(to paren! :this)]
            ]
        ]

        if blank? code [
            do make error! {Expected argument or unary operators + or -.}
        ]

        expression: next expression

        left: compose code

        ; Process any remaining expression tokens.
        while [
            lbp: any [
                select [+ 10 - 10 * 20 / 20 ** 30] expression/1
                0
            ]
            lbp > rbp
        ] [

            this: first expression

            code: select [
                + [add (left) (recurse lbp)]
                - [subtract (left) (recurse lbp)]
                * [multiply (left) (recurse lbp)]
                / [divide (left) (recurse lbp)]
                ** [power (left) (recurse lbp - 1)]
            ] :this

            expression: next expression

            left: compose code
        ]

        RETURN left
    ]

    result: recurse 0

    if not tail? expression [
        do make error! {Expected a single expression.}
    ]

    either only [result][do result]
]
