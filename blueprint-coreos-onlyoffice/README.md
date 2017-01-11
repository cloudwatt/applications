# 5 Minutes Stacks, épisode 47 : ONLYOFFICE #

## Episode 47 : ONLYOFFICE

![ONLYOFFICElogo](img/onlyofficelogo.jpg)
 
ONLYOFFICE est une suite bureautique en ligne vous permettant de créer et modifier vos documents directement à travers un navigateur.

Ainsi, il est possible de modifier des fichiers (compatibles Microsoft Office) de manière collaborative et en temps réel sans l'installation de logiciels tiers, ce qui est un gain de sécurité, mais aussi, dans le cadre d'une entreprise, de gérer des projets et leur avancement, ainsi qu'une base de données de clients par exemple.

Vos e-mails peuvent être lus directement depuis ONLYOFFICE si vous le désirez en y indiquant les serveurs de mail à utiliser. Il est également possible d'utiliser votre propre nom de domaine.

## Préparations

### Les versions
 - CoreOS Stable 1185.5
 - ONLYOFFICE 8.9.1.191

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent :
 * Un accès internet
 * Un shell linux
 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "standard-2" (n1.cw.standard-2). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

 Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `blueprint-coreos-onlyoffice/`

* `blueprint-coreos-onlyoffice.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
* `stack-start.sh`: Script de lancement de la stack, qui simplifie la saisie des parametres et sécurise la création du mot de passe admin.
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

Dans le fichier `blueprint-coreos-onlyoffice.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur. 
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ yaml
heat_template_version: 2015-04-30


description: Blueprint ONLYOFFICE


parameters:
  keypair_name:
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: n1.cw.standard-2
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
    constraints:
      - allowed_values:
          - n1.cw.standard-2
          - n1.cw.standard-4
          - n1.cw.standard-8
          - n1.cw.standard-12
          - n1.cw.standard-16

  volume_attachment:
    description: Attacher un volume cinder de 20GO ?
    default: 0
    type: string
[...]
~~~
### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~ bash
 $ ./stack-start.sh ONLYOFFICE
 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | ed4ac18a-4415-467e-928c-1bef193e4f38 | ONLYOFFICE | CREATE_IN_PROGRESS | 2015-04-21T08:29:45Z |
 +--------------------------------------+------------+--------------------+----------------------+
~~~

Enfin, attendez **5 minutes** que le déploiement soit complet.

 ~~~ bash
 $ watch heat resource-list ONLYOFFICE
 +------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
 | resource_name    | physical_resource_id                                | resource_type                   | resource_status | updated_time         |
 +------------------+-----------------------------------------------------+---------------------------------+-----------------+----------------------+
 | floating_ip      | 44dd841f-8570-4f02-a8cc-f21a125cc8aa                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2015-11-25T11:03:51Z |
 | security_group   | efead2a2-c91b-470e-a234-58746da6ac22                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2015-11-25T11:03:52Z |
 | network          | 7e142d1b-f660-498d-961a-b03d0aee5cff                | OS::Neutron::Net                | CREATE_COMPLETE | 2015-11-25T11:03:56Z |
 | subnet           | 442b31bf-0d3e-406b-8d5f-7b1b6181a381                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-25T11:03:57Z |
 | server           | f5b22d22-1cfe-41bb-9e30-4d089285e5e5                | OS::Nova::Server                | CREATE_COMPLETE | 2015-11-25T11:04:00Z |
 | floating_ip_link | 44dd841f-8570-4f02-a8cc-f21a125cc8aa-`floating IP`  | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2015-11-25T11:04:30Z |
   +------------------+-----------------------------------------------------+-------------------------------+-----------------+----------------------
 ~~~

   Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

   * démarrer une instance basée sur Coreos y déposer le conteneur *ONLYOFFICE Document Server*, le conteneur *ONLYOFFICE Mail Server* et le conteneur *ONLYOFFICE Community Server*,

   * l'exposer sur Internet via une IP flottante.

<a name="console" />

## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer ONLYOFFICE :

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/blueprint-coreos-onlyoffice](https://github.com/cloudwatt/applications/tree/master/blueprint-coreos-onlyoffice)
2.	Cliquez sur le fichier nommé `blueprint-coreos-onlyoffice.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Il ne vous reste plus qu'à patienter 5 bonnes minutes que les applicatifs se lancent. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement. Ne vous reste plus qu'à vous connecter en ssh avec votre keypair.

C’est (déjà) FINI !

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : vous avez accès à ONLYOFFICE !

## Enjoy

Une fois tout ceci fait vous pouvez vous connecter sur votre serveur en SSH en utilisant votre keypair préalablement téléchargée sur votre poste.

Vous êtes maintenant en possession de ONLYOFFICE. Vous pouvez y acceder via l'url `http://ip-floatingip`. Votre url complète sera présente dans la vue d'ensemble de votre stack sur la console horizon Cloudwatt.

Une fois les informations de votre choix données pour le compte administrateur, vous arriverez sur l'interface de ONLYOFFICE :
![interface](img/interface.png)

Vous pouvez à présent utiliser votre suite bureautique, celle-ci étant hébergé en France dans un environnement maîtrisé, vous pouvez avoir une totale confiance dans ce produit.

## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `core` par défaut).

* Vous avez accès à l'interface web en http via l'adresse indiquée dans la sortie de votre stack sur la console horizon Cloudwatt.

* Voici quelques sites d'informations avant d'aller plus loin :

  - http://www.onlyoffice.org/
  - http://helpcenter.onlyoffice.com/

----
Have fun. Hack in peace.
