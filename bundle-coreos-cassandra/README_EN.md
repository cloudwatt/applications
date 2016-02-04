# 5 Minutes Stacks, épisode 22: Cassandra #

## Episode 22: Cassandra

![cassandralogo](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Cassandra_logo.svg/langfr-96px-Cassandra_logo.svg.png)

Apache Cassandra is a distributed NoSQL database management system. Initially developed by Facebook, it was released as an open source project in 2008 and is now a top-level Apache projet. Cassandra allows to handle large amounts of structured, semi-structured, and unstructured data across multiple data centers and in the cloud. By basing on BigTable principles, Cassandra offers flexible data models and ensures a fast reponse request time. It delivers also many other features: continuous availability, fault-tolerant, decentralized and scalability.

## Descriptions

 The "Casssandra" stack bootstrap a 3 node Cassandra cluster with one seed. 

## Preparations

### Les versions
 - Cassandra 3.1.1
 - Docker 1.8.3
 - CoreOS 835.9.0

### The prerequisites to deploy this stack

 * an internet access
 * a Linux shell
 * a [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

 Per default, the script is proposing a deployement on an instance type "Standard 2" (n1.cw.standard-2).  Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

 If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console)

## What will you find in the repository

 Once you have cloned the github, you will find in the `bundle-coreos-cassandra/` repository:

 * `bundle-coreos-cassandra.heat.yml`: HEAT orchestration template. It will be used to deploy the necessary infrastructure.
 * `stack-start.sh`: Stack launching script. This is a small script that will save you some copy-paste.

## Start-up

### Initialize the environment

 Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
 If you are not logged in yet, you will go thru the authentication screen then the script download will start. Thanks to it, you will be able to initiate the shell accesses towards the Cloudwatt APIs.

 Source the downloaded file in your shell. Your password will be requested.

 ~~~ bash
 $ source COMPUTE-[...]-openrc.sh
 Please enter your OpenStack Password:

 ~~~

 Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Adjust the parameters

 With the `bundle-coreos-cassandra.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. This is within this same file that you can adjust the instance size by playing with the `flavor_name` parameter.

 ~~~ yaml
heat_template_version: 2013-05-23

description: Cassandra 3 nodes cluster with Docker on CoreOS

parameters:
  keypair_name:
    type: string
    description: Keypair to inject in instance
	label: SSH Keypair
    default: my-keypair-name                <-- Indicate here your keypair
    
  flavor_name:
    type: string
    description: Flavor to use for the server
    default: n1.cw.standard-2
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
        [...]

resources:
  network:
    type: OS::Neutron::Net

  subnet:
    type: OS::Neutron::Subnet
    properties:
      network_id: { get_resource: network }
      ip_version: 4
      cidr: 10.0.1.0/24
	  dns_nameservers: [8.8.8.8, 8.8.4.4]
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.254 }
[...]

~~~

### Start the stack

 In a shell, run the script `stack-start.sh`:

 ~~~ bash
 $ ./stack-start.sh Cassandra
 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | Cassandra  | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+--------------------+----------------------+
 ~~~

 Within 5 minutes the stack will be fully operational. (Use watch to see the status in real-time)

 ~~~ bash
 $ watch -n 1 heat stack-list
 +--------------------------------------+------------+-----------------+----------------------+
 | id                                   | stack_name | stack_status    | creation_time        |
 +--------------------------------------+------------+-----------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | Cassandra  | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+-----------------+----------------------+
 ~~~

### Enjoy

Once all this done, you have a ready-to-use 3-nodes Cassandra cluster. Instance's IP can be obtained with the following command (and will be listed in the "output" section): 

~~~ bash
$ heat stack-show Cassandra
+-----------------------+---------------------------------------------------+
| Property              | Value                                             |
+-----------------------+---------------------------------------------------+
|                     [...]                                                 |
| outputs               | [                                                 |
|                       |   {                                               |
|                       |     "output_value": "10.0.1.100",                 |
|                       |     "description": "server3 private IP address",  |
|                       |     "output_key": "server3_private_ip"            |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "10.0.1.102",                 |
|                       |     "description": "server1 private IP address",  |
|                       |     "output_key": "server1_private_ip"            |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "XX.XX.XX.XX",                |
|                       |     "description": "server3 public IP address",   |
|                       |     "output_key": "server3_public_ip"             |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "YY.YY.YY.YY",                |
|                       |     "description": "server1 public IP address",   |
|                       |     "output_key": "server1_public_ip"             |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "10.0.1.103",                 |
|                       |     "description": "server2 private IP address",  |
|                       |     "output_key": "server2_private_ip"            |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "ZZ.ZZ.ZZ.ZZ",                |
|                       |     "description": "server2 public IP address",   |
|                       |     "output_key": "server2_public_ip"             |
|                       |   }                                               |
|                       | ]                                                 |
|                     [...]                                                 |
+-----------------------+---------------------------------------------------+
~~~

#### Launch cqlsh command

~~~
ssh -i <keypair> core@<node-ip@>
docker exec -it cassandra cqlsh
~~~

### Manage Cassandra cluster 

The nodetool utility is a command line interface for managing a cluster.

~~~
ssh -i <keypair> core@<node-ip@>
docker exec cassandra nodetool <nodetool_command>
~~~

### Access to Cassandra logs

Cassandra log can be viewed via docker logs command 

~~~
ssh -i <keypair> core@<node-ip@>
docker logs -f cassandra
~~~

Cassandra also saves its logs inside the container. By default, logging output is placed in `/var/log/cassandra/system.log` file. 

~~~
ssh -i <keypair> core@<node-ip@>
docker exec cassandra cat /var/log/cassandra/system.log
~~~


#### Other resources you could be interested in:

* [Cassandra Homepage](http://cassandra.apache.org/)
* [CoreOS Homepage](https://coreos.com/)
