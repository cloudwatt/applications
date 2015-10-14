# 5 Minutes Stacks, Episode 10: Jenkins

## Episode 10: Jenkins

Alfred Thaddeus Crane Pennyworth is Bruce Wayne's valet at Wayne Manor. He knows that Bruce is secretly Batman and [aids him in every way imaginable](https://wiki.jenkins-ci.org/display/JENKINS/Plugins). After a [varied career](https://wiki.jenkins-ci.org/display/JENKINS/Awards), Alfred Pennyworth was [employed as the Wayne family valet](https://wiki.jenkins-ci.org/pages/viewpage.action?pageId=58001258) following the murder of Bruce Wayne's parents. Alfred [raised the young orphan](https://github.com/jenkinsci/jenkins/commits/master) alone, eventually aiding him in his quest to [become Batman](https://wiki.jenkins-ci.org/display/JENKINS/Use+Jenkins). His [impressive skill-set](https://wiki.jenkins-ci.org/display/JENKINS/Awards) makes him Bruce's staunchest ally, boasting a formal demeanor that does little to hide the [intelligence](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Best+Practices) behind his eyes.

Jenkins is our Alfred Pennyworth.

Jenkins, [originally named Hudson](https://en.wikipedia.org/wiki/Jenkins_%28software%29#History), is an amazing tool. I am not qualified to sing its praises, [but I'm not the only one who wants to](https://wiki.jenkins-ci.org/display/JENKINS/Awards). To learn about the power of Jenkins, [check out everything people use it for, live](http://www.google.com/search?ie=UTF-8&q=%22Dashboard+%5BJenkins%5D%22).

[Or you know, just Google it.](http://lmgtfy.com/?q=jenkins)

## Preparations

### The version

* Jenkins (jenkins) 1.627

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

Once you have cloned the github, you will find in the `bundle-trusty-jenkins/` repository:

* `bundle-trusty-jenkins.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
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

In the `.heat.yml` files (heat templates), you will find a section named `parameters` near the top. The mandatory parameters are the `keypair_name`, and the `username` and `password` for Digest login. The `keypair_name`'s `default` value should contain a valid keypair with regards to your Cloudwatt user account, if you wish to have it by default on the console.

The `username` and `password` fields provide the values for Basic Auth, a simple HTTP authentication module belonging to Apache2, providing light security in the case that someone stumbles upon your IP. Since Jenkins is only a build tool, no other security is implemented by default, although you are always free to implement more yourself.

Within these heat templates, you can also adjust (and set the default for) the instance type by playing with the `flavor` parameter accordingly.

By default, the stack network and subnet are generated for the stack, in which the Jenkins server sits alone. This behavior can be changed within the `.heat.yml` as well, if needed.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Jenkins stack


parameters:
  keypair_name:
    default: my-keypair-name                <-- Indicate your keypair here
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string

  username:
    label: Apache2 Auth Username
    description: Basic auth username for all users
    type: string
    constraints:
      - length: { min: 4, max: 24 }
        description: Username must be between 4 and 24 characters
  password:
    label: Apache2 Auth Password
    description: Basic auth password for all users
    type: string
    hidden: true
    constraints:
      - length: { min: 6, max: 24 }
        description: Password must be between 6 and 24 characters

  flavor_name:
    default: s1.cw.small-1                  <-- Indicate your instance type here
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
    constraints:
      - allowed_values:
          [...]

resources:
  network:
    type: OS::Neutron::Net

  subnet:
    type: OS::Neutron::Subnet
    properties:
      network_id: { get_resource: network }
      ip_version: 4
      cidr: 10.0.1.0/24
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.199 }
[...]
~~~

<a name="startup" />

### Start up the stack

In a shell, run the script `stack-start.sh`:

~~~ bash
$ ./stack-start.sh PENNYWORTH «my-keypair-name»
Enter your new Basic Auth username: «username»
Enter your new Basic Auth password:
Enter your new password once more:
Creating stack...
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | PENNYWORTH | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Within 5 minutes the stack will be fully operational. (Use watch to see the status in real-time)

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | PENNYWORTH | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script.

~~~ bash
$ ./stack-get-url.sh PENNYWORTH
PENNYWORTH  http://70.60.637.17
~~~

As shown above, it will parse the assigned floating-IP of your stack into a URL link. You can then click or paste this into your browser of choice, confirm the use of the self-signed certificate, and bask in the glory of a fresh Jenkins instance. Alfred Pennyworth would be proud.

### In the background

The `start-stack.sh` script runs the necessary OpenStack API requests to execute the heat template which:
* Starts a Ubuntu Trusty Tahr based instance
* Attaches an exposed floating-IP
* Reconfigures Apache with your Basic Auth username and password

<a name="console" />

### I'd rather leave shell to the tortoises

If you handle a terminal as well as a _Testudo graeca_ would, then you might want to create your Jenkins stacks from our console instead!

To create our Jenkins stack from the console:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-jenkins](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-jenkins) repository
2.	Click on the file named `bundle-trusty-jenkins.heat.yml` (or `bundle-trusty-jenkins.restore.heat.yml` to [restore from backup](#backup))
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the «[Stacks](https://console.cloudwatt.com/project/stacks/)» section of the console
6.	Click on «Launch stack», then «Template file» and select the file you just saved to your PC, and finally click on «NEXT»
7.	Name your stack in the «Stack name» field
8.	Enter the name of your keypair in the «SSH Keypair» field
9.	Enter your new Basic Auth username and password in their respective fields.
10.	Choose your instance size using the «Instance Type» dropdown and click on «LAUNCH»

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating-IP, or simply refresh the current page and check the Overview tab for a handy link.

If you've reached this point, you're already done! Go enjoy Jenkins!

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

You now have an SSH access point on your virtual machine through the floating-IP and your private keypair (default user name `cloud`).

~~~ bash
$ ssh «floating-IP» -l cloud -i /path/to/your/.ssh/keypair.pem
~~~

#### The interesting directories are:

- `/etc/apache2/sites-available/default-jenkins.conf`: Apache2 configuration file
- `/etc/htpasswd/.htpasswd`: Basic Auth username and password file.
- `/root/jenkins-cli.jar`: Jenkins' CLI `.jar` file
- `/var/lib/jenkins/`: Main Jenkins directory
- `/etc/default/jenkins`: Jenkins default settings upon startup, including HTTP port, prefix, webroot, UNIX user/group and more
- `/usr/share/jenkins/jenkins.war`: Jenkins WAR file
- `/var/cache/jenkins/war/`: Decompressed Jenkins WAR
- `/var/log/jenkins/jenkins.log`: Jenkins' system level log file

Jenkins has an... interesting command-line interface (CLI), which works with a jar we conveniently placed at `/root/jenkins-cli.jar`.
Input commands using the syntax shown below:

~~~ bash
$ java -jar /root/jenkins-cli.jar -s http://127.0.0.1:8080 «jenkins-cli-command»
~~~

The uses for this vary; for ideas I recommend starting with `help`, which lists the possible commands. Tell us what you find!

#### Other resources you could be interested in:

* [Jenkins Homepage](https://jenkins-ci.org/)
* [Jenkins CLI Reference](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI)
* [Jenkins Plugins](https://wiki.jenkins-ci.org/display/JENKINS/Plugins)
* [Jenkins Wiki](https://wiki.jenkins-ci.org/display/JENKINS/Home)
* [Installing Jenkins on Ubuntu](https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu)
* [Running Jenkins behind Apache](https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Apache)


-----
Have fun. Hack in peace.
