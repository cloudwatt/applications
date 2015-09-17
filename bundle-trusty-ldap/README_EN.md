# 5 Minutes Stacks, Episode nine: LDAP

## Episode nine: LDAP

So... LDAP...

Following this tutorial, you will create an Ubuntu Trusty Tahr instance, pre-configured with LDAP, on it's own network.
This LDAP's network (and another network of your choice) will be connected through a Neutron Router, allowing secure and private access to LDAP from your other instances.

As with our GitLab bundle, all of LDAP's data will be stored in a dedicated volume capable of creating backups upon request.

By default, LDAP Account Manager (LAM) will also be running on the instance, accessible through HTTPS port 443 (automatically redirected from port 80).
From LAM you will be able to modify your LDAP database quickly and efficiently through an interface intuitive even to those who have no idea what LDAP is.

## Preparations

### The version

* LDAP (slapd, ldap-utils) 2.4.31-1
* LAM (ldap-account-manager) 4.4-1

### The prerequisites to deploy this stack

These should be routine by now:

* Internet access
* A Linux shell
* A [Cloudwatt account](https://www.cloudwatt.com/authentification) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository
* The ID of an Neutron Subnet containing servers who need to connect to your LDAP instance.

### Size of the instance

By default, the stack deploys on an instance of type "Small" (s1.cw.small-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website).

Furthermore, our LDAP stacks are tailored to make good use of Cinder Volume Storage. This ensures the protection of your precious projects, and allows you to pay only for the space you use. Volume size can be selected from the console, and the LDAP stack can support tens to tens of hundreds of gigabytes worth of project space.

Stack parameters, of course, are yours to tweak at your fancy.

### By the way...

As with the GitLab Bundle, the `.restore` heat template and `backup.sh` script enable you to manipulate Cinder Volume Storage. With these files, you may create Cinder Volume Backups: Save states of your LDAP stack's volume for you to redeploy with the `.restore` heat template when needed.

Both normal and 'restored' stacks can be launched from the [console](#console), but our nifty `stack-start.sh` also allows you to create both kinds of stacks easily from a [terminal](#startup).

Backups must be initialized with our handy `backup.sh` script and take a curt 5 minutes from start to full return of functionality. [(More about backing up and restoring your LDAP...)](#backup)

## What will you find in the repository

Once you have cloned the github, you will find in the `bundle-trusty-ldap/` repository:

* `bundle-trusty-ldap.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `bundle-trusty-ldap.restore.heat.yml`: HEAT orchestration template. It deploys the necessary infrastructure, and restores your data from a previous [backup](#backup).
* `backup.sh`: Backup creation script. Completes a full volume backup for later redeployment in only 5 minutes.
* `stack-start.sh`: Stack launching script, which simplifies the parameters.
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

$ [whatever mind-blowing stuff you have planned...]

~~~

Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Adjust the parameters

In the `.heat.yml` files (heat templates), you will find a section named `parameters` near the top. The mandatory parameters are the `keypair_name` and the `subnet_id`. The `keypair_name`'s `default` value should contain a valid keypair with regards to your Cloudwatt user account, if you wish to have it by default on the console.

Within these heat templates, you can also adjust (and set the defaults for) the instance type, volume size, and volume type by playing with the `flavor`, `volume_size`, and `volume_type` parameters accordingly.

By default, the stack network and subnet are generated for the stack, in which the LDAP server sits alone. This behavior can be changed within the `.heat.yml` as well, if need be, although doing so may be cause for security concerns.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one LDAP stack with LDAP Account Manager


parameters:
  keypair_name:
    default: my-keypair-name                <-- Indicate your keypair here
    label: Paire de cles SSH - SSH Keypair
    description: Paire de cles a injecter dans instance - Keypair to inject in instance
    type: string

  flavor_name:
    default: s1.cw.small-1                  <-- Indicate your instance type here
    label: Type instance - Instance Type (Flavor)
    description: Type instance a deployer - Flavor to use for the deployed instance
    type: string
    constraints:
      - allowed_values:
        [...]

  subnet_id:
    label: Subnet ID
    description: Subnet to attach to router to allow connection to LDAP
    type: string

  volume_size:
    default: 10                             <-- Indicate your volume size here
    label: LDAP Volume Size
    description: Size of Volume for LDAP Storage (Gigabytes)
    type: number
    constraints:
      - range: { min: 2, max: 1000 }
        description: Volume must be at least 2 gigabytes

  volume_type:
    default: standard                       <-- Indicate your volume type here
    label: LDAP Volume Type
    description: Performance flavor of the linked Volume for LDAP Storage
    type: string
    constraints:
      - allowed_values:
          - standard
          - performant


resources:
  network:
    type: OS::Neutron::Net

  subnet:
    type: OS::Neutron::Subnet
    properties:
      network_id: { get_resource: network }
      ip_version: 4
      cidr: 10.27.27.0/24
      allocation_pools:
        - { start: 10.27.27.100, end: 10.27.27.199 }
[...]
~~~

<a name="startup" />

### Start up the stack

In a shell, run the script `stack-start.sh`:

~~~ bash
$ ./stack-start.sh DAPPER «subnet-id» «my-keypair-name»
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | DAPPER     | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Within 5 minutes the stack will be fully operational. (Use watch to see the status in real-time)

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | DAPPER     | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script.

~~~ bash
$ ./stack-get-url.sh DAPPER
DAPPER  http://70.60.637.17

~~~

As shown above, it will parse the assigned floating-IP of your stack into a URL link. You can then click or paste this into your browser of choice, confirm the use of the self-signed certificate, and bask in the glory of a secure LDAP instance.

### In the background

The `start-stack.sh` script runs the necessary OpenStack API requests to execute the heat template which:
* Starts a Ubuntu Trusty Tahr based instance
* Attaches an exposed floating-IP for LAM
* Starts, attaches, and formats a fresh volume for LDAP, or restores one from a provided backup_id
* Reconfigures LDAP to store its data in the volume
* Writes a simple guide (on how to use the LDAP server from the provided subnet's servers) in the output.

<a name="console" />

### Bash is what I do with my head against a wall when I think of shell.

That's okay! But not actually. Sorry folks, but LDAP is not for kids: if you want to play, better get used to that blocky cursor. The actual creation of the stack can be done entirely from our console, but to allow other servers in the provided subnet to connect, you're going to have to connect to those servers in SSH.

To create our LDAP stack from the console:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-ldap](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-ldap) repository
2.	Click on the file named `bundle-trusty-ldap.heat.yml` (or `bundle-trusty-ldap.restore.heat.yml` to [restore from backup](#backup))
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the «[Stacks](https://console.cloudwatt.com/project/stacks/)» section of the console
6.	Click on «Launch stack», then «Template file» and select the file you just saved to your PC, and finally click on «NEXT»
7.	Name your stack in the «Stack name» field
8.	Enter the name of your keypair in the «SSH Keypair» field
9.	Confirm the volume size (in gigabytes) in the «LDAP Volume Size» field
10.	Choose your instance size using the «Instance Type» dropdown and click on «LAUNCH»

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating-IP, or simply refresh the current page and check the Overview tab for a handy link.

If you've reached this point, you're already done! Go enjoy LDAP!

Is what I wish I could say. At this point LDAP will be running, and LAM will work and modify the LDAP database, but no other server has access! The next section covers how to gain access to LDAP from a server in the provided subnet.

## So you wanna see my LDAP?

Thankfully, I made it easy. In the output of the stack, either in the Overview tab of your stack's page on the console, or with:

~~~ bash
$ heat output-show «stack-name» --all

~~~

You will find three steps, not necessarily in the correct order, to aid you on your quest for booty.
Booty, of course, being access to your new LDAP database from a server in the provided subnet.
The steps should look similar to this:

**router-interface-ip** : Find given subnet's router-interface IP with:

~~~ bash
$ neutron router-port-list «ldap-router-name» | grep «provided-subnet-id» | cut -d\"\\\"\" -f8

~~~

**ldap_ip_address_via_router** : Once access to LDAP has been configured as shown here,

LDAP will then be accessible from ldap://«ldap-through-router-ip»:389

**ldap_access_configuration** : From the SSH terminal of any server in the subnet (passed as parameter)add access to LDAP with:

~~~ bash
$ sudo ip route add «ldap-through-router-ip» via «router-interface-ip»

~~~

**floating_ip_url** : LDAP Account Manager External URL

http://«lam-public-ip»/

For those who like a little more instruction in their instructions:

1.  First, from the terminal on your computer, run the command to obtain the *router-interface-ip*, which you will need in the next few steps. The variables will already be inserted, so you can just copy-paste the line into the terminal. Neat right?
2. Armed with the *router-interface-ip*, connect with SSH to a server in the provided subnet and enter the *ldap_access_configuration* command. Running `sudo ip route` will show you the route that was just added, if you're curious.
3. Verify that you can actually connect to LDAP by running `curl «ldap_ip_address_via_router»` with the *ldap_ip_address_via_router* found in the output.

Voila! You can now securely access LDAP from your other servers. LAM is public, however, and can be used through any browser from the *floating_ip_url*.

## LAM (Light Attack Munitions)

Except not really: LDAP Account Manager presents your LDAP database as if it were a user management tool, one of it's most common uses. It also provides a more development/broad-use oriented interface, but for most users the main panel is best, as it is much more intuitive and requires little to no knowledge of LDAP.

By default, the password for the main login (username: Administrator), the *master* password, and the *server preferences* password are all **c10udw477**, but each can be changed individually.

Try it out, tweak it's configuration, read it's manual if you wish: LAM is very modular and I'm sure it can be easily structured to meet any needs you may have in an LDAP GUI. However if you don't want it, or if fool-proof security is very important to you, can always just disassociate its floating-IP, either from the console in the «Access & Security» tab, or from the command line.

~~~ bash
$ nova help floating-ip-disassociate

~~~

<a name="backup" />

## Back up and Restoration

Backing your LDAP, sounds like great idea, right? After all, *ipsa scientia potestas est*, and you never feel as powerless as when you lose your code.
Thankfully we've worked hard to make saving your work quick and easy.

~~~ bash
$ ./backup.sh DAPPER

~~~

And five minutes later you're back in business and your conscience is at ease!
Restoration is as simple as building another stack, although this time with the `.restore.heat.yml`, and specifying the ID of the backup you want. The new volume size should not be smaller than the original, to avoid loss to data. A list of backups can be found in the «Volume Backups» tab under «Volumes» in the console, or from the command line with the Cinder API:

~~~ bash
$ cinder backup-list

+------+-----------+-----------+---------------------------------+------+--------------+---------------+
|  ID  | Volume ID |   Status  |               Name              | Size | Object Count |   Container   |
+------+-----------+-----------+---------------------------------+------+--------------+---------------+
| XXXX | XXXXXXXXX | available | ldap-backup-2025/10/23-07:27:69 |  10  |     206      | volumebackups |
+------+-----------+-----------+---------------------------------+------+--------------+---------------+

~~~

Remember however, that while we have greatly simplified the restoration process, your other services interfacing with LDAP will not take into account changes in IP address. Internal IP addresses may become invalid, so you should make sure to correct any relevant ip routes on your other servers before continuing your work.

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

You now have an SSH access point on your virtual machine through the floating-IP and your private keypair (default user name `cloud`).

The interesting directories are:

- `/dev/vdb`: Volume mount point
- `/mnt/vdb/`: `/dev/vdb` mounts here
- `/mnt/vdb/ldap/`: Mounts onto `/var/lib/ldap/` and contains all of LDAP's data
- `/var/lib/ldap/`: LDAP stores its database here; `/mnt/vdb/ldap/` mounts here
- `/etc/ldap`: LDAP Configuration; only the `ssl/` directory is backed up in the volume here, however this only contains the config database: LDAP accounts and other user-created data are stored in the database at `/var/lib/ldap/`, and are properly stored in the volume
- `/etc/ldap/ssl/`: Apache's '.key' and '.crt' for HTTPS
- `/etc/ldap/ldap-volume.sh`: Script run upon reboot to remount the volume and verify LDAP is ready to function again
- `/usr/share/ldap-account-manager`: Root of LAM's site; some LAM configuration
- `/etc/ldap-account-manager`: More LAM configuration files
- `/var/lib/ldap-account-manager`: LAM's working directory (config, sessions, temporary files)
- `/var/lib/ldap-account-manager/config/`: Another set of LAM configuration files
- `/etc/ldap-account-manager/apache.conf`: `/etc/apache2/conf-available/ldap-account-manager.conf` redirects here; contains Apache-relevant configuration for LAM
- `/etc/apache2/sites-available/ssl-lam.conf`: Apache site configuration for LAM through SSL. Enabled by default.
- `/etc/apache2/sites-available/http-lam.conf`: Apache site configuration for LAM through HTTP. Disabled by default.
- `/mnt/vdb/stack_public_entry_point`: Contains last known IP address, used to replace the IP address in all locations when it changes

Other resources you could be interested in:

* [Ubuntu OpenLDAP Server Guide](https://help.ubuntu.com/lts/serverguide/openldap-server.html)
* [LAM Manual](https://www.ldap-account-manager.org/static/doc/manual-onePage/index.html)
* [OpenLDAP Documentation Catalog](http://www.openldap.org/doc/)
* [OpenLDAP  Independent Publications](http://www.openldap.org/pub/)
* [Online OpenLDAP Man Pages](http://www.openldap.org/software/man.cgi)


-----
Have fun. Hack in peace.
