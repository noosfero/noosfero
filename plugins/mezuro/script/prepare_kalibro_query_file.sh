#!/bin/bash

source plugins/mezuro/script/kalibro_scripts.conf

sudo su postgres -c "export PGPASSWORD=$PASSWORD &&
                     if [ -f $QUERYFILE ]
                        then rm $QUERYFILE
                     fi &&
                     psql -q -t -d $DATABASE -c \"SELECT 'DELETE FROM ' || n.nspname || '.' || c.relname || ' CASCADE;' FROM pg_catalog.pg_class AS c LEFT JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace WHERE relkind = 'r' AND n.nspname NOT IN ('pg_catalog', 'pg_toast') AND pg_catalog.pg_table_is_visible(c.oid)\" | sed '/$EXCEPTION/d' | sort > $QUERYFILE"
