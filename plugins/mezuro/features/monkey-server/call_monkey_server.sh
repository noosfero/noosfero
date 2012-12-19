#!/bin/bash

MONKEY_SERVER_ADDRESS="localhost"
MONKEY_SERVER_PORT=50688

# Ignore errors from all commands
trap "" ERR

exec 5<>/dev/tcp/$MONKEY_SERVER_ADDRESS/$MONKEY_SERVER_PORT
echo "SCENARIO $1" >&5
echo "SCENARIO $1"
