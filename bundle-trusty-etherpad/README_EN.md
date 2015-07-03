# 5 Minutes Stacks, Episode six : Etherpad

## Episode six : Etherpad

For this sixth episode, it is now time to talk about Etherpad. Etherpad is a real time collaborative text editor. It allows different users to edit a document simultaneously and to display in real time the modifications done by other contributors.

Following this tutorial, you will get an Ubuntu Trusty Tahr instance, pre-configured with an NGinx on the port 80 which is forwarding towards a Node.js server, monitored by [Foreverjs](https://github.com/foreverjs/forever) and which display an instance of the Etherpad engine.

## Preparations

### The versions

* Node.js 0.10.25
* Etherpad 1.5.6

### The prerequisites to deploy this stack

There are the same than for the previous episodes :

* an internet acces
* a Linux shell
* a [Cloudwatt account](https://www.cloudwatt.com/authentification), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

Per default, the script is proposing a deployement on an instance type "Small" (s1.cw.small-1). Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console). 

## What will you find in the repository

Once you have cloned the github, you will find in the `bundle-trusty-etherpad/` repository:

* `bundle-trusty-etherpad.heat.yml` : HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh` : Stack launching script. This is a small script that will save you some copy-paste.
* `stack-get-url.sh` : Flotting IP recovery script.

## Start-up

### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). 
If you are not logged in yet, you will go thru the authentication screen then the script download will start. Thanks to it, you will be able to initiate the shell acccesses towards the Cloudwatt APIs.

Source the downloaded file in your shell. Your password will be requested. 

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Adjust the parameters

With the `bundle-trusty-etherpad.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. 
Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. 
This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

~~~ bash
heat_template_version: 2013-05-23


description: All-in-one ETHERPAD stack


parameters:
  keypair_name:
    default: my-keypair-name                   <-- Indicate here your keypair
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: s1.cw.small-1
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
[...]
~~~

### Start up the stack

In a shell, run the script `stack-start.sh` with the name you want to give it as parameter:

~~~ bash
$ ./stack-start.sh DIETHYL
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| ed4ac18a-4415-467e-928c-1bef193e4f38 | DIETHYL    | CREATE_IN_PROGRESS | 2015-04-21T08:29:45Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Last, wait 5 minutes until the deployement been completed.

### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script. It will gather the entry url of your stack.

~~~ bash
./stack-get-url.sh DIETHYL
DIETHYL 82.40.34.249
~~~

It will gather the assigned flotting IP of your stack. You can then paste this IP in your favorite browser and start to configure your Etherpad instance.

## In the background

The  `start-stack.sh` script is taking care of running the API necessary requests to: 
* start an Ubuntu Trusty Tahr based instance
* show a flotting IP on the internet

<a name="console" />

### All of this is fine, but you do not have a way to run the stack thru the console ?

Yes ! Using the console, you can deploy a Etherpad server:

1.	Go the Cloudwatt Github in the applications/bundle-trusty-etherpad repository
2.	Click on the file nammed bundle-trusty-etherpad.heat.yml
3.	Click on RAW, a web page appear with the script details
4.	Save as its content on your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
6.	Click on « Launch stack », then click on « Template file » and select the file you've just saved on your PC, then click on « NEXT »
7.	Named your stack in the « Stack name » field
8.	Enter your keypair in the « keypair_name » field
9.	Choose the instance size using the « flavor_name » popup menu and click on « LAUNCH »

The stack will be automatically created (you can see its progress by clicking on its name). When all its modules will become "green", the creation will be completed. Then you can go on the "Instances" menu to discover the flotting IP value that has been automatically generated. Now, just run this IP adress in your browser and enjoy !

It is (already) FINISH !

## So watt ?

The goal of this tutorial is to accelarate your start. At this point you are the master of the stack.

You have a SSH access point on your virtual machine thru the flotting IP and your private keypair (default user name `cloud`).

The interesting entry access points are:

- `/var/lib/www` : Installation directory of the Etherpad application. This is the directory exposed by Node.js
- `/etc/nginx/sites-available/node_proxy` : Nginx configuration file dedicated to the proxying HTTP towards Node.js
- `/etc/init.d/nodejs` : Init script of the Node.js thru Foreverjs.

Other resources you could be interested in :

* [Documentation NGinx](http://nginx.org/en/docs/)


-----
Have fun. Hack in peace.
