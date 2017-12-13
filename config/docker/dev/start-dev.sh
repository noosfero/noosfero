#!/bin/bash

databaseymlfile='/noosfero/config/database.yml.docker'
if [ -f $databaseymlfile ] ; then
  mv $databaseymlfile /noosfero/config/database.yml
fi

bundle check || bundle install

if bundle exec rake db:exists; then
  bundle exec rake db:migrate
else
  bundle exec rake db:create
  bundle exec rake db:schema:load
  /noosfero/script/sample-profiles
fi

pidfile='/noosfero/tmp/pids/server.pid'
if [ -f $pidfile ] ; then
	echo 'Server PID file exists. Removing it...'
	rm $pidfile
fi

bundle exec rails s -b 0.0.0.0
