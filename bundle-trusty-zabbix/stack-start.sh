#!/bin/bash

heat stack-create $1 -f bundle-trusty-zabbix.heat.yml -Pkeypair_name=$2
