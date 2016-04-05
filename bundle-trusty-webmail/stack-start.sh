#!/bin/bash

if [ ! "$2" ]; then
  echo "Usage $0 stack_name keypair_name mysql_password postfix_admin_pass mail_domain"
  echo "if you want to use the default parameters ,use $0 stack_name keypair_name "
  exit 1
fi

if [ $# -eq 5 ]

then

heat stack-create $1 -f bundle-trusty-webmail.heat.yml -Pkeypair_name=$2 -Pmysql_password=$3 -Ppostfix_admin_pass=$4 -Pmail_domain=$5

else

heat stack-create $1 -f bundle-trusty-webmail.heat.yml -Pkeypair_name=$2

fi
