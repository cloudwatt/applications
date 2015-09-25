#!/bin/bash

RESOURCE_LIST="$(heat resource-list $1)"
if [ -z "$RESOURCE_LIST" ]; then
  echo "ERROR: Heat client cannot find a stack of that name"
  exit 1
fi

URL="https://$(heat resource-list $1 | grep floating_ip_link | tr -d " " | cut -d "|" -f3 | rev | cut -d "-" -f1 | rev)"

echo ""
echo "STACK   $1"
echo "URL     $URL"
echo "INSTALL $URL/install.php"
echo ""
