# 5 Minutes Stacks, Episode 16: Xonotic

## Episode 16: Xonotic, the free and fast arena shooter

**Draft - Image not yet available...**

![Xonotic Logo](img/xonotic-logo.png)

Xonotic is an addictive, arena-style first person shooter with crisp movement and a wide array of weapons. It combines intuitive mechanics with in-your-face action to elevate your heart rate. Xonotic is and will always be free-to-play. It is available under the copyleft-style GPLv2 license.

The game has clients for Windows, Linux, and Mac OS, adapting to any system to provide an excellent play experience. This bundle deploys your personal Xonotic server in minutes, public or private, so that you can start playing with your friends in minutes.

![Battle Screenshot](img/battle.jpg)

## Preparations

### The version

* Xonotic v0.8.1

### The prerequisites to deploy this stack

These should be routine by now:

* Internet access
* A Linux shell
* A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository

### Size of the instance

By default, the stack deploys on an instance of type "Small" (s1.cw.small-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/en/pricing.html) on the Cloudwatt website).

Stack parameters, of course, are yours to tweak at your fancy.

## What will you find in the repository

Once you have cloned the github repository, you will find in the `bundle-trusty-xonotic/` directory:

* `bundle-trusty-xonotic.heat.yml`: Heat orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh`: Stack launching script, which simplifies the parameters and secures the admin password creation.
* `stack-get-ip.sh`: Returns the floating-IP in a URL, which can also be found in the stack output.

## Start-up

### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
If you are not logged in yet, complete the authentication and save the credentials script.
With it, you will be able to wield the amazing powers of the Cloudwatt APIs.

Source the downloaded file in your shell and enter your password when prompted to begin using the OpenStack clients.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Adjust the parameters

In the `.heat.yml` files (heat templates), you will find a section named `parameters` near the top. The mandatory parameters are the `keypair_name` and the server fields for the Xonotic settings.

You can set the `keypair_name`'s `default` value to save yourself time, as shown below.
Remember that key pairs are created [from the console](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab), and only keys created this way can be used.

The server fields provide some settings for the Xonotic server. You can change the server settings later with SSH. You can also adjust (and set the default for) the instance type by playing with the `flavor` parameter accordingly.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Xonotic stack


parameters:
  keypair_name:
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string
    default: my-keypair-name                <-- Indicate your key pair name here

  flavor_name:
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
    default: s1.cw.small-1
    constraints:
      - allowed_values:
        [...]

  server_hostname:
    default: Xonotic Server
    label: Xonotic Server Hostname
    description: Server name for public server list
    type: string

  is_shown:
    default: 1
    label: Xonotic Server is Public
    description: Server is included on the public server list
    type: string
    constraints:
      - allowed_values:
        - 0
        - 1

  server_port:
    default: 26000
    label: Xonotic Server Port
    description: Server port for player connections
    type: number
    constraints:
      - range: { min: 1025, max: 65534 }
        description: Must be a valid free port (1025 - 65534)

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

In a shell, run the script `stack-start.sh`:

~~~ bash
$ ./stack-start.sh PLASMABURN «my-keypair-name»
Enter your server hostname: ComeAtMeScrublordImRipped
Creating stack...
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | PLASMABURN | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Within 5 minutes the stack will be fully operational. (Use watch to see the status in real-time)

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | PLASMABURN | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Stack URL with a terminal

Once all of this done, you can run the `stack-get-ip.sh` script.

~~~ bash
$ ./stack-get-ip.sh PLASMABURN
PLASMABURN  70.60.637.17
~~~

As shown above, it will ouput the assigned floating-IP. You can then paste this into Xonotic and immediately get fragging!

![Weapon Fire](img/weapon-fire.jpg)

<a name="console" />

### Please console me

There there, it's okay... Xonotic stacks can be spawned from our console as well!

To create our Xonotic stack from the console:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-xonotic](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-xonotic) repository
2.	Click on the file named `bundle-trusty-xonotic.heat.yml`
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the page to your PC. You can use the default name proposed by your browser (just remove the .txt if needed)
5.  Go to the [Stacks](https://console.cloudwatt.com/project/stacks/) section of the console
6.	Click on **Launch stack**, then **Template file** and select the file you just saved to your PC, and finally click on **NEXT**
7.	Name your stack in the **Stack name** field
8.	Enter the name of your keypair in the **SSH Keypair** field
9.	Enter the password for the default *admin* user
10.	Choose your instance size using the **Instance Type** dropdown and click on **LAUNCH**

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating-IP, or simply refresh the current page and check the Overview tab for a handy link.

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack. The default game mode is deathmatch, but the admin can change that with SSH. Go to multiplayer and enjoy yourself!

Modify the server settings by connecting with SSH and heading to the file `/opt/xonotic/.xonotic/data/server.cfg`. Edit the contents to your liking and then run the command

~~~ bash
$ sudo initctl restart xonotic
~~~

to reload the configuration. Try some capture the flag, or add some bots!

## The State of Affairs

This bundle deploys a stable Xonotic setup that is resource-light and quick to launch, but can be very fast and even support dozens of players on a high-cpu instance.

#### The interesting directories are:

- `/opt/xonotic`: Xonotic home directory
- `/opt/xonotic/.xonotic/data/server.cfg`: Xonotic server configuration

#### Resources you could be interested in:

* [Xonotic Homepage](http://www.xonotic.org/)
* [Xonotic Wiki](https://gitlab.com/xonotic/xonotic/wikis/home)
* [Xonotic Official Game Download](http://dl.xonotic.org/xonotic-0.8.1.zip)

![Game Menu](img/game-menu.jpg)

-----
Have fun. Hack in peace.
