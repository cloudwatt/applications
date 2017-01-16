#!/bin/bash

if [ ! "$1" ]; then
  echo "Usage: ./minecraft-server-address.sh STACK_NAME"
  exit 1
fi

floating_id=$(openstack stack resource list Maxence-MC | grep "OS::Neutron::FloatingIP" | awk '{print $4}')
floating_ip=$(openstack floating ip show ${floating_id} | grep "floating_ip_address" | awk '{print $4}')

echo $1 "${floating_ip}"
