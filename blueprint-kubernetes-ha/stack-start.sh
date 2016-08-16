#!/bin/bash
echo "Blueprint Kubernetes HA"
echo "-----------------------"
if [[ -z "$OS_PASSWORD" ]]
then
  cat <<EOF
  You must set OS_USERNAME / OS_PASSWORD / OS_TENANT_NAME / OS_AUTH_URL ...
  The simple way to do this is to follow theses instructions:

  - Bring your Cloudwatt credentials and go to this url : https://console.cloudwatt.com/project/access_and_security/api_access/openrc/
  - If you are not connected, fill your Cloudwatt username / password
  - A file suffixed by openrc.sh will be downloaded, once complete, type in your terminal :
    source COMPUTE-[...]-openrc.sh
EOF
  exit 1
fi
cat <<EOF
Openstack credentials :
Username: $OS_USERNAME
Password: *************
Tenant name: $OS_TENANT_NAME
Authentication url: $OS_AUTH_URL
Region: $OS_REGION_NAME
-----------------------
EOF
KEYS=$(nova keypair-list | egrep '\|.*' | tail -n +2 | cut -d' ' -f 2)
echo "What is your keypair name ?"
select KEYPAIR in $KEYS
do
  echo "Key selected: $KEYPAIR"
  break;
done
echo "How do you want to name this stack ?"
read NAME
heat stack-create -f $OS_REGION_NAME/stack.yml -P keypair_name=$KEYPAIR -P os_username=$OS_USERNAME -P os_password=$OS_PASSWORD -P os_tenant=$OS_TENANT_NAME -P os_auth=$OS_AUTH_URL $NAME
until heat stack-show $NAME | egrep 'CREATE_COMPLETE|CREATE_FAILED' &> /dev/null
do
  echo "Waiting for stack to be ready..."
  sleep 10
done
if heat stack-show $NAME | grep CREATE_FAILED &> /dev/null
then
  echo "Error while creating stack"
  exit 1
fi
for output in $(heat output-list $NAME | egrep '\|.*' | tail -n +2 | cut -d' ' -f 2)
do
  echo "$output: $(heat output-show $NAME $output)"
done
