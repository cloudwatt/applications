# 5 Minutes Stacks, episode two : WordPress - English version

## Episode Two : Wordpress

In the CMS Open-Source galaxy, WordPress is the most used in term of community, available functionalities and user adoption.
The Automattic compagny, which develop and distribute Wordpress, provides a SaaS offer allowing a user to create its blog in few minutes. However, those who experiments know that limits can be easily found by the wordpress.com hosting capabilities.

Today, Cloudwatt provides the necessary toolset to start your Wordpress instance in a few minutes and to become its master.

The deployement base is an Ubuntu trusty instance. The Apache and MySQL servers are deployed on a single instance.

## Nota Bene for the impatient

An image named "Stack Orchestration Heat Ubuntu 14.04.2 WORDPRESS" is available in the public image catalogue of the Cloudwatt console. For security reasons, this image does not include the initialisation of the MySQL database and therefore is not working when spawning directly the image thru the "Launch instance" button.

This image has to be launched thru the Orchestration Stack menu with the Heat template that we are detailling in this article. The heat template includes the mandatory steps required after the launch to generated the passsword, the creation of the user, the creation of the MySQL database for Wordpress and the final configuration of Wordpress for the MySQL accesses.


## Preparations

### The versions

* Ubuntu 14.04.2
* Apache 2.4.7
* Wordpress 3.8.2
* MySQL 5.5.43
* PHP 5.5.9

### The prerequisites to deploy this stack

* an internet acces
* a Linux shell
* a [Cloudwatt account](https://www.cloudwatt.com/authentification), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

Per default, the script is proposing a deployement on an instance type "Small" (s1.cw.small-1).  Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console) 

## What will you find in the repository

Once you have cloned the github, you will find in the  `bundle-trusty-wordpress/` repository:

* `bundle-trusty-wordpress.heat.yml` : HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh` : Stack launching script. This is a small script that will save you some copy-paste.
* `stack-get-url.sh` : Flotting IP recovery script.

## Start-up

### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). 
If you are not logged in yet, you will go thru the authentication screen then the script download will start. Thanks to it, you will be able to initiate the shell acccesses towards the Cloudwatt APIs.

Source the downloaded file in your shell. Your password will be requested. 

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~ 

Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Adjust the parameters

With the `bundle-trusty-wordpress.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Wordpress stack


parameters:
  keypair_name:
    default: amaury-ext-compute         <-- Indicate here your keypair
    description: Keypair to inject in instances
    type: string

  flavor_name:
      default: s1.cw.small-1              <-- Indicate here the flavor size
      description: Flavor to use for the deployed instance
      type: string
      constraints:
        - allowed_values:
            - s1.cw.small-1
            - n1.cw.standard-1
            - n1.cw.standard-2
            - n1.cw.standard-4
            - n1.cw.standard-8
            - n1.cw.standard-12
            - n1.cw.standard-16
            
[...]
~~~ 

### Start up the stack

In a shell, run the script `stack-start.sh` with the name you want to give it as parameter:

~~~ bash
$ ./stack-start.sh LE_BIDULE
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| ed4ac18a-4415-467e-928c-1bef193e4f38 | LE_BIDULE  | CREATE_IN_PROGRESS | 2015-04-21T08:29:45Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~ 

Last, wait 5 minutes until the deployement been completed.

At each new deployement of the stack, a mySQL password is generated directly in the `/etc/wordpress/config-default.php` configuration file.

### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script. 

~~~ bash
./stack-get-url.sh THE_THING
THE_THING 82.40.34.249
~~~ 

It will gather the assigned flotting IP of your stack. You can then paste this IP in your favorite browser and start to configure your Wordpress instance.

## In the background

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr
* faire une mise à jour de tous les paquets système
* installer Apache, PHP, MySQL et Wordpress dessus
* configurer MySQL avec un utilisateur et une base dédiés à WordPres, avec mot de passe généré
* l'exposer sur Internet via une IP flottante

<a name="console" />

### All of this is fine, but you do not have a way to run the stack thru the console ?

Yes ! Using the console, you can deploy a Wordless server:

1.	Go the Cloudwatt Github in the applications/bundle-trusty-wordpress repository
2.	Click on the file nammed bundle-trusty-wordpress.heat.yml
3.	Click on RAW, a web page appear with the script details
4.	Save as its content on your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
6.	Click on « Launch stack », then click on « Template file » and select the file you've just saved on your PC, then click on « NEXT »
7.	Named your stack in the « Stack name » field
8.	Enter your keypair in the « keypair_name » field
9.	Choose the instance size using the « flavor_name » popup menu and click on « LAUNCH »

The stack will be automatically created (you can see its progress by clicking on its name). When all its modules will become "green", the creation will be completed. Then you can go on the "Instances" menu to discover the flotting IP value that has been automatically generated. Now, just run this IP adress in your browser and enjoy !

It is (already) FINISH !

## So watt ?

The goal of this tutorial is to accelarate your start. At this point you are the master of the stack.
You have a SSH access point on your virtual machine thru the flotting IP and your private keypair (default user name `cloud`).

The interesting entry access points are:

- `/usr/share/wordpress` : Wordpress installation repository
- `/var/lib/wordpress/wp-content` : Repository of the specific data of your Wordpress instance (themes, media, ...)
- `/etc/wordpress/config-default.php` : Wordpress configuration file, in which you can find the password of the MySQL user that has been generated buring the installation.

-----
Have fun. Hack in peace.
