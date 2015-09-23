# 5 Minutes Stacks, Episode 13: Let's Chat

## Episode 13: Let's Chat

**Draft - Image not yet available...**

Using this bundle as-is, you will set up a "free-for-all" Let's Chat application where anyone can create a user and begin messaging in seconds.

Let's Chat is a quality web-chat application tailored for small development teams. Developed by [Security Compass](http://securitycompass.com/) and released under the [MIT license](https://raw.githubusercontent.com/sdelements/lets-chat/master/LICENSE), Let's Chat is a solid tool for any team, boasting features including persistent messages (with searchable archives), infinite rooms, browser notifications, mentions, file uploads and image embedding, code-paste recognition, private rooms and more!

Let's Chat became the established messaging application within my team *days* after I introduced it for field-testing. I hope your experience with Let's Chat will be as pleasant as it has been for us.

## Preparations

### The version

* Let's Chat v0.4.2

### The prerequisites to deploy this stack

These should be routine by now:

* Internet access
* A Linux shell
* A [Cloudwatt account](https://www.cloudwatt.com/authentification) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository
* The ID of an Neutron Subnet containing servers who need to connect to your Let's Chat instance.

### Size of the instance

By default, the stack deploys on an instance of type "Small" (s1.cw.small-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website).

All stack parameters, of course, are yours to tweak at your fancy.

## What will you find in the repository

Once you have cloned the github, you will find in the `bundle-trusty-letschat/` repository:

* `bundle-trusty-letschat.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh`: Stack launching script, which simplifies the parameters.
* `stack-get-url.sh`: Returns the floating-IP in a URL, which can also be found in the stack output.

## Start-up

### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
If you are not logged in yet, complete the authentication and save the credentials script.
With it, you will be able to wield the amazing powers of the OpenStack APIs.

Source the downloaded file in your shell and enter your password when prompted to begin using the OpenStack clients.

~~~ bash
$ source ~/Downloads/COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Adjust the parameters

In the `.heat.yml` file (the heat template), you will find a section named `parameters` near the top. The only mandatory parameter is the `keypair_name`. You should set the `default` value to a valid keypair with regards to your Cloudwatt user account, as this is how you connect to your stack remotely. A keypair can be generated from the `Key Pairs` tab under `Access & Security` on the console. Make sure to save the public key, otherwise you will not be able to connect to your machine by SSH.

Within the heat template, you can also adjust (and set the default for) the instance type by playing with the `flavor` parameter accordingly.

By default, the stack network and subnet are generated for the stack, in which the Let's Chat server sits alone. This behavior can be changed within the `.heat.yml` as well, if need be, although doing so may be cause for security concerns.

~~~ yaml
    default: my-keypair-name                <-- Indicate your keypair here
    default: s1.cw.small-1                  <-- Indicate your instance type here
        [...]
[...]
~~~

<a name="startup" />

### Start up the stack

In a shell, run the script `stack-start.sh`:

~~~ bash
$ ./stack-start.sh THATCHAT «my-keypair-name»
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | THATCHAT   | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+

~~~

Within 5 minutes the stack will be fully operational. (Use `watch` to see the status in real-time)

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | THATCHAT   | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+

~~~

### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script.

~~~ bash
$ ./stack-get-url.sh THATCHAT
THATCHAT  http://70.60.637.17

~~~

As shown above, it will parse the assigned floating-IP of your stack into a URL link. You can then click or paste this into your browser of choice, confirm the use of the self-signed certificate, and enjoy the simplicity of Let's Chat.

### In the background

The `start-stack.sh` script runs the necessary OpenStack API requests to execute the heat template which:
* Starts a Ubuntu Trusty Tahr based instance
* Attaches an exposed floating-IP for Let's Chat
* Configures Let's Chat to use the exposed floating-IP address.

<a name="console" />

### I already came out of my shell in order to chat... do I have to go back?

Nah, you can keep your eyes on the browser: all Let's Chat setup can accomplished from the console.

To create our Let's Chat stack from the console:

1.	Go the Cloudwatt Github in the [applications/bundle-trusty-devkit](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-devkit) repository
2.	Click on the file named `bundle-trusty-letschat.heat.yml`
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the «[Stacks](https://console.cloudwatt.com/project/stacks/)» section of the console
6.	Click on «Launch stack», then «Template file» and select the file you just saved to your PC, and finally click on «NEXT»
7.	Name your stack in the «Stack name» field
8.	Enter the name of your keypair in the «SSH Keypair» field
9.	Choose your instance size using the «Instance Type» dropdown and click on «LAUNCH»

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating-IP, or simply refresh the current page and check the Overview tab for a handy link.

![Stack Topology](img/stack_topology.png)

If you've reached this point, Let's Chat is running!

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

You now have an SSH access point on your virtual machine through the floating-IP and your private keypair (default user name `cloud`).

The interesting directories are:

- `/some/path`: FIXME

Other resources you could be interested in:

* [Ubuntu](https://help.ubuntu.com/)


-----
Have fun. Hack in peace.
