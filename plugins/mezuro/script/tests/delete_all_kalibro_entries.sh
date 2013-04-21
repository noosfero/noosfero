#!/bin/bash

source plugins/mezuro/script/tests/kalibro_scripts.conf

sudo su postgres -c "export PGPASSWORD=$PASSWORD && psql -q -d $DATABASE -f $QUERYFILE"
