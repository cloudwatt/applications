#!/bin/bash

heat stack-create $1 -f bundle-xenial-wordpress.heat.yml
