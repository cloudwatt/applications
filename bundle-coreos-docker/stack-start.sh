#!/bin/bash

heat stack-create $1 -f bundle-coreos-docker.heat.yml
