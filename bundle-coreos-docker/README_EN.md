# 5 Minutes Stacks, Episode 21: Docker and CoreOS

## Episode 21: Docker

![coreoslogo](https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/CoreOS.svg/320px-CoreOS.svg.png)

 CoreOS is an open-source lightweight operating system based on the Linux kernel and designed for providing infrastructure to clustered deployments, while focusing on automation, ease of applications deployment, security, reliability and scalability. As an operating system, CoreOS provides only the minimal functionality required for deploying applications inside software containers, together with built-in mechanisms for service discovery and configuration sharing.

 This tutorial will help you creating a CoreOS three node cluster. By default each instance is only accessible trough SSH port 22. You will have to create additional rules in your security groups to manage services you aim to deploy.

## Preparations

### The version

* CoreOS 835.9.0
* Docker 1.8.3

### The prerequisites to deploy this stack

 These should be routine by now:

* Internet access
* A Linux shell
* A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository

### Size of the instance

 By default, the stack deploys on an instance of type "Standard 2" (n2.cw.standard-2). A variety of other instance flavors exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website).

 Stack parameters, of course, are yours to tweak at your fancy.

## What will you find in the repository

 Once you have cloned the github, you will find in the `bundle-coreos-docker/` repository:

 * `bundle-coreos-docker.heat.yml`: HEAT orchestration template. It will be used to deploy the necessary infrastructure.
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

In the `bundle-coreos-docker.heat.yml` file (heat template), you will find a section named `parameters` near the top. The only mandatory parameter is the `keypair_name`. The `keypair_name`'s `default` value should contain a valid keypair with regards to your Cloudwatt user account, if you wish to have it by default on the console.

Within these heat templates, you can also adjust (and set the defaults for) the instance type by playing with the `flavor_name` parameter accordingly.

By default, the stack network and subnet are generated for the stack. This behavior can be changed within the `bundle-coreos-docker.heat.yml` file as well, if need be, although doing so may be cause for security concerns.

~~~ yaml
heat_template_version: 2013-05-23

description: CoreOS 3 nodes cluster for docker

parameter_groups:
- label: CoreOS
  parameters:
    - keypair_name
    - flavor_name

parameters:
  keypair_name:
    type: string
    description: Name of keypair to assign to CoreOS instances
    label: SSH Keypair
    default: my-keypair-name                <-- Indicate here your keypair

  flavor_name:
    type: string
    description: Flavor to use for the server
    default : n2.cw.standard-2
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
        - n2.cw.highmem-2
        - n2.cw.highmem-4
        - n2.cw.highmem-8
        - n2.cw.highmem-16
        - n2.cw.standard-1
        - n2.cw.standard-2
        - n2.cw.standard-4
        - n2.cw.standard-8
        - n2.cw.standard-16

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
 $ ./stack-start.sh DOCKER
 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | DOCKER     | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+--------------------+----------------------+
 ~~~

 Within 5 minutes the stack will be fully operational. (Use watch to see the status in real-time)

 ~~~ bash
 $ watch -n 1 heat stack-list
 +--------------------------------------+------------+-----------------+----------------------+
 | id                                   | stack_name | stack_status    | creation_time        |
 +--------------------------------------+------------+-----------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | DOCKER     | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+-----------------+----------------------+
 ~~~

### Enjoy

Once all of this done, instance's IP can be obtained with the following command (and will be listed in the "output" section): 

~~~ bash
$ heat stack-show DOCKER
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

#### How to use CoreOS

To access the CoreOS instances through SSH, the default user is called `core`
The following command can be used to connect to instances:
~~~ bash 
ssh -i <keypair> core@<node-ip@>
~~~

##### etcd - distributed reliable key-value store

Show cluster health:
~~~ bash
ssh -i <keypair> core@<node-ip@>
etcdctl cluster-health
~~~

List all keys in etcd:
~~~ bash
ssh -i <keypair> core@<node-ip@>
etcdctl ls --recursive
~~~

Get the value of a key:
~~~ bash
ssh -i <keypair> core@<node-ip@>
etcdctl get <name/of/key>
~~~

Create/Update a key:
~~~ bash
ssh -i <keypair> core@<node-ip@>
etcdctl set <name/of/key> <value>
~~~

##### systemd - init system for Linux

How to create a "Hello World" service under docker with systemd:

First, you will have to add the following file in `/etc/systemd/system`. It is used to declare your service. Let's name it `hello.service`.
~~~
[Unit]
Description=MyApp
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill busybox1
ExecStartPre=-/usr/bin/docker rm busybox1
ExecStartPre=/usr/bin/docker pull busybox
ExecStart=/usr/bin/docker run --name busybox1 busybox /bin/sh -c "while true; do echo Hello World; sleep 1; done"

[Install]
WantedBy=multi-user.target
~~~

Once your file created, the service needs to be enabled and started: 
~~~ bash
sudo systemctl enable /etc/systemd/system/hello.service
sudo systemctl start hello.service
~~~

Logs can be seen with the following command:
~~~ bash
journalctl -f -u hello.service
~~~

To stop the service, just type:
~~~ bash
sudo systemctl stop hello.service
~~~

And this is how to deactivate it:
~~~ bash
sudo systemctl disable hello.service
~~~

##### flannel - shared virtual network for containers

Flannel is a virtual network that gives a subnet to each host for use with container runtimes. It is started with your stack and allows you connect to any container from any other container, regardless of the hosts those containers are running on.

#### Other resources you could be interested in:

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)


-----
Have fun. Hack in peace.
