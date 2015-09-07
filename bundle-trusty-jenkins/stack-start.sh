#!/bin/bash

if [ ! "$2" ]; then
  echo "Usage: ./stack-start.sh STACK_NAME KEYPAIR_NAME"
  exit 1
fi

echo -n "Enter your new Basic Auth username: "
read -r  USERNAME

PASSWORD="NEW"
while [ "$PASSWORD" != "$PW_CHECK" ]; do
  echo -n "Enter your new Basic Auth password: "
  read -rs PASSWORD
  echo -n "
Enter your new password once more:  "
  read -rs PW_CHECK

  if [ "$PASSWORD" != "$PW_CHECK" ]; then
    echo "
Verification failed, passwords didn't match."
  fi
done

echo "
Creating stack..."
heat stack-create $1 -f bundle-trusty-jenkins.heat.yml -P keypair_name="$2" -P username="$USERNAME" -P password="$PASSWORD"
