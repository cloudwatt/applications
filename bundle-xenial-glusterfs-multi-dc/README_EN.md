# 5 Minutes Stacks, episode 29 : GlusterFs multi Data center #

## Episode 29 : GlusterFs multi Data center

![gluster](https://www.gluster.org/images/antmascot.png?1458134976)

GlusterFS is a powerful network/cluster filesystem written in user space which uses FUSE to hook itself with VFS layer.
GlusterFS takes a layered approach to the file system, where features are added/removed as per the requirement.
Though GlusterFS is a File System, it uses already tried and tested disk file systems like ext3, ext4, xfs, etc. to store the data.
It can easily scale up to petabytes of storage which are available to user under a single mount point.

In this episode, we will create two glusterfs replicate between them, but they are not in the same zone.


## Preparations

### The version
 - Ubuntu Xenial 16.04
 - GlusterFS 3.7

### The prerequisites to deploy this stack

 * an internet acces
 * a Linux shell
 * a [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab) with access to both regions fr1 and fr2
 * the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

 Per default, the script is proposing a deployement on an instance type "Standard 1" (n1.cw.standard-1) for fr1 zone and "Standard 1" (n2.cw.standard-1) for fr2. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Pricing page](https://www.cloudwatt.com/en/pricing.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

 If you do not like command lines, you can go directly to the "run it through the console" section by clicking [here](#console)

## What will you find in the repository

 Once you have cloned the github, you will find in the `bundle-xenial-glusterfs-multi-dc/` repository:

* `bundle-xenial-glusterfs-multi-dc-fr1.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure in fr1 zone.
* `bundle-xenial-glusterfs-multi-dc-fr2.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure in fr2 zone.

* `stack-start-fr1.sh`:  Stack launching script in fr1 zone . This is a small script that will save you some copy-paste.
* `stack-start-fr2.sh`:  Stack launching script in fr2 zone . This is a small script that will save you some copy-paste.

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

 With the `bundle-xenial-glusterfs-multi-dc-fr2.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

~~~ yaml
heat_template_version: 2013-05-23
description: All-in-one Glusterfs Multi DC
parameters:
  keypair_name:   
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string
    default: my_keypair_name        <-- Indicate here your keypair

  flavor_name:
    default: n2.cw.standard-1
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
         - n2.cw.standard-1
         - n2.cw.standard-2
         - n2.cw.standard-4
         - n2.cw.standard-8
         - n2.cw.standard-16
         - n2.cw.highmem-2
         - n2.cw.highmem-4
         - n2.cw.highmem-8
         - n2.cw.highmem-16
[...]
~~~

 With the `bundle-xenial-glusterfs-multi-dc-fr1.heat.yml` file, you will find at the top a section named `parameters`. The both parameters to adjust are the first called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account and the second called `slave_public_ip` must contain flotting ip stack fr2. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

 ~~~ yaml
heat_template_version: 2013-05-23
description: All-in-one Glusterfs Multi Dc
parameters:
  keypair_name:
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string
    default: my-keypair-name                <-- Indicate here your keypair

  flavor_name:
    default: n1.cw.standard-1
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
          - n1.cw.standard-1
          - n1.cw.standard-2
          - n1.cw.standard-4
          - n1.cw.standard-8
          - n1.cw.standard-12
          - n1.cw.standard-16

  slave_public_ip:                        
     type: string
     label: slave public ip
     default: 0.0.0.0                      <-- Indicate here flotting ip glusterfs dc 2

[...]
~~~
### Start stack

 In a shell, run the script `stack-start.sh`:

~~~bash
$ export OS_REGION_NAME=fr2
$ ./stack-start-fr2.sh your_stack_name
~~~

Exemple :

$ ./stack-start-fr2.sh  your_stack_name
~~~bash
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | you_stack_name       | CREATE_IN_PROGRESS |  |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

 Wait **5 minutes** the stack will be fully operational. (Use watch to see the status in real-time)

~~~bash
$ heat resource-list your_stack_name
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name    | physical_resource_id                                | resource_type                   | resource_status | updated_time         |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip      | 44dd841f-8570-4f02-a8cc-f21a125cc8aa                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| security_group   | efead2a2-c91b-470e-a234-58746da6ac22                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| network          | 7e142d1b-f660-498d-961a-b03d0aee5cff                | OS::Neutron::Net                | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| subnet           | 442b31bf-0d3e-406b-8d5f-7b1b6181a381                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| server           | f5b22d22-1cfe-41bb-9e30-4d089285e5e5                | OS::Nova::Server                | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| floating_ip_link | 44dd841f-8570-4f02-a8cc-f21a125cc8aa-`floating_ip_stack_fr2`  | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------
~~~

The `start-stack-fr2.sh` script takes care of running the API necessary requests to execute the normal heat template which:

* Starts an Ubuntu xenial based instance on fr2 zone
* Expose it on the Internet via a floating IP.

After deployment of the stack on fr2 zone, you can launch the stack on fr1 zone.
~~~bash
$ export OS_REGION_NAME=fr1
$ ./stack-start-fr1.sh your_stack_name
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | your_stack_name       | CREATE_IN_PROGRESS | 2016-06-22T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

The `start-stack-fr1.sh` script takes care of running the API necessary requests to execute the normal heat template which:

* Starts an Ubuntu xenial based instance on fr1 zone
* Expose it on the Internet via a floating IP.

<a name="console" />

## All of this is fine,
### but you do not have a way to create the stack from the console?

We do indeed! Using the console, you can deploy a the both glusterfs servers:

1.	Go the Cloudwatt Github in the [applications/bundle-xenial-glusterfs-multi-dc](https://github.com/cloudwatt/applications/tree/master/bundle-xenil-glusterfs-multi-dc) repository.
2.	Click on the file named `bundle-xenial-glusterfs-multi-dc-fr1(ou 2).heat.yml` (or `bundle-xenial-glusterfs-multi-dc-fr1(ou 2).restore.heat.yml` to [restore from backup](#backup))
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
6.	Click on « Launch stack », then « Template file » and select the file you just saved to your PC, and finally click on « NEXT »
7.	Name your stack in the « Stack name » field
8.	Enter the name of your keypair in the « SSH Keypair » field
9.  Write a passphrase that will be used for encrypting backups
10.	Choose your instance size using the « Instance Type » dropdown and click on « LAUNCH »

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating IP, or simply refresh the current page and check the Overview tab for a handy link.

If you've reached this point, you're already done! Go enjoy GlusterFS!

## Enjoy

In order to test the replication state between the both servers, connect to glusterfs fr1, then type the following command.
~~~bash
# gluster vol geo-rep datastore your_stack_name-gluster-dc2::datastore status
MASTER NODE            MASTER VOL    MASTER BRICK     SLAVE USER    SLAVE                             SLAVE NODE             STATUS    CRAWL STATUS       LAST_SYNCED                  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
your_stack_name-gluster-dc1    datastore     /brick/brick1    root          your_stack_name-gluster-dc2::datastore    your_stack_name-gluster-dc2    Active    Changelog Crawl    2016-06-23 10:35:56          
your_stack_name-gluster-dc1    datastore     /brick/brick2    root          your_stack_name-gluster-dc2::datastore    your_stack_name-gluster-dc2    Active    Changelog Crawl    2016-06-23 10:35:56    
~~~

You can mount the glusterfs volume in a client machine that connects to the same network as the server machine :
~~~bash
# apt-get -y install gusterfs-client
# mkdir /mnt/datastore
# mount -t glusterfs your_stack_name-gluster-dc1:datastore /mnt/datastore
~~~

**To restart gluterfs-server service **

~~~ bash
# service glusterfs-server restart
~~~


## So watt?

On each server glusterfs either fr1 or fr2, we created a replication volume `datastore` that contains two bricks `/brick/brick1` and `/brick/brick2`,
so you can add other bricks for knowing how, click on this [link](https://access.redhat.com/documentation/en-US/Red_Hat_Storage/2.1/html/Administration_Guide/Expanding_Volumes.html).


### Other resources you could be interested in:
*[ GlusterFs Home page](http://www.gluster.org/)

----
Have fun. Hack in peace.
