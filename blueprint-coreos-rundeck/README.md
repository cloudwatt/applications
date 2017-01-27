# 5 Minutes Stacks, épisode 51 : Rundeck! avec job de snapshot #

## Episode 51 : Rundeck! avec job de snapshot

![logo](img/rundeck.jpg)

Cette stack va vous permettre de lancer une instance CoreOS avec un contener Rundeck préconfiguré. Vous y trouverez dès le démarrage un job de backup pour vos instances Cloudwatt.
En effet celui ci effecturera un snapshot des instances que vous souhaitez sauvegarder.

Rundeck est un outil d’automatisation de processus idéal pour administrer un ou plusieurs serveurs. Rundeck est ainsi une sorte de chef d’orchestre permettant d’exécuter des commandes sur des machines distantes ou locales.
L’outil est accompagné d’une interface dite ”web” simplifiant l’accès aux scripts et autres jobs mais également d’une interface “ligne de commande” : une collection d’outils est en effet fournie afin d’utiliser toutes les fonctionnalités offertes par le logiciel.

## Preparations

### Les versions
 - CoreOS Stable 1010.6
 - Rundeck 2.7.1
 - Rundeck-cli 1.0.3

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent :
 * Un accès internet
 * Un shell linux
 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "standard-1" (n1.cw.standard-1). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

 Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `blueprint-coreos-rundeck/`

* `blueprint-coreos-rundeck.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
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

Dans le fichier `blueprint-coreos-rundeck.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml

parameters:

  keypair_name:
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: n1.cw.standard-1
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
    default: 10
    label: Backup Volume Size
    description: Size of Volume for rundeck Storage (Gigabytes)
    type: number
    constraints:
      - range: { min: 5, max: 10000 }
        description: Volume must be at least 10 gigabytes

  volume_type:
    default: standard
    label: Backup Volume Type
    description: Performance flavor of the linked Volume for rundeck Storage
    type: string
    constraints:
      - allowed_values:
          - standard
          - performant

  os_region_name:
      default: fr1
      label: OpenStack region
      description: OpenStack region
      type: string
      constraints:
        - allowed_values:
          - fr1
          - fr2

  os_username:
    description: OpenStack Username
    label: OpenStack Username
    type: string

  os_password:
    description: OpenStack Password
    label: OpenStack Password
    type: string
    hidden: true

  os_tenant_name:
    description: OpenStack Tenant Name
    label: OpenStack Tenant Name
    type: string

  os_auth_url:
    description: OpenStack Auth URL
    default: https://identity.fr1.cloudwatt.com/v2.0
    label: OpenStack Auth URL
    type: string

  mysql_root_password:
   description: mysql root password
   label: Mysql Root Password
   type: string
   hidden: true

  rundeck_password :
    description: Rundeck Admin Password
    label: Rundeck Admin Password
    type: string
    hidden: true

[...]
 ~~~
### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~ bash
 $ ./stack-start.sh rundeck
 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | ed4ac18a-4415-467e-928c-1bef193e4f38 | rundeck    | CREATE_IN_PROGRESS | 2017-01-12T16:36:05Z |
 +--------------------------------------+------------+--------------------+----------------------+
~~~

Enfin, attendez **5 minutes** que le déploiement soit complet.

 ~~~ bash
 $ watch heat resource-list rundeck
 +-------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name     | physical_resource_id                                                                | resource_type                   | resource_status | updated_time         |
+-------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| cinder_volume     | 24016996-f5c4-4086-b351-d5613072792d                                                | OS::Cinder::Volume              | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| floating_ip       | 22d6e3eb-7562-472e-9f3b-e434d1f689b2                                                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| floating_ip_link  | 855900                                                                              | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| interface         | 7129e80e-2214-45f4-a1f3-135c7578854e:subnet_id=a613b683-d94e-4343-9148-5b8e3e1900f6 | OS::Neutron::RouterInterface    | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| network           | a06ae947-6021-4440-b3bd-ea4fcf93f877                                                | OS::Neutron::Net                | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| ports             | 842e6b17-78a9-466d-8b21-fe6b5cd8b52d                                                | OS::Neutron::Port               | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| router            | 7129e80e-2214-45f4-a1f3-135c7578854e                                                | OS::Neutron::Router             | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| security_group    | c9f8660e-9be5-4df8-ae67-a8b1c7cbcd2f                                                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| server            | a5354423-5008-4206-8703-348c130a82a6                                                | OS::Nova::Server                | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| subnet            | a613b683-d94e-4343-9148-5b8e3e1900f6                                                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
| volume_attachment | 24016996-f5c4-4086-b351-d5613072792d                                                | OS::Cinder::VolumeAttachment    | CREATE_COMPLETE | 2017-01-12T16:36:05Z |
+-------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
 ~~~

   Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

   * Démarrer une instance basée sur Coreos y deposer le conteneur *rundeck* rattaché à sa database *Mysql*,

   * l'exposer sur Internet via une IP flottante.

