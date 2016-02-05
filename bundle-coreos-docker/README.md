# 5 Minutes Stacks, Episode 21: Docker et CoreOS

## Episode 21: Docker

![coreoslogo](https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/CoreOS.svg/320px-CoreOS.svg.png)

 CoreOS est un système d'exploitation open-source utilisant le noyau linux, créé pour gérer l'ensemble des applications qui s'exécute sur ce système dans des conteneurs. CoreOS s'accompagne de quelques outils essentiels pour déployer et maintenir vos services :
* etcd : une base de données clé/valeur distribuée, accessible par l'ensemble de votre cluster CoreOS permettant de partager des informations entre tous vos services.
* systemd : un processus d'initialisation pour vos services.
* docker : un logiciel qui permet d'automatiser le déploiement et la gestion des conteneurs.

 En suivant ce tutoriel, vous obtiendrez un cluster de 3 instances CoreOS relié au réseau public via un routeur Neutron. Par défaut, seul le port 22 est accessible depuis l'extérieur afin de pouvoir se connecter aux instances via SSH. Les autres ports ne sont accessibles que sur le réseau local.  

## Préparations

### Les versions

* CoreOS 835.9.0
* Docker 1.8.3

### Les pré-requis pour déployer cette stack

 Ce devrait être la routine maintenant :

* un accès internet
* un shell Linux
* un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact), avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance

Par défaut, le script propose un déploiement de 3 instances de type " Standard 2 " (n2.cw.standard-2) en tarification à l'usage (les prix à l'heure et au mois sont disponibles sur la [page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt). Bien sûr, vous pouvez ajuster les paramètres de la stack et en particulier sa taille par défaut.

## Tour du propriétaire

Une fois le répertoire cloné, vous trouvez, dans le répertoire `bundle-coreos-docker/`:

* `bundle-coreos-docker.heat.yml` : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.
* `stack-start.sh` : Script de lancement de la stack. C'est un micro-script pour vous économiser quelques copier-coller.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

$ [whatever mind-blowing stuff you have planned...]
~~~

Une fois ceci fait, les outils en ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

Dans le fichier `bundle-coreos-docker.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur

C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance en jouant sur le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23

description: CoreOS 3 nodes cluster for docker

parameter_groups:
- label: CoreOS
  parameters:
    - keypair_name
    - flavor_name

parameters:
  keypair_name:
    type: string
    description: Name of keypair to assign to CoreOS instances
    label: SSH Keypair
    default: my-keypair-name                <-- Mettez ici le nom de votre keypair

  flavor_name:
    type: string
    description: Flavor to use for the server
    default : n2.cw.standard-2
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
        - n2.cw.highmem-2
        - n2.cw.highmem-4
        - n2.cw.highmem-8
        - n2.cw.highmem-16
        - n2.cw.standard-1
        - n2.cw.standard-2
        - n2.cw.standard-4
        - n2.cw.standard-8
        - n2.cw.standard-16

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

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` :

~~~ bash
$ ./stack-start.sh DOCKER
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | DOCKER     | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Attendez **5 minutes** que le déploiement soit complet (vous pouvez utiliser la commande `watch` pour voir le statut en temps réel).

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | DOCKER     | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Enjoy

Une fois tout ceci fait, vous pouvez récupérer les IP associées aux instances créées grâce à la commande suivante (la section `outputs` liste les IP de chaque instance) :

~~~ bash
$ heat stack-show DOCKER
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

#### Utilisation des outils fournis avec CoreOS

Pour se connecter via SSH à vos instances CoreOS, l'utilisateur par défaut se nomme `core`.
La commande à utiliser est la suivante :
~~~ bash
ssh -i <keypair> core@<node-ip@>
~~~


##### etcd - base de données clé/valeur distribuée

Consulter l'état du cluster etcd :
~~~ bash
ssh -i <keypair> core@<node-ip@>
etcdctl cluster-health
~~~

Lister l'ensemble des clés contenues dans la base :
~~~ bash
ssh -i <keypair> core@<node-ip@>
etcdctl ls --recursive
~~~

Récupérer la valeur d'une clée :
~~~ bash
ssh -i <keypair> core@<node-ip@>
etcdctl get <name/of/key>
~~~

Créer ou mettre à jour une clée :
~~~ bash
ssh -i <keypair> core@<node-ip@>
etcdctl set <name/of/key> <value>
~~~

##### systemd - système d'initialisation de services

Création d'un service "Hello World" docker sous systemd :

Il faut avant tout créer un fichier dans le répertoire `/etc/systemd/system` pour déclarer votre service, nous nommerons le notre `hello.service`.
~~~
[Unit]
Description=MyApp
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill busybox1
ExecStartPre=-/usr/bin/docker rm busybox1
ExecStartPre=/usr/bin/docker pull busybox
ExecStart=/usr/bin/docker run --name busybox1 busybox /bin/sh -c "while true; do echo Hello World; sleep 1; done"

[Install]
WantedBy=multi-user.target
~~~

Une fois le fichier créé, nous devons activer et démarrer le service : 
~~~ bash
sudo systemctl enable /etc/systemd/system/hello.service
sudo systemctl start hello.service
~~~

Il est possible de consulter les logs en sortie du service lancé grâce à la commande suivante :
~~~ bash
journalctl -f -u hello.service
~~~

Le service se stop de la manière suivante :
~~~ bash
sudo systemctl stop hello.service
~~~

Et se désactive comme suit :
~~~ bash
sudo systemctl disable hello.service
~~~

##### flannel - réseau virtuel partagé pour les conteneurs

Flannel est paramétré au lancement de votre stack. Ce service gère un réseau virtuel partagé entre toutes les instances de votre cluster CoreOS. Les conteneurs peuvent ainsi communiquer entre eux, quelle que soit l'instance sur laquelle ils sont lancés.



#### Autres sources pouvant vous intéresser:

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)


-----
Have fun. Hack in peace.
