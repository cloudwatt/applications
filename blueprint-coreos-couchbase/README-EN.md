# 5 Minutes Stacks, 31 episode : CouchBase #

## Episode 31 : CouchBase

![couchebase](img/couchbase-logo.gif)

Couchbase Server is a NoSQL document database with a distributed architecture for performance, scalability, and availability. It enables developers to build applications easier and faster by leveraging the power of SQL with the flexibility of JSON.

## Preparations

### The version
  - CoreOS Stable 1010.6
  - Docker 1.10.3
  - CoucheBase 4.5.0

### The prerequisites to deploy this stack

   These should be routine by now:

  * Internet access
  * A Linux shell
  * A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
  * The tools of the trade: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
  * A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) git repository

### Size of the instance

   By default, the stack deploys on an instance of type "Standard 2" (n1.cw.standard-2). A variety of other instance flavors exist to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/en/produits/tarifs.html) on the Cloudwatt website).

   Stack parameters, of course, are yours to tweak at your fancy.

## What will you find in the repository

   Once you have cloned the github, you will find in the `blueprint-coreos-couchbase/` repository:

   * `blueprint-coreos-couchbase.heat.yml`: HEAT orchestration template. It will be used to deploy the necessary infrastructure.
   * `stack-start.sh`: Stack launching script. This is a small script that will save you some copy-paste.

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

  In the `blueprint-coreos-couchbase.heat.yml` file (heat template), you will find a section named `parameters` near the top. The only mandatory parameter is the `keypair_name`. The `keypair_name`'s `default` value should contain a valid keypair with regards to your Cloudwatt user account, if you wish to have it by default on the console.

  Within these heat templates, you can also adjust (and set the defaults for) the instance type by playing with the `flavor_name` parameter accordingly.

  By default, the stack network and subnet are generated for the stack. This behavior can be changed within the `blueprint-coreos-couchbase.heat.yml` file as well, if need be, although doing so may be cause for security concerns.

  ~~~ yaml
  heat_template_version: 2013-05-23
  description: Blueprint CoreOS Couchbase
  parameters:
    keypair_name:  
      default: keypair  <-- Indicate here your keypair     
      description: Keypair to inject in instance
      label: SSH Keypair
      type: string

    flavor_name:
      default: n1.cw.standard-1   <-- Indicate here flavor size
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


    volume_size:
      default: 5           <-- Indicate here volume size
      label: Backup Volume Size
      description: Size of Volume for couchbase Storage (Gigabytes)
      type: number
      constraints:
        - range: { min: 5, max: 10000 }
          description: Volume must be at least 10 gigabytes

    volume_type:
      default: standard    <-- Indicate here volume type
      label: Backup Volume Type
      description: Performance flavor of the linked Volume for couchbase Storage
      type: string
      constraints:
        - allowed_values:
            - standard
            - performant

   [...]
   ~~~
### Start the stack

 In a shell, run the script `stack-start.sh`:

 ~~~ bash
 $ ./stack-start.sh couchbase
 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | couchbase    | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+--------------------+----------------------+
 ~~~

 Within 5 minutes the stack will be fully operational. (Use watch to see the status in real-time)

 ~~~ bash
 $ watch -n 1 heat stack-list
 +--------------------------------------+------------+-----------------+----------------------+
 | id                                   | stack_name | stack_status    | creation_time        |
 +--------------------------------------+------------+-----------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | couchbase    | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+-----------------+----------------------+
 ~~~

 <a name="console" />

## That's fine but...

### I already came out of my shell in order to couchbase... do I have to go back?

Nah, you can keep your eyes on the browser: all CoucheBase setup can be accomplished from the console.

To create our Couchbase stack from the console:

