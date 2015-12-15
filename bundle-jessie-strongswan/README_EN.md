# 5 Minutes Stacks, episode 16 : Strongswan VPN Tunnel #

**WORK IN PROGRESS**

## Episode 16 : Strongswan

![Strongswan logo](img/strongswan.png)

StrongSwan est une implémentation du protocole IPSec placé sous licence GPL. Il est né par
un fork du projet FreeS/WAN. Le projet a été lancé en 2005 avec pour but de construire
une plate-forme IPSec stable doté d'extension X.509.

Ce que nous allons voir dans cet épisode vous permettra de mettre en place un tunnel
IPSec en un minium d'étapes, afin de disposer d'un canal sécurisé et authentifié vers une
zone externe à la plate-forme Cloudwatt.

## Preparations

### The version

* Debian Jessie
* Strongswan 5.2.1

### The prerequisites to deploy this stack

* Internet access
* A Linux shell
* A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section or "run it by the 1-clic" section by clicking [here](#console). 

## What will you find in the repository

Once you have cloned the github repository, you will find in the `bundle-jessie-strongswan/` directory:

* `bundle-jessie-strongswan.heat.yml` : Heat orchestration template. It will be use to deploy the necessary infrastructure.

## Démarrage

### Initialize the environment

Log in to the [Cloudwatt Console](https://console.cloudwatt.com) and

Have your Cloudwatt username and password ready and click [download a 'Cloudwatt API' credentials script](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
With it, you will be able to wield the amazing powers of the OpenStack APIs.

Source the downloaded file in your shell (enter your password when prompted) to begin using the OpenStack clients.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Only then can the Openstack command-line tools interact with your Cloudwatt user account.

### Adjust the parameters

The stack that we are proposing requires some input parameters to be used:

* `keypair_name` : The keypair name that will be injected into the server to allow your connection
* `local_cidr` : The CIDR of the private subnetwork which will be deployed by the stack (ex: 192.168.47.0/24). This should be a [classe C](https://fr.wikipedia.org/wiki/Classe_d'adresse_IP) network.
* `partner_cidr` : The CIDR of the private subnetwork which exist at the other side of the IPSec tunnel (ex: 192.168.58.0/24). This should be a [classe C](https://fr.wikipedia.org/wiki/Classe_d'adresse_IP) network.
* `preshared_key` : The secret string character that is shared between the 2 sides of the IPsec tunnel. This secret will be injected into the server that will be started by the stack but is not stored on the Cloudwatt plateform.

### Start-up

For this exemple, we will use these parameter values:

* `keypair_name` : "my_key.pem"
* `local_cidr` : "192.168.47.0/24"
* `partner_cidr` : "10.0.240.0/24"
* `preshared_key` : "pr3ttyh4rd4nd0ngs3cr3tstr1ngsharedw1thmyb|_|ddy"

Use the `-P` option of the heat client to pass the parameters into our stack:

~~~
$ heat stack-create BATMAN -f bundle-jessie-strongswan.heat.yml \
  -Pkeypair_name="my_key.pem"       \
  -Plocal_cidr="192.168.47.0/24"    \
  -Ppartner_cidr="10.0.240.0/24"    \
  -Ppreshared_key="pr3ttyh4rd4nd0ngs3cr3tstr1ngsharedw1thmyb|_|ddy"

+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| 3b740e36-f0e4-4180-91f9-a9c991d175c1 | BATMAN        | CREATE_IN_PROGRESS | 2015-12-11T13:45:29Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Within **5 minutes** the stack will be fully operational.

```
$ heat resource-list BATMAN
+--------------------------------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name                              | physical_resource_id                                                                | resource_type                   | resource_status | updated_time         |
+--------------------------------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip                                | 977f03c4-3a0f-4ead-a588-99c97673b703                                                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2015-12-11T13:03:45Z |
| router                                     | 00530a88-f65d-450e-a6e8-988e71135d25                                                | OS::Neutron::Router             | CREATE_COMPLETE | 2015-12-11T13:03:48Z |
| network                                    | f51f3cf3-9eda-4695-954e-9ae8da38cf4d                                                | OS::Neutron::Net                | CREATE_COMPLETE | 2015-12-11T13:03:52Z |
| security_group                             | d9a28485-3595-4f8e-9246-e51fdf54dfae                                                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2015-12-11T13:03:52Z |
| subnet                                     | 8a34acee-9a8e-4ff3-97c3-f8970165d563                                                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-12-11T13:03:54Z |
| floating_ip_injection_and_route_finetuning | ad38bb7c-51ef-4d99-8d2e-e4a92a0c8e9d                                                | OS::Heat::SoftwareConfig        | CREATE_COMPLETE | 2015-12-11T13:03:56Z |
| keeper_init                                | 5eeade9a-be79-4d4f-a252-649d77d7b4a2                                                | OS::Heat::MultipartMime         | CREATE_COMPLETE | 2015-12-11T13:03:58Z |
| router_interface                           | 00530a88-f65d-450e-a6e8-988e71135d25:subnet_id=8a34acee-9a8e-4ff3-97c3-f8970165d563 | OS::Neutron::RouterInterface    | CREATE_COMPLETE | 2015-12-11T13:03:58Z |
| server_port                                | 7b5926c0-50bb-4f36-bd38-e857d1a1d7fc                                                | OS::Neutron::Port               | CREATE_COMPLETE | 2015-12-11T13:03:58Z |
| keeper_server                              | 8b6511ec-c249-43a6-95c7-4814297aacaf                                                | OS::Nova::Server                | CREATE_COMPLETE | 2015-12-11T13:04:00Z |
| floating_ip_link                           | 977f03c4-3a0f-4ead-a588-99c97673b703-84.39.41.55                                    | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2015-12-11T13:04:24Z |
+--------------------------------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+```
```

The `start-stack.sh` script is taking care of running the API necessary requests to:

* start a Debian based instance, pre-provisionned with Strongswan and a part of the configuration.
* Attach an exposed floating-IP

### The light at the end of the tunnel

To complete the installation, you should *have in hand the public IP adress of the other side of the tunnel*.
Considering 

Pour finaliser l'installation, il faut *vous munir de l'adresse IP publique de l'autre extrémité du tunnel*.
Assuming that the target server is configured correctly and wait only for your inputs, the procedure is confined to:

* connect in SHH to your server
* move to root via `sudo -i`
* run the command:

```
ipsec_post_install $ADDRESS_IP_PUBLIC_OF_THE_OTHER_SIDE_OF-THE_TUNNEL
```

Of course, this assumes that the other extremity is a server already parametered with the shared secret, knows the CIDR of your private zone and is on-line.

Once all these conditions fulfilled:

* le serveur de la stack, qui héberge Strongswan, peut contacter toutes les machines du sous-réseau de l'autre côté du tunnel.
* Tout serveur démarré dans le sous-réseau de votre stack pourra contacter toutes les machines du sous-réseau de l'autre côté du tunnel.


### Ready to play?

Si vous ne disposez pas d'un partenaire de tunnel, rien ne vous empêche de jouer avec Strongswan en démarrant une deuxième
stack (que nous pourrions appeler ROBIN par exemple) en inversant les valeurs de local_cidr et partner_cidr et de faire la post-installation de chacune des stacks avec la valeur de l'IP flottante attribuée à l'autre.

* Start a BATMAN stack as described above
* Get its floating IP
* Start a ROBIN stack as described above (with the same preshared_key)
* Get its floating IP
* Perform the BATMAN post-install with the ROBIN IP address
* Perform the ROBIN post-install with the BATMAN IP address

You will get then 2 totaly isolated network silos which can communicate thru the crypted tunnel.

<a name="console" />

## That's fine but...

### You do not have a way to run the stack thru the console?

Lucky for you then, all of the setup for Strongswan can be accomplished using only the web-interface.

1.	Upload directly [the stack file](https://raw.githubusercontent.com/cloudwatt/applications/master/bundle-jessie-strongswan/bundle-jessie-strongswan.heat.yml).
2.  Go to the «[Stacks](https://console.cloudwatt.com/project/stacks/)» section of the console
3.	Click on «Launch stack», then «Template file» and select the file you just saved to your PC, and finally click on «NEXT»
4.	Name your stack in the «Stack name» field
5.	Fill up the other parameters of the formular
6.  Perform the post-configuration tasks as described above (no escape this time, you will need to access thru SSH).

### Or an easier way thru a 1-click?

... Yes! Go to the [Apps page](https://www.cloudwatt.com/en/applications/index.html) on the Cloudwatt website, choose the apps, press "DEPLOY" and follow the simple steps... 5 minutes later, a green button appears... ACCESS: you have nearly your Strongswan! (no escape this time, you will need to access thru SSH)

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

If your want to have a closer look at the Strongswan configuration, you can start by:

* `/etc/ipsec.conf`: configuration file of thr Strongswan connections
* `/etc/ipsec.secrets`: Strongswan secrets storage file

#### Other resources you could be interested in:

* [Documentation portal of Strongswan](https://www.strongswan.org/documentation.html)
* [The exemple which we have used to build this stack](https://www.strongswan.org/testresults4.html)

-----
Have fun. Hack in peace.
