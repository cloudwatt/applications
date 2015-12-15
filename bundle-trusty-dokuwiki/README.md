# 5 Minutes Stacks, Episode 12: Dokuwiki

## Episode 12: Dokuwiki

Dokiwiki est un logiciel wiki open source et [très polyvalent](https://www.dokuwiki.org/features) qui fonctionne
sans base de données. Facile à customiser et bénéficiant d'une bonne bibliothèque
de [plugins](https://www.dokuwiki.org/plugins) et [themes](https://www.dokuwiki.org/template). Les utilisations
de DokuWiki peuvent s'étendre beaucoup plus loin que celles d'un wiki traditionnel de wiki. Voulez-vous un
aperçu? [le siteweb de Dokiwiki](https://www.dokuwiki.org) est en fait un Dokuwiki.

## Préparation

### La version

* Dokuwiki : 2015-08-10a "Detritus"

### Les pré-requis pour déployer cette stack

Ceci devrait maintenant être de la routine :

* Un accès Internet
* Un shell Linux
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec [une paire de clé existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* Les outils Openstack [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications) (si la création de votre stack se fait depuis un shell)

### Taille de l'instance

Par défaut, la stack est déployée sur une instance de type "Small" (s1.cw.small-1). Il existe d'autres types
d'instances pour la satisfaction de vos besoins, vous permettant de payer uniquement pour les services dont
vous avez besoin. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les
services que vous avez consommés et plafonnés à leur prix mensuel (vous trouverez plus de détails
sur [La page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Les stacks Dokuwiki suivent les traces de nos précédentes stacks en utilisation de volume, faisant bon
usage des volumes de stockage pour assurer la protection de vos données et vous permettant de payer
uniquement pour l'espace que vous avez utilisé.

La taille du volume est totalement ajustable, et la stack Dokuwiki peut supporter de dizaines à des
centaines de gigaoctets d'espace du projet.

Les paramètres de la Stack sont, bien sûr, à votre fantaisie.


### Au fait...

Comme avec les autres bundles comprenant des volumes, le template heat `.restore` et le script
`backup.sh` vous permettra de manipuler les volumes de stockage Cinder. Avec ces fichiers, vous pouvez
créer des sauvegardes de volumes Cinder : Enregistrer les états du volume de votre stack Dokuwiki et
redéployer avec le template heat `.restore` en cas de besoin.

Les deux stacks 'normal' et 'restored' peuvent être lancées depuis [console](#console), mais notre astucieux `stack-start.sh` vous permet aussi de créer les deux types de stack facilement depuis un terminal.

Les sauvegardes doivent être initialisées avec notre script 'backup.sh` et cela prendra environ
5 minutes entre le lancement et la mise à disposition du service.
[(Plus sur le backup et la restauration de votre Dokuwiki...)](#backup)

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version **"Je lance en 1-clic"** ou **"Je lance avec la console"** en cliquant sur [ce lien](#console)...

## Que trouverez-vous dans le dépôt

Une fois le github cloné, vous trouverez dans le dépôt `bundle-trusty-dokuwiki/`:

* `bundle-trusty-dokuwiki.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
* `bundle-trusty-dokuwiki.restore.heat.yml`: Template d'orchestration HEAT, Il déploie l'infrastructure nécessaire et restaure vos données depuis un précedent [backup](#backup).
* `backup.sh`: Script de création de backup. Réalise une sauvegarde complète et securisée du volume.
* `stack-start.sh`: Script de lancement de la stack, qui simplifie les paramètres.
* `stack-get-url.sh`: Script de récupération de l'IP d'entrée de votre stack, qui peut aussi se trouver dans la sortie de la stack.


### Initialiser l'environnement

Se connecter à [la console Cloudwatt](https://console.cloudwatt.com) et munissez-vous de vos identifiants Cloudwatt, et cliquez [Télécharger un script d'identité 'Cloudwatt API' ](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
Avec cela, vous serez en possession de pouvoirs extraordinaires sur les API Opensatck.

Sourcez le fichier téléchargé dans votre shell et entrez votre mot de passe lorsque vous êtes invité à utiliser les clients OpenStack.


~~~ bash
$ source ~/Downloads/COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Seulement alors les outils de commande en ligne d'OpenStack peuvent interagir avec votre compte utilisateur Cloudwatt


<a name="parameters" />

### Ajuster les paramètres

Dans le fichier '.heat.yml' (templates heat), vous trouverez en haut une section paramètres. Le seul paramètre qui n'est pas par défaut est la `keypair_name`. Réglez la valeur `default` à une paire de clés valides en rapport avec votre compte utilisateur Cloudwatt, comme **ce sera la paire de clés que vous utiliserez pour vous connecter à votre stack à distance** Une keypair peut être génerée depuis [l'onglet `Key Pairs` sous `Access & Security` de la console](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab).
Assurez-vous d'enregistrer la clé publique, sinon vous ne serez pas en mesure de vous connecter à votre machine par SSH.

Il est également possible dans les templates heat d'ajuster (et définir les valeurs par défaut pour ) le type d'instance, la taille du volume, et le type de volume en jouant avec le ` flavor_name`, le` volume_size` et le 'volume_type` selon les paramètres.

Par défaut, le réseau et sous-réseau de la stack sont générés pour la stack, dans lequel le serveur Dokuwiki est seul installé. Ce comportement peut être modifié si necessaire dans le template heat.


~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one DokuWiki stack


parameters:
  keypair_name:
    default: my-keypair-name                <-- Indicate your keypair here
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string

  flavor_name:
    default: s1.cw.small-1                  <-- Indicate your instance type here
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
    constraints:
      - allowed_values:
        [...]

  volume_size:
    default: 10                             <-- Indicate your volume size here
    label: Dokuwiki Volume Size
    description: Size of Volume for Dokuwiki Storage (Gigabytes)
    type: number
    constraints:
      - range: { min: 2, max: 1000 }
        description: Volume must be at least 2 gigabytes

  volume_type:
    default: standard                       <-- Indicate your volume type here
    label: Dokuwiki Volume Type
    description: Performance flavor of the linked Volume for Dokuwiki Storage
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
      cidr: 10.0.3.0/24
      allocation_pools:
        - { start: 10.0.3.100, end: 10.0.3.199 }
[...]

~~~

<a name="startup" />

## Start-up

Pas un fan du Shell? [Sauter à la stack de création depuis la console.](#console)

Dans un shell, lancer le script `stack-start.sh` (assurez-vous [avoir défini la valeur par défaut](#parameters) pour le paramètre `flavor_name`):

~~~ bash
$ ./stack-start.sh TRUEWIKI «my-keypair-name»
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | TRUEWIKI   | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+

~~~

Au bout de 5 minutes, la stack sera totalement opérationnelle; vous pouvez utiliser la commande `watch` pour voir le statut en temps réel.

~~~ bash
$ watch -n 1 heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | TRUEWIKI   | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+

~~~

Nice `watch`.

### Profitez

Une fois que le `stack_status` est `CREATE_COMPLETE`, alors vous pouvez lancer le script `stack-get-url.sh`.

~~~ bash
$ ./stack-get-url.sh TRUEWIKI

STACK   TRUEWIKI
URL     https://70.60.637.17
INSTALL https://70.60.637.17/install.php

~~~

Comme indiqué ci-dessus, il va analyser le l'IP flottante attribuée à votre stack dans un lien URL. Vous pourrez alors cliquer ou coller cela dans le navigateur de votre choix, confirmer l'utilisation du certificat auto-signé, et [ être prêt au wiki~](#using_stack)

### En arrière plan

Le script `start-stack.sh` execute les requettes des API OpenStack nécessaires pour le template heat qui :

* Démarre une instance basée Ubuntu Trusty Tahr
* Attache une IP-flottante pour le Dokiwiki
* Commence, attache, et formate un nouveau volume pour toutes les données de DokuWiki, ou restaure un à partir d'un backup_Id fourni
* Reconfigure le Dokuwiki pour stocker ses données dans le volume

<a name="console" />

## C’est bien tout ça, mais...

### Une Ligne de commande semble aussi amical qu'un management à la militaire

Heureusement pour vous alors, la totalité de la configuration de DokuWiki peut être faite en utilisant uniquement l'interface web. Comme d'habitude cependant, la sauvegarde de votre bien-aimé Dokuwiki implique notre superbe script `backup.sh`.

Pour créer votre stack Dokuwiki depuis la [Console Cloudwatt](https://console.cloudwatt.com):

1.	Allez sur le Github Cloudwatt dans le dépôt [applications/bundle-trusty-dokuwiki](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-dokuwiki)
2.	Cliquez sur le fichier nommé `bundle-trusty-dokuwiki.heat.yml` (ou `bundle-trusty-dokuwiki.restore.heat.yml` pour [restore from backup](#backup))
3.	Cliquez sur RAW, une page web apparait avec uniquement le template
[Nouveau](https://raw.githubusercontent.com/cloudwatt/applications/master/bundle-trusty-dokuwiki/bundle-trusty-dokuwiki.heat.yml) ou [Restauré](https://raw.githubusercontent.com/cloudwatt/applications/master/bundle-trusty-dokuwiki/bundle-trusty-dokuwiki.restore.heat.yml)
4.	Enregistrez le fichier sur votre PC. Vous pouvez utiliser le nom proposé par défaut par votre navigateur (juste enlever le `.txt` si besoin)
5.  Allez dans la section [Stacks](https://console.cloudwatt.com/project/stacks/) de la console
6.	Cliquez sur `LAUNCH STACK`, puis `Browse` sous `Template file` et selectionnez le fichier que vous venez d'enregistrer sur votre PC et puis cliquez finalement sur `NEXT`
7.	Nommez votre stack dans le champs `Stack Name`
10.	Choisissez votre instance flavor en utilisant le menu déroulant `Instance Type`
8.	Entrez le nom de votre keypair dans le champs `SSH Keypair`
9.	Confirmez la taille du volume (en gigabytes) et le type dans les champs `Dokuwiki Volume Size` et `Dokuwiki Volume Type` et cliquez sur `LAUNCH`

La stack sera automatiquement générée (vous pourrez voir sa progression en cliquant sur son nom). Lorsque tous les modules passeront au vert, la création sera complète. Vous pouvez alors aller dans le menu "instances" pour trouver l'IP-flottante, ou simplement rafraîchir la page courante et vérifier l'onglet Présentation.

Si vous avez atteint ce point, alors votre stack est fonctionnelle! Mettez en place et profitez de Dokiwiki.

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : vous avez votre Dokuwiki !

<a name="using_stack" />

## Utilisation de Dokuwiki

La mise en place de Dokuwiki est simple: suivez ce guide accompagné d'images et vous serez en peu de temps un habitué.

Par souci de simplicité, nous omettons l'adresse IP pour nommer les liens: si l'IP-lottante de votre URL est `https://70.60.637.17`, alors `/some/path` serait `https://70.60.637.17/some/path`.

Dès lors que Dokiwiki utilise les certificats auto-signés SSL,l'interaction avec certains navigateurs ne se passe pas bien
, **Firefox est le pire de tous**. (Vous avez été prévenu) Ne vous souciez pas du message renvoyé par votre navigateur: validez les exceptions SSL, et vous ne rencontrerez plus de probèmes avec le navigateur.

Une fois la page principale de votre navigateur atteinte, apparaitra une page comme celle ci-dessous:

![Dokuwiki First Look](img/first_look.png)

Yay Dokuwiki!  Il reste une configuration à faire. Allez dans `/install.php` pour "installer" Dokuwiki.

![Dokuwiki install.php](img/install_php.png)

Quelques notifications:

* Nommez le wiki comme vous le souhaitez.
* Vous voulez certainement activer ACL: c'est l'outil de login pour Dokiwiki.(Sauf si vous souhaitez l'anarchie sur votre wiki, dans ce cas, décochez le.
* Le `Superuser` sera l'unique personne qui aura accès par défaut au panneau d'administration de Dokuwiki.
* Les champs `Real Name` , `E-Mail` et `Password` sont à remplir par vous.
* Réglez le niveau de l'ACL pour répondre à vos besoins;
* Vous pouvez créer les utilisatuers et leurs rôles depuis le panneau d'administration à la main; Avec cette approche, permettre ou pas aux utilisateurs de faire eux même leur enregistrement.

Ci-dessous la forme, il vous demandera de choisir une licence pour votre wiki : étudier si vous le souhaitez, puis faites votre choix et Enregistrez.

Dokuwiki est maitenant prêt: suivez le lien `Votre Nouveau DokuWiki` sur la page où vous avez été redirigé ( ou allez à `/doku.php?id=wiki:welcome`) pour un petit Dokuwiki qui vous aidera à commencer à utiliser votre wiki!

![Start using Dokuwiki](img/start_using.png)

[Configurer votre Dokuwiki~](https://www.dokuwiki.org/config)

<a name="backup" />

## Sauvegarde et Restauration

Sauvegarder votre Dokuwiki semble être une excellente idée, non? Nous avons fait le nécessaire pour rendre l'enregistrement de votre travail rapide et facile.

~~~ bash
$ ./backup.sh TRUEWIKI

~~~

Et cinq minutes plus tard, vous êtes de retour et opérationnel avec une conscience tranquille

La restauration est aussi simple que la mise en place d'une autre stack, mais cette fois avec `.restore.heat.yml`, et en spécifiant l'ID du backup dont vous avez besoin.
La nouvelle taille du volume ne doit pas être plus petite que l'original afin d'éviter toute perte/corruption de données.
Une liste de sauvegardes peut être trouvée dans « Volumes Backups » sous l'onglet « Volumes » dans la console, ou à partir de la ligne de commande avec l'API de Cinder:

~~~ bash
$ cinder backup-list

+------+-----------+-----------+-------------------------------------+------+--------------+---------------+
|  ID  | Volume ID |   Status  |                 Name                | Size | Object Count |   Container   |
+------+-----------+-----------+-------------------------------------+------+--------------+---------------+
| XXXX | XXXXXXXXX | available | TRUEWIKI-backup-2025/10/23-07:27:69 |  10  |     206      | volumebackups |
+------+-----------+-----------+-------------------------------------+------+--------------+---------------+

~~~

## So watt?

Le but de ce tutoriel est d'accélerer votre démarrage. A ce ce niveau **vous** êtes mâitre de votre stack.

Vous avez un point d'accès en SSH sur votre machine virtuelle à travers l'IP flottante et votre keypair privée
(nom d'utilisateur par défaut *cloud*).

Les dossiers importants sont:

- `/dev/vdb`: Point de montage de Volume
- `/mnt/vdb/`: `/dev/vdb` monte ici: Contient toutes les données du Dokuwiki
- `/mnt/vdb/stack_public_entry_point`: Contient la dernière adresse IP-flottante connue, utilisé pour remplacer l'adresse de l'IP-flottante à tous les endroits où il change.
- `/etc/dokuwiki/ssl/`: La clé du serveur `.key` et l'autosigné `.crt` pour le HTTPS
- `/etc/dokuwiki/dokuwiki-volume.sh`: Exécute le script au redémarrage pour remonter le volume et vérifie si Dokuwiki est prêt à fonctionner de nouveau
- `/var/www/dokuwiki`: Point de montage du Volume de Dokuwiki

Autres ressources qui pourraient vous être utiles :

* [Dokuwiki Homepage](https://www.dokuwiki.org)
* [Dokuwiki Features](https://www.dokuwiki.org/features)
* [Dokuwiki Configuration](https://www.dokuwiki.org/config)
* [Dokuwiki Plugins](https://www.dokuwiki.org/plugins)
* [Dokuwiki Themes/Skins](https://www.dokuwiki.org/template)


-----
Have fun. Hack in peace.
