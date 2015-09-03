#!/bin/bash

if [ ! "$2" ]; then
  echo "\
Usage: ./stack-start.sh STACK_NAME SUBNET_ID KEYPAIR_NAME [BACKUP_ID]
Include backup ID only when restoring from backup.
"
  exit 1
fi

if [ ! "$4" ]; then
  heat stack-create $1 -f bundle-trusty-ldap.heat.yml -P subnet_id="$2" -P keypair_name="$3"
else
  heat stack-create $1 -f bundle-trusty-ldap.restore.heat.yml -P subnet_id="$2" -P keypair_name="$3" -P backup_id="$4"
fi