1.	Go the Cloudwatt Github in the [applications/blueprint-coreos-couchbase](https://github.com/cloudwatt/applications/edit/master/blueprint-coreos-couchbase/) repository
2.	Click on the file named `blueprint-coreos-couchbase.heat.yml`
3.	Click on RAW, a web page will appear containing purely the template
4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the «[Stacks](https://console.cloudwatt.com/project/stacks/)» section of the console
6.	Click on «Launch stack», then «Template file» and select the file you just saved to your PC, and finally click on «NEXT»
7.	Name your stack in the «Stack name» field
8.	Enter the name of your keypair in the «SSH Keypair» field and few other fields required
9.	Choose your instance size using the «Instance Type» dropdown and click on «LAUNCH»

The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete. You can then go to the "Instances" menu to find the floating-IP, or simply refresh the current page and check the Overview tab for a handy link.

If you've reached this point, Couchbase is running!

### A one-click sounds really nice...

... Good! Go to the [Apps page](https://www.cloudwatt.com/en/apps/) on the Cloudwatt website, choose the apps, press **DEPLOY** and follow the simple steps... 2 minutes later, a green button appears... **ACCESS**: you have your Couchbase!


### Enjoy

Once all of this done, stack's description can be obtained with the following command :

 ~~~ bash
 $ heat stack-show couchbase
 +-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
| Property              | Value                                                                                                                                    |
+-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
| capabilities          | []                                                                                                                                       |
| creation_time         | 2016-08-22T12:41:20Z                                                                                                                     |
| description           | Blueprint CoreOS Couchbase                                                                                                               |
| disable_rollback      | True                                                                                                                                     |
| id                    | 0cb5221a-c104-497a-92c1-47f49b7145cb                                                                                                     |
| links                 | https://orchestration.fr1.cloudwatt.com/v1/467b00f998064f1688feeca95bdc7a88/stacks/couchbase/0cb5221a-c104-497a-92c1-47f49b7145cb (self) |
| notification_topics   | []                                                                                                                                       |
| outputs               | [                                                                                                                                        |
|                       |   {                                                                                                                                      |
|                       |     "output_value": "http://floatingIp:8091",                                                                                          |
|                       |     "description": "couchbase URL",                                                                                                      |
|                       |     "output_key": "floating_ip_url"                                                                                                      |
|                       |   }                                                                                                                                      |
|                       | ]                                                                                                                                        |
| parameters            | {                                                                                                                                        |
|                       |   "OS::project_id": "467b00f998064f1688feeca95bdc7a88",                                                                                  |
|                       |   "OS::stack_id": "0cb5221a-c104-497a-92c1-47f49b7145cb",                                                                                |
|                       |   "OS::stack_name": "couchbase",                                                                                                         |
|                       |   "keypair_name": "yourkey",                                                                                                              |
|                       |   "volume_type": "standard",                                                                                                             |
|                       |   "volume_size": "5",                                                                                                                    |
|                       |   "flavor_name": "n1.cw.standard-1"                                                                                                      |
|                       | }                                                                                                                                        |
| parent                | None                                                                                                                                     |
| stack_name            | couchbase                                                                                                                                |
| stack_owner           | youremail@cloudwatt.com                                                                                                |
| stack_status          | CREATE_COMPLETE                                                                                                                          |
| stack_status_reason   | Stack CREATE completed successfully                                                                                                      |
| stack_user_project_id | 65091a1295424361bb38d30f568bf150                                                                                                         |
| template_description  | Blueprint CoreOS Couchbase                                                                                                               |
| timeout_mins          | 60                                                                                                                                       |
| updated_time          | None                                                                                                                                     |
+-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
 ~~~

 You can connect via a web browser to couchbase server from this url http://floatingIp:8091 and setup your couchbase server.

![couchbase1](img/couchbase1.png)

##### Systemd - init system for Couchbase service

 To start the service :
~~~ bash
sudo systemctl start couchbase.service
~~~

Logs can be seen with the following command:
~~~ bash
journalctl -f -u couchbase.service
~~~

To stop the service:
~~~ bash
sudo systemctl stop couchbase.service
~~~

#### Other resources you could be interested in:

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)
* [CouchBase Documentatuion](http://www.couchbase.com/)

-----

Have fun. Hack in peace.
