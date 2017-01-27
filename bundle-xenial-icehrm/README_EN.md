# 5 Minutes Stacks, episode 52 : iceHRM #

## Episode 52 : iceHRM

![iceHRMlogo](img/icehrmlogo.png)

iceHRM is a Human Resources Management tool allowing to manage a company ant its employees. It is possible to add their personnal information, to create plannings, payslips and to set up some projects. The interface is really intuitive.

iceHRM is developed in PHP and uses a MariaDB database to save all the data it needs.

This episode will help you to deploy iceHRM with a High Availability (HA) on a cluster of two instances behind a load-balancer, each instance being mutually replicated in real time.

## Preparations

### The Versions
 - Ubuntu 16.04
 - Apache 2.4.18
 - MariaDB Galera Cluster 5.5.53
 - GlusterFS 3.7.6
 - iceHRM 18.0.OS

### The prerequisites to deploy this stack

These should be routine by now:
 * An Internet access
 * A Linux shell
 * A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository (if you are creating your stack from a shell)

### Size of the instance

By default, the stack deploys two instances of type "Standard 1" (n1.cw.standard-1). A variety of other instance types exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Pricing page](https://www.cloudwatt.com/en/pricing.html) on the Cloudwatt website).

 Stack parameters, of course, are yours to tweak at your fancy.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console)

## What will you find in the repository

 Once you have cloned the github, you will find in the `bundle-xenial-icehrm/` repository:

 * `bundle-xenial-icehrm.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
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

With the `bundle-xenial-icehrm.heat.yml` file, you will find at the top a section named `parameters`. The parameters to adjust are `keypair_name` and `sqlpass`. Their `default` value must contain respectively a valid keypair with regards to your Cloudwatt user account and the password you want to use to the iceHRM database. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one iceHRM stack


parameters:
  keypair_name:
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

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

  volume_attachment:
    description: Attacher un volume cinder de 20GO ?
    default: 0
    type: string
[...]
~~~
### Start stack

 In a shell, run the script `stack-start.sh` with his name in parameter:


 ~~~ bash
 ./stack-start.sh iceHRM
+--------------------------------------+-----------------------+--------------------+----------------------+
| id                                   | stack_name            | stack_status       | creation_time        |
+--------------------------------------+-----------------------+--------------------+----------------------+
| 4785c76e-3681-4b02-8a91-a7a3cc4a6440 | iceHRM                | CREATE_IN_PROGRESS | 2016-12-21T13:53:56Z |
+--------------------------------------+-----------------------+--------------------+----------------------+
 ~~~

 Within **5 minutes** the stack will be fully operational. (Use `watch` to see the status in real-time)

 ~~~
 $ watch heat resource-list iceHRM
+-----------------------+------------------------------------+-----------------+----------------------+
| resource_name         | resource_type                      | resource_status | updated_time         |
+-----------------------+------------------------------------+-----------------+----------------------+
| inst1                 | OS::Nova::Server                   | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| inst1_cinder          | OS::Heat::ResourceGroup            | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| inst1_port            | OS::Neutron::Port                  | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| inst2                 | OS::Nova::Server                   | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| inst2_cinder          | OS::Heat::ResourceGroup            | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| inst2_port            | OS::Neutron::Port                  | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| lbaas                 | OS::Neutron::LoadBalancer          | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| lbaas_pool            | OS::Neutron::Pool                  | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| lbaas_pool_vip        | OS::Neutron::FloatingIPAssociation | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| lbaas_vip_floating_ip | OS::Neutron::FloatingIP            | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| lbaas_vip_port        | OS::Neutron::Port                  | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| network               | OS::Neutron::Net                   | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| security_group        | OS::Neutron::SecurityGroup         | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
| subnet                | OS::Neutron::Subnet                | CREATE_COMPLETE | 2016-12-21T13:53:57Z |
+-----------------------+------------------------------------+-----------------+----------------------+
 ~~~

 The `start-stack.sh` script takes care of running the API necessary requests to execute the normal heat template which:

 * Starts two Ubuntu Xenial based instances preprovisionned with the iceHRM stack
 * Expose it on the Internet via a floating IP

<a name="console" />

## All of this is fine, but...

### You do not have a way to create the stack from the console?

 We do indeed! Using the console, you can deploy iceHRM:

 1.	Go the Cloudwatt Github in the [applications/bundle-xenial-icehrm](https://github.com/cloudwatt/applications/tree/master/bundle-xenial-icehrm) repository
 2.	Click on the file named `bundle-xenial-icehrm.heat.yml`
 3.	Click on RAW, a web page will appear containing purely the template
 4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
 5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
 6.	Click on « Launch stack », then « Template file » and select the file you just saved to your PC, and finally click on « NEXT »
 7.	Name your stack in the « Stack name » field
 8.	Enter the name of your keypair in the « SSH Keypair » field
 9. Write a passphrase that will be used for the database icehrmuser
 10.	Choose your instance size using the « Instance Type » dropdown and click on « LAUNCH »

 The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating IP, or simply refresh the current page and check the Overview tab for a handy link.

 If you've reached this point, you're already done! Go enjoy iceHRM!

### A one-click deployment sounds really nice...

 ... Good! Go to the [Apps page](https://www.cloudwatt.com/en/apps/) on the Cloudwatt website, choose the apps, press **DEPLOY** and follow the simple steps... 2 minutes later, a green button appears... **ACCESS**: you have iceHRM.

## Enjoy

You are now in possession of iceHRM, you can enter via the URL `http://ip-floatingip`. Your full URL will be present in your stack overview in horizon Cloudwatt console.

The stack is composed like this:

![schema](img/schema.png)

At your first connexion you will ask to give the information about how to access to the database. Complete the fields as below, the password is which one you chose when you created the stack.

![firstco](img/firstco.png)

The default username and password to connect to iceHRM are `admin`.

![login](img/login.png)

You can now discover the iceHRM's interface:

![interface](img/interface.png)

You can now setup your Human Resources Management tool, this one being hosted in France in a safe environment, you can completely trust on this product.

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

Some useful links:
* [Home iceHRM](https://www.icehrm.com/)
* [Help iceHRM](http://blog.icehrm.com/docs/home/)

----
Have fun. Hack in peace.
