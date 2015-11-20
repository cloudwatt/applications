#!/bin/bash

heat stack-create $1 -f bundle-trusty-tomcat7.heat.yml
