#!/bin/bash

heat stack-create $1 -f bundle-trusty-duplicity.heat.yml
