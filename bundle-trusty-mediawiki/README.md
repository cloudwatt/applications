# 5 Minutes Stacks, épisode 20 : Mediawiki #

## Episode 20 : Mediawiki

![mediawikilogo](https://upload.wikimedia.org/wikipedia/commons/0/01/MediaWiki-smaller-logo.png)

MediaWiki est un moteur de wiki pour le Web. Il est utilisé par l’ensemble des projets de la Wikimedia Foundation, ainsi que par l’ensemble des wikis hébergés chez Wikia et par de nombreux autres wikis. Conçu pour répondre aux besoins de Wikipédia, ce moteur est depuis 2008 également utilisé par des entreprises comme solution de gestion des connaissances et comme système de gestion de contenu.
MediaWiki est écrit en PHP, et peut aussi bien fonctionner avec une base de données MySQL que PostgreSQL. C'est un logiciel libre distribué selon les termes de la GPL.
MediaWiki inclut de nombreuses fonctionnalités pour les sites à vocation collaborative : la gestion des espaces de noms, ou encore l'utilisation de pages de discussions associées à chaque article.

## Preparations

### Les versions
 - Ubuntu Trusty 14.04.2
 - MediaWiki 1.26.2
 - Mysql  5.7

### Les pré-requis pour déployer cette stack
Ceci devrait être une routine à présent:

* Un accès internet
* Un shell linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "Small" (s1.cw.small-1). Il
existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `bundle-trusty-mediawiki/`

* `bundle-trusty-mediawiki.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
* `stack-start.sh`: Scipt de lancement de la stack, qui simplifie la saisie des parametres et sécurise la création du mot de passe admin.
* `stack-get-url.sh`: Script de récupération de l'IP d'entrée de votre stack, qui peut aussi se trouver dans les parametres de sortie de la stack.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell et entrez votre mot de passe lorsque vous êtes invité à utiliser les clients OpenStack.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Une fois ceci fait, les outils de ligne de commande d'OpenStack peuvent interagir avec votre compte Cloudwatt.


### Ajuster les paramètres

Dans le fichier `bundle-trusty-mediawiki.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster
est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Mediawiki stack


parameters:
  keypair_name:
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string
    default: my-keypair-name                <-- Mettez ici le nom de votre keypair


  flavor_name:
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
    default: s1.cw.small-1
    constraints:
      - allowed_values:
        [...]

resources:
  network:
    type: OS::Neutron::Net

  subnet:
    type: OS::Neutron::Subnet
    properties:
      network_id: { get_resource: network }
      ip_version: 4
      cidr: 10.0.1.0/24
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.199 }
[...]
~~~

<a name="startup" />

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh`:

~~~
./stack-start.sh nom_de_votre_stack
~~~

Exemple :

~~~bash
$ ./stack-start.sh EXP_STACK
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | EXP_STACK       | CREATE_IN_PROGRESS | 2015-11-25T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Puis attendez **5 minutes** que le déploiement soit complet.


~~~bash
$ heat resource-list EXP_STACK
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name    | physical_resource_id                                | resource_type                   | resource_status | updated_time         |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip      | 44dd841f-8570-4f02-a8cc-f21a125cc8aa                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2015-11-25T11:03:51Z |
| security_group   | efead2a2-c91b-470e-a234-58746da6ac22                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2015-11-25T11:03:52Z |
| network          | 7e142d1b-f660-498d-961a-b03d0aee5cff                | OS::Neutron::Net                | CREATE_COMPLETE | 2015-11-25T11:03:56Z |
| subnet           | 442b31bf-0d3e-406b-8d5f-7b1b6181a381                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-25T11:03:57Z |
| server           | f5b22d22-1cfe-41bb-9e30-4d089285e5e5                | OS::Nova::Server                | CREATE_COMPLETE | 2015-11-25T11:04:00Z |
| floating_ip_link | 44dd841f-8570-4f02-a8cc-f21a125cc8aa-`floating IP`  | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2015-11-25T11:04:30Z |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------
~~~

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu trusty, pré-provisionnée avec la stack mediawiki
* l'exposer sur Internet via une IP flottante

### Enjoy

Une fois tout ceci fait vous pouvez vous connecter via un navigateur web sur votre serveur mediawiki afin de commencer à le paramétrer
exemple :

http://floatingIP/mediawiki

vous devez arriver sur cette page :

![imagesetup](https://www.siteground.com/img/knox/tutorials/uploaded_images/images/mediawiki/new/image1.jpg)

le login de votre base de donnée est 'mediawiki' et le mot de passe de votre base de donnée ce trouve dans le fichier /mediawiki/password_db

![confBDD](https://www.siteground.com/img/knox/tutorials/uploaded_images/images/mediawiki/new/inst3.jpg)

une fois le fichier `LocalSettings.php` généré sauvegardez le.

Il faut maintenant le copier dans le répertoire `/etc/mediawiki` sur votre serveur via la commande suivante:

```
$ scp /Telechargement/LocalSettings.php -oIdentityFile "chemin ssh key" cloud@floattingIP:/var/www/html/mediawiki/
```

une fois cette opération effectuée lancer la commande

```
# service apache2 restart
```

afin que le service apache reprenne l'ensemble des paramètres

faites un refresh sur l'url http://floatingIP/mediawiki

Mediawiki est maintenant configuré vous pouvez commencer à écrire vos articles,

#### Autres sources pouvant vous intéresser:

* [Mediawiki Homepage](https://www.mediawiki.org/wiki/MediaWiki/fr)
* [Mediawiki Documentation](https://www.mediawiki.org/wiki/Documentation/fr)

-----
Have fun. Hack in peace.
