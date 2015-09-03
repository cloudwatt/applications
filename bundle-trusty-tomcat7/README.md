# 5 Minutes Stacks, Episode huit : Tomcat 7

## Episode huit : Tomcat 7

Pour ce huitième épisode, un grand classique : Tomcat 7.

## Préparatifs

### Les versions

* Tomcat 7 (tomcat7) 7.0.52-1ubuntu0.3

### Les pré-requis pour déployer cette stack

Ce sont les mêmes que pour les épisodes précédents :

* un accès internet
* un shell Linux
* un [compte Cloudwatt](https://www.cloudwatt.com/authentification), avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type " Small " (s1.cw.small-1) en tarification à l'usage (les prix à l'heure et au mois sont disponibles sur la [page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt). Bien sûr, vous pouvez ajuster les paramètres de la stack et en particulier sa taille par défaut.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version « lancement par la console » en cliquant sur [ce lien](#console).
Et si vous le souhaitez, vous pouvez même lancer cette stack directement depuis le site web de Cloudwatt dans la rubrique [Applications](https://www.cloudwatt.com/fr/applications/index.html) d’un simple clic !

## Tour du propriétaire

Une fois le repository cloné, vous trouvez, dans le répertoire `bundle-trusty-tomcat7/` :

* `bundle-trusty-tomcat7.heat.yml` : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.
* `stack-start.sh` : Script de lancement de la stack. C'est un micro-script pour vous économiser quelques copier-coller.
* `stack-get-url.sh` : Script de récupération de l'IP d'entrée de votre stack.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis vous le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

$ [some sweet shell input...]
~~~

Une fois ceci fait, les outils ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

Dans le fichier `bundle-trusty-tomcat7.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.

C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

Par défaut, un réseau et un sous-réseau sont automatiquement créés. Ce comportement peut être modifié aussi en éditant le fichier `bundle-trusty-gitlab.heat.yml`.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Tomcat7 stack


parameters:
  keypair_name:
    default: my-keypair-name                <-- Indiquer ici votre paire de clés par défaut
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: s1.cw.small-1                  <-- Indiquer ici la taille du volume par défaut
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
          - s1.cw.small-1
          - n1.cw.standard-1
          - n1.cw.standard-2
          - n1.cw.standard-4
          - n1.cw.standard-8
          - n1.cw.standard-12
          - n1.cw.standard-16

resources:
  network:                                  <-- Paramètres réseau
    type: OS::Neutron::Net

  subnet:                                   <-- Paramètres sous-réseau
    type: OS::Neutron::Subnet
    properties:
      network_id: { get_resource: network }
      ip_version: 4
      cidr: 10.0.1.0/24
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.199 }
[...]
~~~

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~ bash
$ ./stack-start.sh Bobcat8
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | Bobcat8    | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Enfin, attendez 5 minutes que le déploiement soit complet (vous pouvez utiliser la commande `watch` pour voir le statut en temps réel).

~~~ bash
$ watch heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | Bobcat8    | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Enjoy

Une fois tout ceci fait, vous pouvez lancez le script `stack-get-url.sh` en passant en paramètre le nom de la stack.

~~~ bash
$ ./stack-get-url.sh Bobcat8
Bobcat8 http://70.60.637.17
~~~

qui va récupérer l'IP flottante attribuée à votre stack. Vous pouvez alors attaquer cette IP avec votre navigateur préféré et commencer à jour avec votre instance Tomcat 7.

## Dans les coulisses

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr
* l'exposer sur Internet via une IP flottante

<a name="console" />

### C’est bien tout ça, mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer votre serveur
Tomcat 7 :

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/bundle-trusty-tomcat7](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-tomcat7)
2.	Cliquez sur le fichier nommé `bundle-trusty-tomcat7.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script (ou alors, juste cliquez [ici](https://raw.githubusercontent.com/cloudwatt/applications/master/bundle-trusty-tomcat7/bundle-trusty-tomcat7.heat.yml))
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement ou plus simplement aller dans l'onglet "vue d'ensemble". Ne vous reste plus qu’à lancer votre IP dans votre navigateur.

C’est (déjà) FINI !

## So watt?

Ce tutoriel a pour but d'accélérer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en ssh via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Les chemins intéressants sur votre machine :

- `/etc/apache2/sites-available/default-tomcat.conf`: Apache proxy configuration file for Tomcat 7. By default this is the only site enabled.
- `/var/lib/tomcat7/webapps/`: Tomcat 7's default app directory.
- `/var/lib/tomcat7/webapps/ROOT.war`: Sample WAR file from [the official site](https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/).
- `/var/lib/tomcat7/webapps/ROOT/`: Deployed sample app, automatically generated by Tomcat 7 from the ROOT.war.
- `/etc/tomcat7/server.xml`: Main Tomcat 7 configuration file.

Quelques ressources qui pourraient vous intéresser :

* [Tomcat Main Site](http://tomcat.apache.org/)
* [Tomcat 7 Documentation](https://tomcat.apache.org/tomcat-7.0-doc/)
* [Tomcat 7 Developer Site](https://tomcat.apache.org/tomcat-7.0-doc/appdev/)


-----
Have fun. Hack in peace.
