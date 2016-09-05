# 5 Minutes Stacks, épisode 31 : CouchBase #

## Episode 31 : CouchBase

![couchebase](img/couchbase-logo.gif)

CouchBase joue la carte de la base de données NoSQL dans une approche temps réel, et mise fortement sur une demande en devenir, le NoSQL sur le mobile via la synchronisation sur le modèle JSon.
Avec le temps, les bases de données NoSQL se font de plus en plus efficaces. Il était temps. Car il faut affronter la problématique de l’augmentation exponentielle des volumes de données, en particulier non structurées. Couchbase propose sa solution, et va plus loin en misant sur l’arrivée du modèle JSon sur le mobile pour accompagner la synchronisation avec sa base et ses serveurs NoSQL.

## Preparations

### Les versions
  - CoreOS Stable 1010.6
  - Docker 1.10.3
  - CoucheBase 4.5.0

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent:
 * Un accès internet
 * Un shell linux
 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "standard-1" (n1.cw.standard-1). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `blueprint-coreos-couchbase/`

* `blueprint-coreos-couchbase.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.

* `stack-start.sh`: Script de lancement de la stack, qui simplifie la saisie des parametres et sécurise la création du mot de passe admin.

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

Dans le fichier `blueprint-coreos-couchbase.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23
description: Blueprint CoreOS Couchbase
parameters:
  keypair_name:                 
    default: keypair            <-- Indiquer ici votre paire de clés par défaut
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: n1.cw.standard-1   <-- Indiquer ici la taille de l’instance par défaut
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
          - n1.cw.standard-1
          - n1.cw.standard-2
          - n1.cw.standard-4
          - n1.cw.standard-8
          - n1.cw.standard-12
          - n1.cw.standard-16

  volume_size:            <-- Indiquer ici la taille du volume
    default: 5
    label: Backup Volume Size
    description: Size of Volume for couchbase Storage (Gigabytes)
    type: number
    constraints:
      - range: { min: 5, max: 10000 }
        description: Volume must be at least 10 gigabytes

  volume_type:
    default: standard   <-- Indiquer ici le type du volume
    label: Backup Volume Type
    description: Performance flavor of the linked Volume for couchbase Storage
    type: string
    constraints:
      - allowed_values:
          - standard
          - performant

 [...]
 ~~~
### Démarrer la stack

 Dans un shell, lancer le script `stack-start.sh` :

 ~~~ bash
 $ ./stack-start.sh couchbase
 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | couchbase     | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+--------------------+----------------------+
 ~~~

 Attendez **5 minutes** que le déploiement soit complet (vous pouvez utiliser la commande `watch` pour voir le statut en temps réel).

 ~~~ bash
 $ watch -n 1 heat stack-list
 +--------------------------------------+------------+-----------------+----------------------+
 | id                                   | stack_name | stack_status    | creation_time        |
 +--------------------------------------+------------+-----------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | couchbase     | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+-----------------+----------------------+
 ~~~

 <a name="console" />

## C’est bien tout ça, mais...

### Une Ligne de commande semble aussi amical qu'un management à la militaire

Heureusement pour vous alors, la totalité de la configuration de CouchBase peut être faite en utilisant uniquement l'interface web.

