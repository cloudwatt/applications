# 5 Minutes Stacks, épisode 16 : Strongswan #

## Episode 16 : Strongswan

![Strongswan logo](img/strongswan.png)

StrongSwan est une implémentation du protocole IPSec placé sous licence GPL. Il est né par
un fork du projet FreeS/WAN. Le projet a été lancé en 2005 avec pour but de construire
une plate-forme IPSec stable doté d'extension X.509.

Ce que nous allons voir dans cet épisode vous permettra de mettre en place un tunnel
IPSec en un minium d'étapes, afin de disposer d'un canal sécurisé et authentifié vers une
zone externe à la plate-forme Cloudwatt.

### Les versions

* Debian Jessie
* Strongswan 5.2.1

### Les pré-requis pour déployer cette stack

* un accès internet
* un shell Linux
* un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact), avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version « lancement par la console » en cliquant sur [ce lien](#console)

## Tour du propriétaire

Une fois le dépôt git cloné, vous trouvez le fichier suivant dans le répertoire `images/bundle-jessie-strongswan/`:

* `bundle-jessie-strongswan.heat.yml` : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Une fois ceci fait, les outils ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Les paramètres de la stack

La stack que nous vous fournissons ici nécessite plusieurs paramètres pour être exploitée:

* `keypair_name` : Le nom de la paire de clé qui sera injecté dans le serveur pour votre
permettre de vous connecter
* `local_cidr` : Le CIDR du sous-réseau privé qui sera déployé par la stack (ex: 192.168.47.0/24).
Ce doit être un réseau de [classe C](https://fr.wikipedia.org/wiki/Classe_d'adresse_IP).
* `partner_cidr` : Le CIDR du sous-réseau privé qui existe à l'autre bout du tunnet IPSec (ex: 192.168.58.0/24).
Ce doit être un réseau de [classe C](https://fr.wikipedia.org/wiki/Classe_d'adresse_IP).
* `preshared_key` : La chaîne de caractère secrète partagée par les deux extrémités du tunnel IPSec.
Ce secret sera injecté dans le serveur qui va être démarré par la stack mais n'est pas stocké
dans la plate-forme Cloudwatt.

### Démarrer la stack

Pour l'exemple nous prendrons les valeurs :

* `keypair_name` : "my_key.pem"
* `local_cidr` : "192.168.47.0/24"
* `partner_cidr` : "10.0.240.0/24"
* `preshared_key` : "pr3ttyh4rd4nd0ngs3cr3tstr1ngsharedw1thmyb|_|ddy"

Pour passer les paramètres à notre stack, il vous faut utiliser l'option `-P` du client heat :
~~~
$ heat stack-create BATMAN -f bundle-jessie-strongswan.heat.yml \
  -Pkeypair_name="my_key.pem"       \
  -Plocal_cidr="192.168.47.0/24"    \
  -Ppartner_cidr="10.0.240.0/24"    \
  -Ppreshared_key="pr3ttyh4rd4nd0ngs3cr3tstr1ngsharedw1thmyb|_|ddy"

+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| 3b740e36-f0e4-4180-91f9-a9c991d175c1 | BATMAN        | CREATE_IN_PROGRESS | 2015-12-11T13:45:29Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Puis attendez **5 minutes** que le déploiement soit complet.


```
$ heat resource-list BATMAN
+--------------------------------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name                              | physical_resource_id                                                                | resource_type                   | resource_status | updated_time         |
+--------------------------------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| floating_ip                                | 977f03c4-3a0f-4ead-a588-99c97673b703                                                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2015-12-11T13:03:45Z |
| router                                     | 00530a88-f65d-450e-a6e8-988e71135d25                                                | OS::Neutron::Router             | CREATE_COMPLETE | 2015-12-11T13:03:48Z |
| network                                    | f51f3cf3-9eda-4695-954e-9ae8da38cf4d                                                | OS::Neutron::Net                | CREATE_COMPLETE | 2015-12-11T13:03:52Z |
| security_group                             | d9a28485-3595-4f8e-9246-e51fdf54dfae                                                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2015-12-11T13:03:52Z |
| subnet                                     | 8a34acee-9a8e-4ff3-97c3-f8970165d563                                                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-12-11T13:03:54Z |
| floating_ip_injection_and_route_finetuning | ad38bb7c-51ef-4d99-8d2e-e4a92a0c8e9d                                                | OS::Heat::SoftwareConfig        | CREATE_COMPLETE | 2015-12-11T13:03:56Z |
| keeper_init                                | 5eeade9a-be79-4d4f-a252-649d77d7b4a2                                                | OS::Heat::MultipartMime         | CREATE_COMPLETE | 2015-12-11T13:03:58Z |
| router_interface                           | 00530a88-f65d-450e-a6e8-988e71135d25:subnet_id=8a34acee-9a8e-4ff3-97c3-f8970165d563 | OS::Neutron::RouterInterface    | CREATE_COMPLETE | 2015-12-11T13:03:58Z |
| server_port                                | 7b5926c0-50bb-4f36-bd38-e857d1a1d7fc                                                | OS::Neutron::Port               | CREATE_COMPLETE | 2015-12-11T13:03:58Z |
| keeper_server                              | 8b6511ec-c249-43a6-95c7-4814297aacaf                                                | OS::Nova::Server                | CREATE_COMPLETE | 2015-12-11T13:04:00Z |
| floating_ip_link                           | 977f03c4-3a0f-4ead-a588-99c97673b703-84.39.41.55                                    | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2015-12-11T13:04:24Z |
+--------------------------------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+```
```

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Debian, pré-provisionnée avec Strongswan et un partie de la configuration.
* l'exposer sur Internet via une IP flottante

### La lumière au bout du tunnel

Pour finaliser l'installation, il faut *vous munir de l'adresse IP publique de l'autre extrémité du tunnel*.
A supposer que ce serveur cible soit correctement configuré et n'attende plus que votre partie, la procédure se cantonne à:

* vous connecter en SSH sur votre serveur
* passer en root via `sudo -i`
* lancer la commande:

```
ipsec_post_install $ADRESSE_IP_PUBLIQUE_DE_L_AUTRE_BOUT_DU_TUNNEL
```

Bien sûr cela suppose que l'autre extrémité soit un serveur déjà paramétré avec le secret partagé,
connaissant le CIDR de votre zone privé et qu'il soit en écoute.

Une fois remplies toutes ces conditions:

* le serveur de la stack, qui héberge Strongswan, peut contacter toutes les machines du sous-réseau de l'autre côté du tunnel.
* Tout serveur démarré dans le sous-réseau de votre stack pourra contacter toutes les machines du sous-réseau de l'autre côté du tunnel.


### Envie de jouer ?

Si vous ne disposez pas d'un partenaire de tunnel, rien ne vous empêche de jouer avec Strongswan en démarrant une deuxième
stack (que nous pourrions appeler ROBIN par exemple) en inversant les valeurs de local_cidr et partner_cidr et de faire la post-installation de chacune des stacks avec la valeur de l'IP flottante attribué à l'autre.

* démarrer une stack BATMAN comme décrit plus haut
* récupérer son IP flottante
* démarrer une stack ROBIN comme décrit plus haut (avec la même preshared_key)
* récupérer son IP flottante
* faire la post-install de BATMAN avec l'IP flottante de ROBIN
* faire la post-install de ROBIN avec l'IP flottante de BATMAN

Vous aurez ainsi 2 silos réseau totalement isolés, qui peuvent néanmoins communiquer au travers d'un tunnel chiffré.

<a name="console" />

## C’est bien tout ça, mais...

### Mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur shinken :

1.	Télécharger directement [le fichier de stack](https://raw.githubusercontent.com/cloudwatt/applications/master/bundle-jessie-strongswan/bundle-jessie-strongswan.heat.yml).
2.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez le reste des paramètres dans le formulaire qui vous est proposé.
9.  Effectuez les opération de post-configuration comme décrit plus haut (vous ne couperez pas à un accès SSH pour cette fois).

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 5 minutes plus tard un bouton vert apparait... ACCEDER : vous avez votre Shinken !

## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Si vous souhaitez regarder la configuration de Strongswan, vous pouvez commencer par :

* `/etc/ipsec.conf`: fichier de configuration des connexions Strongswan
* `/etc/ipsec.secrets`: fichier de stockage des secrets Strongswan

#### Autres sources pouvant vous interesser:

* [Portail de documentation Strongswan](https://www.strongswan.org/documentation.html)
* [L'exemple qui a servi de base au montage de cette stack](https://www.strongswan.org/testresults4.html)

-----
Have fun. Hack in peace.
