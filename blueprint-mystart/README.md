# 5 Minutes Stacks, épisode 29 : MyStart #

## Episode 29 : MyStart

Cette stack vous permet d'intialiser votre tenant par la création rapide d'une keypair, d'un réseau et d'un security group. Ces ressources sont des pré-requis pour la création d'instances dans le cloud.


## Preparations

### Les pré-requis pour déployer cette stack
Ceci devrait être une routine à présent:

* Un accès internet
* Un shell linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)


### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `blueprint-mystart/`

* `blueprint-mystart.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.

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

Dans le fichier `blueprint-mystart.heat.yml` vous trouverez en haut une section `parameters`.

~~~ yaml
  heat_template_version: 2013-05-23

  description: Template blueprint-mystart

  parameters:
    keypair_name_prefix:
      default: mykeypair                 <-- Mettez ici le prefix du nom de votre keypair
      type: string
      label: key Name prefix
      description: the keypair name.
    net_cidr:
      default: 192.168.1.0/24            <-- Mettez ici l'adresse ip réseaux cidr sous forme /24
      type: string
      label: /24 cidr of your network
      description: /24 cidr of private network

[...]
~~~
### Démarrer la stack

Dans un shell, lancer le script la commande suivante :

~~~
heat stack-create nom_de_votre_stack -f blueprint-mystart.heat.yml -Pkeypair_name_prefix=prefix_de_keypair -Pnet_cidr=192.168.1.0/24
~~~

Exemple :

~~~bash
$ heat stack-create mysatck_name -f blueprint-mystart.heat.yml -Pkeypair_name_prefix=préfix -Pnet_cidr=192.168.1.0/24
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | nom_de_votre_stack       | CREATE_IN_PROGRESS | 2015-11-25T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Puis attendez quelques minutes que le déploiement soit complet.

~~~bash
$ heat resource-list nom_de_votre_stack
+---------------+--------------------------------------+----------------------------+-----------------+----------------------+
| resource_name | physical_resource_id                 | resource_type              | resource_status | updated_time         |
+---------------+--------------------------------------+----------------------------+-----------------+----------------------+
| keypair       | mystart-mykeypair                    | OS::Nova::KeyPair          | CREATE_COMPLETE | 2016-06-02T16:14:43Z |
| network       | 165fff85-a6ac-4bdd-ad63-ac2ba8e58f45 | OS::Neutron::Net           | CREATE_COMPLETE | 2016-06-02T16:14:43Z |
| sg            | 9d5f6961-8eb2-4e59-b637-fa3f70659b55 | OS::Neutron::SecurityGroup | CREATE_COMPLETE | 2016-06-02T16:14:43Z |
| subnet        | f5d63c5e-1fb5-4ed9-9927-a7025c5dbd95 | OS::Neutron::Subnet        | CREATE_COMPLETE | 2016-06-02T16:14:43Z |
+---------------+--------------------------------------+----------------------------+-----------------+----------------------+
~~~

## C’est bien tout ça,
### mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur mail:

1.	Allez sur le Github Cloudwatt dans le répertoire
[applications/blueprint-mystart](https://github.com/cloudwatt/applications/tree/master/blueprint-mystart)
2.	Cliquez sur le fichier nommé `blueprint-mystart.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Remplissez les deux champs  « key Name prefix » et « /24 cidr of private network » puis cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée.
C’est (déjà) FINI !

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/) du site de Cloudwatt, choisissez l'appli, appuyez sur **DEPLOYER** et laisser vous guider... 2 minutes plus tard un bouton vert apparait... **ACCEDER** : vous avez votre Stack !


## Enjoy

Pour télécharger votre clé privée, consultez cet url
`https://console.cloudwatt.com/project/access_and_security/keypairs/prefix-nom_votre_stack/download/`.
Puis cliquez sur `Download key pair "prefix-nom_votre_stack"`.

Maintenant vous pouvez lancer votre première instance :

~~~bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:
$ nova boot --flavor n1.cw.standard-1 --image Ubuntu 16.04 --nic net-id=id_start-net-nom_votre_stack --security-group start-sg-nom_votre_stack --key-name préfix-nom_votre_stack nom_de_votre_instance
~~~

### Autres sources pouvant vous intéresser:
* [ Openstack Home page](https://www.openstack.org/)

----
Have fun. Hack in peace.
