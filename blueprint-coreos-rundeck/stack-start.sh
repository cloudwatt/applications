#!/bin/bash

heat stack-create $1 -f bundle-coreos-rundeck.heat.yml
