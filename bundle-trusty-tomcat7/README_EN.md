# 5 Minutes Stacks, Episode eight: Tomcat 7

## Episode eight: Tomcat 7

For this eighth episode, we doubled back and prepared a classic: Tomcat 7.

## Preparations

### The version

* Tomcat 7 (tomcat7) 7.0.52-1ubuntu0.3

### The prerequisites to deploy this stack

These should be routine by now:

* Internet access
* A Linux shell
* A [Cloudwatt account](https://www.cloudwatt.com/authentification) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository

### Size of the instance

By default, the stack deploys on an instance of type "Small" (s1.cw.small-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website).

Other stack parameters, of course, are yours to tweak at your fancy.

### By the way...

Should the word 'terminal' conjure images of mortal illnesses, do not fret. Tomcat 7 stacks can be started directly from the [console](#console), just like its predecessors.

## What will you find in the repository

Once you have cloned the github, you will find in the `bundle-trusty-tomcat7/` repository:

* `bundle-trusty-tomcat7.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh`: Stack launching script, taking just the stack name as a parameter.
* `stack-get-url.sh`: A handy-dandy URL maker. Depending on your terminal, you might even be able to click it!

## Start-up

### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
If you are not logged in yet, complete the authentication and the credentials script will download. With it, you will be able to wield the awe-inspiring powers of the various Cloudwatt APIs.

Source the downloaded file in your shell. Your password will be requested.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

$ [some sweet shell input...]
~~~

Once this done, the Openstack command line clients can interact with your Cloudwatt user account.

### Adjust the parameters

In the `.heat.yml` files, you will find a section named `parameters` near the top. The sole mandatory parameter is `keypair_name`. Its `default` value should contain a valid keypair with regards to your Cloudwatt user account, if you wish to avoid repeatedly typing it into the command line.

It is within this same file that you can adjust (and set the defaults for) the instance type, modifying the `flavor` parameter accordingly.

By default, the stack network and subnet are generated for the stack, in which the Tomcat 7 server sits alone. This behavior can be changed within the `.heat.yml` as well, if need be.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Tomcat7 stack


parameters:
  keypair_name:
    default: my-keypair-name                <-- Indicate your keypair here
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: s1.cw.small-1                  <-- Indicate your instance type here
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
          - s1.cw.small-1
          - n1.cw.standard-1
          - n1.cw.standard-2
          - n1.cw.standard-4
          - n1.cw.standard-8
          - n1.cw.standard-12
          - n1.cw.standard-16

resources:
  network:                                  <-- Network settings
    type: OS::Neutron::Net

  subnet:                                   <-- Subnet settings
    type: OS::Neutron::Subnet
    properties:
      network_id: { get_resource: network }
      ip_version: 4
      cidr: 10.0.1.0/24
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.199 }
[...]
~~~

### Start up the stack

In a shell, run the script `stack-start.sh` with its unique new name as the only parameter:

~~~ bash
$ ./stack-start.sh Bobcat8
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | Bobcat8    | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Last, wait 5 minutes until the deployment been completed. (Use watch to see the status in real-time)

~~~ bash
$ watch heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | Bobcat8    | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script.

~~~ bash
$ ./stack-get-url.sh Bobcat8
Bobcat8 http://70.60.637.17
~~~

As shown above, it will inject the IP of your stack into a URL. You can then click or paste this into your browser of choice, and sigh as you realize we just did all the heavy lifting. Enjoy Tomcat 7.

## In the background

The  `start-stack.sh` script is takes care of running the API-necessary requests to execute the normal heat template which:
* starts an Ubuntu Trusty Tahr based instance
* attaches an exposed floating IP

<a name="console" />

### All of this is fine, but could I just create stacks from the console?

You could indeed! Using the console, deploying a Tomcat 7 server is simple:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-tomcat7](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-tomcat7) repository
2.	Click on the file named `bundle-trusty-tomcat7.heat.yml`
3.	Select « RAW » near the top left, a web page will appear containing purely the template (or you know, just click [here](https://raw.githubusercontent.com/cloudwatt/applications/master/bundle-trusty-tomcat7/bundle-trusty-tomcat7.heat.yml))
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the `.txt`)
5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
6.	Click on « Launch stack », then « Template file » and select the file you just saved to your PC, and finally click on « NEXT »
7.	Name your stack in the « Stack Name » field
8.	Enter the name of your keypair in the « SSH Keypair » field
9.	Choose your instance size using the « Instance Type » dropdown and click on « LAUNCH »

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating IP, or simply refresh the current page and check the Overview tab for a handy link.

If you've reached this point, Tomcat 7 is ready! Cross that off your to-do list for world domination.

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

You now have an SSH access point on your virtual machine (through the floating IP and your private keypair, with the default user name `cloud`).

Some interesting directories are:

- `/etc/apache2/sites-available/default-tomcat.conf`: Apache proxy configuration file for Tomcat 7. By default this is the only site enabled.
- `/var/lib/tomcat7/webapps/`: Tomcat 7's default app directory.
- `/var/lib/tomcat7/webapps/ROOT.war`: Sample WAR file from [the official site](https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/).
- `/var/lib/tomcat7/webapps/ROOT/`: Deployed sample app, automatically generated by Tomcat 7 from the ROOT.war.
- `/etc/tomcat7/server.xml`: Main Tomcat 7 configuration file.

Other resources you could be interested in:

* [Tomcat Main Site](http://tomcat.apache.org/)
* [Tomcat 7 Documentation](https://tomcat.apache.org/tomcat-7.0-doc/)
* [Tomcat 7 Developer Site](https://tomcat.apache.org/tomcat-7.0-doc/appdev/)


-----
Have fun. Hack in peace.
