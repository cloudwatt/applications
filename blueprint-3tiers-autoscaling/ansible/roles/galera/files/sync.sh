#!/bin/bash

SERVER=node0
PORT=4567
</dev/tcp/$SERVER/$PORT 2>/dev/null

if [ "$?" -ne 0 ]; then

echo "Connection to $SERVER on port $PORT failed"

exit 1

else
</dev/tcp/localhost/3306 2>/dev/null

if [ "$?" -ne 0 ]; then

echo "Connection to $SERVER on port $PORT succeeded and local mysql is down"

/etc/init.d/mysql start

echo "Connection to $SERVER on port $PORT succeeded"

else


echo "mysql is up"

fi


fi
