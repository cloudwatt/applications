# 5 Minutes Stacks, épisode 21 : Clamav #

## Episode 21 : CLAMAV

![logoclamav](http://www.clamav.net/assets/clamav-trademark.png)

Clam AntiVirus (ClamAv) is a open source antivirus for UNIX. Capable of scanning mail for any client in real-time, ClamAv provides a first line of defense against spam and viruses. The deployment we offer you today is highly flexible: easily manipulated from the command line and automatically updating its virus database daily. This program is based on a library distributed with the package Clam AntiVrus, which you could even use to create your own antivirus package.

## Preparations

### The Versions

- Clamav 0.99.0

### The prerequisites to deploy this Stacks

These should be routine by now:

* Internet access
* A Linux shell
* A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository
* The ID of an Neutron Subnet containing servers who need to connect to your clamav instance.

### Size of the instance

By default, the stack deploys on an instance of type "Small" (s1.cw.small-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website).

All stack parameters, of course, are yours to tweak at your fancy.

### By the way...

If you do not like terminal, stacks can still be [generated directly from the console](#console).

## What will you find in the repository

Once you have cloned the github, you will find in the `bundle-trusty-clamav/` repository:

* `bundle-trusty-clamav.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh`: Stack launching script, which simplifies the parameters.
* `stack-get-url.sh`: Returns the floating-IP in a URL, which can also be found in the stack output.

## Start-up

### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
If you are not logged in yet, complete the authentication and save the credentials script.
With it, you will be able to wield the amazing powers of the OpenStack APIs.

Source the downloaded file in your shell and enter your password when prompted to begin using the OpenStack clients.

### Adjust the parameters

In the `.heat.yml` file (the heat template), you will find a section named `parameters` near the top. The only mandatory parameter is the `keypair_name`. You should set the `default` value to a valid keypair with regards to your Cloudwatt user account, as this is how you connect to your stack remotely. A keypair can be generated from the `Key Pairs` tab under `Access & Security` on the console. Make sure to save the public key, otherwise you will not be able to connect to your machine by SSH.

Within the heat template, you can also adjust (and set the default for) the instance type by playing with the `flavor` parameter accordingly.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one ClamAv stack


parameters:
  keypair_name:
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string
    default: my-keypair-name                <-- Indicate your keypair here

  flavor_name:
    default: s1.cw.small-1                  <-- Indicate your instance type here
    description: Flavor to use for the deployed instance
    type: string
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
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.199 }
[...]

~~~

<a name="startup" />

### Stack up with a terminal

In a shell, go in the directory and run the script `stack-start.sh` with the name you want to give it as parameter:

~~~ bash
$ ./stack-start.sh EXP_STACK
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | EXP_STACK       | CREATE_IN_PROGRESS | 2015-11-25T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+

~~~

Within 5 minutes the stack will be fully operational.

~~~ bash
$ heat resource-list EXP_STACK
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name    | physical_resource_id                                | resource_type                   | resource_status | updated_time         |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip      | 44dd841f-8570-4f02-a8cc-f21a125cc8aa                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2015-11-25T11:03:51Z |
| security_group   | efead2a2-c91b-470e-a234-58746da6ac22                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2015-11-25T11:03:52Z |
| network          | 7e142d1b-f660-498d-961a-b03d0aee5cff                | OS::Neutron::Net                | CREATE_COMPLETE | 2015-11-25T11:03:56Z |
| subnet           | 442b31bf-0d3e-406b-8d5f-7b1b6181a381                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-25T11:03:57Z |
| server           | f5b22d22-1cfe-41bb-9e30-4d089285e5e5                | OS::Nova::Server                | CREATE_COMPLETE | 2015-11-25T11:04:00Z |
| floating_ip_link | 44dd841f-8570-4f02-a8cc-f21a125cc8aa-`floating IP`  | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2015-11-25T11:04:30Z |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------
~~~

The script `start-stack.sh` takes care of issuing the necessary calls to the Cloudwatt API for:

* Start an Ubuntu Trusty based instance, pre-equipped with ClamAV
* Exposes it on the Internet via a floating IP

![ClamVersatile](http://www.clamav.net/assets/Ill-03.png)

### Enjoy

Once all this is complete, you can connect to your server with SSH.

By default we placed the `fileclamav.sh` script in `/etc/cron.daily/` so that ClamAV can update daily, it is up to you to modify it. To do a test update you can enter the following command:

~~~bash
sudo /etc/cron.daily/fileclamav.sh
~~~

You can do run a scan on your system with the command `clamscan`.

[On this page](https://help.ubuntu.com/community/ClamAV) you will find useful ClamAV scripts, as well as on [the ClamAV downloads page]((http://www.clamav.net/downloads)).
