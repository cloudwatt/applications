# 5 Minutes Stacks, Episode 10: Jenkins

## Episode 10: Jenkins

Alfred Thaddeus Crane Pennyworth est le valet de Bruce Wayne dans Wayne Manor. il sait bien que Bruce est secretement Batman et [l'aide de manière  imaginable](https://wiki.jenkins-ci.org/display/JENKINS/Plugins). Apres [une carrière bien variée ](https://wiki.jenkins-ci.org/display/JENKINS/Awards), Alfred Pennyworth a [été employé comme valet dans la famille de Wayne ](https://wiki.jenkins-ci.org/pages/viewpage.action?pageId=58001258) quand les parents de Bruce ont été tués. Alfred [a élevé le jeune orphelin](https://github.com/jenkinsci/jenkins/commits/master) seul et l'a aidé finalement dans sa quête pour [devenir Batman](https://wiki.jenkins-ci.org/display/JENKINS/Use+Jenkins). His [impressive skill-set](https://wiki.jenkins-ci.org/display/JENKINS/Awards) makes him Bruce's staunchest ally, boasting a formal demeanor that does little to hide the [intelligence](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Best+Practices) behind his eyes.

Jenkins est notre Alfred Pennyworth à nous.

Jenkins, [historiquement appellé Hudson](https://en.wikipedia.org/wiki/Jenkins_%28software%29#History), est un magnifique outil. Je ne suis pas apte à chanter ses louanges, [mais je ne suis pas le seul à le souhaiter](https://wiki.jenkins-ci.org/display/JENKINS/Awards). Pour comprendre la puissance de Jenkins, [vérifier ce pourquoi les gens l'utilisent](http://www.google.com/search?ie=UTF-8&q=%22Dashboard+%5BJenkins%5D%22).

[Ou, faites une recherche Google.](http://lmgtfy.com/?q=jenkins)

## Préparations

### La version

* Jenkins (jenkins) 1.627

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine dès cet instant:

* Un accès internet
* Un shell linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/authentification) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type "Small" (s1.cw.small-1). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturés à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnés à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs ](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version "Je lance en 1-clic" ou "Je lance avec la console" en cliquant sur [ce lien](#console)...


## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `bundle-trusty-jenkins/`

* `bundle-trusty-jenkins.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
* `stack-start.sh`: Script de lancement de la stack. C'est un micro-script vous permettant d'économiser quelques copier-coller.
* `stack-get-url.sh`: Script de récupération de l'IP d'entrée de votre stack, qui peut aussi se trouver dans la sortie de la stack.

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

Dans le fichier `.heat.yml` (template heat), vous trouverez en haut une section `paramètres`. Les paramètres obligatoires pour la connexion sont la `keypair_name`, le `username` et le `password` pour Digest login. La valeur de la `keypair_name` par `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur, si vous souhaitez l'avoir par défaut dans la console.

Le champs `username` et `password` fournissent les valeurs pour une authentification basique, un simple module d'authentication HTTP appartenant a Apache2, fournisant une legère sécurité au cas où quelqu'un essaierait de passer par votre IP. Du fait que Jenkins est seulement un outil de construction, aucune autre sécurité n'est implémentée par défaut, bien que vous êtes toujours libre d'en mettre plus vous-même.

Dans ce template heat, vous pouvez également ajuster (et régler par défaut) le type d'instance en jouant en conséquence avec le paramètre `flavor`.

Par défaut, le réseau et sous-réseau de la stack sont générés pour la stack, dans lequel le serveur Jenkins est seul installé. Ce comportement peut être modifié si necessaire dans fichier` .heat.yml`.


~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one Jenkins stack


parameters:
  keypair_name:
    default: my-keypair-name                <-- Mettez ici le nom de votre paire de clés
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string

  username:
    label: Apache2 Auth Username
    description: Basic auth username for all users
    type: string
    constraints:
      - length: { min: 4, max: 24 }
        description: Username must be between 4 and 24 characters
  password:
    label: Apache2 Auth Password
    description: Basic auth password for all users
    type: string
    hidden: true
    constraints:
      - length: { min: 6, max: 24 }
        description: Password must be between 6 and 24 characters

  flavor_name:
    default: s1.cw.small-1                  <-- Mettez ici votre taille d'instance
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
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
$ ./stack-start.sh PENNYWORTH «my-keypair-name»
Enter your new Basic Auth username: «username»
Enter your new Basic Auth password:
Enter your new password once more:
Creating stack...
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | PENNYWORTH | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Au bout de **5 minutes**, la stack sera totalement opérationnelle. (Vous pouvez utiliser la commande `watch` pour voir le statut en temps réel).

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | PENNYWORTH | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Profitez

Une fois tout ceci fait, vous pouvez lancer le script 'stack-get-url.sh'.

~~~ bash
$ ./stack-get-url.sh PENNYWORTH
PENNYWORTH  http://70.60.637.17
~~~

Comme indiqué ci-dessus, il va analyser les IP flottantes attribuées à votre stack dans un lien URL.
Vous pouvez alors cliquer ou le coller dans un navigateur de votre choix, confirmer l'utilisation du certificat auto-signé, et se prélasser dans la gloire d'une nouvelle instance Jenkins.

Alfred Pennyworth devrait être fier.

### En arrière plan

Le script `start-stack.sh`execute les requettes des API OpenStack nécessaire pour le template heat qui :

* Démarre une instance basée Ubuntu Trusty Tahr
* Fixe une IP-flottante exposée
* Reconfigure Apache avec votre nom d'utilisateur et votre mot de passe de base.

<a name="console" />

## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer votre serveur Jenkins :

1.	Allez sur le Github Cloudwatt dans le dépôt [applications/bundle-trusty-jenkins](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-jenkins)
2.	Cliquez sur le fichier nommé `bundle-trusty-jenkins.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec les détails du template
4.	Enregistrez le fichier sur votre PC. Vous pouvez utiliser le nom proposé par votre navigateur (il faudrait juste enlever le .txt)
5.  Allez dans la section «[Stacks](https://console.cloudwatt.com/project/stacks/)»  de la console
6.	Cliquez sur «Launch stack», puis «Template file» et sélectioner le fichier que vous venez d'enregistr sur votre PC, et pour finir cliquez sur «NEXT»
7.	Donnez un nom à votre stack dans le champ «Stack name»
8.	Entrez le nom de votre keypair dans le champ «SSH Keypair»
9.	Entrez votre nouvel Basic Auth username et mot de passe dans les champs indiqués
10.	Choisissez la taille de votre instance dans le menu déroulant « Type d'instance » et cliquez sur «LANCER»

La stack va se créer automatiquement (vous pourrez voir la progression en cliquant sur son nom). Quand tous les modules passeront au vert, la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour retrouver l’IP flottante qui a été générée, ou rafraichir la page en cours pour avoir le lien.

Si vous avez atteint ce point, alors vous y êtes arrivé ! Profitez de Jenkins !

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur **DEPLOYER** et laisser vous guider... 5 minutes plus tard un bouton vert apparait... **ACCEDER** : vous avez votre Jenkins !

## So watt?

Le but de ce tutoriel est d'accélerer votre démarrage. Dès à présent, **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante et votre clé privée (utilisateur par défaut `cloud`).

~~~ bash
$ ssh «floating-IP» -l cloud -i /path/to/your/.ssh/keypair.pem
~~~

#### Les dossiers importants sont:

- `/etc/apache2/sites-available/default-jenkins.conf`: Fichier de configuration d'Apache2
- `/etc/htpasswd/.htpasswd`: Fichier d'authentification de base username et password.
- `/root/jenkins-cli.jar`: Jenkins' CLI ficher `.jar`
- `/var/lib/jenkins/`: Dossier principal Jenkins
- `/etc/default/jenkins`: Jenkins default settings upon startup, including HTTP port, prefix, webroot, UNIX user/group and more
- `/usr/share/jenkins/jenkins.war`: Fichier WAR Jenkins
- `/var/cache/jenkins/war/`: WAR Jenkins décompressé
- `/var/log/jenkins/jenkins.log`: Fichier système log Jenkins

Jenkins a une intéressante interface ligne de commande (CLI), qui fonctionne avec un jar que nous avons placé à `/root/jenkins-cli.jar`.

Rentrez les commandes en utilisant les syntaxes ci-dessous:

~~~ bash
$ java -jar /root/jenkins-cli.jar -s http://127.0.0.1:8080 «jenkins-cli-command»
~~~

Les avantages sont multiples. Pour un début je recommande commencer par `help`, qui fournit la liste des commandes possible. Partagez avec nous vos trouvailles!

#### Autres ressources qui pourraient vous être utiles :

* [Jenkins Homepage](https://jenkins-ci.org/)
* [Jenkins CLI Reference](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI)
* [Jenkins Plugins](https://wiki.jenkins-ci.org/display/JENKINS/Plugins)
* [Jenkins Wiki](https://wiki.jenkins-ci.org/display/JENKINS/Home)
* [Installing Jenkins on Ubuntu](https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu)
* [Running Jenkins behind Apache](https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Apache)


-----
Have fun. Hack in peace.
