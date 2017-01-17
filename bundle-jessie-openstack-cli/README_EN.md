# 5 Minutes Stacks, 46 episode : OpenStack CLI #

## Episode 46 : OpenStack CLI

This stack helps you to control the different modules of the CloudWatt Openstack infrastructure.
We start by Debian Jessie image with the openstack client installed and your credentials that will allow you to access the Cloudwatt API via the shell of the instance.

## Preparations

### The version

* openstackclient 3.6.0

### The prerequisites to deploy this stack

 * an internet acces
 * a Linux shell
 * a [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)


### Size of the instance

 By default, the stack deploys on an instance of type "Tiny" (t1.cw.tiny). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website).

 Other stack parameters, of course, are yours to tweak at your fancy.

## Start-up

### but you do not have a way to create the stack from the console?

We do indeed! Using the console, you can deploy a Openstack CLi server:

1.	Go the Cloudwatt Github in the [applications/Jestart](https://github.com/cloudwatt/applications/tree/master/Jestart) repository
2.	Click on the file named 'bundle-jessie-openstack-cli.heat.yml'
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
6.	Click on « Launch stack », then « Template file » and select the file you just saved to your PC, and finally click on « NEXT »
7.	Name your stack in the « Stack name » field and click "LAUNCH"
8.	Enter the name of your keypair in the « SSH Keypair » field
9.	Choose your instance size using the « Instance Type » dropdown and click on « LAUNCH »
10. Enter the name of your network_name in the « network_name » field
11. Enter the name of your os_auth_url in the « os_auth_url  » field
12. Choose the region (fr1 or fr2) From the drop-down menu « os_region_name »
13. Enter the name of your os_tenant_name in the « os_tenant_name » field
14. Enter the name of your os_username in the « os_username » field
15. Enter the name of your os_password in the « os_password » field then click « LAUNCH »


The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete.
If you've reached this point, you're already done!

### A one-click chat sounds really nice...

... Good! Go to the [Apps page](https://www.cloudwatt.com/fr/applications/index.html) on the Cloudwatt website, choose the apps, press **DEPLOYER** and follow the simple steps... 2 minutes later, a green button appears... **ACCEDER**: you have your stack !

## Enjoy

### Some examples of using the `openstack` command.

You now have an SSH access point on your virtual machine (through the floating IP and your private keypair, with the default user name `cloud`).


To display the instances that are on your tenant :
~~~bash
$ openstack server list
~~~  

To display the images that are on your tenant :
~~~bash
$ openstack image list
~~~  

To display the networks that are on your tenant :
~~~bash
openstack network list
~~~

To creat a stack via heat template:
~~~bash
$ openstack stack create MYSTACK --template server_console.yaml
~~~

To display your stack details:
~~~bash
$ openstack stack resource list MYSTACK
~~~

To display how to use `openstack` commande :
~~~bash
$ openstack help
~~~

The environment variables are in `/home/cloud/.bashrc` file, for dislaying:
~~~bash
$ env | grep OS

OS_REGION_NAME=fr1
OS_PASSWORD=xxxxxxxxxxxxxxxxxxxxx
OS_AUTH_URL=https://identity.fr1.cloudwatt.com/v2.0
OS_USERNAME=your_username
OS_TENANT_NAME=xxxxxxxxxxxxxxxxxx
~~~

### Other resources you could be interested in:

* [Openstack-cli page](http://docs.openstack.org/user-guide/cli-cheat-sheet.html)
* [Cloudwatt tutorial](https://support.cloudwatt.com/debuter/cli-fin.html)

----
Have fun. Hack in peace.
