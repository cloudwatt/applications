# 5 Minutes Stacks, Episode 14: Graylog

## Episode 14: Graylog

**Projet - Image actuellement non disponible...**

Graylog is an open source log management platform capable of manipulating and presenting data from virtually any source. At it's core, Graylog consists of a 3-tier architecture:

![Graylog Diagram](img/graylog_diagram.png)

* The Graylog Web Interface is a powerful tool that allows anyone to manipulate the entirety of what Graylog has to offer through an intuitive and appealing web application.
* At the heart of Graylog is it's own strong software. Graylog Server interacts with all other components using REST APIs so that each component of the system can be scaled without comprimising the integrity of the system as a whole.
* Real-time search results when you want them and how you want them: Graylog is only able to provide this thanks to the tried and tested power of Elasticsearch. The Elasticsearch nodes behind the scenes give Graylog the speed that makes it a real pleasure to use.

Boasting this impressive architecture as well as a vast library of plugins, Graylog stands as a strong and versatile log management solution.

By following this guide you will deploy a compressed but fully functional version of Graylog: Graylog Web and Server as well as Elasticsearch all deployed on one instance. This is a great way to discover the potential of Graylog and explore it's versatile web UI without expending many resources.

## Préparations

### La version

* Graylog (graylog-server/graylog-web) 1.2.2-1
* Elasticsearch (elasticsearch) 1.7.3
* MongoDB (mongodb-org) 3.0.7

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent:

