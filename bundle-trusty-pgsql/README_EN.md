# 5 Minutes Stacks, Episode four : PostgreSQL
## Work in progress

## PostgreSQL

For this fourth episode of the 5 minutes Stacks serie, we will mount a well-known relationnal database server : PostgreSQL. 
Following this tutorial, you will get :

* an Ubuntu Trusty Tahr based instance, preprovisionned with the pgSQL stack
* an web based administration interface
* a data volume hosting the basic data allowing easier backups procedure 

### The versions

* Ubuntu 14.04.2
* Apache 2.4.7
* PostgreSQL 9.3
* PHP 5.5.9
* PhpPgAdmin 5.1

### The prerequisites to deploy this stack

There are the same than for the previous episodes :

* an internet acces
* a Linux shell
* a [Cloudwatt account](https://www.cloudwatt.com/authentification), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

Per default, the script is proposing a deployement on an instance type "Small" (s1.cw.small-1). Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console) 

## What will you find in the repository

Once you have cloned the github, you will find in the `bundle-trusty-pgsql/` repository:

* `bundle-trusty-pgsql.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `seed-pgsql.yml` : Post-configuration Ansible playbook that will generate the admin password, verify the mounting points, etc.
* `stack-start.sh`: Stack launching script. This is a small script that will save you some copy-paste.
* `stack-get-url.sh`: Flotting IP recovery script.

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

With the `bundle-trusty-pgsql.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

~~~ yaml
heat_template_version: 2013-05-23


description: Postgresql with PhpPgAdmin


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

~~~
./stack-start.sh ACID
~~~

Last, wait 5 minutes until the deployement been completed.

The  `start-stack.sh` script is taking care of running the API necessary requests to: 

* start an Ubuntu Trusty Tahr based instance, preprovisionned with the pgSQL stack
* show a flotting IP on the internet


### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script. It will gather the entry url of your stack.

~~~ bash
./stack-get-url.sh ACID
ACID 82.40.34.249
~~~ 

### Administration interface

Dans cette stack, nous avons adjoint à PostgreSQL une instance de PhpPgAdmin pour pouvoir facilement administrer la base.
Pour plus de sûreté, les Security Group créés n'exposent pas cette interface à l'extérieur. pour vous y rendre, le moyen 
le plus sûr est d'établir un tunnel ssh vers votre instance.

~~~ bash
$ ssh cloud@82.40.34.249 -i ~/.ssh/$VOTRE_KEYPAIR -L 8080:localhost:80
~~~

Cela va établir un transfert du port 80 de votre serveur de base, vers le port 8080 de votre machine locale. Profitez 
donc d'être connecté pour récupérer le mot de passe généré pour votre instance.

~~~ bash
# à lancer sur le serveur lancé
$ sudo cat /root/keystore
~~~

Le contenu de ce fichier contient votre mot de passe unique pour le super-utilisateur de PostgreSQL.

A partir de là, avec votre navigateur préféré, rendez-vous sur `http://localhost:8080/phppgadmin` et 
connectez vous avec l'utilisateur `pgadmin` et le mot de passe que vous venez de récupérer. 
Vous êtes maintenant en autonomie sur la gestion de la base.

<a name="console" />

### All of this is fine, but you do not have a way to run the stack thru the console ?

Yes ! Using the console, you can deploy a pgSQL server:

1.	Go the Cloudwatt Github in the applications/bundle-trusty-mean repository
2.	Click on the file nammed bundle-trusty-pgsql.heat.yml
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

Parmi les pistes pour vous approprier ces ressources et les utiliser dans la Vraie Vie :

* organiser des backups par des snapshots réguliers du volume de data.
* retravailler le template heat pour déployer votre instance PostgreSQL dans une zone privée, accessible depuis vos frontaux web.
* déployer manuellement l'image publique `Application Ubuntu 14.04.2 PGSQL` dans votre architecture.

Dans ce dernier cas, pensez, soit à appliquer le [playbook ansible](http://docs.ansible.com/playbooks.html) `seed-pgsql.yml` sur le serveur, ou au moins a le lire pour avoir le détail des opérations de configuration post-lancement.

-----
Have fun. Hack in peace.
