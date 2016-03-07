# 5 Minutes Stacks, épisode 24 : CozyCloud #

## Episode 24 : CozyCloud

![CozyCloudlogo](http://blog.jingleweb.fr/wp-content/uploads/2015/03/bighappycloud.png)


Cozycloud your free personal cloud server. Unlike other personal cloud , Cozy focuses on applications and collaboration applications around your personal data. Cozy is a solution of PaaS (Platform as a Service) staff that allows you to deploy personal web applications in one click . This is rich web applications. You can choose from existing Cozy applications (Notes , Todos , Calendar, Contacts , Photos ... ) , adapting an existing Node.js application or start your own web application " from-scratch " ( documentation and tutorials available).

A feature of Cozy is the centralization of storage for different applications in a common database with typed data and control of access by data type. In this way the different applications work with the same source data (contacts, mails, notes ... ). Cozycloud is currently focused on Node.js but support for Python and Ruby applications is expected. More cozy developed in **France** by **French developers**.

### The Versions
- Ubuntu Trusty 14.04.2
- Cozycloud 2.0

### The prerequisites to deploy this stack

These should be routine by now:

 * Internet access
 * A Linux shell
 * A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository (if you are creating your stack from a shell)


### Size of the instance

By default, the stack deploys on an instance of type "Small" (s1.cw.small-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website).

CozyCloud stacks follow in the footsteps of our previous volume-using stacks, making good use of Cinder Volume Storage to ensure the protection of your data and allowing you to pay only for the space you use. Volume size is fully adjustable, and the Cozycloud stack can support tens to tens of hundreds of gigabytes worth of project space.

 Stack parameters, of course, are yours to tweak at your fancy.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console)

## What will you find in the repository

 Once you have cloned the github, you will find in the `bundle-trusty-cozycloud/` repository:

 * `bundle-trusty-cozycloud.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
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

With the `bundle-trusty-cozycloud.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one CozyCloud stack


parameters:
  keypair_name:
    default: my-keypair-name                   <-- Rajoutez cette ligne avec le nom de votre paire de clés
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
In a shell, run the script `stack-start.sh`:

~~~
./stack-start.sh stack_name
~~~

Exemple :

~~~bash
$ ./stack-start.sh CozyCloud
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | CozyCloud       | CREATE_IN_PROGRESS | 2015-11-25T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Within **5 minutes** the stack will be fully operational. (Use `watch` to see the status in real-time)

~~~bash
$ watch heat resource-list Cozycloud
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name    | physical_resource_id                                | resource_type                   | resource_status | updated_time         |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip      | 44dd841f-8570-4f02-a8cc-f21a125cc8aa                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2015-11-25T11:03:51Z |
| security_group   | efead2a2-c91b-470e-a234-58746da6ac22                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2015-11-25T11:03:52Z |
| network          | 7e142d1b-f660-498d-961a-b03d0aee5cff                | OS::Neutron::Net                | CREATE_COMPLETE | 2015-11-25T11:03:56Z |
| subnet           | 442b31bf-0d3e-406b-8d5f-7b1b6181a381                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-25T11:03:57Z |
| server           | f5b22d22-1cfe-41bb-9e30-4d089285e5e5                | OS::Nova::Server                | CREATE_COMPLETE | 2015-11-25T11:04:00Z |
| floating_ip_link | 44dd841f-8570-4f02-a8cc-f21a125cc8aa-`floating IP`  | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2015-11-25T11:04:30Z |
  +------------------+-----------------------------------------------------+-------------------------------+-----------------+----------------------
~~~

The `start-stack.sh` script takes care of running the API necessary requests to execute the normal heat template which:

* Starts an Ubuntu Trusty Tahr based instance
* Expose it on the Internet via a floating IP.

![cozycloudlogo](http://www.woinux.fr/wp-content/uploads/2013/10/cozy-banner.jpg)

### All of this is fine, but you do not have a way to create the stack from the console?

We do indeed! Using the console, you can deploy a cozycloud server:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-cozycloud](https://github.com/cloudwatt/applications/tree/master/bbundle-trusty-cozycloud) repository
2.	Click on the file named `bbundle-trusty-cozycloud.heat.yml` (or `bbundle-trusty-cozycloud.restore.heat.yml` to [restore from backup](#backup))
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
6.	Click on « Launch stack », then « Template file » and select the file you just saved to your PC, and finally click on « NEXT »
7.	Name your stack in the « Stack name » field
8.	Enter the name of your keypair in the « SSH Keypair » field
9.  Write a passphrase that will be used for encrypting backups
10.	Choose your instance size using the « Instance Type » dropdown and click on « LAUNCH »

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating IP, or simply refresh the current page and check the Overview tab for a handy link.

If you've reached this point, you're already done! Go enjoy Duplicity!

### A one-click chat sounds really nice...

... Good! Go to the [Apps page](https://www.cloudwatt.com/fr/applications/index.html) on the Cloudwatt website, choose the apps, press **DEPLOYER** and follow the simple steps... 2 minutes later, a green button appears... **ACCEDER**: you have your cozycloud server!

### Enjoy

Once all this makes you can connect on your server in SSH by using your keypair beforehand downloaded on your compute,


You are now in possession of your own cloud server , you can enter via the URL ` https:// ip-floatingip.rev.cloudwatt.com` by replacing the `.` your floating IP by `-` ( example: ip-10-11-12-13.rev.cloudwatt.com ). Your full URL will be present in the file `/etc/ansible/cozy-vars.yml`.

An SSL certificate is automatically generated via Let's encrypt and it is renewed via a CRON job every 90 days,

You can now download the android application and sync your data with your cozy, this one being hosted in France in a safe environment, you can completely trust on this product.

![prezcozy](http://www.usine-digitale.fr/mediatheque/2/3/2/000337232_homePageUne/cozy-cloud.jpg)

On the desktop of your cozy you'll find a button `Store` it will be your marketplace , you can install a mail server or a ghost for example. The list is completed by the day , more contributions via git repository are possible, the cozy community enlarged more and more .

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

You now have an SSH access point on your virtual machine through the floating-IP and your private keypair (default user name `cloud`).

* You have access to the web interface en https via the address specified in this file `/etc/ansible/cozy-vars.yml`.

* Here are some news sites to learn more:

- https://cozy.io/en/    
- https://forum.cozy.io/
- https://blog.cozycloud.cc/
