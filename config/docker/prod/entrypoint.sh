#!/bin/bash

cmd="$@"
#RAILS_ENV=production (remover esta variavel)

databaseymlfile='/noosfero/config/database.yml.docker'
if [ -f $databaseymlfile ] ; then
  mv $databaseymlfile /noosfero/config/database.yml
fi

dump_file="/noosfero/dump/${NOOSFERO_DUMP_FILE}"
if [ -f $dump_file ] ; then
  echo ">>>>> DUMP FILE FOUND PREPARING DATABASE <<<<<"
  bundle exec rake db:drop
  bundle exec rake db:create

  echo ">>>>> LOADING DATABASE DUMP <<<<<"
  yes | bundle exec rake restore BACKUP=$dump_file
fi

if bundle exec rake db:exists; then
  echo ">>>>> DATABASE DETECTED APPLYING MIGRATIONS <<<<<"
  bundle exec rake db:migrate
else
  echo ">>>>> NO DATABASE DETECTED CREATING A NEW ONE <<<<<"
  bundle exec rake db:create
  bundle exec rake db:schema:load
  bundle exec rake db:migrate
fi

echo ">>>>> COMPILING ASSETS <<<<<"
bundle exec rake assets:precompile

pidfile='/noosfero/tmp/pids/server.pid'
if [ -f $pidfile ] ; then
	echo 'Server PID file exists. Removing it...'
	rm $pidfile
fi

echo ">>>>> STARTING SERVER <<<<<"
/noosfero/script/production start

exec $cmd