* Un accès internet
* Un shell linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/authentification) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type "Small" (s1.cw.small-1). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturés à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnés à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs ](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version "Je lance avec la console" en cliquant sur [ce lien](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `bundle-trusty-graylog/`

* `bundle-trusty-graylog.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
* `stack-start.sh`: Stack launching script, which simplifies the parameters and secures the admin password creation.
* `stack-get-url.sh`: Script de récupération de l'IP d'entrée de votre stack, qui peut aussi se trouver dans les parametres de sortie de la stack.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell et entrez votre mot de passe lorsque vous êtes invité à utiliser les clients OpenStack.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

$ [whatever mind-blowing stuff you have planned...]
~~~

Une fois ceci fait, les outils de ligne de commande d'OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

In the `.heat.yml` files (heat templates), you will find a section named `parameters` near the top. The mandatory parameters are the `keypair_name` and the `password` for the Graylog *admin* user.

You can set the `keypair_name`'s `default` value to save yourself time, as shown below.
Remember that key pairs are created [from the console](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab), and only keys created this way can be used.

The `password` field provides the password for Graylog's default *admin* user. You will need it upon initial login, but you can always create other users later. You can also adjust (and set the default for) the instance type by playing with the `flavor` parameter accordingly.

Par défaut, le réseau et sous-réseau de la stack sont générés pour la stack, dans lequel le serveur Graylog est seul installé. Ce comportement peut être modifié si necessaire dans fichier` .heat.yml`.

~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Graylog stack


parameters:
  keypair_name:
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string
    default: my-keypair-name                <-- Mettez ici le nom de votre keypair

  password:
    label: Password
    description: Graylog root user password
    type: string
    hidden: true
    constraints:
      - length: { min: 6, max: 96 }
        description: Password must be between 6 and 96 characters

  flavor_name:
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
    default: s1.cw.small-1
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
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.199 }
[...]
~~~

<a name="startup" />

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh`:

~~~ bash
$ ./stack-start.sh TICKERTAPE «my-keypair-name»
Enter your new admin password:
Enter your new password once more:
Creating stack...
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | TICKERTAPE | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Au bout de **5 minutes**, la stack sera totalement opérationnelle. (Vous pouvez utiliser la commande `watch` pour voir le statut en temps réel).

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | TICKERTAPE | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Profitez - Stack URL with a terminal

Une fois tout ceci fait, vous pouvez lancer le script 'stack-get-url.sh'.

~~~ bash
$ ./stack-get-url.sh TICKERTAPE
TICKERTAPE  http://70.60.637.17:9000/
~~~

Comme indiqué ci-dessus, il va analyser les IP flottantes attribuées à votre stack dans un lien URL.
Vous pouvez alors cliquer ou le coller dans un navigateur de votre choix, et profitez de votre nouvelle instance Graylog.

![Graylog Home](img/graylog_home.png)

<a name="console" />

## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer votre Graylog :

1.	Allez sur le Github Cloudwatt dans le dépôt [applications/bundle-trusty-graylog](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-graylog)
2.	Cliquez sur le fichier nommé `bundle-trusty-graylog.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec les détails du template
4.	Enregistrez le fichier sur votre PC. Vous pouvez utiliser le nom proposé par votre navigateur (il faudrait juste enlever le .txt)
5.  Allez dans la section «[Stacks](https://console.cloudwatt.com/project/stacks/)»  de la console
6.	Cliquez sur «Launch stack», puis «Template file» et sélectioner le fichier que vous venez d'enregistr sur votre PC, et pour finir cliquez sur «NEXT»
7.	Donnez un nom à votre stack dans le champ «Stack name»
8.	Entrez le nom de votre keypair dans le champ «SSH Keypair»
9.	Entrez le mot de passe que vous avez choisit pour l'utilisateur par defaut *admin*
10.	Choisissez la taille de votre instance dans le menu déroulant « Type d'instance » et cliquez sur «LANCER»

La stack va se créer automatiquement (vous pourrez voir la progression en cliquant sur son nom). Quand tous les modules passeront au vert, la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour retrouver l’IP flottante qui a été générée, ou rafraichir la page en cours pour avoir le lien.

Souvenez vous que l'UI de Graylog se trouve sur le port 9000, pas sur le 80 !

Si vous avez atteint ce point, alors vous y êtes arrivé ! Profitez de Graylog !

## So watt?

Le but de ce tutoriel est d'accélerer votre démarrage. Dès à présent, **vous** êtes maître(sse) à bord. 

The default user is *admin* with the password you set during stack creation. An easy way to [get started](http://docs.graylog.org/en/1.2/pages/getting_started.html#get-messages-in) is to have your Graylog server log itself!

![Graylog Inputs](img/graylog_inputs.png)

Graylog takes inputs from a plethora of ports and protocols, I recommend you take the time to document yourselves on the possibilities. Just remember that all input and output ports must be explicitly set in the stack's [security group](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__security_groups_tab). To add an input, click on **MANAGE RULES** for your stack's security group and then, once on the page *MANAGE SECURITY GROUP RULES*, click **+ ADD RULE**. If logs don't make it to your graylog instance, check the [security group](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__security_groups_tab) first!

![Graylog Sources](img/graylog_sources.png)

Once you are receiving logs from a variety of sources, dashboards will certainly become your favorite tool. Search results can be converted into widgets that update in real-time, and dashboards let you organize those widgets into information-rich panels that can give essential visibility on the state of your environment. Take the time to create a dashboard which displays the information you care about, and monitoring your VMs is sure to become a more pleasant experience.

![Graylog Dashboard Example](img/graylog_dashboard.png)

You also now have an SSH access point on your virtual machine through the floating-IP and your private key pair (default user name `cloud`). Be warned, the default browser connection to Graylog is not encrypted (HTTP): if you are using your Graylog instance to store sensitive data, you may want to connect with an SSH tunnel instead.

~~~ bash
user@home$ cd applications/bundle-trusty-graylog/
user@home$ ./stack-get-url.sh TICKERTAPE
TICKERTAPE  http://70.60.637.17:9000/
user@home$ ssh 70.60.637.17 -l cloud -i /path/to/your/.ssh/keypair.pem -L 5000:localhost:9000
[...]
cloud@graylog-server$ █
~~~

By doing the above, I could then access my Graylog server from http://localhost:5000/ on my browser. ^^

## The State of Affairs

This bundle deploys the minimum Graylog setup for use in smaller, non-critical, or test setups. None of the components are redundant but it is resource-light and quick to launch.

![Minimum setup](http://docs.graylog.org/en/1.3/_images/simple_setup.png)

Bigger production environments are much heftier but carry a number of advantages, not least among them being fluid horizontal scaling. This allows Graylog to expand and shrink to meet the current workload. If you are interested in such an environment, check out the link *Graylog architectural considerations* below.

#### Les dossiers importants sont:

- `/etc/graylog/server/server.conf`: Graylog server configuration
- `/etc/graylog/web/web.conf`: Graylog web UI configuration
- `/etc/elasticsearch/elasticsearch.yml`: Elasticsearch configuration

#### Autres ressources qui pourraient vous être utiles :

* [Graylog Homepage](https://www.graylog.org/)
* [Graylog - Getting Started](http://docs.graylog.org/en/1.2/pages/getting_started.html#get-messages-in)
* [Graylog architectural considerations](http://docs.graylog.org/en/1.3/pages/architecture.html)
* [Elasticsearch Homepage](https://www.elastic.co/products/elasticsearch)
* [Installing MongoDB on Ubuntu](https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/)

-----
Have fun. Hack in peace.