Pour créer votre stack CoucheBase depuis la [Console Cloudwatt](https://console.cloudwatt.com):

1.	Allez sur le Github Cloudwatt dans le dépôt [applications/blueprint-coreos-couchbase](https://github.com/cloudwatt/applications/edit/master/blueprint-coreos-couchbase/)
2.	Cliquez sur le fichier nommé `blueprint-coreos-couchbase.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec uniquement le template
4.	Enregistrez le fichier sur votre PC. Vous pouvez utiliser le nom proposé par défaut par votre navigateur (juste enlever le `.txt` si besoin)
5.  Allez dans la section [Stacks](https://console.cloudwatt.com/project/stacks/) de la console
6.	Cliquez sur `LAUNCH STACK`, puis `Browse` sous `Template file` et selectionnez le fichier que vous venez d'enregistrer sur votre PC et puis cliquez finalement sur `NEXT`
7.	Nommez votre stack dans le champs `Stack Name`
8.	Entrez le nom de votre keypair dans le champs `SSH Keypair` et remplissez les quelques autres champs
9.	Choisissez votre instance flavor en utilisant le menu déroulant `Instance Type` et cliquez sur `LAUNCH`

La stack sera automatiquement générée (vous pourrez voir sa progression en cliquant sur son nom). Lorsque tous les modules passeront au vert, la création sera complète. Vous pouvez alors aller dans le menu "instances" pour trouver l'IP-flottante, ou simplement rafraîchir la page courante et vérifier l'onglet Présentation.

Si vous avez atteint ce point, alors votre stack est fonctionnelle ! Profitez de Couchbase.

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... Coder maintenant !


### Enjoy

 Une fois tout ceci fait, vous pouvez récupérer la description du votre stack à partir de cette commande :

 ~~~ bash
 $ heat stack-show couchbase
 +-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
| Property              | Value                                                                                                                                    |
+-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
| capabilities          | []                                                                                                                                       |
| creation_time         | 2016-08-22T12:41:20Z                                                                                                                     |
| description           | Blueprint CoreOS Couchbase                                                                                                               |
| disable_rollback      | True                                                                                                                                     |
| id                    | 0cb5221a-c104-497a-92c1-47f49b7145cb                                                                                                     |
| links                 | https://orchestration.fr1.cloudwatt.com/v1/467b00f998064f1688feeca95bdc7a88/stacks/couchbase/0cb5221a-c104-497a-92c1-47f49b7145cb (self) |
| notification_topics   | []                                                                                                                                       |
| outputs               | [                                                                                                                                        |
|                       |   {                                                                                                                                      |
|                       |     "output_value": "http://floatingIp:8091",                                                                                          |
|                       |     "description": "couchbase URL",                                                                                                      |
|                       |     "output_key": "floating_ip_url"                                                                                                      |
|                       |   }                                                                                                                                      |
|                       | ]                                                                                                                                        |
| parameters            | {                                                                                                                                        |
|                       |   "OS::project_id": "467b00f998064f1688feeca95bdc7a88",                                                                                  |
|                       |   "OS::stack_id": "0cb5221a-c104-497a-92c1-47f49b7145cb",                                                                                |
|                       |   "OS::stack_name": "couchbase",                                                                                                         |
|                       |   "keypair_name": "yourkey",                                                                                                              |
|                       |   "volume_type": "standard",                                                                                                             |
|                       |   "volume_size": "5",                                                                                                                    |
|                       |   "flavor_name": "n1.cw.standard-1"                                                                                                      |
|                       | }                                                                                                                                        |
| parent                | None                                                                                                                                     |
| stack_name            | couchbase                                                                                                                                |
| stack_owner           | youremail@cloudwatt.com                                                                                                |
| stack_status          | CREATE_COMPLETE                                                                                                                          |
| stack_status_reason   | Stack CREATE completed successfully                                                                                                      |
| stack_user_project_id | 65091a1295424361bb38d30f568bf150                                                                                                         |
| template_description  | Blueprint CoreOS Couchbase                                                                                                               |
| timeout_mins          | 60                                                                                                                                       |
| updated_time          | None                                                                                                                                     |
+-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
 ~~~

 Vous pouvez vous connecter sur l'inteface de Couchbase via un navigateur web à partir de cet url http://floatingIp:8091 et continuez l'installation de Couchbase.

 ![couchbase1](img/couchbase1.png)


##### Systemd - système d'initialisation de service couchbase

Pour démarrer le service :
~~~ bash
sudo systemctl start couchbase.service
~~~

Il est possible de consulter les logs en sortie du service lancé grâce à la commande suivante :
~~~ bash
journalctl -f -u couchbase.service
~~~

Le service se stop de la manière suivante :
~~~ bash
sudo systemctl stop couchbase.service
~~~


#### Autres sources pouvant vous intéresser:

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)
* [CouchBase Documentatuion](http://www.couchbase.com/)

-----
Have fun. Hack in peace.
