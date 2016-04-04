#!/bin/bash
if [ $# -eq 4 ]

then

heat stack-create $1 -f bundle-freebsd-pfsense.heat.yml -Pkeypair_name="$2" -Pprivate_net_cidr="$3" -Ppublic_net_cidr="$4"

else

echo "usage $0 stack_name keypair_name private_net_cidr public_net_cidr"

fi
