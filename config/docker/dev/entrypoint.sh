#!/bin/bash

cmd="$@"

bundle check || bundle install

echo "copying config/database.yml.docker -> config/database.yml"
cp /noosfero/config/database.yml.docker /noosfero/config/database.yml

function_postgres_ready() {
ruby << END
require 'pg'
begin
  PG.connect(dbname: "$POSTGRES_DB", user: "$POSTGRES_USER", password: "$POSTGRES_PASSWORD", host: "postgres")
rescue
  exit -1
else
  exit 0
end
END
}

until function_postgres_ready; do
  >&2 echo "POSTGRES IS UNAVAILABLE, SLEEP"
  sleep 1
done

echo "POSTGRES IS UP, CONTINUE"

if bundle exec rake db:exists; then
  echo "RUNNING MIGRATIONS"
  bundle exec rake db:migrate
else
  echo "SETTING THE DATABASE UP"
  bundle exec rake db:create
  bundle exec rake db:schema:load
  /noosfero/script/sample-data
fi

pidfile='/noosfero/tmp/pids/server.pid'
if [ -f $pidfile ] ; then
  echo 'Server PID file exists. Removing it...'
  rm $pidfile
fi

exec $cmd
