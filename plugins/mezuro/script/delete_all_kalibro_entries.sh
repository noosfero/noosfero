#!/bin/bash

DATABASE="kalibro_test"

sudo su postgres -c "export PGPASSWORD=\"kalibro\" && psql -q -t -d $DATABASE -c \"SELECT 'DELETE FROM ' || n.nspname || '.' || c.relname || ' CASCADE;' FROM pg_catalog.pg_class AS c LEFT JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace WHERE relkind = 'r' AND n.nspname NOT IN ('pg_catalog', 'pg_toast') AND pg_catalog.pg_table_is_visible(c.oid)\" | sed '/sequences/d' > /tmp/query && psql -q -d $DATABASE -f /tmp/query && rm /tmp/query"
