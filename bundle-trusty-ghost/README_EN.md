# 5 Minutes Stacks, episode five : Ghost
## Episode cinq : Ghost

Pour ce cinquième volet, nous nous penchons sur Ghost. Le projet Ghost est un moteur de blog simple et puissant. Il est basé sur Node.js et permet de rédiger ses blog posts au format Markdown. Ghost assure une offre SaaS, mais comme c'est un projet open source, il est également possible de l'installer sur un serveur en propre.

En suivant ce tutoriel, vous obtiendrez une instance Ubuntu Trusty Tahr, pré-configurée avec un serveur NGinx en frontal sur le port 80, forwardant vers un serveur Node.js, monitoré et maintenu en vie par [Foreverjs](https://github.com/foreverjs/forever), qui propulse une instance du moteur Ghost.

### Les versions

* Node.js 0.10.25
* Ghost 0.6.4

### The prerequisites to deploy this stack

There are the same than for the previous episodes :

* an internet acces
* a Linux shell
* a [Cloudwatt account](https://www.cloudwatt.com/authentification), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

Per default, the script is proposing a deployement on an instance type "Small" (s1.cw.small-1). Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console) 

## Préparatifs

## What will you find in the repository

Once you have cloned the github, you will find in the `bundle-trusty-ghost/` repository:

* `bundle-trusty-ghost.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh`: Stack launching script. This is a small script that will save you some copy-paste.
* `stack-get-url.sh`: Flotting IP recovery script.

## Tour du propriétaire

Une fois le repository cloné, vous trouvez, dans le répertoire `bundle-trusty-ghost/` :

* `bundle-trusty-ghost.heat.yml` : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.
* `stack-start.sh` : Script de lancement de la stack. C'est un micro-script pour vous économiser quelques copier-coller.
* `stack-get-url.sh` : Script de récupération de l'IP d'entrée de votre stack.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis vous le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Une fois ceci fait, les outils ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

Dans le fichier `bundle-trusty-ghost.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.
C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

~~~ bash
heat_template_version: 2013-05-23


description: All-in-one GHOST stack


parameters:
  keypair_name:
    default: my-keypair-name                   <-- Rajoutez cette ligne avec le nom de votre paire de clés
    description: Keypair to inject in instance
    label: SSH Keypair
    type: string

  flavor_name:
    default: s1.cw.small-1
    description: Flavor to use for the deployed instance
    type: string
    label: Instance Type (Flavor)
[...]
~~~

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~ bash
$ ./stack-start.sh CASPER
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| ed4ac18a-4415-467e-928c-1bef193e4f38 | CASPER     | CREATE_IN_PROGRESS | 2015-04-21T08:29:45Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Enfin, attendez 5 minutes que le déploiement soit complet.

### Enjoy

Une fois tout ceci fait, vous pouvez lancez le script `stack-get-url.sh` en passant en paramètre le nom de la stack.

~~~ bash
./stack-get-url.sh CASPER
CASPER 82.40.34.249
~~~

qui va récupérer l'IP flottante attribuée à votre stack. Vous pouvez alors attaquer cette IP avec votre navigateur préféré et commencer à configurer votre instance Wordpress.

## Dans les coulisses

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr
* l'exposer sur Internet via une IP flottante

<a name="console" />

### C’est bien tout ça, mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur Ghost :

1.	Allez sur le Github Cloudwatt dans le répertoire applications/bundle-trusty-ghost
2.	Cliquez sur le fichier nommé bundle-trusty-ghost.heat.yml
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement. Ne vous reste plus qu’à lancer votre IP dans votre navigateur.

C’est (déjà) FINI !

## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en ssh via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Les chemins intéressants sur votre machine :

- `/var/lib/www` : Répertoire d'installation de l'application Ghost. C'est le répertoire exposé par Node.js
- `/etc/nginx/sites-available/node_proxy` : Fichier de configuration de Nginx dédié au proxying HTTP vers Node.js
- `/etc/init.d/nodejs` : Script d'init du service Node.js via Foreverjs.

Quelques ressources qui pourraient vous intéresser :

* [Documentation NGinx](http://nginx.org/en/docs/)
* [Documentation Ghost](http://docs.ghost.org/fr/usage//)


-----
Have fun. Hack in peace.


