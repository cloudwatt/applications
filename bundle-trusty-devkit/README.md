# 5 Minutes de Stacks, Episode 11: DevKit

## Episode 11: DevKit

Je vous présente chers hackers et gentilshommes une vraie perle bundle: **Le DevKit**.

* **GitLab** est un utilitaire de gestion de projet, offrant un équivalent de GitHub pour vous et votre équipe.

* **Jenkins** est notre outil préféré de construction (et bientôt le votre), la manipulation de votre build comme vous le souhaitez et peu importe le projet, grâce à son incroyable bibliothèque de plug-in et à son solide noyau, maintenu par une communauté active.

* **Dokuwiki** est un logiciel de wiki très polyvalent qui fonctionne entièrement sans base de données.

* **OpenLDAP** est une implémentation libre et respectée de la Lightweight Directory Access Protocol(LDAP). Le DevKit  s'appuie sur OpenLDAP pour centraliser la gestion des utilisateurs, ce qui simplifie largement les choses pour vous ou pour votre gestionnaire d'équipe. Connectez-vous avec le même nom d'utilisateur et même mot de passe partout à travers le DevKit.

* **LDAP Account Manager**, ou LAM, est une interface PHP conçue pour rendre la gestion de LDAP aussi facile que possible pour l'utilisateur. Il fait abstraction des détails techniques de LDAP, permettant même à ceux sans connaissances techniques de gérer les entrées LDAP. Si l'on souhaite manipuler la base de données LDAP, on peut directement apporter des modifications via le navigateur LDAP intégré.

* **Let's Chat** est une application webchat adaptée pour les petites équipes de développement. Développée par [Security Compass](http://securitycompass.com/), Let's Chat gère les messages persistants, les salons de discussions, les notifications via le navigateur, le transfert des fichiers et l'embarquement d'images, la coloration syntaxique, les chambres privées et plus encore !

Bien sûr, chacun de ces outils est complètement **Open Source**, et chacun de ces outils s'appuie sur LDAP pour l'authentification.

Ensemble, ces outils fournissent les bases d'un environnement de développement.

* **Codez** et exécutez votre travail en utilisant les pratiques éprouvées de Git avec GitLab.
* **Compilez** et testez votre projet à l'aide de Jenkins pour un feedback immédiat lors de votre progression.
* **Communiquez** et collaborez en interne avec l'utilisation de Let's chat.
* **Corroborez** vos idées et documentez les créations et les pratiques de votre équipe grâce à Dokuwiki.
* **Contrôlez** tous les comptes utilisateurs grâce à LAM et OpenLDAP.

## Préparations

### Les Versions

* GitLab : 7.14.3-ce.0
* Jenkins : 1.628
* Dokuwiki : 2015-08-10a "Detritus"
* OpenLDAP : 2.4.31-1
* LDAP Account Manager : 4.4-1
* Let's Chat : 0.4.2

### Les pré-requis pour déployer cette stack

A l'épisode 11, cette liste doit maintenant vous être familière :

