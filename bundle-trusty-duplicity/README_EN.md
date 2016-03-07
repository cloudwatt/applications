# 5 Minutes Stacks, episode 23 : Duplicity #

## Episode 23 : Duplicity

![Backuplogo](img/logobackup.jpg)

The duplicity utility is a tool **in command line** allowing to make incremental backup of files and directories.

Duplicity backs directories by producing encrypted tar-format volumes and uploading them to a remote or local file server. Because duplicity uses librsync, the incremental archives are space efficient and only record the parts of files that have changed since the last backup. Because duplicity uses GnuPG to encrypt and/or sign these archives, they will be safe from spying and/or modification by the server.

### The Versions
 - Ubuntu Trusty 14.04.2
 - Duplicity 0.7.06

### The prerequisites to deploy this stack

These should be routine by now:

 * Internet access
 * A Linux shell
 * A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository (if you are creating your stack from a shell)


### Size of the instance

By default, the stack deploys on an instance of type "Small" (s1.cw.small-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Pricing page](https://www.cloudwatt.com/en/pricing.html) on the Cloudwatt website).

Duplicity stacks follow in the footsteps of our previous volume-using stacks, making good use of Cinder Volume Storage to ensure the protection of your data and allowing you to pay only for the space you use. Volume size is fully adjustable, and the Duplicity stack can support tens to tens of hundreds of gigabytes worth of project space.

 Stack parameters, of course, are yours to tweak at your fancy.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console)

## What will you find in the repository

 Once you have cloned the github, you will find in the `bundle-trusty-duplicity/` repository:

 * `bundle-trusty-duplicity.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
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

With the `bundle-trusty-duplicity.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameters to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account.The `passcode`  will allow you to encrypt your backups. You can also indicate the `volume_size` who will attach on your stack. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

~~~ yaml
heat_template_version: 2016-02-09


description: Basic all-in-one Duplicity stack


parameters:
  keypair_name:
    default: keypair_name        <-- Indicate here your keypair
    description: Keypair to inject in instances
    type: string

  flavor_name:
    default: s1.cw.small-1              <-- indicate here the flavor size
    description: Flavor to use for the deployed instance
    type: string
    constraints:
      - allowed_values:
          - t1.cw.tiny
          - s1.cw.small-1
          - n2.cw.standard-1
          - n2.cw.standard-2
          - n2.cw.standard-4
          - n2.cw.standard-8
          - n2.cw.standard-16
          - n2.cw.highmem-2
          - n2.cw.highmem-4
          - n2.cw.highmem-8
          - n2.cw.highmem-12


   volume_size:
      default: 10                                       <------ Indicate Volume Size
      label: Backup Volume Size
      description: Size of Volume for DevKit Storage (Gigabytes)
      type: number
      constraints:
        - range: { min: 10, max: 10000 }
          description: Volume must be at least 10 gigabytes               

[...]
~~~

In a shell, run the script `stack-start.sh`:

~~~
./stack-start.sh stack_name
~~~

Exemple :

~~~bash
$ ./stack-start.sh DUPLICITY
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | DUPLICITY       | CREATE_IN_PROGRESS | 2015-11-25T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Within 5 minutes the stack will be fully operational. (Use `watch` to see the status in real-time)

~~~bash
$ watch heat resource-list DUPLICITY
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

<a name="console" />

## All of this is fine, but...

### You do not have a way to create the stack from the console?

