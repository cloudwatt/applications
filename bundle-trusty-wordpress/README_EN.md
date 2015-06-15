# 5 Minutes Stacks, episode two : WordPress - English version

## Episode Two : Wordpress

In the CMS Open-Source galaxy, WordPress is the most used in term of community, available functionalities and user adoption.
The Automattic compagny, which develop and distribute Wordpress, provides a SaaS offer allowing a user to create its blog in few minutes. However, those who experiments know that limits can be easily found by the wordpress.com hosting capabilities.

Today, Cloudwatt provides the necessary toolset to start your Wordpress instance in a few minutes and to become its master.

The deployement base is an Ubuntu trusty instance. The Apache and MySQL servers are deployed on a single instance.

## Nota Bene pour les plus pressés

Une image "Application Ubuntu 14.04.2 WORDPRESS" est disponible dans le catalogue des images publiques de la
console Cloudwatt. Pour des raisons de sécurité, cette image ne contient pas l'initialisation de la base MySQL et n'est donc pas 
fonctionnelle en mode "Lancer une instance". 

Cette image est destinée à servir de base de déploiement au template Heat que nous allons détailler dans cet article.
Le template en question contient les étapes indispensables après lancement, de génération de mot de passe, création 
d'utilisateur, création de la base MySQL pour Wordpress et configuration finale de Wordpress pour les accès à MySQL.

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

A chaque nouveau déploiement de stack, un mot de passe MySQL est généré, directement dans le fichier de configuration `/etc/wordpress/config-default.php`.

### Enjoy

Une fois tout ceci fait, vous pouvez lancez le script `stack-get-url.sh` en passant en paramètre le nom de la stack.

~~~ bash
./stack-get-url.sh LE_BIDULE
LE_BIDULE 82.40.34.249
~~~ 

qui va récupérer l'IP flottante attribuée à votre stack. Vous pouvez alors attaquer cette IP avec votre navigateur préféré et commencer à configurer votre instance Wordpress.

## Dans les coulisses

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr
* faire une mise à jour de tous les paquets système
* installer Apache, PHP, MySQL et Wordpress dessus
* configurer MySQL avec un utilisateur et une base dédiés à WordPres, avec mot de passe généré
* l'exposer sur Internet via une IP flottante

<a name="console" />

### C’est bien tout ça, mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur Wordpress :

1.	Allez sur le Github Cloudwatt dans le répertoire applications/bundle-trusty-wordpress
2.	Cliquez sur le fichier nommé bundle-trusty-wordpress.heat.yml
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

Vous avez un point d'entrée sur votre machine virtuelle en ssh via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Les chemins intéressants sur votre machine :

- `/usr/share/wordpress` : Répertoire d'installation de WordPress.
- `/var/lib/wordpress/wp-content` : Répertoire de données spécifiques à votre instance Wordpress (thèmes, médias, ...).
- `/etc/wordpress/config-default.php` : Fichier de configuration de WordPress, dans lequel se trouve le mot de passe du user MySQL, généré pendant l'installation.


-----
Have fun. Hack in peace.
