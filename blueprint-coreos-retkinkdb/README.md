# 5 Minutes Stacks, épisode 34 : RetkinkDb #

## Episode 34 : RethinkDb

![Rethinkdb](img/rethinkdb.png)

RethinkDB est un système de gestion de bases de données distribuées orienté documents qui permet
de stocker des documents JSON. Il a été développé à partir de 2009 par une société du même nom.
L’entreprise est domiciliée au 156 E.Dana St. Mountain View, CA 94041 aux Etats-Unis.
## Preparations

### Les versions
  - CoreOS Stable 1010.6
  - Docker 1.10.3
  - RethinkDb 2.3.4

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent:
 * Un accès internet
 * Un shell linux
 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "standard-1" (n1.cw.standard-1). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les paramétres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `blueprint-coreos-rethinkdb/`

* `blueprint-coreos-rethinkdb.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.

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

Dans le fichier `blueprint-coreos-rethinkdb.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23
description: Blueprint CoreOS Rethinkdb
parameters:
  keypair_name:
    default: keypair            <-- Indiquer ici votre paire de clés par défaut
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: n1.cw.standard-1    <-- Indiquer ici la taille de l’instance par défaut
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

  volume_size:
    default: 5         <-- Indiquer ici la taille du volume
    label: Backup Volume Size
    description: Size of Volume for Rethinkdb Storage (Gigabytes)
    type: number
    constraints:
      - range: { min: 5, max: 10000 }
        description: Volume must be at least 10 gigabytes

  volume_type:
    default: standard  <-- Indiquer ici le type du volume
    label: Backup Volume Type
    description: Performance flavor of the linked Volume for Rethinkdb Storage
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
 $ ./stack-start.sh rethinkdb
 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | rethinkdb     | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+--------------------+----------------------+
 ~~~

 Attendez **5 minutes** que le déploiement soit complet (vous pouvez utiliser la commande `watch` pour voir le statut en temps réel).

 ~~~ bash
 $ watch -n 1 heat stack-list
 +--------------------------------------+------------+-----------------+----------------------+
 | id                                   | stack_name | stack_status    | creation_time        |
 +--------------------------------------+------------+-----------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | rethinkdb     | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+-----------------+----------------------+
 ~~~

 <a name="console" />

## C’est bien tout ça, mais...

### Une Ligne de commande semble aussi amical qu'un management à la militaire

 Heureusement pour vous alors, la totalité de la configuration de RethinkDB peut être faite en utilisant uniquement l'interface web.

 Pour créer votre stack RethinkDB depuis la [Console Cloudwatt](https://console.cloudwatt.com):

 1.	Allez sur le Github Cloudwatt dans le dépôt [applications/blueprint-coreos-rethinkdb](https://github.com/cloudwatt/applications/edit/master/blueprint-coreos-rethinkdb/)
 2.	Cliquez sur le fichier nommé `blueprint-coreos-rethinkdb.heat.yml`
 3.	Cliquez sur RAW, une page web apparait avec uniquement le template
 4.	Enregistrez le fichier sur votre PC. Vous pouvez utiliser le nom proposé par défaut par votre navigateur (juste enlever le `.txt` si besoin)
 5.  Allez dans la section [Stacks](https://console.cloudwatt.com/project/stacks/) de la console
 6.	Cliquez sur `LAUNCH STACK`, puis `Browse` sous `Template file` et selectionnez le fichier que vous venez d'enregistrer sur votre PC et puis cliquez finalement sur `NEXT`
 7.	Nommez votre stack dans le champs `Stack Name`
 8.	Entrez le nom de votre keypair dans le champs `SSH Keypair` et remplissez les quelques autres champs
 9.	Choisissez votre instance flavor en utilisant le menu déroulant `Instance Type` et cliquez sur `LAUNCH`

 La stack sera automatiquement générée (vous pourrez voir sa progression en cliquant sur son nom). Lorsque tous les modules passeront au vert, la création sera complète. Vous pouvez alors aller dans le menu "instances" pour trouver l'IP-flottante, ou simplement rafraîchir la page courante et vérifier l'onglet Présentation.

 Si vous avez atteint ce point, alors votre stack est fonctionnelle ! Profitez de RethinkDB.

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

 Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : Coder maintenant !



### Enjoy

 Une fois tout ceci fait, vous pouvez récupérer la description du votre stack à partir de cette commande :

 ~~~ bash
 $ heat stack-show rethinkdb
 +-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
| Property              | Value                                                                                                                                    |
+-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
| capabilities          | []                                                                                                                                       |
| creation_time         | 2016-08-22T13:28:15Z                                                                                                                     |
| description           | Blueprint CoreOS Rethinkdb                                                                                                               |
| disable_rollback      | True                                                                                                                                     |
| id                    | 84448c39-7813-4a42-8030-be4661fc551b                                                                                                     |
| links                 | https://orchestration.fr1.cloudwatt.com/v1/467b00f998064f1688feeca95bdc7a88/stacks/rethinkdb/84448c39-7813-4a42-8030-be4661fc551b (self) |
| notification_topics   | []                                                                                                                                       |
| outputs               | [                                                                                                                                        |
|                       |   {                                                                                                                                      |
|                       |     "output_value": "http://84.39.37.10:8080",                                                                                           |
|                       |     "description": "Rethinkdb URL",                                                                                                      |
|                       |     "output_key": "floating_ip_url"                                                                                                      |
|                       |   }                                                                                                                                      |
|                       | ]                                                                                                                                        |
| parameters            | {                                                                                                                                        |
|                       |   "OS::project_id": "467b00f998064f1688feeca95bdc7a88",                                                                                  |
|                       |   "OS::stack_id": "84448c39-7813-4a42-8030-be4661fc551b",                                                                                |
|                       |   "OS::stack_name": "rethinkdb",                                                                                                         |
|                       |   "keypair_name": "yourkey",                                                                                                              |
|                       |   "volume_type": "standard",                                                                                                             |
|                       |   "volume_size": "5",                                                                                                                    |
|                       |   "flavor_name": "n1.cw.standard-1"                                                                                                      |
|                       | }                                                                                                                                        |
| parent                | None                                                                                                                                     |
| stack_name            | rethinkdb                                                                                                                                |
| stack_owner           | youremail@cloudwatt.com                                                                                                |
| stack_status          | CREATE_COMPLETE                                                                                                                          |
| stack_status_reason   | Stack CREATE completed successfully                                                                                                      |
| stack_user_project_id | c18212ee8fd0416dbe3f049db2e67b60                                                                                                         |
| template_description  | Blueprint CoreOS Rethinkdb                                                                                                               |
| timeout_mins          | 60                                                                                                                                       |
| updated_time          | None                                                                                                                                     |
+-----------------------+------------------------------------------------------------------------------------------------------------------------------------------+
 ~~~

 Vous pouvez vous connecter sur l'inteface de RethinkDB via un navigateur web à partir de cet url http://floatingIp:8080

 ![Rethinkdb1](img/rethinkdb1.png)


##### Systemd - système d'initialisation de service rethinkdb

Pour démarrer le service :
~~~ bash
sudo systemctl start rethinkdb.service
~~~

Il est possible de consulter les logs en sortie du service lancé grâce à la commande suivante :
~~~ bash
journalctl -f -u rethinkdb.service
~~~

Le service se stop de la manière suivante :
~~~ bash
sudo systemctl stop rethinkdb.service
~~~


#### Autres sources pouvant vous intéresser:

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)
* [RethinkDb Documentatuion](https://www.rethinkdb.com/)

-----
Have fun. Hack in peace.
