# 5 Minutes Stacks, épisode deux : WordPress

## Episode deux : Wordpress

Dans la galaxie des CMS Open-Source, WordPress figure en bonne place en termes de communauté, de fonctionnalités et d'adoption. La société Automattic, qui développe et distribue WordPress, fourni une offre SaaS permettant de créer son blog en quelques minutes. Pour autant, ceux qui en ont fait l'expérience savent qu'on se retrouve rapidement limité par le cadre d'hébergement de wordpress.com.

Aujourd'hui nous mettons à votre disposition de quoi démarrer votre instance WordPress en quelques minutes et rester maître à bord pour la faire vivre.

La base de déploiement est une instance unique Ubuntu Trusty pré-provisionnée avec les serveurs Apache et MySQL.

## Préparatifs

### Les versions

* Ubuntu 14.04.2
* Apache 2.4.7
* Wordpress 3.8.2
* MySQL 5.5.43
* PHP 5.5.9

### Les pré-requis pour déployer cette stack

* un accès internet
* un shell Linux
* un [compte Cloudwatt](https://www.cloudwatt.com/authentification), avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### La taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type " Small " (s1.cw.small-1) en tarification à l'usage (les prix à l'heure et au mois sont disponibles sur la [page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt). Bien sur, vous pouvez ajuster les parametres de la stack et en particulier sa taille par défaut. 

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version « lancement par la console » en cliquant sur [ce lien](#console) 

## Tour du propriétaire

Une fois le repository cloné, vous trouvez, dans le répertoire `bundle-trusty-wordpress/` :

* `bundle-trusty-wordpress.heat.yml` : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.
* `stack-start.sh` : Script de lancement de la stack. C'est un micro-script pour vous économiser quelques copier-coller.
* `stack-get-url.sh` : Script de récupération de l'IP d'entrée de votre stack.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis vous le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé. 

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~ 

Une fois ceci fait, les outils ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

Dans le fichier `bundle-trusty-wordpress.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Wordpress stack


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

~~~ bash
$ ./stack-start.sh LE_BIDULE
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| ed4ac18a-4415-467e-928c-1bef193e4f38 | LE_BIDULE  | CREATE_IN_PROGRESS | 2015-04-21T08:29:45Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~ 

Enfin, attendez 5 minutes que le déploiement soit complet.

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