* Un accès Internet
* Un shell Linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* Les outils: [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [ des applications Cloudwatt ](https://github.com/cloudwatt/applications)


### Taille de l'instance

La Stack DevKit installe tous les outils sur la même instance, pour simplifier la sauvegarde du volume, la configuration et la sécurité. Cela crée une charge potentiellement importante, c'est pourquoi nous recommandons que votre instance soit au moins du type " Standard- 2 " ( n1.cw.standard - 2).

Les Stacks DevKit suivent les traces de nos précédentes stacks GitLab et LDAP, en faisant bon usage des volumes de stockage Cinder pour assurer la protection de vos données et vous permettant ainsi de payer uniquement pour l'espace que vous utilisez. La taille du volume est entièrement ajustable, et la stack de DevKit peut supporter des dizaines à des centaines de gigaoctets d'espace nécessaire à votre projet.

Bien sûr les paramètres de la stack, sont à manipuler selon vos besoins.


### Au fait...

Comme avec les bundles Gitlab le template Heat `.restore` et et le script `backup.sh` vous permettent de manipuler les volumes de stockage Cinder. Avec ces fichiers, vous pouvez créer des volumes de backup Cinder : Sauvegardez les états de volume de votre stack de DevKit qui pourront être redéployé avec le modèle du template `.restore` en cas de besoin.

De la même façon que les stack normales, celles 'restaurées' peuvent être lancées à partir de la [ console ] ( # console), mais notre astucieux `stack-start.sh` vous permet également de lancer facilement deux types de stacks depuis un [Terminal]

Les sauvegardes doivent être initialisées avec notre script` backup.sh` et cela prend environ 5 minutes du début au retour à la fonctionnalité finale. [ ( Plus sur la sauvegarde et la restauration de votre DevKit ... ) ] (# backup)

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version **"Je lance en 1-clic"** ou **"Je lance avec la console"** en cliquant sur [ce lien](#console)...

## Détails des fichiers

Une fois que vous avez cloné le github, vous trouverez dans le reférentiel  `bundle-trusty-devkit/`:

* `bundle-trusty-devkit.heat.yml`: Template d'orchestration HEAT. Il sera utilisé pour le déploiement de l'infrastructure nécessaire.

* `bundle-trusty-devkit.restore.heat.yml`: Template d'orchestration HEAT. Il permet le déploiement de l'infrastructure nécessaire et restaure vos données deupis le recent [backup](#backup).

* `backup.sh`: Script de creation de backup. Réalise un backup  complet du volume pour une sauvegarde sécurisée.

* `stack-start.sh`: Stack de lancement du script qui simplifie les paramètres.

* `stack-get-url.sh`: Fourni l'IP flottante dans une URL qui peut aussi se trouver dans la stack de sortie.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez
[ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
Si vous n'êtes pas connecté, vous passerez par l'étape d'authentification et enregistrerez le script contenant vos identifiants.
Avec cela vous pourrez alors profiter des pouvoirs extraordinaires des API d'Openstack.

Sourcez le fichier téléchargé dans votre shell et entrez votre mot de passe lorsque vous êtes invité à utiliser les clients OpenStack.

~~~ bash
$ source ~/Downloads/COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Une fois ceci fait, les outils de ligne de commande d'OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

Dans le fichier `.heat.yml` (templates heat), vous trouverez en haut une section paramètres. Le seul paramètre obligatoire pour la connexion est la `keypair_name`.

Vous devez paramétrer la valeur par défaut de la keypair en relation avec votre compte utilisateur Cloudwatt, vu que ceci est votre moyen de connexion à distance. Une keypair peut être générée depuis l'onglet `Key Pairs` sous `Access & Security` depuis la console.
Rassurez-vous d'avoir enregistré la clé publique, sinon il vous sera impossible de vous connecter à votre machine par SSH.

C'est dans ce même fichier que vous pouvez ajuster(et définir les valeurs par défaut pour) le type d'instance, la taille du volume, et le type de volume en jouant avec le `flavor`, `volume_size`, et `volume_type` selon les paramètres.

Par défaut, le réseau de la stack et le sous-réseau sont générés pour la stack, dans laquelle le serveur de DevKit est logé. Ce comportement peut être modifié dans le `.heat.yml` si besoin.


~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one DevKit stack


parameters:
  keypair_name:
    default: my-keypair-name                <-- Indicate your keypair here
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string

  flavor_name:
    default: n1.cw.standard-2               <-- Indicate your instance type here
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
    constraints:
      - allowed_values:
        [...]

  volume_size:
    default: 10                             <-- Indicate your volume size here
    default: 10
    label: DevKit Volume Size
    description: Size of Volume for DevKit Storage (Gigabytes)
    type: number
    constraints:
      - range: { min: 10, max: 10000 }
        description: Volume must be at least 10 gigabytes

  volume_type:
    default: standard                       <-- Indicate your volume type here
    label: DevKit Volume Type
    description: Performance flavor of the linked Volume for DevKit Storage
    type: string
    constraints:
      - allowed_values:
          - standard
          - performant


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
$ ./stack-start.sh OMNITOOL «my-keypair-name»
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | OMNITOOL   | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+

~~~

Au bout de **5 minutes**, la stack sera totalement opérationnelle. (Vous pouvez utiliser la commande watch pour voir le statut en temps réel)

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | OMNITOOL   | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+

~~~

### Profitez

Une fois tout ceci fait, vous pouvez lancer le script 'stack-get-url.sh'.

~~~ bash
$ ./stack-get-url.sh OMNITOOL
OMNITOOL  http://70.60.637.17

~~~

Comme indiqué ci-dessus, il va analyser les IP flottantes attribuées à votre stack dans un lien URL. Vous pouvez alors cliquer ou le coller dans un navigateur de votre choix,
confirmer l'utilisation du certificat auto-signé, et vous délecter de l'irradiante puissance de votre DevKit.


### En arrière plan

Le script `start-stack.sh` exécute les requêtes des API OpenStack nécessaires pour le template heat qui:

* Démarre une instance basée Ubuntu Trusty Tahr

* Fixe une IP-flottante exposée pour le DevKit

* Démarre, attache et formate un nouveau volume pour toutes les données de DevKit, ou restaure un depuis un backup_id qui lui est fourni

* Reconfigure le DevKit afin de garder ses données dans le volume.

* Configure le DevKit pour l'utilisation de l'adresse IP flottante. (Ceci est ensuite traité par des scripts en interne)


<a name="console" />

## C’est bien tout ça, mais...

### La ligne de commande vous semble aussi agréable qu'un stage de survie en Guyane

Heureusement pour vous, la totalité de la configuration de la DevKit peut être accomplie en utilisant seulement les interfaces Web de chaque outil . Comme habituellement pensé, la sauvegarde de votre DevKit implique notre super et pratique script `backup.sh`.

Pour créer une stack DevKit depuis la console:

1.	Allez sur le Github Cloudwatt dans le dépôt [applications/bundle-trusty-devkit](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-devkit)
2.	Cliquez sur le fichier nommé `bundle-trusty-devkit.heat.yml` (`bundle-trusty-devkit.restore.heat.yml` pour [restaurer depuis le backup](#backup))
3.	Cliquez sur RAW, une page web apparait avec les détails du template
4.	Enregistrez le fichier sur votre Pc. Vous pouvez utiliser le nom proposé par votre navigateur (il faudrait juste enlever le .txt)
5.  Allez dans la section «[Stacks](https://console.cloudwatt.com/project/stacks/)» de la console
6.	Cliquez sur «Launch stack», puis «Template file» et sélectioner le fichier que vous venez d'enregistrer sur votre PC, et pour finir cliquez sur «NEXT»
7.	Donnez un nom à votre stack dans le champ «Stack name»
8.	Entrez le nom de votre keypair dans le champ «SSH Keypair»
9.	Confirmez le type et la taille du volume (en gigaoctets) dans les champs «DevKit Volume Type» et «DevKit Volume Size»
10.	Choisissez la taille de votre instance en utilisant le menu déroulant «Instance Type» et cliquez sur «LAUNCH»

La stack va se créer automatiquement (vous pourrez voir la progression en cliquant sur son nom). Quand tous les modules passeront au vert, la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour retrouver l’IP flottante qui a été générée, ou rafraichir la page en cours pour avoir le lien.

Si vous avez atteint ce point, alors vous y êtes arrivé ! Profitez du DevKit!

Chaque outil devra être configuré, cependant cela ne prendra pas beaucoup de temps: le guide écrit ci-dessous vous sera utile pour cela !

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 5 minutes plus tard un bouton vert apparait... ACCEDER : vous avez votre DevKit !

Chaque outil devra être configuré, cependant cela ne prendra pas beaucoup de temps: le guide écrit ci-dessous vous sera utile pour cela !

## Préparez votre boîte à outils

Obtenir vos outils de DevKit prêt est simple, mais peut-être pas la première fois : suivre ce guide avec des captures d'écran qui vous peremettra
d'y arriver.

Par souci de simplicité, nous omettons l'adresse IP pendant la nomination des liens : si l'IP flottante de  votre URL
est `http://70.60.637.17`, alors `/some/path` serait `http://70.60.637.17/some/path`.

Du moment où la DevKit utilise des certificats SSL auto - signé, il réagit différement à certains navigateurs, notamment Firefox(vous êtes prévenu); Pas d'inquiétudes sur ce que dit votre navigateur: valider les exceptions SSL et autres joyeusetés, et à partir de là le navigateur ne devrait plus vous déranger.


#### Utiliser le DevKit

**LAM** se trouve à `/lam`, le password pour l'utilisateur principal (username: *Administrator*), le password du
 *master*, et le password des *server preferences* sont par défaut **c10udw477**. Je vous recommande l'installation du LAM avant tout autre chose.

[Installation du LAM](tutorials/lam.md)

**GitLab** est le suivant! Avant l'utilisation du Gitlab, vous aimeriez bien configurer votre compte admin.

[Getting GitLab ready](tutorials/gitlab.md)

**Dokuwiki** a son propre port, `:8081`, alors validez encore le certificat HTTPS (ceci dépend de votre navigateur) et vous atteindrez la page principale, `:8081/doku.php`. (Pour des besoins de commodité, `/dokuwiki` reécrit en `:8081`.)

[Installation du Dokuwiki](tutorials/dokuwiki.md)

**Jenkins** a l'installation la plus facile, et se trouve à `/jenkins`. Il n'y a veritablement pas d'installation. Se connecter avec n'importe quel user LDAP et commencer à construire.

[Jenkins Login Screenshot](tutorials/img/jenkins_login.png)

**Let's Chat**, tout comme Dokuwiki, se trouve sur un port séparé: `:8082`. (Pour des besoins de commodité, `/lets-chat` renvoyé vers`:8082`.)
Suivez les étapes ci-dessous et découvrez!


[Utilisation de Let's Chat](tutorials/lets_chat.md)

<a name="backup" />

## Sauvegarde et Restauration

Sauvegarder votre DevKit, sonne comme une idée geniale, non? Après tout, *ipsa scientia potestas est*, et vous ne vous sentez jamais aussi impuissant que lorsque vous avez perdu votre code. Heureusement, nous avons travaillé dur pour faire enregistrer votre travail rapidement et facilement .


~~~ bash
$ ./backup.sh OMNITOOL
~~~

Cinq minutes plus tard, vous êtes de retour dans le travail avec la conscience tranquile!
La restauration aussi simple que la création d'une nouvelle stack, bien qu'à ce moment avec le `.restore.heat.yml`, et en spécifiant l'ID du backup dont vous avez besoin.
La taille du nouveau volume ne devrait pas être plus petite que celle de l'origine afin d'éviter toute perte/corruption de données. Une liste des backups peut être trouvée dans l'onglet «Volume Backups» sous «Volumes» dans la console, ou depuis la ligne de commande avec l'API Cinder.


~~~ bash
$ cinder backup-list

+------+-----------+-----------+-------------------------------------+------+--------------+---------------+
|  ID  | Volume ID |   Status  |                 Name                | Size | Object Count |   Container   |
+------+-----------+-----------+-------------------------------------+------+--------------+---------------+
| XXXX | XXXXXXXXX | available | OMNITOOL-backup-2025/10/23-07:27:69 |  10  |     206      | volumebackups |
+------+-----------+-----------+-------------------------------------+------+--------------+---------------+

~~~

Rappelez-vous cependant que, si nous avons largement simplifié le processus de restauration et entièrement géré le changement de l'IP flottante dans le DevKit, **d'autres services qui interfacent avec le DevKit ne prendront pas en compte les changements d'adresse IP, connus dans votre configuration Git **. La clé SSH locale de votre Git sera toujours valide, par contre vous devez vous assurer de corriger les adresses hôtes et prévoir les adresses distantes avant de continuer votre travail


## So watt?

Le but de ce tutoriel est d'accélérer votre lancement. À ce stade, **vous** êtes le maître de la stack.

Vous avez un point d'accès SSH sur votre machine virtuelle par l'IP flottante et votre keypair privée
You now have an SSH access point on your virtual machine through the floating-IP and your private keypair(nom de l'utilisateur par défaut *cloud*).

Les répertoires sont intéressants:

- `/dev/vdb`: Point de montage des volumes
- `/mnt/vdb/`: `/dev/vdb` Montages ici: Contient toutes les données de la DevKit, à l'exception de celle de Let's Chat
- `/mnt/vdb/stack_public_entry_point`: Contient la dernière adresse IP flottante connue, utilisé pour remplacer l'adresse IP flottante depuis toute location lors d'un changement.
- `/etc/nginx/`: Fichiers de configuration Nginx
- `/etc/devkit/ssl/`: The server's `.key` and self-signed `.crt` for HTTPS
- `/etc/devkit/devkit-volume.sh`: Exécuter le script après ​​un redémarrage pour remonter le volume et vérifier que le DevKit est prêt à fonctionner de nouveau

- `/var/opt/gitlab`: Point de montage des volumes Gitlab
- `/var/www/dokuwiki`: Point de montage des volumes Dokuwiki
- `/var/lib/ldap`: Point de montage des volumes Ldap
- `/var/lib/jenkins`: Point de montage des volumes
- `/var/lib/lets-chat`: Point d'installation de Let's Chat

Autres ressources qui pourraient vous interesser.

* [LAM Manual](https://www.ldap-account-manager.org/static/doc/manual-onePage/index.html)
* [OpenLDAP Documentation Catalog](http://www.openldap.org/doc/)
* [Doc for GitLab CE](http://doc.gitlab.com/ce/)
* [Jenkins Homepage](https://jenkins-ci.org/)
* [Jenkins Wiki](https://wiki.jenkins-ci.org/display/JENKINS/Home)
* [Let's Chat Documentation](https://github.com/sdelements/lets-chat/wiki)
* [Dokuwiki Homepage](https://www.dokuwiki.org)
* [Nginx - How to Configure Nginx](https://www.linode.com/docs/websites/nginx/how-to-configure-nginx)
* [Nginx - Rewrite Module](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html)
* [Nginx - Logging](http://nginx.org/en/docs/debugging_log.html)
* [Nginx - Guide to Nginx](https://www.nginx.com/resources/admin-guide/nginx-web-server/)
* [Nginx - Dokuwiki & Nginx #1](https://www.dokuwiki.org/install:nginx#dokuwiki_with_nginx_on_ubuntu_linux_1204_and_newer)
* [Nginx - Dokuwiki & Nginx #2](https://wiki.boetes.org/dokuwiki_on_nginx)
* [Nginx - Dokuwiki & Nginx #3](http://wiki.nginx.org/Dokuwiki)
* [Nginx - LAM & Nginx](https://www.ldap-account-manager.org/static/doc/manual/apbs07.html)
* [Nginx - Jenkins & Nginx](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy)


-----
Amusez vous.
