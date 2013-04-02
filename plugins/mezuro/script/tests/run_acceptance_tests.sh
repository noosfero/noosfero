#!/bin/bash

TEST_FILE=$1
PROFILE=$2

if [ -z "$PROFILE" ]; then
  PROFILE='default'
fi

# where are your .kalibro dir?
KALIBRO_HOME='/usr/share/tomcat6/.kalibro'

# create a kalibro test dir
echo "-->  Creating tests directory"
sudo mkdir $KALIBRO_HOME/tests
echo "-->  Copying test settings"
sudo cp $KALIBRO_HOME/kalibro_test.settings $KALIBRO_HOME/tests/kalibro.settings
echo "-->  Changing owner of tests directory to tomcat6"
sudo chown -R tomcat6:tomcat6 $KALIBRO_HOME/tests

# you must restart tomcat6
#if you are using a tomcat installed from apt-get, for example:
sudo service tomcat6 restart

#if you are using a tomcat installed a specific dir, for exemple:
#~/tomcat6/bin/shoutdown.sh
#~/tomcat6/bin/startup.sh

# run test
cucumber $TEST_FILE -p $PROFILE

#back to normal mode
echo "-->  Removing tests directory"
sudo rm -rf $KALIBRO_HOME/tests

# you must restart tomcat6 again
sudo service tomcat6 restart

#or some thing like that...
#~/tomcat6/bin/shoutdown.sh
#~/tomcat6/bin/startup.sh

