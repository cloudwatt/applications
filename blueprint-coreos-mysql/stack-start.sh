#!/bin/bash

heat stack-create $1 -f bundle-coreos-mysql.heat.yml
