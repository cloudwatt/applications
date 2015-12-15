# 5 Minutes Stacks, Episode 17: Minecraft

## Episode 17: Minecraft

![Minecraft Logo](img/minecraft.png)

Minecraft is a game about breaking and placing blocks. Originally a sandbox video game created by Swedish programmer Notch, Minecraft is now developed and published by Mojang. Integrating exploration, resource gathering, crafting, and combat into a rewarding experience, Minecraft stays fresh through hours of play. Multiplayer provides yet another layer of depth as players band together to create vast structures beyond your imagination.

With this bundle anyone can easily deploy their own Minecraft server, easily accessible from the Minecraft launcher for play with friends or strangers.

## Préparations

### Les versions

* Ubuntu Trusty 14.04.2
* Minecraft (minecraft_server.1.8.9.jar) 1.8.9

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent:

* Un accès internet
* Un shell linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type "Small" (s1.cw.small-1). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console ouo en 1-clic"](#console)...


## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `bundle-trusty-minecraft/` :

* `bundle-trusty-minecraft.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
* `stack-start.sh`: Script de lancement de la stack, qui simplifie la saisie des parametres et sécurise la création du mot de passe admin.
* `minecraft-server-address.sh`: Script de récupération de l'IP d'entrée de votre stack, qui peut aussi se trouver dans les parametres de sortie de la stack.

![Animals](img/animals.png)

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

Dans le fichier `.heat.yml` (le template HEAT), vous trouverez au début une section nommée `parameters`. Les paramètres obligatoires sont la `keypair_name` et le `admin_username` de l'utilisateur Minecraft *op*.

Le champs `keypair_name` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur ('default' pour ne pas perdre de temps).

Remember that key pairs are created [from the console](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab), and only keys created this way can be used.

The `admin_username` field provides the username for Minecraft's default *op* user. You will need it to set other players as *op* and use administrative commands. You can also adjust (and set the default for) the instance type by playing with the `flavor` parameter accordingly.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Minecraft stack


parameters:
  keypair_name:
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string
    default: my-keypair-name                <-- Indicate your key pair name here

  flavor_name:
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
    default: s1.cw.small-1
    constraints:
      - allowed_values:
        [...]

  admin_username:
    label: Admin Username
    description: Minecraft username to become first admin
    type: string

resources:
  network:
    type: OS::Neutron::Net

  subnet:
    type: OS::Neutron::Subnet
    properties:
      network_id: { get_resource: network }
      ip_version: 4
      cidr: 10.0.1.0/24
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.199 }
[...]
~~~

<a name="startup" />

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh`:

~~~ bash
$ ./stack-start.sh GOLDDIGGER «my-keypair-name»
Enter the username of the first admin: bob1337
Enter the admin username again: bob1337
Creating stack...
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | GOLDDIGGER | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Au bout de **5 minutes**, la stack sera totalement opérationnelle. (Vous pouvez utiliser la commande `watch` pour voir le statut en temps réel).

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | GOLDDIGGER | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Stack URL with a terminal

Une fois ceci fait, vous pouvez lancer le scfript `minecraft-server-address.sh`.

~~~ bash
$ ./minecraft-server-address.sh GOLDDIGGER
GOLDDIGGER  70.60.637.17
~~~

As shown above, it will display the assigned address of your minecraft server. You can then click or paste this into Minecraft and bask in the glory of a fresh Minecraft server.

![Minecraft Relaxing](img/resting.jpg)

<a name="console" />

## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer votre Minecraft :

1.	Allez sur le Github Cloudwatt dans le dépôt [applications/bundle-trusty-minecraft](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-minecraft) repository
2.	Cliquez sur le fichier nommé `bundle-trusty-minecraft.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec les détails du template
4.	Enregistrez le fichier sur votre PC. Vous pouvez utiliser le nom proposé par votre navigateur (il faudrait juste enlever le .txt)
5.  Allez dans la section «[Stacks](https://console.cloudwatt.com/project/stacks/)»  de la console
6.	Cliquez sur «Launch stack», puis «Template file» et sélectionner le fichier que vous venez d'enregistrer sur votre PC, et pour finir cliquez sur «NEXT»
7.	Donnez un nom à votre stack dans le champ «Stack name»
8.	Entrez le nom de votre keypair dans le champ «SSH Keypair»
9.	Entrez le mot de passe que vous avez choisi pour l'utilisateur par defaut *admin*
10.	Choisissez la taille de votre instance dans le menu déroulant « Type d'instance » et cliquez sur «LANCER»

La stack va se créer automatiquement (vous pourrez voir la progression en cliquant sur son nom). Quand tous les modules passeront au vert, la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour retrouver l’IP flottante qui a été générée, ou rafraichir la page en cours pour avoir le lien.

Si vous avez atteint ce point, alors votre stack est fonctionnelle ! Profitez de Minecraft.

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : Chatter maintenant !

![Kingdoms](img/kingdom.jpg)

## So watt ?

Le but de ce tutoriel est d'accélerer votre démarrage. Dès à présent, **vous** êtes maître(sse) à bord.

The default game mode is survival, but the admin can change that. Go to multiplayer and enjoy yourself!

## The State of Affairs

This bundle deploys a stable Minecraft setup for use in fun, non-critical setups. None of the components are redundant but it is resource-light and quick to launch.

#### Les dossiers importants sont:

- `/opt/minecraft`: Minecraft server configuration

#### Autres ressources qui pourraient vous être utiles :

* [Minecraft Homepage](https://minecraft.net/)
* [Minecraft Wiki](http://minecraft.gamepedia.com/Minecraft_Wiki)
* [Minecraft Commands](http://minecraft.gamepedia.com/Commands)

![Castle](img/castle.jpg)

-----
Have fun. Hack in peace.
