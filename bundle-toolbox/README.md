# 5 Minutes Stacks, épisode 26 : Toolbox #

## Episode 26 : Toolbox



La toolbox est une  stack différente de tout ce qu'on a pu faire jusqu'à présent, celle-ci à pour but de vous apporter un ensemble d'outils afin d'unifier, d'armoniser et monitorer votre/vos tenant(s).En effet celle ci renferme un lot d'application qui a pour voccation de vous aider dans la gestion de vos instances.

Cette toolbox à entièrement été développer par Cloudwatt. L'interface utilisateur est faite en réact, celle-ci repose sur une instance CoreOS et l'ensemble des applications se déploie via des conteneurs Docker. De plus depuis l'interface vous pouvez installer ou configurer l'ensemble des applications sur vos instance via des playbooks Ansible.

Afin de sécuriser au maximum cette toolbox aucun port n'est exposer sur internet mis à part le port 22 afin de pouvoir récupérer un fichier de configuration Openvpn. Cette méthode est expliquée plus bas dans l'article.

## Preparations

### Les versions

  - CoreOS Stable 899.13.0
  - Docker 1.10.3
  - Zabbix 3.0
  - Rundeck 2.6.2
  - Graylog 1.3.4
  - Nexus 2.12.1-01
  - Nginx 1.9.12
  - Aptly  0.9.6
  - SkyDNS 2.5.3a
  - Etcd 2.0.3

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent:
 * Un accès internet
 * Un shell linux
 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)
 * Un client Openvpn

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "standard-4" (n2.cw.standard-4). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `bundle-toolbox/`

* `bundle-toolbox.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.

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

Dans le fichier `bundle-toolbox.heat.yml` vous trouverez en haut une section `parameters`. Cette stack à besoin de l'ensemble de vos informations utilisateur afin de pouvoir interagir avec l'ensemble de vos instances qui seront connecté au *routeur* de cette Toolbox.

**Un conseil** : Afin que la toolbox n'ait pas l'ensemble des droits sur votre tenant, vous pouvez lui créer un compte avec des droits réstrinct. Un compte avec les droits de lecture suffit (TENANT_SHOW).
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`. Afin de ne pas avoir de problème nous vous conseillons d'utiliser une instance de type "standard-4".

~~~ yaml
heat_template_version: 2013-05-23


description: CoreOS stack for Cloudwatt


parameters:
  keypair_name:
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  os_username:
    description: OpenStack Username
    label: OpenStack Username
    type: string

  os_password:
    description: OpenStack Password
    label: OpenStack Password
    type: string

  os_tenant:
    description: OpenStack Tenant Name
    label: OpenStack Tenant Name
    type: string

  os_auth:
    description: OpenStack Auth URL
    default: https://identity.fr1.cloudwatt.com/v2.0
    label: OpenStack Auth URL
    type: string

  domain:
    description: Wildcarded domain, ex example.com must have a *.example.com DNS entry
    label: Cloud DNS
    type: string

  flavor_name:
    default: n2.cw.standard-4
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
          - s1.cw.small-1
          - n1.cw.standard-1
          - n1.cw.standard-2
          - n2.cw.standard-4
          - n1.cw.standard-8
          - n1.cw.standard-12
          - n1.cw.standard-16

 ~~~
### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~ bash
$ ./stack-start.sh Toolbox
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| ed4ac18a-4415-467e-928c-1bef193e4f38 | Toolbox    | CREATE_IN_PROGRESS | 2016-03-24T08:29:45Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Enfin, attendez **5 minutes** que le déploiement soit complet.

~~~bash
$ heat resource-list Toolbox
+-------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name     | physical_resource_id                                                                | resource_type                   | resource_status | updated_time         |
+-------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip       | c683dbfa-3c9a-4cd6-a38d-2839fb203e9c                                                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2016-03-15T10:34:01Z |
| network           | b87a5d95-61fb-4586-ba1c-d531d2f638c9                                                | OS::Neutron::Net                | CREATE_COMPLETE | 2016-03-15T10:34:02Z |
| security_group    | 8d7745dd-c517-461a-bf57-b95cc1fcbeba                                                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2016-03-15T10:34:02Z |
| router            | b0977098-3fa4-461a-9a79-6715d3604822                                                | OS::Neutron::Router             | CREATE_COMPLETE | 2016-03-15T10:34:03Z |
| subnet            | 7f531a2c-4a3e-41d3-aa33-64396cb5f2d2                                                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2016-03-15T10:34:04Z |
| ports             | ab7791ee-3a07-4cc3-9a3b-da7cc53fb8aa                                                | OS::Neutron::Port               | CREATE_COMPLETE | 2016-03-15T10:34:09Z |
| toolbox_interface | b0977098-3fa4-461a-9a79-6715d3604822:subnet_id=7f531a2c-4a3e-41d3-aa33-64396cb5f2d2 | OS::Neutron::RouterInterface    | CREATE_COMPLETE | 2016-03-15T10:34:09Z |
| server            | f45d47a2-9686-44a9-9634-22d6012ef497                                                | OS::Nova::Server                | CREATE_COMPLETE | 2016-03-15T10:34:11Z |
| floating_ip_link  | c683dbfa-3c9a-4cd6-a38d-2839fb203e9c-84.39.44.44                                    | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2016-03-15T10:34:34Z |
+-------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+

~~~
Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur coreos,
* déployer le conteneur Openvpn

## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer la Toolbox:

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/bundle-toolbox](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-cozycloud)
2.	Cliquez sur le fichier nommé `bundle-toolbox.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.  Donner l'ensemble des informations du compte pouvant acceder à votre tenant,
10.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Ne vous reste plus qu'à récupérer le fichier de configuration **open vpn** `cloud.ovpn`.

```bash
scp -i ~/.ssh/your_keypair core@FloatingIP:cloud.ovpn .
```
Si celui-ci n'est pas disponible, attendez **2 minutes** que l'ensemble de la stack soit disponible.
Une fois cette opération réalisée ajoutez le fichier de configuration à votre client openvpn et connectez vous à votre toolbox.

C’est (déjà) FINI !

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : vous avez votre toolbox !

## Enjoy

Une fois connecté en VPN sur la stack vous avez maintenant accès à l'interface d'administration via l'url *http://manager."yourdomain"/*

#### Présentation de l'interface :

Voici l'accueil de la toolbox, chaque vignette représente un conteneur pret à être lancé.

![accueil](img/accueil.png)

L'ensemble de conteneurs présent peuvent être paramétrer grace au bouton **Settings** présent sur chaque vignette, prenons comme exemple le conteneur Zabbix.

![zabbix](img/zabbix.png)

 Comme vous pouvez le constater vous pouvez inscrire ici l'ensemble des paramètres qui serviront à configurer le conteneur à son lancement.



Un menu est présent en haut en gauche de la page, celui-ci permet de vous déplacer dans les différentes section de la toolbox à savoir, les **apps**, les **instances** et les **tasks**.

![menu](img/menu.png)

Les **tasks** servent à avoir un suivi des actions effectuées sur la toolbox.

![tasks](img/tasks.png)

il vous ait possible d'annuler une taches en attente en cas d'erreur en cliquant sur ![horloge](img/horloge.png) ce qui vous affichera ensuite ce logo ![poubelle](img/poubelle.png).





## So watt  ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

* Vous avez accès à l'interface web en https via l'adresse ip lan que vous avez défini pour Pfsense depuis le server ubuntu.

* Voici quelques sites d'informations avant d'aller plus loin :
- https://www.pfsense.org/
- https://forum.pfsense.org
