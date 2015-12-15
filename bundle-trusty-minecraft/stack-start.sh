#!/bin/bash

if [ ! "$2" ]; then
  echo "Usage: ./stack-start.sh STACK_NAME KEYPAIR_NAME"
  exit 1
fi

USERNAME="NEW"
while [ "$USERNAME" != "$USER_CHECK" ]; do
  echo -n "Enter the username of the first admin: "
  read -r USERNAME
  echo -n "
Enter the admin username again:  "
  read -r USER_CHECK

  if [ "$USERNAME" != "$USER_CHECK" ]; then
    echo "
Verification failed, usernames didn't match."
  fi
done

echo "
Creating stack..."
heat stack-create $1 -f bundle-trusty-minecraft.heat.yml -P keypair_name="$2" -P admin_username="$USERNAME"
