#!/bin/bash

if [ ! "$2" ]; then
  echo "Usage: ./stack-start.sh STACK_NAME KEYPAIR_NAME"
  exit 1
fi

echo -n "Enter your server's hostname: "
read -r HOSTNAME

echo "
Creating stack..."
heat stack-create $1 -f bundle-trusty-xonotic.heat.yml -P keypair_name="$2" -P server_hostname="$HOSTNAME"
