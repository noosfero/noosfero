#!/bin/bash

source plugins/mezuro/script/tests/kalibro_scripts.conf

DROPLIMIT="END OF DROP TABLES"
RANGE=$(grep -n "$DROPLIMIT" $PSQLFILE | cut -d":" -f1)
START=1
END=$(($RANGE - 1))
CUT=$START,$END\!d
REPLACE="s/DROP TABLE IF EXISTS sequences,/TRUNCATE/"

if [ -f $QUERYFILE ]
  then sudo rm $QUERYFILE
fi

sed -e "$CUT" -e "$REPLACE" $PSQLFILE > $QUERYFILE
sudo chown postgres.postgres $QUERYFILE
