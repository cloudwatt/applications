
# 5 Minutes Stacks, episode three : MEAN - English version
## Work in progress
## Episode three : MEAN

Pour ce troisème volet, nous nous penchons sur la stack MEAN :

* MongoDB : Le désormais célèbre moteur NoSQL orienté document
* Express.js : Le framework web pour Node.js
* Angular.js : Framework d'applications Front-web
* Node.js : Le serveur d'application en Javascript

En suivant ce tutoriel, vous obtiendrez une instance Ubuntu Trusty Tahr, pré-configurée avec un serveur NGinx en frontal sur le port 80, forwardant vers un serveur Node.js, monitoré et maintenu en vie par [Foreverjs](https://github.com/foreverjs/forever), une instance MongoDB et un déploiement fonctionnel de l'application de démonstration de [MeanJS](http://meanjs.org/). Pour des considérations de sécurité, MongoDB n'accepte de connexions que depuis le serveur lui-même.

## Préparatifs

### The versions

* MongoDB
* Express
* Angular 
* Node.js

### The prerequisites to deploy this stack

Ce sont les mêmes que pour les épisodes précédents :

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

Once you have cloned the github, you will find in the `bundle-trusty-mean/` repository:

* `bundle-trusty-mean.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
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

Dans le fichier `bundle-trusty-mean.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ bash
heat_template_version: 2013-05-23


description: All-in-one MEAN stack


parameters:
  keypair_name:
    default: amaury-ext-compute         <-- Mettez ici le nom de votre paire de clés
    description: Keypair to inject in instances
    type: string

[...]
~~~ 

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~ bash
$ ./stack-start.sh IM_MEAN
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| ed4ac18a-4415-467e-928c-1bef193e4f38 | IM_MEAN    | CREATE_IN_PROGRESS | 2015-04-21T08:29:45Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~ 

Enfin, attendez 5 minutes que le déploiement soit complet.

### Enjoy

Une fois tout ceci fait, vous pouvez lancez le script `stack-get-url.sh` en passant en paramètre le nom de la stack.

~~~ bash
./stack-get-url.sh IM_MEAN
IM_MEAN 82.40.34.249
~~~ 

qui va récupérer l'IP flottante attribuée à votre stack. Vous pouvez alors attaquer cette IP avec votre navigateur préféré et commencer à configurer votre instance Wordpress.

## Dans les coulisses

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr
* l'exposer sur Internet via une IP flottante

<a name="console" />

### C’est bien tout ça, mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur MEAN :

1.	Allez sur le Github Cloudwatt dans le répertoire applications/bundle-trusty-mean
2.	Cliquez sur le fichier nommé bundle-trusty-mean.heat.yml
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

- `/var/lib/www` : Répertoire d'installation de l'application MeanJS. C'est le répertoire exposé par Node.js
- `/etc/nginx/sites-available/node_proxy` : Fichier de configuration de Nginx dédié au proxying HTTP vers Node.js
- `/etc/init.d/nodejs` : Script d'init du service Node.js via Foreverjs.

Quelques ressources qui pourraient vous intéresser :

* [Documentation NGinx](http://nginx.org/en/docs/)
* [Framework MeanJS](http://meanjs.org/)


-----
Have fun. Hack in peace.

