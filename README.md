# Influx-Schema-Table-Maker
Create a readable table of the schema from an Influx database.



## Introduction
InfluxDB, being a schema-less database, does not require a schema definition. It is useful however, to know what the schema is at any point in time. Influx's built-in tools do not it easy to grasp the schema.

These scripts extract the schema from an Influx database, create a nicely arranged (ie. compact, clear, structured) csv, and then render it in an easy to read ASCII format.

## Usage
1. Run `SHOW TAG KEYS ON db;SHOW FIELD KEYS ON db` at the Influx CLI prompt, where `db` is the name of your database.
1. Pipe the result into `make_schema_table.pl` to make the csv.
1. Pipe the result into `column -s"," -t` to format it nicely.

To do all three steps at once, use `./extract_make_and_format_schema_table.sh db`, where `db` is the name of your database.
