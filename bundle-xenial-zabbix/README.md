# 5 Minutes Stacks, épisode 36 : Zabbix #

## Episode 36 : Zabbix-server

![Minimum setup](img/zabbix_logo.png)

Zabbix est un logiciel libre permettant de surveiller l'état de divers services réseau, serveurs et autres matériels réseau; et produisant des graphiques dynamiques de consommation des ressources. Zabbix utilise MySQL, PostgreSQL ou Oracle pour stocker les données. Selon l'importance du nombre de machines et de données à surveiller, le choix du SGBD influe grandement sur les performances. Son interface web est écrite en PHP et fourni une vision temps réel sur les métriques collectées.

Zabbix-server dans un réseau se présente comme suit :

![Architecture réseau zabbix](img/zabbix-monitoring-in-5-pictures-2-638.jpg)

On remarque dans cette architecture que le serveur Zabbix peut monitorer les hôtes sur lesquels sont installés l'agent Zabbix ou via SNMP.

### Les versions

* Ubuntu 16.04
* Zabbix 3.2
* Mysql 5.7

### Les pré-requis pour déployer cette stack

* un accès internet
* un shell Linux
* un [compte Cloudwatt](https://www.cloudwatt.com/authentification), avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type "Small" (s1.cw.small-1) en tarification à l'usage (les prix à l'heure et au mois sont disponibles sur la [page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt). Bien sûr, vous pouvez ajuster les paramètres de la stack, et en particulier sa taille par défaut.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version « lancement par la console » en cliquant sur [ce lien](#console)

## Tour du propriétaire

Une fois le dépôt git cloné, vous trouvez plusieurs fichiers dans le répertoire `images/bundle-xenial-zabbix/`:

* `bundle-xenial.heat.yml` : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.
* `stack-start.sh` : Script de lancement de la stack. C'est un micro-script pour vous économiser quelques copier-coller.
* `stack-get-url.sh` : Script de récupération de l'IP d'entrée de votre stack.


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

Dans le fichier `bundle-xenial-zabbix.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur. C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2013-05-23

description: All-in-one Zabbix stack

parameters:
  keypair_name:
    default:                                              <-- Mettez ici le nom de votre paire de clés
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: s1.cw.small-1                                    <-- Mettez ici l'identifiant de votre flavor
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
        - t1.cw.tiny
        - s1.cw.small-1
         [...]
~~~

### Démarrer la stack

Dans un shell, placez vous dans votre dossier cloné et lancez le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~ bash
./stack-start.sh nom_de_votre_stack
~~~
Exemple :

~~~ bash
$ ./stack-start.sh EXP_STACK
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | EXP_STACK       | CREATE_IN_PROGRESS | 2015-11-25T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Puis attendez 5 minutes que le déploiement soit complet.


~~~ bash
$ heat resource-list EXP_STACK
+------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name    | physical_resource_id                                                                | resource_type                   | resource_status | updated_time         |
+------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip      | 8aa20b7a-129a-4b8c-9d8c-dfec4a25897f                                                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
| floating_ip_link | 632178                                                                              | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
| interface        | 5b83fc95-0e3c-41eb-8933-b299b3530045:subnet_id=3109449f-47a0-4a1d-a35d-cb81d2a6a31d | OS::Neutron::RouterInterface    | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
| network          | be3d1095-19e7-4221-84a2-f5846a836fc9                                                | OS::Neutron::Net                | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
| port             | 82c260c2-058b-475a-a055-adfe08aee8df                                                | OS::Neutron::Port               | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
| router           | 5b83fc95-0e3c-41eb-8933-b299b3530045                                                | OS::Neutron::Router             | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
| security_group   | 95ca1f46-855e-4b7f-bf93-d3d244a68785                                                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
| server           | c592398a-a347-4c4d-8b08-729d375f77d6                                                | OS::Nova::Server                | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
| subnet           | 3109449f-47a0-4a1d-a35d-cb81d2a6a31d                                                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2016-09-20T14:01:23Z |
+------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
~~~

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Xenial, pré-provisionnée avec la stack Zabbix et un agent Zabbix.
* l'exposer sur Internet via une IP flotante

## C’est bien tout ça,
### mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur mail:

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/bundle-xenial-zabbix](https://github.com/cloudwatt/applications/tree/master/bundle-xenial-zabbix)
2.	Cliquez sur le fichier nommé `bundle-xenial-zabbix.heat.yml`
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

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : vous avez votre Zabbix !

### Enjoy

Une fois tout ceci fait, vous pouvez lancez le script `stack-get-url.sh` qui va récupérer l'url d'entrée de votre stack.

Exemple:

~~~ bash
$ ./stack-get-url.sh EXP_STACK
EXP_STACK `floating IP `
~~~

A ce niveau, vous pouvez vous connecter sur votre instance de serveur Zabbix avec un navigateur web en pointant sur votre floating IP, sur le port 80 (http://xx.xx.xx.xx). Pour s'authentifier sur l'interface web :

  * login : Admin
  * mot de passe : zabbix

**Pensez à changer ce mot de passe par défaut immédiatement après votre authentification.**

![Interface connection zabbix](img/login.png)

Une fois que l'authentification est faite, vous avez accès à l'interface graphique de Zabbix-server.

![Bigger production setup](img/zabbix_cp.png)

### Pour monitorer plus de  machines

Il faut s'assurer que les machines à monitorer :

  * sont visibles sur le réseau depuis le serveur Zabbix
  * ont un agent Zabbix fonctionnel
  * acceptent les communications UDP et TCP entrantes sur le port 10050, port d'écoute des agents Zabbix par défaut.

### Exemple de monitoring d'un serveur Ghost

Voyons ensemble un exemple d'intégration d'une instance serveur portant le moteur de blog Ghost.

  * Déployez une stack Ghost [comme nous l'avions vu à l'épisode5](https://dev.cloudwatt.com/fr/blog/5-minutes-stacks-episode-cinq-ghost.html).

  * Depuis la section [Accès et Sécurité de la console Cloudwatt](https://console.cloudwatt.com/project/access_and_security/), ajoutez 2 règles au groupe de sécurité de la stack Ghost :
  * Règle UDP personnalisée, en Entrée, Port 10050
  * Règle TCP personnalisée, en Entrée, Port 10050

Cela permettra au serveur Zabbix de se connecter pour récupérer les métriques de la machine. Il faut maintenant créer de la visibilité réseau entre notre stack Zabbix et notre stack Ghost, via la création d'un routeur Neutron :

  1. Récupérez l'identifiant de sous-réseau de la stack Ghost :

  ~~~ bash
  $ heat resource-list NOM_DE_STACK_GHOST | grep subnet

  | subnet           | bd69c3f5-ddc8-4fe4-8cbe-19ecea0fdf2c              | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-24T15:18:30Z |
  ~~~

  2. Ajoutez au routeur une interface avec le sous-réseau de la stack Ghost et une autre avec le sous-réseau de la stack Zabbix :

    ~~~ bash
    $ neutron router-interface-add `$Zabbix_ROUTER_ID` `$GHOST_SUBNET_ID`
    $ neutron router-interface-add `$Zabbix_GHOST_ROUTER_ID` `$Zabbix_SUBNET_ID`

    ~~~

Quelques minutes plus tard, le serveur Zabbix et le serveur Ghost pourront se contacter directement via leur réseau LAN.

A présent, il faut effectuer de la configuration sur le serveur à monitorer. Pour vous faciliter la prise en main, nous vous avons préparé un playbook Ansible qui automatise ces tâches.

  3. Assurez vous de pouvoir vous connecter :

    * En SSH
    * Avec l'utilisateur `cloud`
    * Sur le serveur Ghost
    * Depuis le serveur Zabbix


  4. Sur le serveur Zabbix, ajoutez les informations de connexion dans l'inventaire `/etc/ansible/hosts` :

  ~~~bash         
  [servers]
  xx.xx.xx.xx ansible_ssh_user=cloud ansible_ssh_private_key_file=/home/cloud/.ssh/id_rsa_ghost_server.pem
  ~~~

  5. Sur le serveur Zabbix, lancez le playbook `/home/cloud/servers-monitoring_zabbix.yml` que nous avons déposé dans l'image serveur pour vous faciliter la vie :

  ~~~
  $ ansible-playbook ~cloud/servers-monitoring_zabbix.yml
  ~~~

Ce playbook va faire toutes les opérations d'installation et de configuration sur le serveur Ghost pour qu'il puisse être monitoré par le serveur Zabbix.

Le playbook `servers-monitoring_zabbix.yml` supporte les systèmes d'exploitation suivants: Centos (6 et 7), Debian (jessie et wheezy) et Ubuntu (trusty,xenial).

Maintenant, votre monitoring client - serveur est configuré. Vous pouvez à présent vous connecter sur l'interface web de votre zabbix via son adresse IP http://X.X.X.X et ainsi vous pouvez maintenant visualiser les métriques des agents monitorés par le server Zabbix.

 ![Visualiser les métriques ](http://glpi.objetdirect.com/wp-content/uploads/2014/01/zabbix_webgraph.png)

## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Vous pouvez commencer à faire vivre votre monitoring en prenant la main sur votre serveur.

### Les points d'entrée utiles :
* `/etc/zabbix/zabbix_server.conf`: le répertoire contenant le fichier de configuration permettant à Zabbix-server de se connecter à la base de données
* `/var/lib/mysql`: le répertoire contenant les fichiers de la base de donnée de zabbix
* `/var/log/zabbix/zabbix_server.log`: le fichier contenant les log.
* `/etc/zabbix/zabbix.conf.php`: le répertoire contenant  le fichier de configuration de l'interface Zabbix

#### Autres sources pouvant vous intéresser:

* [Zabbix-monitoring Homepage](http://www.zabbix.com/)
* [Zabbix documentation](https://www.zabbix.com/documentation/2.2/start)

---
Have fun. Hack in peace.
