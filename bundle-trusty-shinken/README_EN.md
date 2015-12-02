# 5 Minutes Stacks, Episode 15: Shinken

## Episode 15: Shinken-server

![Minimum setup](http://www.samuelpoggioli.fr/wp-content/uploads/2014/12/Shinken-624x192.jpg)

Shinken is an application for system and network monitoring.
It monitors specified hosts and services, alerting when systems
go bad and when they get better. This is free software licensed under the GNU AGPL.
Shinken is fully compatible with Nagios software.

The deployment base chosen for this bundle is an instance Debian Jessie. Shinken the server,
his web interface and database are deployed in a single instance.

## Preparations

### The version

* Debian Jessie   8.2
* Shinken         2.4.2
* SQlitedb        3.8.2

### The prerequisites to deploy this stack

These should be routine by now:

* Internet access
* A Linux shell
* A [Cloudwatt account](https://www.cloudwatt.com/authentification) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository

### Size of the instance

By default, the stack deploys on an instance of type "Small" (s1.cw.small-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website).

Stack parameters, of course, are yours to tweak at your fancy.

## What will you find in the repository

Once you have cloned the github repository, you will find in the `bundle-trusty-shinken/` directory:

* `bundle-trusty-shinken.heat.yml`: Heat orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh`: Stack launching script, which simplifies the parameters and secures the admin password creation.
* `stack-get-url.sh`: Returns the floating-IP in a URL, which can also be found in the stack output.

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

In the `.heat.yml` files (heat templates), you will find a section named `parameters` near the top. The mandatory parameters are the `keypair_name` and the `password` for the Shinken *admin* user.

You can set the `keypair_name`'s `default` value to save yourself time, as shown below.
Remember that key pairs are created [from the console](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab), and only keys created this way can be used.

The `password` field provides the password for Shinken default *admin* user. You will need it upon initial login, but you can always create other users later. You can also adjust (and set the default for) the instance type by playing with the `flavor` parameter accordingly.

By default, the stack network and subnet are generated for the stack, in which the Shinken server sits alone. This behavior can be changed within the `.heat.yml` as well, if needed.

~~~ yaml

heat_template_version: 2013-05-23


description: All-in-one Shinken stack


parameters:
  keypair_name:
    default: buildshinken                            <-- put here your keypair_name
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: s1.cw.small-1                                    
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
        - t1.cw.tiny
        - s1.cw.small-1
         [...]

~~~

<a name="startup" />

### Stack up with a terminal

In a shell, go in the `bundle-trusty-shinken/` directory and run the script `stack-start.sh`:

~~~ bash
$ ./stack-start.sh `name_of_my_stack`

Creating stack...
+--------------------------------------+------------+--------------------+-----------------------------+
| id                                   | stack_name         | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+------------------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | `name_of_my_stack` | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+------------------------------+
~~~

Within 5 minutes the stack will be fully operational. (Use watch to see the status in real-time)

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+------------------------------+
| id                                   | stack_name         | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+------------------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | `name_of_my_stack` | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+------------------------------+
~~~

### Stack URL with a terminal

Once all of this done, you can run the `stack-get-url.sh` script to get the floating_network_id

~~~ bash
$ ./stack-get-url.sh `name_of_my_stack`
`name_of_my_stack`  floating_ip
~~~

As shown above, it will parse the assigned floating-IP of your stack into a URL link, with the right port included. You can then click or paste this into your browser of choice and bask in the glory of a fresh Shinken instance.
* login : admin
* mot de passe : admin
For now, our monitoring server and client are configured. We need to access the Shinken Webui using the IP address of our server http://X.X.X.X:7767.

![Interface connection shinken](https://mescompetencespro.files.wordpress.com/2012/12/authentification-shinken.png)

Once the authentication is done, click on the `ALL` to see different metrics monitored by shinken

![Bigger production setup](http://performance.izzop.com/sites/default/files/SHINKEN/image_01_WEBUI.png)

you can to create a widget into your dashboard

![Bigger production ](http://shinkenlab.io/images/course2/course2-dasboardfilled.png)

Good !!!
<a name="console" />

### For monitoring more machines

  It must be ensured that the machines to be monitored:

* are visible on the network from the server Shinken
* have a functional SNMP daemon
* allow incoming UDP communications on port 161 (port for exchanging information with SNMP) and 123 (NTP server synchronization port)

On the shinken-server, you must describe the configuration of file hosts who is in the directory `/etc/shinken/hosts/localhost.cfg` who describe the configuration of the hosts to monitor.

### Example of monitoring a server Ghost

Let's see an example of integration of a server instance with the Ghost blog engine.

  * deploy a stack Ghost [as we saw in episode 5](https://dev.cloudwatt.com/fr/blog/5-minutes-stacks-episode-cinq-ghost.html).
  * for your section [Access and Security Cloudwatt console](https://console.cloudwatt.com/project/access_and_security/),   
    add two rules to the security group of the stack Ghost :
    * Rules UDP , Entry, Port 161
    * Rules UDP , Entry, Port 123

This will allow the Shinken server to connect to retrieve the metric of the machine. We must now create the network between our visibility and our stack stack Shinken Ghost, through the creation of a Neutron router:


  1. Get the subnet ID of the stack Ghost:

  ```
  $ heat resource-list $NOM_DE_STACK_GHOST | grep subnet

  | subnet           | bd69c3f5-ddc8-4fe4-8cbe-19ecea0fdf2c              | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-24T15:18:30Z |
  ```

  2. Get the subnet ID of the stack Shinken:

  ```
  $ heat resource-list $NOM_DE_STACK_SHINKEN | grep subnet

  | subnet           | babdd078-ddc8-4280-8cbe-0f77951a5933              | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-24T15:18:30Z |
  ```

  3. Create a new router :

    ```
    $ neutron router-create SHINKEN_GHOST

    Created a new router:
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | admin_state_up        | True                                 |
    | external_gateway_info |                                      |
    | id                    | babdd078-c0c6-4280-88f5-0f77951a5933 |
    | name                  | SHINKEN_GHOST                        |
    | status                | ACTIVE                               |
    | tenant_id             | 8acb072da1b14c61b9dced19a6be3355     |
    +-----------------------+--------------------------------------+
    ```

  4. Add to a router interface, the subnet of the Ghost stack and  the subnet of the stack Shinken:

    ```
    $ neutron router-interface-add $SHINKEN_GHOST_ROUTER_ID $SHINKEN_SUBNET_ID

    $ neutron router-interface-add $SHINKEN_GHOST_ROUTER_ID $GHOST_SUBNET_ID

    ```

  A few minutes later, the Shinken server and the Ghost server will contact each other directly. To provide an "executable documentation" the integration of a Ubuntu server, we will use Ansible for the future.

  5. Make sure you can log:
      * SSH
      * user `cloud`
      * Ghost server
      * since Shinken-server

  6. Since the Shinken-server, add the connection information in the inventory `/etc/ansible/hosts` :

  ```         
  [...]

  [slaves]
  xx.xx.xx.xx ansible_ssh_user=cloud ansible_ssh_private_key_file=/home/cloud/.ssh/id_rsa_ghost_server.pem

  [...]
  ```

  7. Start the playbook `slave-monitoring.yml` as Shinken root on the server:
  ```
  # ansible-playbook /root/slave-monitoring.yml
  ```

This playbook  will do all the installation and setup on the Ghost server to integrate monitoring Shinken.

For now, our monitoring server and client are configured. We need to access the Shinken Web UI using the IP address of our server http://X.X.X.X:7767.

![Bigger production setup](http://shinken.readthedocs.org/en/latest/_images/shinken_webui.png)


<a name="console" />


### Please console me

There there, it's okay... Shinken stacks can be spawned from our console as well!

To create our Shinken stack from the console:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-Shinken](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-Shinken) repository
2.	Click on the file named `bundle-trusty-shinken.heat.yml`
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the page to your PC. You can use the default name proposed by your browser (just remove the .txt if needed)
5.  Go to the [Stacks](https://console.cloudwatt.com/project/stacks/) section of the console
6.	Click on **Launch stack**, then **Template file** and select the file you just saved to your PC, and finally click
    on **NEXT**
7.	Name your stack in the **Stack name** field
8.	Enter the name of your keypair in the **SSH Keypair** field
9.	Enter your new admin password
10.	Choose your instance size using the **Instance Type** dropdown and click on **LAUNCH**

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating-IP, or simply refresh the current page and check the Overview tab for a handy link.

Remember that the differents ports where Shinken-server listening:

            Arbiter : 7770
            Broker : 7772
            WebUI : 7767
            Reactionner : 7769
            Scheduler : 7768
            Poller : 7771

## So watt?

This tutorial aims to improve your startup. At this stage you are master on board.
You have an entry point to your virtual machine via SSH floating IP exposed and your private key (`cloud` user by default).
You can start to live your monitoring taking hold of your server.

#### The interesting directories are:

* `/etc/shinken/hosts/`: the directory containing the file hosts (the machines to be monitored)
* `/usr/bin/shinken-*`:  the directory containing scripts
* `/var/lib/shinken`:    the directory containing the monitoring modules of Shinken
* `/var/log/shinken`:    the directory containing the log

#### Other resources you could be interested in:

* [shinken-monitoring Homepage](http://www.shinken-monitoring.org/)
* [Shinken Solutions - Index](http://www.shinken-solutions.com/)
* [Shinken manual](http://shinken.readthedocs.org/en/latest/)
* [Shinken blog](http://shinkenlab.io/online-course-2-webui/)
* [shinken-monitoring architecture](https://shinken.readthedocs.org/en/latest/)


-----
Have fun. Hack in peace.
