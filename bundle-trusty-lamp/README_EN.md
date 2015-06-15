# DRAFT english version - 5 minutes stacks episode one : LAMP #

Welcome to the inauguration of the 5 Minutes Stacks series !

## The concept

Regularly, Cloudwatt will publish on his technical blog and his github, applicative stacks with their associated deployement guide. 
The goal is to facilitate your life while starting up projects. The procedure takes few minutes to prepare and 5 minutes to deploy.

Once the stack is deployed, you become its master and you can immediately play with it.

If you have any questions, remarks or enhancement requests, do not hesitate to open an issue on the github or to submit a pull request.

## Episode premier : Linux-Apache-MySQL-PHP5

The deployement base is an Ubuntu trusty instance. The Apache and MySQL servers are deployed on a single instance.

### The versions

* Ubuntu 14.04.2
* Apache 2.4.7
* MySQL 5.5.43
* PHP 5.5.9

### The prerequisites to deploy this stack

* an internet acces
* a Linux shell
* a [Cloudwatt account](https://www.cloudwatt.com/authentification), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

Per default, the script is proposing a deployement on an instance type "Small" (s1.cw.small-1).  Instances are charged by the minute and capped at their monthly price (you can find amore details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by cliking [here](#console) 

## Tour du propriétaire

Once you have cloned the github, you will find in the `bundle-trusty-lamp/` repository :

* `bundle-trusty-lamp.heat.yml` : HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh` : Stack launching script. This is a small script that will save you some copy-paste.
* `stack-get-url.sh` : Flotting IP recovery script.


## Start-up

### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). 
If you are not logged in yet, you will go thru the authentication screeen then the swript download will start. Thanks to it, you will be able to initiate the shell acccesses towards the Cloudwatt APIs.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé. 

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Une fois ceci fait, les outils ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Adjust the parameters

Dans le fichier `bundle-trusty-lamp.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23


description: Basic all-in-one LAMP stack


parameters:
  keypair_name:
    default: amaury-ext-compute         <-- Indicate here your keypair
    description: Keypair to inject in instances
    type: string

  flavor_name:
    default: s1.cw.small-1              <-- indicate here the flavor size
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

In a shell, run the script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~
./stack-start.sh MA_LAMPE
~~~

Last, wait 5 minutes until the deployement been completed.

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr, pré-provisionnée avec la stack LAMP
* l'exposer sur Internet via une IP flottante

### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script qui va récupérer l'url d'entrée de votre stack.

<a name="console" />

### All of this is fine, but you do not have a way to run the stack thru the console ?

Et bien si ! Using the console, you can deploy a LAMP server :

1.	Go the Cloudwatt Github in the applications/bundle-trusty-lamp repository
2.	Cliquez sur le fichier nommé bundle-trusty-lamp.heat.yml
3.	Clic on RAW, a web page appear with the script detail
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement. Ne vous reste plus qu’à lancer votre IP dans votre navigateur.

C’est (déjà) FINI !


## So watt ?


This tutorial a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord. 

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Vous pouvez commencer à construire votre site en prenant la main sur votre serveur. Les points d'entrée utiles :

* `/etc/apache2/sites-available/default-cw.conf` : configuration Apache par défaut 
* `/var/www/cw` : le répertoire de déploiement du mini site php d'exemple

-----
Have fun. Hack in peace.
