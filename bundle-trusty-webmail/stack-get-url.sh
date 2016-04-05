#!/bin/bash


if [ $# -eq 4 ]

then

  heat stack-create $1 -f bundle-trusty-webmail.heat.yml -P keypair_name="$2" -P mysql_password="$3" -P postfix_admin="$4"

else

echo "usage $0 stack_name keypair_name mysql_password postfix_admin_pass"

fi
