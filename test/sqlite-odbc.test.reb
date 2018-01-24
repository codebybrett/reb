REBOL [
    Title: "ODBC - Tests"
    Version: 1.0.0
    Rights: {
        Copyright 2017 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Comment: {

        Testing REN-C port of work from https://github.com/gurzgri/r3-odbc

        See Sqlite ODBC driver: http://www.ch-werner.de/sqliteodbc/
    }
]

script-needs [
    %requirements.reb
]

test-db: clean-path %test.s3db

connection-string: join-all [
    {DSN=SQLite3 Datasource;Database=} (file-to-local test-db)
]

odbc-spec: compose [
    scheme: 'ODBC
    target: (connection-string)
]

requirements 'sqlite-odbc [

    [{Open/Close Connection}
        attempt [
            connection: open odbc-spec
            close connection
            attempt [delete test-db]
            true
        ]
    ]
]

