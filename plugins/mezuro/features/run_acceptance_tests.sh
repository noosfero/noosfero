#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MEZURO_HOME="$DIR/.."


echo $MEZURO_HOME

# Ignore errors from all commands
trap "" ERR

# Change Kalibro Service
echo "http://localhost:8080/KalibroTest/" > "$MEZURO_HOME/service.yml"
echo "Changed Kalibro Service"

# Run acceptance test
if [ "$1" == "" ];  then
  rake test:noosfero_plugins:cucumber:enabled
else
  /usr/bin/ruby1.8 -S cucumber $1
fi
#cat "$MEZURO_HOME/service.yml"

mysql -h lua -u kalibro -pkalibro2012p4ss -D 'kalibro_test' < $MEZURO_HOME/features/clean_kalibro_db.sql

# Change back Kalibro Service
echo "http://localhost:8080/KalibroService/" > "$MEZURO_HOME/service.yml"
echo "Changed back Kalibro Service"
#cat "$MEZURO_HOME/service.yml"

