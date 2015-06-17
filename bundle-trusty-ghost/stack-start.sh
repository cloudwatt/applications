#!/bin/bash

heat stack-create $1 -f bundle-trusty-ghost.heat.yml
