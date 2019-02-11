#!/bin/bash
set -e

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

dump_file="/noosfero/dump/${NOOSFERO_DUMP_FILE}"
if [ -f $dump_file ]; then
  echo ">>>>> DUMP FILE FOUND PREPARING DATABASE <<<<<"
  bundle exec rake db:drop
  bundle exec rake db:create

  echo ">>>>> LOADING DATABASE DUMP <<<<<"
  yes | bundle exec rake restore BACKUP=$dump_file
fi

if ! bundle exec rake db:exists; then
  echo ">>>>> NO DATABASE DETECTED CREATING A NEW ONE <<<<<"
  bundle exec rake db:create
fi

if ! bundle exec rake db:tables:exists; then
  echo ">>>>> NO DATABASE TABLES DETECTED LOADING SCHEMA <<<<<"
  bundle exec rake db:schema:load
  echo ">>>>> CREATING DEFAULT ENVIRONMENT AND ADMIN USER <<<<<"
  bundle exec rake db:data:minimal
fi

echo ">>>>> DATABASE DETECTED APPLYING MIGRATIONS <<<<<"
bundle exec rake db:migrate

echo ">>>>> PID VERIFICATION <<<<<"
pidfile='/noosfero/tmp/pids/server.pid'
if [ -f $pidfile ] ; then
  echo 'Server PID file exists. Removing it...'
  rm $pidfile
fi

echo ">>>>> COMPILING ASSETS <<<<<"
bundle exec rake assets:precompile

exec "$@"
