# 5 Minutes Stacks, épisode 22 : Cassandra #

## Episode 22 : Cassandra

![cassandralogo](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Cassandra_logo.svg/langfr-96px-Cassandra_logo.svg.png)

Apache Cassandra est un système de gestion de base de données distribuée NoSQL. Initialement conçu en interne par Facebook, le projet est passé sous licence open source depuis 2008 et est maintenant un projet à part entière de la fondation Apache. Cassandra permet de stocker en grande quantité sur plusieurs Data center ou dans le cloud tous types de données, qu'elles soient structurées, semi-structurées ou non-structurées. S'inspirant de l'architecture BigTable, Cassandra supporte un ensemble de modèles de données flexibles et assure un temps de réponse rapide. Il fournit en plus de multiples caractéristiques: haute disponibilité, tolérance aux pannes, décentralisation et élasticité. 

## Descriptions

La stack "Casssandra" crée un cluster Cassandra de 3 noeuds dont un est désigné seed. 

## Preparations

### Les versions
 - Cassandra 3.1.1
 - Docker 1.8.3
 - CoreOS 835.9.0

### Les pré-requis pour déployer cette stack
Ceci devrait être une routine à présent:

* Un accès internet
* Un shell linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "Standard" (n1.cw.standard-2). Il
existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les paramètres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `bundle-coreos-cassandra/`

* `bundle-coreos-cassandra.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
* `stack-start.sh`: Scipt de lancement de la stack, qui simplifie la saisie des paramètres et sécurise la création du mot de passe admin.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell et entrez votre mot de passe lorsque vous êtes invité à utiliser les clients OpenStack.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Une fois ceci fait, les outils en ligne de commande d'OpenStack peuvent interagir avec votre compte Cloudwatt.


### Ajuster les paramètres

Dans le fichier `bundle-coreos-cassandra.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster
est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor_name`.

~~~ yaml
heat_template_version: 2013-05-23

description: Cassandra 3 nodes cluster with Docker on CoreOS

parameters:
  keypair_name:
    type: string
    description: Keypair to inject in instance
	label: SSH Keypair
    default: my-keypair-name                <-- Mettez ici le nom de votre keypair
    
  flavor_name:
    type: string
    description: Flavor to use for the server
    default : n1.cw.standard-2
    label: Instance Type (Flavor)
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
	  dns_nameservers: [8.8.8.8, 8.8.4.4]
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.254 }
[...]
~~~

Par défaut, les ports utilisés par Cassandra ne sont accessibles que sur le réseau local, si vous souhaitez changer ces règles de filtrage (pour ouvrir par exemple le port 9042), vous pouvez également éditer le fichier `bundle-coreos-cassandra.heat.yml`.

~~~ yaml 
  security_group:
    type: OS::Neutron::SecurityGroup
    properties:
      rules:
        - { direction: ingress, protocol: TCP, port_range_min: 22, port_range_max: 22 }
        - { direction: ingress, protocol: TCP, port_range_min: 80, port_range_max: 80 }
        - { direction: ingress, protocol: UDP, port_range_min: 8285, port_range_max: 8285, remote_ip_prefix: 10.0.1.0/24 }
        - { direction: ingress, protocol: TCP, port_range_min: 2379, port_range_max: 2379, remote_ip_prefix: 10.0.1.0/24 }
        - { direction: ingress, protocol: TCP, port_range_min: 2380, port_range_max: 2380, remote_ip_prefix: 10.0.1.0/24 }
        - { direction: ingress, protocol: TCP, port_range_min: 4001, port_range_max: 4001, remote_ip_prefix: 10.0.1.0/24 }
        - { direction: ingress, protocol: TCP, port_range_min: 7000, port_range_max: 7001, remote_ip_prefix: 10.0.1.0/24 }
        - { direction: ingress, protocol: TCP, port_range_min: 7199, port_range_max: 7199, remote_ip_prefix: 10.0.1.0/24 }
        - { direction: ingress, protocol: TCP, port_range_min: 9042, port_range_max: 9042, remote_ip_prefix: 10.0.1.0/24 }       <-- Supprimer la clé remote_ip_prefix pour laisser ce port accessible 
        - { direction: ingress, protocol: TCP, port_range_min: 9160, port_range_max: 9160, remote_ip_prefix: 10.0.1.0/24 }
        - { direction: ingress, protocol: ICMP }
        - { direction: egress, protocol: ICMP }
        - { direction: egress, protocol: TCP }
        - { direction: egress, protocol: UDP }
~~~ 


### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh`:

