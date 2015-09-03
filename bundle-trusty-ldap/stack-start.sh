#!/bin/bash

if [ ! "$2" ]; then
  echo "\
Usage: ./stack-start.sh STACK_NAME KEYPAIR_NAME [BACKUP_ID]

Include backup ID only when restoring from backup."
fi

if [ ! "$3" ]; then
  heat stack-create $1 -f bundle-trusty-ldap.heat.yml -P keypair_name="$2"
else
  heat stack-create $1 -f bundle-trusty-ldap.restore.heat.yml -P keypair_name="$2" -P backup_id="$3"
fi
