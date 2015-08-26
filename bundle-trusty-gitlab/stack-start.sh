#!/bin/bash

if [ ! "$1" ]
  echo "\
Usage: ./stack-start.sh STACK_NAME [BACKUP_ID]

Include backup ID only when restoring from backup."
fi

if [ ! "$2" ]
  heat stack-create "$1" -f bundle-trusty-gitlab.heat.yml
else
  heat stack-create "$1" -f bundle-trusty-gitlab.restore.heat.yml -P backup_id="$2"
if
