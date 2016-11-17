## 5 Minutes Stacks, episode 39 BioLinux 8 #

## Episode 39 : BioLinux 8

![logo](images/Biolinux.png)

Bio-Linux 8 is a powerful, free bioinformatics workstation platform that can be installed on anything from a laptop to a large server, or run as a virtual machine. Bio-Linux 8 adds more than 250 bioinformatics packages to an Ubuntu Linux 14.04 LTS base, providing around 50 graphical applications and several hundred command line tools. The Galaxy environment for browser-based data analysis and workflow construction is also incorporated in Bio-Linux 8.

### The versions

* BioLinux 8
* You will find The Softwares List in this [page](http://environmentalomics.org/bio-linux-software-list/)

### The prerequisites to deploy this stack

* an internet acces
* a Linux shell
* a [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

 Per default, the script is proposing a deployement on an instance type "Standard" (n1.cw.standard-1).  Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

 If you do not like command lines, you can go directly to the "run it through the console" section by clicking [here](#console)

## What will you find in the repository

 Once you have cloned the github, you will find in the `bundle-trusty-biolinux/` repository:

 * `bundle-trusty-biolinux.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
 * `stack-start.sh`: Stack launching script. This is a small script that will save you some copy-paste.
 * `stack-get-url.sh`: Flotting IP recovery script.


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

 With the `bundle-trusty-biolinux.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

 ~~~ yaml
 heat_template_version: 2013-05-23
 description: All-in-one Biolinux stack
 parameters:
  keypair_name:
     default: keypair_name        <-- Indicate here your keypair
     description: Keypair to inject in instances
     type: string
flavor_name:
     default: n1.cw.standard-1              <-- indicate here the flavor size
     description: Flavor to use for the deployed instance
     type: string
     constraints:
       - allowed_values:
         - n1.cw.highcpu-2
         - n1.cw.highcpu-4
         - n1.cw.highcpu-8
         - n1.cw.standard-1
         - n1.cw.standard-2
         - n1.cw.standard-4
         - n1.cw.standard-8
         - n1.cw.standard-12
         - n1.cw.standard-16
         - n1.cw.highmem-2
         - n1.cw.highmem-4
         - n1.cw.highmem-8
         - n1.cw.highmem-12

 resources:
 [...]
 ~~~
 ### Start stack

 In a shell, run the script `stack-start.sh`:

 ~~~ bash
 ./stack-start.sh your_stack_name
 ~~~
 Exemple :

 ~~~bash
 $ ./stack-start.sh EXP_STACK

 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | your_stack_name | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+--------------------+----------------------+
 ~~~

 Wait **5 minutes** the stack will be fully operational. (Use watch to see the status in real-time)

 ~~~ bash
 $ watch -n 1 heat stack-list
 +--------------------------------------+------------+-----------------+----------------------+
 | id                                   | stack_name | stack_status    | creation_time        |
 +--------------------------------------+------------+-----------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | your_stack_name | CREATE_COMPLETE | 2016-10-21T11:03:51Z |
 +--------------------------------------+------------+-----------------+----------------------+
 ~~~
 ~~~bash
$ watch heat resource-list your_stack_name
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name    | physical_resource_id                                | resource_type                   | resource_status | updated_time         |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip      | 44dd841f-8570-4f02-a8cc-f21a125cc8aa                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2016-10-21T11:03:51Z |
| security_group   | efead2a2-c91b-470e-a234-58746da6ac22                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2016-10-21T11:03:52Z |
| network          | 7e142d1b-f660-498d-961a-b03d0aee5cff                | OS::Neutron::Net                | CREATE_COMPLETE | 2016-10-21T11:03:56Z |
| subnet           | 442b31bf-0d3e-406b-8d5f-7b1b6181a381                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2016-10-21T11:03:57Z |
| server           | f5b22d22-1cfe-41bb-9e30-4d089285e5e5                | OS::Nova::Server                | CREATE_COMPLETE | 2016-10-21T11:03:00Z |
| floating_ip_link | 44dd841f-8570-4f02-a8cc-f21a125cc8aa-`floating IP`  | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2016-10-21T11:03:30Z |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------
~~~

The `start-stack.sh` script takes care of running the API necessary requests to execute the normal heat template which:

* Starts an Ubuntu Trusty Tahr based instance
* Expose it on the Internet via a floating IP.


## All of this is fine,
### but you do not have a way to create the stack from the console?

We do indeed! Using the console, you can deploy a Biolinux server:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-biolinux]https://github.com/cloudwatt/applications/tree/master/bundle-trusty-biolinux) repository
2.	Click on the file named `bundle-trusty-biolinux.heat.yml` (or `bundle-trusty-biolinux.restore.heat.yml` to [restore from backup](#backup))
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
6.	Click on « Launch stack », then « Template file » and select the file you just saved to your PC, and finally click on « NEXT »
7.	Name your stack in the « Stack name » field
8.	Enter the name of your keypair in the « SSH Keypair » field
9.  Write a passphrase that will be used for encrypting backups
10.	Choose your instance size using the « Instance Type » dropdown and click on « LAUNCH »

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating IP, or simply refresh the current page and check the Overview tab for a handy link.

If you've reached this point, you're already done! Go enjoy Biolinux!

### A one-click chat sounds really nice...

... Good! Go to the [Apps page](https://www.cloudwatt.com/fr/applications/index.html) on the Cloudwatt website, choose the apps, press **DEPLOYER** and follow the simple steps... 2 minutes later, a green button appears... **ACCEDER**: you have your Biolinux server!


### Enjoy

To access the machine, you have 2 choices:

1) By ssh.
~~~bash
 $ ssh cloud@floating_ip -i your_key_pair.pem
~~~

2) By nomachine client.
User is **cloud** and the default password **cloud**

![img1](images/1.png)

![img2](images/2.png)

![img3](images/3.png)

![img4](images/4.png)

![img5](images/5.png)

![img6](images/6.png)

![img7](images/7.png)

![img8](images/8.png)

![img9](images/9.png)

![img10](images/10.png)

In order to change cloud password use this command :
~~~bash
$ sudo passwd cloud
~~~

### Resources you could be interested in:

* [BioLinux homepage](http://environmentalomics.org/bio-linux/)

-----
Have fun. Hack in peace.
