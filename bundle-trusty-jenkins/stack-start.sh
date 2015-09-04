#!/bin/bash

heat stack-create $1 -f bundle-trusty-jenkins.heat.yml
