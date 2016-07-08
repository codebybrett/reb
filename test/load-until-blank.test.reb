REBOL [
    Title: "Load-Until-Blank - Tests"
    Version: 1.0.0
    Rights: {
        Copyright 2015 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
]

script-needs [
    %requirements.reb
    %../load-until-blank.reb
]

requirements %load-until-blank [

    [blank? load-until-blank {}]
    [[[1 [2]] ""] = load-until-blank {1 [2]^/}]
    [[[1 [2]] "rest"] = load-until-blank "1 [2]^/^/rest"]
]
