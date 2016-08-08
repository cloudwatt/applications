# 5 Minutes Stacks, épisode 29 : GlusterFs multi Data center #

## Episode 29 : GlusterFs multi Data center

![gluster](https://www.gluster.org/images/antmascot.png?1458134976)

GlusterFS est un logiciel libre de système de fichiers distribué en parallèle, capable de monter jusqu'à plusieurs pétaoctets.
GlusterFS est un système de fichiers de cluster/réseaux. GlusterFS est livré avec deux éléments, un serveur et un client.
Le serveur de stockage (ou chaque serveur d'un cluster) fait tourner glusterfsd et les clients utilisent la commande mount ou glusterfs client pour monter les systèmes de fichiers servis, en utilisant FUSE.

Dans cet épisode, nous allons créer deux glusterfs qui se répliquent entre eux mais ne sont pas dans la même zone.

## Preparations

### Les versions
 - Ubuntu Xenial 16.04
 - Glusterfs 3.7

### Les pré-requis pour déployer cette stack
Ceci devrait être une routine à présent:

* Un accès internet
* Un shell linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab) avec accès aux 2 régions fr1 et fr2
* Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "Standard-1" (n1.cw.standard-1) pour la zone fr1 et "Standard-1" (n2.cw.standard-1) pour la zone fr2. Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `bundle-xenial-glusterfs-multi-dc/`

* `bundle-xenial-glusterfs-multi-dc-fr1.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire dans la zone fr1.
* `bundle-xenial-glusterfs-multi-dc-fr2.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire dans la zone fr2.

* `stack-start-fr1.sh`: Script de lancement de la stack dans la zone fr1, qui simplifie la saisie des parametres et sécurise la création du mot de passe admin.

* `stack-start-fr2.sh`: Script de lancement de la stack dans la zone fr2, qui simplifie la saisie des parametres et sécurise la création du mot de passe admin.
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

Dans le fichier `bundle-xenial-glusterfs-multi-dc-fr2.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23
description: All-in-one Glusterfs Multi DC
parameters:
  keypair_name:   
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string
    default: my-keypair-name                <-- Mettez ici le nom de votre keypair

  flavor_name:
    default: n2.cw.standard-1
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
         - n2.cw.standard-1
         - n2.cw.standard-2
         - n2.cw.standard-4
         - n2.cw.standard-8
         - n2.cw.standard-16
         - n2.cw.highmem-2
         - n2.cw.highmem-4
         - n2.cw.highmem-8
         - n2.cw.highmem-16
[...]
~~~

Dans le fichier `bundle-xenial-glusterfs-multi-dc-fr1.heat.yml` vous trouverez en haut une section `parameters`.Il y a deux paramètres obligatoires à ajuster, le premier nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur et le deuxième nommé `slave_public_ip` doit contenir la flotting Ip de la Stack fr2.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23
description: All-in-one Glusterfs Multi Dc
parameters:
  keypair_name:
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string
    default: my-keypair-name                <-- Mettez ici le nom de votre keypair

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

  slave_public_ip:                        
     type: string
     label: slave public ip
     default: 0.0.0.0                      <-- Mettez ici la floating ip du glusterfs dc 2

[...]
~~~
### Démarrer la stack

D'abord il faut lancer la stack fr2 la première et si la stack fr2 est bien lancée, vous pouvez lancer la stack sur fr1.
Il faut aussi que les deux stacks sur fr1 et fr2 aient le même nom.
Dans un shell, lancer le script `stack-start-fr2.sh`:

~~~bash
$ export OS_REGION_NAME=fr2
$ ./stack-start-fr2.sh nom_de_votre_stack
~~~

Exemple :

~~~bash
$ ./stack-start-fr2.sh  nom_de_votre_stack
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | nom_de_votre_stack       | CREATE_IN_PROGRESS |  |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Puis attendez **5 minutes** que le déploiement soit complet.

~~~bash
$ heat resource-list nom_de_votre_stack
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name    | physical_resource_id                                | resource_type                   | resource_status | updated_time         |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip      | 44dd841f-8570-4f02-a8cc-f21a125cc8aa                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| security_group   | efead2a2-c91b-470e-a234-58746da6ac22                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| network          | 7e142d1b-f660-498d-961a-b03d0aee5cff                | OS::Neutron::Net                | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| subnet           | 442b31bf-0d3e-406b-8d5f-7b1b6181a381                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| server           | f5b22d22-1cfe-41bb-9e30-4d089285e5e5                | OS::Nova::Server                | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
| floating_ip_link | 44dd841f-8570-4f02-a8cc-f21a125cc8aa-`floating_ip_stack_fr2`  | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2016-06-22T11:03:51Z |
+------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------
~~~

Le script `start-stack-fr2.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu xenial, pré-provisionnée avec la stack glusterfs sur fr2
* l'exposer sur Internet via une IP flottante

Après le déploiement de la stack sur fr2, vous pouvez lancer la stack sur fr1.
~~~bash
$ export OS_REGION_NAME=fr1
$ ./stack-start-fr1.sh nom_de_votre_stack
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | nom_de_votre_stack       | CREATE_IN_PROGRESS | 2016-06-22T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Le script `start-stack-fr1.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu xenial, pré-provisionnée avec la stack glusterfs sur fr1
* l'exposer sur Internet via une IP flottante

<a name="console" />

## C’est bien tout ça,
### mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer les deux serveurs glusterfs:

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/bundle-xenial-glusterfs-multi-dc](https://github.com/cloudwatt/applications/tree/master/bundle-xenial-glusterfs-multi-dc)
2.	Cliquez sur le fichier nommé `bundle-xenial-glusterfs-multi-dc-fr1(ou 2).heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.  Donner votre passphrase qui servira pour le chiffrement des sauvegardes
10.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement. Ne vous reste plus qu'à vous connecter en ssh avec votre keypair.

C’est (déjà) FINI !

## Enjoy

Afin de tester l'état de la réplication entre les deux serveurs, connectez sur glusterfs fr1, puis exécuter la commande suivante.
~~~bash
# gluster vol geo-rep datastore nom_de_votre_stack-gluster-dc2::datastore status
MASTER NODE            MASTER VOL    MASTER BRICK     SLAVE USER    SLAVE                             SLAVE NODE             STATUS    CRAWL STATUS       LAST_SYNCED                  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
nom_de_votre_stack-gluster-dc1    datastore     /brick/brick1    root          nom_de_votre_stack-gluster-dc2::datastore    nom_de_votre_stack-gluster-dc2    Active    Changelog Crawl    2016-06-23 10:35:56          
nom_de_votre_stack-gluster-dc1    datastore     /brick/brick2    root          nom_de_votre_stack-gluster-dc2::datastore    nom_de_votre_stack-gluster-dc2    Active    Changelog Crawl    2016-06-23 10:35:56          

~~~

Vous pouvez monter le volume glusterfs dans une machine cliente qui se connecte dans le même réseau que la machine serveur :
~~~bash
# apt-get -y install gusterfs-client
# mkdir /mnt/datastore
# mount -t glusterfs nom_de_votre_stack-gluster-dc1:datastore /mnt/datastore
~~~
**Pour pour redémarrer le service gluterfs-server **

~~~ bash
# service glusterfs-server restart
~~~


## So watt?

Sur chaque serveur glusterfs soit sur fr1 ou fr2, on a créé un volume replication `datastore` qui contient deux bricks `/brick/brick1` et `/brick/brick2`,pour savoir comment ajouter autres bricks, consultez ce [lien](https://access.redhat.com/documentation/en-US/Red_Hat_Storage/2.1/html/Administration_Guide/Expanding_Volumes.html).


### Autres sources pouvant vous intéresser:
* [ GlusterFs Home page](http://www.gluster.org/)

----
Have fun. Hack in peace.
