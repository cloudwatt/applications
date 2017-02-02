#!/bin/bash

if [ ! "$1" ]; then
  echo "Usage: ./stack-start.sh STACK_NAME"
  exit 1
fi

heat stack-create $1 -f bundle-centos-backbee.heat.yaml
