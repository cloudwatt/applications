# 5 Minutes Stacks, épisode premier : LAMP #

Bienvenue à l'inauguration de la série des 5 Minutes Stacks !

## Le concept

Régulièrement, Cloudwatt publiera, de façon conjointe sur ce blog et
sur son github, des stacks applicatives avec un guide de déploiement.
Le but est de vous facilitez la vie pour démarrer des projets. La
procédure prend quelques minutes à préparer et 5 minutes à déployer.

Une fois la pile applicative déployée, vous êtes maître dessus et vous
pouvez commencer à l'exploiter immédiatement.

Si vous avez des questions, remarques, idées d'améliorations n'hésitez
pas à ouvrir une issue sur Github ou à soumettre une pull-request.

## Episode premier : Linux-Apache-MySQL-PHP5

La base de déploiement est une instance Ubuntu Trusty. Les serveurs Apache et MySQL sont
déployés dans une instance unique. 

### Les versions

* Ubuntu 14.04
* Apache 2.0
* MySQL 
* PHP 5

### Les pré-requis pour déployer cette stack

* un accès internet
* un shell Linux
* un [compte Cloudwatt](https://www.cloudwatt.com/authentification), avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type "Small" en tarification à l'usage (les prix à l'heure et au mois sont disponibles sur la [page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt). Bien sur, vous pouvez ajuster les parametres de la stack et en particulier sa taille par défaut. 

## Tour du propriétaire

Une fois le repository cloné, vous trouvez, dans le répertoire ```bundle-trusty-lamp/```:

* ~~~ bundle-trusty-lamp.heat.yml ~~~ : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.
* ~~~ stack-start.sh ~~~ : Script de lancement de la stack. C'est un micro-script pour vous économiser quelques copier-coller.
* ~~~stack-get-url.sh~~~ : Script de récupération de l'IP d'entrée de votre stack.


## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé. 

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Une fois ceci fait, les outils ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

Dans le fichier ```bundle-trusty-lamp.heat.yml``` vous trouverez en haut une section ```parameters```. Le seul paramètre obligatoire à ajuster est celui nommé ```keypair_name``` dont la valeur ```default``` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre ```flavor```.

~~~ bash
heat_template_version: 2013-05-23


description: Basic all-in-one LAMP stack


parameters:
  keypair_name:
    default: amaury-ext-compute         <-- Mettez ici le nom de votre paire de clés
    description: Keypair to inject in instances
    type: string

[...]
~~~

### Démarrer la stack

Dans un shell, lancer le script ~~~ stack-start.sh ~~~ en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~
./stack-start.sh LE_BIDULE
~~~

Enfin, attendez 5 minutes que le déploiement soit complet.

Le script ```start-stack.sh``` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr, pré-provisionnée avec la stack LAMP
* l'exposer sur Internet via une IP flottante

### Enjoy

Une fois tout ceci fait, vous pouvez lancez le script ```stack-get-url.sh``` qui va récupérer l'url d'entrée de votre stack.


## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord. 

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur ```cloud``` par défaut).

Vous pouvez commencer à construire votre site en prenant la main sur votre serveur. Les points d'entrée utiles :

* ```/etc/apache2/sites-available/default-cw.conf``` : configuration Apache par défaut 
* ```/var/www/cw``` : le répertoire de déploiement du mini site php d'exemple

-----
Have fun. Hack in peace.
