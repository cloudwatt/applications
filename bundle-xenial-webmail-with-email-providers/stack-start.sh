#!/bin/bash

heat stack-create $1 -f bundle-xenial-webmail-with-email-providers.heat.yml
