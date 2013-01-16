#!/bin/bash

COMMAND_TEST = $1

# where are your .kalibro dir?
KALIBRO_HOME= ~/.kalibro

# create a kalibro test dir
mkdir $KALIBRO_HOME/tests
cp $KALIBRO_HOME/kalibro_tests.settings $KALIBRO_HOME/tests/kalibro.settings

# you must restart tomcat6
#if you are using a tomcat installed from apt-get, for example:
#sudo service tomcat6 restart

#if you are using a tomcat installed a specific dir, form exemplo:
#~/tomcat6/bin/shoutdown.sh
#~/tomcat6/bin/startup.sh

# run test
COMMAND_TEST

#back to normal mode
rm -rf $KALIBRO_HOME/tests

# you must restart tomcat6 again
#sudo service tomcat6 restart
