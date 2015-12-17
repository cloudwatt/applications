# 5 Minutes Stacks, épisode 18 : Zabbix #

## Episode 18 : Zabbix-server

![Minimum setup](http://blog.stack.systems/wp-content/uploads/2015/01/5-passos-instalacao-zabbix-2-4-guia-definitivo.png)

Zabbix is free software to monitor the status of various network services, servers and other network equipment; and producing dynamic graphics resource consumption. Zabbix uses MySQL, PostgreSQL or Oracle to store data. According to the importance of the number of machines and data to monitor, the choice of the DBMS greatly affects performance. Its web interface is written in PHP. 

Zabbix-server in a network is as follows:

![Architecture réseau zabbix](http://image.slidesharecdn.com/zabbixfeaturesin5pictures-03-150131052309-conversion-gate02/95/zabbix-monitoring-in-5-pictures-2-638.jpg?cb=1440581062)

We note in this architecture as Zabbix-server can monitor the hosts that are installed zabbix-agent or via SNMP daemon.

## Preparations

### The version

* Ubuntu 14.04
* Zabbix 2.2
* Mysql  5.5

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

Once you have cloned the github repository, you will find in the `bundle-trusty-zabbix/` directory:

* `bundle-trusty-zabbix.heat.yml`: Heat orchestration template. It will be use to deploy the necessary infrastructure.
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

In the `.heat.yml` files (heat templates), you will find a section named `parameters` near the top. The mandatory parameters are the `keypair_name` and the `password` for the zabbix *admin* user.

You can set the `keypair_name`'s `default` value to save yourself time, as shown below.
Remember that key pairs are created [from the console](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab), and only keys created this way can be used.

The `password` field provides thttp://wiki.monitoring-fr.org/zabbix/zabbix-work
By default, the stack network and subnet are generated for the stack, in which the Zabbix server sits alone. This behavior can be changed within the `.heat.yml` as well, if needed.

~~~ yaml

heat_template_version: 2013-05-23


description: All-in-one zabbix stack


parameters:
  keypair_name:
    default:                                   <-- put here your keypair_name
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

In a shell, go in the `bundle-trusty-zabbix/` directory and run the script `stack-start.sh`:

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

As shown above, it will parse the assigned floating-IP of your stack into a URL link, with the right port included. You can then click or paste this into your browser of choice and bask in the glory of a fresh Zabbix instance.
For now, our monitoring server and client are configured. We need to access the Zabbix interface using the IP address of our server http://X.X.X.X

* login : admin
* password : zabbix

Remember to change the default password immediately after your authentication.

![Interface connection zabbix](https://cdn-02.memo-linux.com/wp-content/uploads/2015/03/zabbix-07-300x253.png)

Once authentication is complete you will have access to Zabbix-server.

![Bigger production setup](https://cdn-02.memo-linux.com/wp-content/uploads/2015/03/zabbix-08-300x276.png)


Good !!!
<a name="console" />

### For monitoring more machines

  It must be ensured that the machines to be monitored:
  

* are visible on the network from the Zabbix-server
* Have a functional zabbix agent
* accept incoming TCP and UDP communications on the 10050 port, listening port of Zabbix agents by default.      


### Example of monitoring a server Ghost

Let's see an example of integration of a server instance with the Ghost blog engine.

  * deploy a stack Ghost [as we saw in episode 5](https://dev.cloudwatt.com/fr/blog/5-minutes-stacks-episode-cinq-ghost.html).
  * for your section [Access and Security Cloudwatt console](https://console.cloudwatt.com/project/access_and_security/),   
  add two rules to the security group of the stack Ghost :


  * Rules UDP , Entry, Port 10050
  * Rules TCP , Entry, Port 10050

This will allow the Zabbix server to connect to retrieve the metric of the machine. We must now create the network between our visibility and our stack stack Zabbix Ghost, through the creation of a Neutron router:


  1. Get the subnet ID of the stack Ghost:

  ```
  $ heat resource-list $NOM_DE_STACK_GHOST | grep subnet

  | subnet           | bd69c3f5-ddc8-4fe4-8cbe-19ecea0fdf2c              | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-24T15:18:30Z |
  ```

  2. Get the subnet ID of the stack Zabbix:

  ```
  $ heat resource-list $NOM_DE_STACK_Zabbix | grep subnet

  | subnet           | babdd078-ddc8-4280-8cbe-0f77951a5933              | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-24T15:18:30Z |
  ```

  3. Create a new router :

    ```
    $ neutron router-create Zabbix_GHOST

    Created a new router:
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | admin_state_up        | True                                 |
    | external_gateway_info |                                      |
    | id                    | babdd078-c0c6-4280-88f5-0f77951a5933 |
    | name                  | Zabbix_GHOST                        |
    | status                | ACTIVE                               |
    | tenant_id             | 8acb072da1b14c61b9dced19a6be3355     |
    +-----------------------+--------------------------------------+
    ```

  4. Add to a router interface, the subnet of the Ghost stack and  the subnet of the stack Zabbix:

    ```
    $ neutron router-interface-add $Zabbix_GHOST_ROUTER_ID $Zabbix_SUBNET_ID

    $ neutron router-interface-add $Zabbix_GHOST_ROUTER_ID $GHOST_SUBNET_ID

    ```

  A few minutes later, the Zabbix server and the Ghost server will contact each other directly. To provide an "executable documentation" the integration of a Ubuntu server, we will use Ansible for the future.

  5. Make sure you can log:
      * SSH
      * user `cloud`
      * Ghost server
      * since Zabbix-server

  6. Since the Zabbix-server, add the connection information in the inventory `/etc/ansible/hosts` :

  ```         
  [...]

  [slaves]
  xx.xx.xx.xx ansible_ssh_user=cloud ansible_ssh_private_key_file=/home/cloud/.ssh/id_rsa_ghost_server.pem

  [...]
  ```

  7. Start the playbook `slave-monitoring_zabbix.yml` as Zabbix root on the server:
  ```
  # ansible-playbook /root/slave-monitoring_zabbix.yml
  ```

This playbook  will do all the installation and setup on the Ghost server to integrate monitoring Zabbix.

Now, our monitoring server and client are configured. We need to access the Zabbix Web UI using the IP address of our server http://X.X.X.X

For your host (server Ghost here), can be monitoring by the Zabbix server, you must do the following operations:

  *   Click on Configuration Menu
  *   Click on Hosts submenu
  *   Click on Create Host button at right side


  ![Ajouter un host zabbix ](https://www.zabbix.com/documentation/2.2/_media/manual/quickstart/new_host.png?cache=)

  Now fill the following details of remote host and go to Templates tab.

  *   Click on add link (chose for exemple **template OS linux**) 
  *   Select desired Template : Please select carefully, Because it will enabled all checks for the host
  *   Click on save button

  ![Lier un template ] (https://watilearnd2day.files.wordpress.com/2015/08/zabbix-configuration9.jpg?w=606&h=410) 


  Congratulation! You can view the metric of your zabbix agents monitor by Zabbix-server.

 ![Visualiser les métriques ](http://glpi.objetdirect.com/wp-content/uploads/2014/01/zabbix_webgraph.png)


<a name="console" />


### Please console me

There there, it's okay... Zabbix stacks can be spawned from our console as well!

To create our Zabbix stack from the console:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-zabbix](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-zabbix) repository
2.	Click on the file named `bundle-trusty-Zabbix.heat.yml`
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

## So watt?

This tutorial aims to improve your startup. At this stage you are master on board.
You have an entry point to your virtual machine via SSH floating IP exposed and your private key (`cloud` user by default).
You can start to live your monitoring taking hold of your server.

#### The interesting directories are:

* `/etc/default/zabbix-server`: the directory containing the Zabbix-server configuration file
* `/etc/zabbix/zabbix_server.conf`: Containing directory tea tea zabbix-server configuration file
* `/usr/share/zabbix-server-mysql/`: the directory containing the files in the database zabbix-server-mysql
* `/var/log/zabbix-server/zabbix_server.log`: the directory containing the log.
* `/etc/zabbix/zabbix.conf.php`: the directory containing the interface configuration file Zabbix

#### Other resources you could be interested in:

* [Zabbix-monitoring Homepage](http://www.zabbix.com/)
* [Zabbix documentation](https://www.zabbix.com/documentation/2.2/start)

