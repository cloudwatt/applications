# 5 Minutes Stacks, épisode 23 : Duplicity #

## Episode 23 : Duplicity

![Backuplogo](img/logobackup.jpg)

L'utilitaire duplicity est un outil en **ligne de commande** permettant d'effectuer des sauvegardes incrémentielles de fichiers et de dossiers.

Il effectue la sauvegarde en créant des archives TAR chiffrées avec GnuPG. Ces archives sont alors envoyées dans un répertoire de sauvegarde local ou distant les protocoles distants pris en charge sont entre autre FTP, SSH/SCP, Rsync, WebDAV/WebDAVs. Puisque Duplicity repose sur librsync, les sauvegardes incrémentielles sont économes en espace de stockage : seules les parties modifiées des fichiers sont prises en considération.

### Les versions
 - Ubuntu Trusty 14.04.2
 - Duplicity 0.7.06

### Les pré-requis pour déployer cette stack

 Ceci devrait être une routine à présent:

 * Un accès internet
 * Un shell linux
 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
 Par défaut, le script propose un déploiement sur une instance de type "Small" (s1.cw.small-1). Il
 existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins.
 Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel
 (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

 Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

 Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version ["Je lance avec la console"](#console)...

## Tour du propriétaire

 Une fois le dépôt cloné, vous trouverez le répertoire `bundle-trusty-duplicity/`

 * `bundle-trusty-duplicity.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
 * `stack-start.sh`: Scipt de lancement de la stack, qui simplifie la saisie des parametres et sécurise la création du mot de passe admin.
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
 Dans le fichier `bundle-trusty-duplicity.heat.yml` vous trouverez en haut une section `parameters`. Les seuls paramètres obligatoires sont celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur et celui du `passcode` qui va permettre de chiffrer vos backups. De plus vous pouvez indiquer la taille du volume qui sera attaché à votre stack via le paramètre `volume_size`.
 C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

 ~~~yaml
 heat_template_version: 2013-05-23


description: All-in-one duplicity stack


parameters:
  keypair_name:
    label: SSH Keypair
    description: Keypair to inject in instance
    type: string
    default: my-keypair-name        <-- Mettez ici le nom de votre keypair  

  flavor_name:
    default: s1.cw.small-1
    label: Instance Type (Flavor)
    description: Flavor to use for the deployed instance
    type: string
    constraints:
      - allowed_values:
        - t1.cw.tiny
        - s1.cw.small-1
        - n2.cw.standard-1
        - n2.cw.standard-2
        - n2.cw.standard-4
        - n2.cw.standard-8
        - n2.cw.standard-16
        - n2.cw.highmem-2
        - n2.cw.highmem-4
        - n2.cw.highmem-8
        - n2.cw.highmem-12

  passcode:
    label: GnuPG Encryption Key Passcode
    description: Passcode for GnuPG Keys used to encrypt and sign all data backups
    type: string
    hidden: true
    constraints:
      - length: { min: 4, max: 24 }
        description: Password must be between 6 and 24 characters

  volume_size:
    default: 10                                       <------ Mettre la taille du volume souhaité
    label: Backup Volume Size
    description: Size of Volume for DevKit Storage (Gigabytes)
    type: number
    constraints:
      - range: { min: 10, max: 10000 }
         description: Volume must be at least 10 gigabytes      
[...]


~~~


### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh`:
~~~
./stack-start.sh nom_de_votre_stack
~~~

Exemple :

~~~bash
$ ./stack-start.sh EXP_STACK
+--------------------------------------+-----------------+--------------------+----------------------+
| id                                   | stack_name      | stack_status       | creation_time        |
+--------------------------------------+-----------------+--------------------+----------------------+
| ee873a3a-a306-4127-8647-4bc80469cec4 | EXP_STACK       | CREATE_IN_PROGRESS | 2015-11-25T11:03:51Z |
+--------------------------------------+-----------------+--------------------+----------------------+
~~~

Puis attendez **5 minutes** que le déploiement soit complet.


~~~
$ heat resource-list EXP_STACK
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

  * démarrer une instance basée sur Ubuntu trusty, pré-provisionnée avec la stack Duplicity,
  * l'exposer sur Internet via une IP flottante.



### C’est bien tout ça, mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur duplicity:

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/bundle-trusty-duplicity](https://github.com/cloudwatt/applications/tree/master/bbundle-trusty-backup)
2.	Cliquez sur le fichier nommé `bundle-trusty-duplicity.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.  Donner votre passphrase qui servira pour le chiffrement des sauvegardes
10.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement. Ne vous reste plus qu'à vous connecter en ssh avec votre keypair.

C’est (déjà) FINI !

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur **DEPLOYER** et laisser vous guider... 2 minutes plus tard un bouton vert apparait... **ACCEDER** : vous avez votre Duplicity !

![logosvgcloud](http://www.cachem.fr/wp-content/uploads/2015/09/nuage-backup1.jpg)

### Visibilité Réseau
Il faut maintenant créer la visibilité réseau entre notre stack Duplicity et le reste des machines de notre tenant. Lors de la création de la stack Duplicity, un routeur à été crée afin que vous puissiez y attacher différent réseau de votre tenant, voici comment faire:

1. Dans un premier temps il faut connaitre l'id du routeur de la stack Duplicity. Cela est possible via la commande suivante:

~~~
heat resource-list $Nom_de_la_stack_duplicity
~~~
~~~bash
+--------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| resource_name      | physical_resource_id                                                                | resource_type                   | resource_status | updated_time         |
+--------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
| network            | a29ce347-969a-4ba9-8da6-c909f1b249b7                                                | OS::Neutron::Net                | CREATE_COMPLETE | 2016-03-07T09:00:00Z |
| volume             | c04798dd-dc12-4456-a92d-91ce9871c3a5                                                | OS::Cinder::Volume              | CREATE_COMPLETE | 2016-03-07T09:00:00Z |
| floating_ip        | f65cebbf-a7b5-47b4-b2cd-a7a212288263                                                | OS::Neutron::FloatingIP         | CREATE_COMPLETE | 2016-03-07T09:00:01Z |
| router             | dd25c093-0076-4664-8713-0c3488ea78d9                                                | OS::Neutron::Router             | CREATE_COMPLETE | 2016-03-07T09:00:01Z |
| security_group     | cf5b2af8-1455-4c16-972e-4b5f96a56f4c                                                | OS::Neutron::SecurityGroup      | CREATE_COMPLETE | 2016-03-07T09:00:01Z |
| server_init        | f4cf30ab-02d8-4896-8796-537369c6d787                                                | OS::Heat::SoftwareConfig        | CREATE_COMPLETE | 2016-03-07T09:00:01Z |
| subnet             | 4b39f6ac-44ec-4482-9732-28449db8856b                                                | OS::Neutron::Subnet             | CREATE_COMPLETE | 2016-03-07T09:00:04Z |
| backup_interface   | `dd25c093-0076-4664-8713-0c3488ea78d9`:subnet_id=4b39f6ac-44ec-4482-9732-28449db8856b | OS::Neutron::RouterInterface    | CREATE_COMPLETE | 2016-03-07T09:00:07Z |
| server             | 115a1f0b-f537-418d-a7c5-f6c6c5d65b60                                                | OS::Nova::Server                | CREATE_COMPLETE | 2016-03-07T09:00:08Z |
| volume_attachement | c04798dd-dc12-4456-a92d-91ce9871c3a5                                                | OS::Cinder::VolumeAttachment    | CREATE_COMPLETE | 2016-03-07T09:00:38Z |
| floating_ip_link   | f65cebbf-a7b5-47b4-b2cd-a7a212288263-84.39.34.17                                    | OS::Nova::FloatingIPAssociation | CREATE_COMPLETE | 2016-03-07T09:00:39Z |
+--------------------+-------------------------------------------------------------------------------------+---------------------------------+-----------------+----------------------+
~~~

2. Trouvons l'ID du subnet à ajouter au router Duplicity:

~~~bash

$ heat resource-list $NOM_DE_STACK_A_AJOUTER | grep subnet

| subnet           | babdd078-ddc8-4280-8cbe-0f77951a5933              | OS::Neutron::Subnet             | CREATE_COMPLETE | 2015-11-24T15:18:30Z |
~~~

3. A présent faites la liaison entre l'id du routeur Duplicity et l'id du subnet du réseau à ajouter:

~~~bash
$ neutron router-interface-add $DUPLICITY_ROUTER_ID $STACK_SUBNET_ID
~~~

### Enjoy

Une fois tout ceci fait vous pouvez vous connecter sur votre serveur en SSH en utilisant votre keypair préalablement téléchargée sur votre poste,

Vous etes maintenant en possession d'un serveur de backup.
Celui ci est capable de générer des sauvegardes chiffrées et de les copier ou bon vous semble, duplicity est capable de faire des sauvegardes full et incrémentales (incrémentale signifie que seules les parties modifiées des fichiers sont prises en considération depuis la précédente sauvegarde).
Attention si vous faites de l'incrémentale Duplicity à besoin de l'ensemble des sauvegardes incrémentales depuis la dernière full pour être réstaurées.

**Un conseil utile:** Faites une sauvegarde full par semaine et ensuite une incrémentale par jour afin d'avoir un jeu de sauvegarde propre.

Par défaut l'ensemble des codes et passphrase générés par l'application sont stockés dans `/etc/duplicity`. Vous trouverez un fichier `dup_vars.sh` contenant l'ensemble des informations utiles pour réaliser l'ensemble des exemples présenté ci-dessous.
Si vous souhaitez faire du backup à distance vous devez copier ou créer votre clé ssh sur le serveur Duplicity afin qu'il puisse s'authentifier sur le serveur distant. Le chemin de votre clé sera à renseigner en utilisant l'option `--ssh-option ` de la commande `duplicity`.

A titre d'information lorsque vous sauvegardez pour la première fois un répertoire, Duplicity va effectuer une sauvegarde Full et ensuite des sauvegardes incrémentales. Duplicity va regarder la signature du fichier à restaurer, si la signature correspond à une sauvegarde existante, Duplicity va lancer une sauvegarde incrémentale. Si vous voulez faire une full à chaque fois cela est possible avec la commande `duplicity full`.

La génération de sauvegarde à la fois incrémentales et chiffrées, y compris pour les bases de données, font de Duplicity une solution de backup idéale pour l’auto-hébergement.

**Voici quelques exemples simple d'utilisation:**

Pour effectuer un backup (local) avec une liste de fichier spécifique:

~~~
duplicity /your_directory file:///var/backups/duplicity/ --include-globbing-filelist filelist.txt --exclude '**'
~~~
Pour effectuer un backup sur un serveur distant:

~~~
duplicity --encrypt-key key_from_GPG --exclude files_to_exclude --include files_to_include path_to_back_up sftp://root@backupHost//remotebackup/duplicityDroplet
~~~

Pour effectuer un backup full du serveur et l'envoyer sur un serveur distant avec une clé ssh (keypair), une passphrase et une 'encrypt-key' tout en exluant /proc &  /sys & /tmp:
~~~
PASSPHRASE="yourpassphrase" duplicity --encrypt-key your_encrypt_key --exclude /proc --exclude /sys --exclude /tmp / sftp://cloud@DuplicityPrivateIP//directory --ssh-option="-oIdentityFile=keypair_path"
~~~

Pour effectuer une restauration de fichier local sans Encryption:

~~~
duplicity restore file:///var/backups/duplicity/ /any/directory/
~~~  

Pour effectuer une restauration de fichier distant avec une clé ssh (keypair), une passphrase et une encrypt-key:
~~~
PASSPHRASE="yourpassphrase" duplicity sftp://cloud@DuplicityPrivateIP//your_sauvegarde_directory --ssh-option="-oIdentityFile=/home/cloud/.ssh/yourkeypair.pem" /your_restore_directory
~~~

Vous pouvez aussi sauvegarder une base de donnée en exportant la base puis en sauvegardant le fichier exporté:

~~~
mysql -uroot -ppassword --skip-comments -ql my_database > my_database.sql

~~~
#### Maintenant que vous avez appris à vous servir du produit allons plus loin ...

![schmeasvg](http://www.itpro.fr/upload/picture/2011/08/29/ca41fb53bb2098700e2c9ee5cb4c14a0.jpg)

**Automatisons maintenant les sauvegardes :**

Afin d'automatiser les sauvegardes vous pouvez utiliser CRON installé par défaut sur le serveur. Celui-ci va vous permettre de **scheduler** vos sauvegardes pour que vous n'ayez plus à vous en occuper.

**Une chose à garder en tête:** Lorsque qu'un service tourne sur le serveur à sauvegarder, un lock est positionné sur les fichiers utilisés par celui-ci. Si vous voulez effectuer un sauvegarde **FULL**, il faudra arreter l'ensemble des services du serveur afin que Duplicity ait accès à l'ensemble des fichiers.

Pour faciliter la gestion des sauvegardes, je vous propose de les centraliser sur un **volume** attaché au serveur Duplicity. Celui ci est monté à la création de la stack. je l'ai fait  dans le but de dissocier le server de vos sauvegardes pour plus de **sécurité** et de **fléxibilité**. Le volume est monté en ext4 dans le répertoire `/mnt/vdb/`, il va vous permettre d'avoir un jeu de sauvegarde complétement indépendant de votre serveur Duplicity.

La commande suivante permet de sauvegarder un serveur de votre infrastructure depuis votre serveur de sauvegarde Duplicity et de stocker la sauvegarde sur le volume attaché a Duplicity:
~~~
ssh cloud@iPserverdistant -i ~/.ssh/yourkeypair.pem "duplicity  --exclude /proc --exclude /sys --exclude /tmp / sftp://cloud@DuplicityPrivateIP//mnt/vdb/ --ssh-option="-oIdentityFile=/home/cloud/.ssh/yourkeypair.pem""
~~~
Une passphrase vous sera demandée, celle ci est à trouver dans `/etc/duplicity/dup_vars.sh`.

**Dernière info:** Lors d'une restauration, afin que le système puisse écrire l'ensemble des informations, il est préférable de l'exécuter en tant qu'utilisateur `root`.

## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Vous pouvez commencer à élaborer votre plan de sauvegarde. Voici les points d'entrée utiles:

* `/etc/duplicity` : ensemble des clés & passphrase nécessaire au fonctionnement de Duplicity

* voici quelques sites d'informations afin d'aller plus loin :

    - http://duplicity.nongnu.org/
    - https://doc.ubuntu-fr.org/duplicity
    - https://help.ubuntu.com/community/DuplicityBackupHowto

-----
Have fun. Hack in peace.
