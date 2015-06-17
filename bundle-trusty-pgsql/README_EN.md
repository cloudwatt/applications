# 5 Minutes Stacks, Episode four : PostgreSQL
## Work in progress


## PostgreSQL

Dans ce quatrième épisode, nous allons monter un serveur de base de données 
relationnelles bien connu : PostgreSQL. En suivant ce tutoriel, vous obtiendrez :

* une instance Ubuntu Trusty Tahr, pré-configurée avec un serveur PostgreSQL
* une interface d'aministration web
* un volume de données hébergeant  les données des bases, pour plus de simplicité à monter les backups

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



### Ajuster les paramètres

Dans le fichier `bundle-trusty-lamp.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23


description: Postgresql with PhpPgAdmin


parameters:
  keypair_name:
    default: amaury-ext-compute         <-- Mettez ici le nom de votre paire de clés
    description: Keypair to inject in instances
    type: string

  flavor_name:
    default: s1.cw.small-1              <-- Mettez ici l'identifiant de votre flavor
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

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~
./stack-start.sh ACID
~~~

Enfin, attendez 5 minutes que le déploiement soit complet.

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr, pré-provisionnée avec la stack LAMP
* l'exposer sur Internet via une IP flottante

### Bienvenue

Une fois tout ceci fait, vous pouvez lancez le script `stack-get-url.sh` qui va récupérer l'url d'entrée de votre stack.

~~~ bash
./stack-get-url.sh ACID
ACID 82.40.34.249
~~~ 

### Interface d'administration

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

### C’est bien tout ça, mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur de base de données relationnelles PostgreSQL :

1.	Allez sur le Github Cloudwatt dans le répertoire applications/bundle-trusty-mean
2.	Cliquez sur le fichier nommé bundle-trusty-pgsql.heat.yml
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement. Ne vous reste plus qu’à lancer votre IP dans votre navigateur.

C’est (déjà) FINI !

## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord. 

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Parmi les pistes pour vous approprier ces ressources et les utiliser dans la Vraie Vie :

* organiser des backups par des snapshots réguliers du volume de data.
* retravailler le template heat pour déployer votre instance PostgreSQL dans une zone privée, accessible depuis vos frontaux web.
* déployer manuellement l'image publique `Application Ubuntu 14.04.2 PGSQL` dans votre architecture.

Dans ce dernier cas, pensez, soit à appliquer le [playbook ansible](http://docs.ansible.com/playbooks.html) `seed-pgsql.yml` sur le serveur, ou au moins a le lire pour 
avoir le détail des opérations de configuration post-lancement.

-----
Have fun. Hack in peace.
