#!/bin/bash

heat stack-create $1 -f bundle-xenial-glusterfs-multi-dc-fr1.heat.yml 
