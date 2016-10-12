#!/bin/bash

heat stack-create $1 -f bundle-xenial-zabbix.heat.yml -Pkeypair_name=$2
