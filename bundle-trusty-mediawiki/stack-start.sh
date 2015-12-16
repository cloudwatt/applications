#!/bin/bash

heat stack-create $1 -f bundle-trusty-mediawiki.heat.yml