<a name="console" />

## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer Rundeck! :

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/blueprint-coreos-rundeck](https://github.com/cloudwatt/applications/tree/master/blueprint-coreos-rundeck)
2.	Cliquez sur le fichier nommé `blueprint-coreos-rundeck.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT ».
7.	Donnez un nom à votre stack dans le champ « Nom de la stack ».
8.	Entrez votre keypair dans le champ « SSH Keypair ».
9.	Choisissez la taille de votre instance parmi le menu déroulant « Instance Type (Flavor) ».
10. Entrez la taille de volume de backup dans le champ « Backup Volume Size », puis  choisissez le type de volume dans le champ
    « Backup Volume Type ».
11. Entrez les credentials de votre compte Cloudwatt dans les champs « OpenStack region », « OpenStack Username »,
   « OpenStack Password », « OpenStack Tenant Name » et « OpenStack Auth URL ».
12. Entrez le mot de passe root de mysql dans le champ « Mysql Root Password ».
13. Entrez le mot de passe admin de rundeck dans le champ « Rundeck Admin Password » et cliquez sur « LANCER ».

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement. Ne vous reste plus qu'à vous connecter en ssh avec votre keypair.

C’est (déjà) FINI !

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : vous avez votre Rundeck! !

## Enjoy

Une fois tout ceci fait vous pouvez vous connecter sur votre serveur en SSH en utilisant votre keypair préalablement téléchargée sur votre poste.

Vous êtes maintenant en possession de votre serveur Rundeck!. Vous pouvez y acceder via l'url `http://ip-floatingip:4440`. Votre url complète sera présente dans la vue d'ensemble de votre stack sur la console horizon Cloudwatt.

![rundeck1](img/rundeck1.png)

Pour s'authentifier vous utilisez le login **admin** et le password que vous avez mis **Rundeck Admin Password**, vous devez arriver sur cette page.

![rundeck2](img/rundeck2.png)

Pour lancer le job qui va créer les snapshots des instances,vous devez cliquer sur le projet `InstancesSnapshot`.

![rundeck3](img/rundeck3.png)

Cliquez sur l'onglet `jobs`.

![rundeck4](img/rundeck4.png)

Cliquez sur le job `snapshot` et entrez la liste des Ids de vos instances que vous vouliez snapshoter dans le champ `List_instances`, enfin cliquez sur `Run Job Now` .

![rundeck5](img/rundeck5.png)

Puis vérifiez que vos instances ont été bien snapshotées avec la commande.

~~~bash
$ glance image-list | grep id_instance
~~~

Pour récupérer les IDs de vos instances lancez cette commande:
~~~bash
$ nova list
+--------------------------------------+-------------------------------------------------------+--------+------------+-------------+-------------------------------------------------------+
| ID                                   | Name                                                  | Status | Task State | Power State | Networks                                              |
+--------------------------------------+-------------------------------------------------------+--------+------------+-------------+-------------------------------------------------------+
| 627fd0b7-0af0-4a53-bb40-2b921f228c3b | factory-server-ctwk3vwqiesv                           | ACTIVE | -          | Running     | factory-dmz-6a4ysedl3h73=10.42.42.100                 |
| 5b00d121-9998-4143-8504-298a2857f181 | ku-sj47pz-6otjy4e7bn6a-rqe6zfiitpz3-node-drjqqgaz4jw2 | ACTIVE | -          | Running     | kube-network-ih7t7tdomdz6=10.1.1.11                   |
+--------------------------------------+-------------------------------------------------------+--------+------------+-------------+-------------------------------------------------------+
~~~

Les snaphosts sont sous forme `nom_instance-date-temps`, par exemple: `nom_instance-2017-01-13-1123`.
## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `core` par défaut).

* Vous avez accès à l'interface web en http via l'adresse indiquée dans la sortie de votre stack sur la console horizon Cloudwatt.

* Voici quelques sites d'informations avant d'aller plus loin :

  - http://rundeck.org/


----
Have fun. Hack in peace.
