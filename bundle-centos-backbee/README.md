# 5 Minutes Stacks, épisode 54 : Backbee

## Episode 54 : Backbee

BackBee est le premier système de gestion de contenu (CMS) "One-Page-Editing", ce qui signifie que vous pouvez facilement créer et gérer des sites Web tels qu'ils apparaissent sans aucune connaissance technique préalable.

La technologie "One-Page-Editing" est un outil qui vous permet d'entrer, d'éditer et de gérer votre site web directement tel qu'il apparaît à vos utilisateurs: Le back office et le front office sont fusionnés.

Aujourd'hui, Cloudwatt fournit les outils nécessaires et de lancer votre instance BackBee en quelques minutes et de devenir son maître.

La base de déploiement est une instance unique Centos 7 pré-provisionnée avec les serveurs Apache et MariaDB.

## Préparatifs

### Les versions

* Centos 7 
* Apache 2.4
* BackBee 1.2
* MariaDB 5.5
* PHP 5.4

## Installation One-Click

Allez sur la page Applications du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : vous avez accès à votre BackBee !

Il ne vous reste plus cas finir l'installation de celui-ci, vous trouverez plus d'informations sur [ce lien](#install)

## Installation via la console

En utilisant la console, vous pouvez déployer un serveur BackBee :

1.	Allez sur le Github Cloudwatt dans le répertoire applications/bundle-centos-backbee
2.	Cliquez sur le fichier nommé bundle-centos-backbee.heat.yml
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement. Ne vous reste plus qu’à lancer votre IP dans votre navigateur.

C’est (déjà) FINI !

## Installation en CLI

Si vous n'aimez que la ligne de commande, vous pouvez passer directement à la version "lancement en CLI" en cliquant sur [ce lien](#cli)

## Pour aller plus loin
<a name="install" />

### Configuration de la base de donnée
![Configuration de la base de donnée](https://raw.githubusercontent.com/flemzord/applications/master/bundle-centos-backbee/images/installation.png?raw=true)

### Page d'accueil
![Page d'accueil](https://raw.githubusercontent.com/flemzord/applications/master/bundle-centos-backbee/images/homepage.png?raw=true)

### Page d'accueil + BackOffice
![Page d'accueil et BackOffice](https://raw.githubusercontent.com/flemzord/applications/master/bundle-centos-backbee/images/homepage_back.png?raw=true)

### Configuration de la base de donnée

La configuration de la base de donnée est assez simple. 

Vous devez rentrer les informations suivantes : 

- Serveur : 127.0.0.1 ou localhost
- Port : 3306
- Nom de la base de donnée : backbee
- Nom d'utilisateur de la base de donnée : backbee

Vous trouverez le mot de passe de votre utilisateur MariaDB a cette adresse : `http://IP/password.txt`.

Et voilà, vous pouvez continuer de configurer BackBee comme vous le souhaitez.


## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord. 

Vous avez un point d'entrée sur votre machine virtuelle en ssh via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Les chemins intéressants sur votre machine :

- `/home/www` : Répertoire d'installation de BackBee
- [Site de l'editeur](https://backbee.com/)
- [Site Dev](http://developers.backbee.com/)


<a name="cli" />

## Installer en CLI

### Les pré-requis pour déployer cette stack

* un accès internet
* un shell Linux
* un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact), avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)

### La taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type " Small " (s1.cw.small-1) en tarification à l'usage (les prix à l'heure et au mois sont disponibles sur la [page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt). Bien sur, vous pouvez ajuster les parametres de la stack et en particulier sa taille par défaut. 

### Tour du propriétaire

Une fois le repository cloné, vous trouvez, dans le répertoire `bundle-centos-backbee/` :

* `bundle-centos-backbee.heat.yml` : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.
* `stack-start.sh` : Script de lancement de la stack. C'est un micro-script pour vous économiser quelques copier-coller.
* `stack-get-url.sh` : Script de récupération de l'IP d'entrée de votre stack.

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis vous le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé. 

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~ 

Une fois ceci fait, les outils ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

Dans le fichier `bundle-centos-backbee.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one BackBee stack


parameters:
  keypair_name:
    default: YOUR_KEY         <-- Mettez ici le nom de votre paire de clés
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

~~~ bash
$ ./stack-start.sh STACK_NAME
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| ed4ac18a-4415-467e-928c-1bef193e4f38 | STACK_NAME | CREATE_IN_PROGRESS | 2015-04-21T08:29:45Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~ 

Enfin, attendez 5 minutes que le déploiement soit complet.

A chaque nouveau déploiement de stack, un mot de passe MySQL est généré, disponible lors de l'installation a l'adresse `http://IP/password.txt`.
Une fois le CMS installé celui-ci sera supprimé.

### Enjoy

Une fois tout ceci fait, vous pouvez lancez le script `stack-get-url.sh` en passant en paramètre le nom de la stack.

~~~ bash
./stack-get-url.sh STACK_NAME
STACK_NAME 82.40.34.249
~~~ 

Celui-ci va récupérer l'IP flottante attribuée à votre stack. Vous pouvez alors attaquer cette IP avec votre navigateur préféré et commencer à configurer votre instance Wordpress.

## Dans les coulisses

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Centos 7
* faire une mise à jour de tous les paquets système
* installer Apache, PHP, MariaDB et BackBee dessus
* configurer MySQL avec un utilisateur et une base dédiés à BackBee, avec mot de passe généré
* l'exposer sur Internet via une IP flottante

-----
Have fun. Hack in peace.