# 5 Minutes Stacks, épisode 46  : OpenStack CLI #

## Episode 46 : OpenStack CLI

Cette stack à pour but de vous permettre de piloter les différents modules de l'infrastructure Openstack de Cloudwatt.
En démarrant une image basée sur Debian Jessie avec le client openstack installé et vos informations d'identification qui vont vous permettre d'accéder à l'API de Cloudwatt via le shell de l'instance.

## Preparations

### Les versions

* openstackclient 3.6.0

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent:

* Un accès internet
* Un shell linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)

### Taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type "Tiny" (t1.cw.tiny) en tarification à l'usage (les prix à l'heure et au mois sont disponibles sur la [page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt). Bien sûr, vous pouvez ajuster les paramètres de la stack et en particulier sa taille par défaut.

## Démarrage

### mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer votre stack:

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/blueprint-jessie-openstack-cli](https://github.com/cloudwatt/applications/tree/master/blueprint-jessie-openstack-cli)
2.	Cliquez sur le fichier nommé `bundle-jessie-openstack-cli.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keession cliquant sur ypair dans le champ « keypair_name »
                                                                                      9.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name »
                                                                                      10. Entrez votre network_name dans le champ « network_name »
                                                                                      11. Entrez votre os_auth_url dans le champ « os_auth_url  »
                                                                                      12. Choisissez la région (fr1 ou fr2) parmi le menu déroulant « os_region_name »
                                                                                      13. Entrez votre os_tenant_name dans le champ « os_tenant_name »
                                                                                      14. Entrez votre os_username dans le champ « os_username »
                                                                                      15. Entrez votre os_password dans le champ « os_password » enfin cliquez sur « LANCER »
                                                                                      La stack va se créer automatiquement (vous pouvez en voir la progrson nom). Quand tous les modules deviendront « verts », la création sera terminée.
C’est (déjà) FINI !

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur **DEPLOYER** et laisser vous guider... 2 minutes plus tard un bouton vert apparait... **ACCEDER** : vous avez votre Stack !


## Enjoy

### Quelques exemples d'utilisation de la commande `openstack`.

Vous avez un point d'entrée sur votre machine virtuelle en ssh via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Pour lister les instances qui sont sur votre tenant :
~~~bash
$ openstack server list
~~~  

Pour lister les images qui sont sur votre tenant :
~~~bash
$ openstack image list
~~~  

Pour lister les réseaux qui sont sur votre tenant
~~~bash
openstack network list
~~~
Pour créer une stack via template heat :
~~~bash
$ openstack stack create MYSTACK --template server_console.yaml
~~~

Pour voir les détails de votre stack :
~~~bash
$ openstack stack resource list MYSTACK
~~~

Pour voir l'ensemble des options de la commande `openstack` :
~~~bash
$ openstack help
~~~

Les variables d'environnement sont dans le fichier `/home/cloud/.bashrc`, pour les lister via le shell:
~~~bash
$ env | grep OS

OS_REGION_NAME=fr1
OS_PASSWORD=xxxxxxxxxxxxxxxxxxxxx
OS_AUTH_URL=https://identity.fr1.cloudwatt.com/v2.0
OS_USERNAME=your_username
OS_TENANT_NAME=xxxxxxxxxxxxxxxxxx
~~~

### Autre sources pouvant vous intéresser:

* [Cloudwatt tutorial](https://support.cloudwatt.com/debuter/cli-fin.html)
* [Openstack-cli page](http://docs.openstack.org/user-guide/cli-cheat-sheet.html)


----
Have fun. Hack in peace.