~~~
./stack-start.sh nom\_de\_votre\_stack
~~~

Exemple :

~~~bash
$ ./stack-start.sh Cassandra
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | Cassandra       | CREATE_IN_PROGRESS | 2015-11-25T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Puis attendez **5 minutes** que le déploiement soit complet.


 ~~~ bash
 $ watch -n 1 heat stack-list
 +--------------------------------------+------------+-----------------+----------------------+
 | id                                   | stack_name | stack_status    | creation_time        |
 +--------------------------------------+------------+-----------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | Cassandra  | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+-----------------+----------------------+
 ~~~

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer 3 instances basées sur CoreOS, pré-provisionnée avec la stack cassandra
* configurer un cluster 3 noeuds Cassandra dont un des 3 noeuds est configuré pour être le seed

### Enjoy

Une fois tout ceci fait vous avez un cluster Cassandra de 3 noeuds prêt à être utilisé, vous pouvez récupérer les IP associées aux instances créées grâce à la commande suivante (la section `outputs` liste les IP de chaque instance) :

~~~ bash
$ heat stack-show Cassandra
+-----------------------+---------------------------------------------------+
| Property              | Value                                             |
+-----------------------+---------------------------------------------------+
|                     [...]                                                 |
| outputs               | [                                                 |
|                       |   {                                               |
|                       |     "output_value": "10.0.1.100",                 |
|                       |     "description": "server3 private IP address",  |
|                       |     "output_key": "server3_private_ip"            |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "10.0.1.102",                 |
|                       |     "description": "server1 private IP address",  |
|                       |     "output_key": "server1_private_ip"            |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "XX.XX.XX.XX",                |
|                       |     "description": "server3 public IP address",   |
|                       |     "output_key": "server3_public_ip"             |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "YY.YY.YY.YY",                |
|                       |     "description": "server1 public IP address",   |
|                       |     "output_key": "server1_public_ip"             |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "10.0.1.103",                 |
|                       |     "description": "server2 private IP address",  |
|                       |     "output_key": "server2_private_ip"            |
|                       |   },                                              |
|                       |   {                                               |
|                       |     "output_value": "ZZ.ZZ.ZZ.ZZ",                |
|                       |     "description": "server2 public IP address",   |
|                       |     "output_key": "server2_public_ip"             |
|                       |   }                                               |
|                       | ]                                                 |
|                     [...]                                                 |
+-----------------------+---------------------------------------------------+
~~~

#### Lancer la commande cqlsh

~~~ bash
ssh -i <keypair> core@<node-ip@>
docker exec -it cassandra cqlsh
~~~

### Administer le cluster Cassandra

Cassandra fournit `nodetool` comme un outil permettant de gérer le cluster.

~~~ bash
ssh -i <keypair> core@<node-ip@>
docker exec cassandra nodetool <nodetool_commande>
~~~

### Consulter les logs de cassandra

Les logs de services Cassandra sont visibles via docker

~~~ bash
ssh -i <keypair> core@<node-ip@>
docker logs -f cassandra
~~~

Cassandra sauvegarde ses logs dans le fichier `/var/log/cassandra/system.log`

~~~ bash
ssh -i <keypair> core@<node-ip@>
docker exec cassandra cat /var/log/cassandra/system.log
~~~


#### Autres sources pouvant vous intéresser:

* [Cassandra Homepage](http://cassandra.apache.org/)
* [CoreOS Homepage](https://coreos.com/)


-----
Have fun. Hack in peace.
