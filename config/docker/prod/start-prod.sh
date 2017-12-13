#!/bin/bash

databaseymlfile='/noosfero/config/database.yml.docker'
if [ -f $databaseymlfile ] ; then
  mv $databaseymlfile /noosfero/config/database.yml
fi

dump_file="/dump/${NOOSFERO_DUMP_FILE}"
if [ -f $dump_file ] ; then
  echo ">>>>> DUMP FILE FOUND PREPARING DATABASE <<<<<"
  RAILS_ENV=production bundle exec rake db:drop
  RAILS_ENV=production bundle exec rake db:create

  echo ">>>>> LOADING DATABASE DUMP <<<<<"
  yes | RAILS_ENV=production bundle exec rake restore BACKUP=$dump_file
fi

if RAILS_ENV=production bundle exec rake db:exists; then
  echo ">>>>> DATABASE DETECTED APPLYING MIGRATIONS <<<<<"
  RAILS_ENV=production bundle exec rake db:migrate
else
  echo ">>>>> NO DATABASE DETECTED CREATING A NEW ONE <<<<<"
  RAILS_ENV=production bundle exec rake db:create
  RAILS_ENV=production bundle exec rake db:schema:load
  RAILS_ENV=production bundle exec rake db:migrate
fi

echo ">>>>> COMPILING ASSETS <<<<<"
RAILS_ENV=production bundle exec rake assets:precompile

pidfile='/noosfero/tmp/pids/server.pid'
if [ -f $pidfile ] ; then
	echo 'Server PID file exists. Removing it...'
	rm $pidfile
fi

echo ">>>>> STARTING SERVER <<<<<"
/noosfero/script/production start
tail -f /dev/null
