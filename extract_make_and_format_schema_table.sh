#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 db_name"
    exit
fi

influx -execute "SHOW TAG KEYS ON $1;SHOW FIELD KEYS ON $1" | ./make_schema_table.pl | column -s"," -t