We do indeed! Using the console, you can deploy a Duplicity server:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-dupliciy](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-duplicity) repository
2.	Click on the file named `bundle-trusty-duplicity.heat.yml` (or `bundle-trusty-duplicity.restore.heat.yml` to [restore from backup](#backup))
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

... Good! Go to the [Apps page](https://www.cloudwatt.com/fr/applications/index.html) on the Cloudwatt website, choose the apps, press **DEPLOYER** and follow the simple steps... 2 minutes later, a green button appears... **ACCEDER**: you have your Duplicity server!

![logosvgcloud](http://www.cachem.fr/wp-content/uploads/2015/09/nuage-backup1.jpg)

### Network visibility
Network visibility must now create between our stack Duplicity and the rest of the machines in your tenant. During the creation of a stack Duplicity, a router was created for attach different networks, here's how:

1. In first time, you must know the id of the router in Duplicity stack. This is possible via the following command:
~~~
heat resource-list $DUPLICITY_STACK_NAME
~~~
~~~bash
+--------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name      | physical_resource_id                                                                | resource_type                   | resource_status | updated_time         |
+--------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| network            | a29ce347-969a-4ba9-8da6-c909f1b249b7                                                | OS::Neutron::Net                | CREATE_COMPLETE | 2016-03-07T09:00:00Z |
| volume             | c04798dd-dc12-4456-a92d-91ce9871c3a5                                                | OS::Cinder::Volume              | CREATE_COMPLETE | 2016-03-07T09:00:00Z |
| floating_ip        | f65cebbf-a7b5-47b4-b2cd-a7a212288263                                                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2016-03-07T09:00:01Z |
| router             | dd25c093-0076-4664-8713-0c3488ea78d9                                                | OS::Neutron::Router             | CREATE_COMPLETE | 2016-03-07T09:00:01Z |
| security_group     | cf5b2af8-1455-4c16-972e-4b5f96a56f4c                                                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2016-03-07T09:00:01Z |
| server_init        | f4cf30ab-02d8-4896-8796-537369c6d787                                                | OS::Heat::SoftwareConfig        | CREATE_COMPLETE | 2016-03-07T09:00:01Z |
| subnet             | 4b39f6ac-44ec-4482-9732-28449db8856b                                                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2016-03-07T09:00:04Z |
| backup_interface   | `dd25c093-0076-4664-8713-0c3488ea78d9`:subnet_id=4b39f6ac-44ec-4482-9732-28449db8856b | OS::Neutron::RouterInterface    | CREATE_COMPLETE | 2016-03-07T09:00:07Z |
| server             | 115a1f0b-f537-418d-a7c5-f6c6c5d65b60                                                | OS::Nova::Server                | CREATE_COMPLETE | 2016-03-07T09:00:08Z |
| volume_attachement | c04798dd-dc12-4456-a92d-91ce9871c3a5                                                | OS::Cinder::VolumeAttachment    | CREATE_COMPLETE | 2016-03-07T09:00:38Z |
| floating_ip_link   | f65cebbf-a7b5-47b4-b2cd-a7a212288263-84.39.34.17                                    | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2016-03-07T09:00:39Z |
+--------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
~~~

2. Let us find the ID of the subnet router to add Duplicity:

~~~bash

$ heat resource-list $NAME_STACK | grep subnet

| subnet           | babdd078-ddc8-4280-8cbe-0f77951a5933              | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-24T15:18:30Z |
~~~


3. Now make the connection between the router Duplicity IS and the network subnet ID to be added:
~~~bash
$ neutron router-interface-add $DUPLICITY_ROUTER_ID $STACK_SUBNET_ID
~~~

### Enjoy

Once all this makes you can connect on your server in SSH by using your keypair beforehand downloaded on your compute,

You are now in possession of a backup server,
it's able to generating a coded backup and to copy them where you want, duplicity is able to making back up full and incremental (Incremental means that only the changed parts of files are taken into account since the previous backup).
Be carreful if you make a incremental backup, Duplicity needs all of them to restore backup,

**Helpful hint:** make a full backup in week and one incremental per days to have a clean backup solution,

By default all codes and passphrase generated by the application are stored in `/etc/duplicity`, you will find a file `dup_vars.sh` containing all the relevant information to make all the examples presented below. If you want to do remote backup you have to copy or create your ssh key on the Duplicity server for it can authenticate to the remote server, the path to your key will write into the option ` --ssh-option ` of `duplicity` command.

For information when you make the first backup duplicity will do a fully backup and after incremental. Duplicity will look at the signature of the file to be restored, if the signature matches an existing backup Duplicity will launch an incremental backup.If you want to make a fully backup all the time you can use this duplicity command `duplicity full`.



Generating incremental backups encrypt , including databases , make's Duplicity an ideal backup solution for self-hosting .

### Examples easy to use:

To make backup with file list:

~~~
duplicity /your_directory file:///var/backups/duplicity/ --include-globbing-filelist filelist.txt --exclude '**'
~~~

To make backup in a remote server without keypair:
~~~
duplicity --encrypt-key key_from_GPG --exclude files_to_exclude --include files_to_include path_to_back_up sftp://root@backupHost//remotebackup/duplicityDroplet
~~~
To make backup and copy in a remote server with keypair & passphrase & encrypt-key:
~~~
PASSPHRASE="yourpassphrase" duplicity --encrypt-key your_encrypt_key --exclude /proc --exclude /sys --exclude /tmp / sftp://cloud@DuplicityPrivateIP//directory --ssh-option="-oIdentityFile=keypair_path"
~~~

To make restore  without Encryption:
~~~
duplicity restore file:///var/backups/duplicity/ /any/directory/
~~~  
To make restore on remote server with keypair, passphrase and ecrypt-key:
~~~
PASSPHRASE="yourpassphrase" duplicity sftp://cloud@floating_ip//your_sauvegarde_directory --ssh-option="-oIdentityFile=/home/cloud/.ssh/yourkeypair.pem" /your_restore_directory
~~~

You can backup your database with sql export in .sql
~~~
mysql -uroot -ppassword --skip-comments -ql my_database > my_database.sql
~~~

#### Now that you have learned to use the product go further ...

![schmeasvg](http://www.itpro.fr/upload/picture/2011/08/29/ca41fb53bb2098700e2c9ee5cb4c14a0.jpg)

**Now automate backups:**

To automate the backup you can use CRON installed by default on the server. it's going to allow you to **schedule** your backup.


**One thing to keep in mind:** When a service running on the server to save a lock is placed on the files used by it. If you want to make a backup **FULL**, you have to stop all services.

To help manage backups , I propose to centralize on a **volume** attached to the server Duplicity.This one is mounted on the start of the stack . I did it for separate the server of your backups for more **security** and **flexibility**. The volume is mounted in `/mnt/vdb/`, it will allow you to have a completely independent backup set of your server Duplicity.

This following command, backup a server in your infrastructure from your Duplicity server and storing the backup on the volume attach with Duplicity:
~~~
ssh cloud@iPremoteserver -i ~/.ssh/yourkeypair.pem "duplicity  --exclude /proc --exclude /sys --exclude /tmp / sftp://cloud@IPduplicity//mnt/vdb/ --ssh-option="-oIdentityFile=/home/cloud/.ssh/yourkeypair.pem""
~~~


**Latest news :** During a restore , for the system can write all the information , it is best to run as a ` root`.

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

You now have an SSH access point on your virtual machine through the floating-IP and your private keypair (default user name `cloud`).

You can start developing your backup plan. Here are useful entry points:

* `/etc/duplicity` : all key and passphrase needed to operate duplicity

* Here are some news sites to learn more:

    - http://duplicity.nongnu.org/
    - http://www.linuxuser.co.uk/tutorials/create-secure-remote-backups-using-duplicity-tutorial
    - https://www.digitalocean.com/community/tutorials/how-to-use-duplicity-with-gpg-to-securely-automate-backups-on-ubuntu

    -----
    Have fun. Hack in peace.
