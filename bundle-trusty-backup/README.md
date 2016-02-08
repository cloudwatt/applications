# 5 Minutes Stacks, épisode 23 : Duplicity #

## Episode 23 : Duplicity

![logoduplicity](http://3.bp.blogspot.com/-XGwKwPUH8wM/UPKzagbzUmI/AAAAAAAABoI/XQf7Of5FXts/s1600/blog-domenech-org-ubuntu-deja-dup-amazon-web-services-s3-logo.png)

L'utilitaire duplicity est un outil en **ligne de commande** permettant d'effectuer des sauvegardes incrémentielles de fichiers et dossiers.

Il effectue la sauvegarde en créant des archives TAR chiffrées avec GnuPG. Ces archives sont alors envoyées dans un répertoire de sauvegarde local ou distant – les protocoles distants pris en charge sont FTP, SSH/SCP, Rsync, WebDAV/WebDAVs et Amazon S3. Puisque duplicity repose sur librsync, les sauvegardes incrémentielles sont économes en espace de stockage : seules les parties modifiées des fichiers sont prises en considération.

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

 Une fois le dépôt cloné, vous trouverez le répertoire `bundle-trusty-backup/`

 * `bundle-trusty-backup.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.
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
 Dans le fichier `bundle-trusty-backup.heat.yml` vous trouverez en haut une section `parameters`. Les seuls paramètres obligatoire sont celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur et celui du `passcode` qui va permettre de chiffrer vos backup.
 C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance par le paramètre `flavor`.

 ~~~yaml
 heat_template_version: 2013-05-23


description: All-in-one Backup stack


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
        - n2.cw.standard-12
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

  * démarrer une instance basée sur Ubuntu trusty, pré-provisionnée avec la stack backup,
  * l'exposer sur Internet via une IP flottante.

![Backuplogo](http://www.nordic-vikings.net/wp-content/uploads/2013/06/linuxbackup.jpg)

### C’est bien tout ça, mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur DUPLICITY:

1.	Allez sur le Github Cloudwatt dans le répertoire applications/bundle-trusty-backup
2.	Cliquez sur le fichier nommé bundle-trusty-backup.heat.yml
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

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : vous avez votre duplicity !

### Enjoy

  Une fois tout ceci fait vous pouvez vous connecter sur votre serveur en SSH en utilisant votre keypair préalablement téléchargé sur votre poste,

  Vous etes maintenant en possession d'un serveur de backup,
  Celui ci est capable de générer des sauvegarde chiffrer et de les copier ou bon vous semble, duplicity est capable de faire des sauvegarde full et incrémentale.
  Attention si vous faites de l'incrémentale Duplicity à besoin de l'ensemble des sauvegarde incrémentales depuis la dernière full pour être réstaurées,

  un conseil faites une full par semaine et ensuite une incrémentale par jour afin d'avoir un jeu de sauvegarde propre.

  Par défaut l'ensemble des codes et passphrase générés par l'application sont stockés dans `/etc/duplicity`.

  Afin d'automatiser les sauvegardes vous pouvez utiliser CRON installé par défaut sur le serveur. Celui-ci va vous permettre de scheduler vous sauvegarde pour que vous n'ayez plus à vous en occuper.

  La génération de sauvegardes à la fois incrémentales et chiffrées, y compris pour les bases de données, font de duplicity une solution de backup idéale pour l’auto-hébergement.

  Lancer la commande de backup (local):

~~~
duplicity /your_directory file:///var/backups/duplicity/ --include-globbing-filelist filelist.txt --exclude '**'
~~~
Lancer la commande de backup sur un serveur distant:
~~~
duplicity --encrypt-key key_from_GPG --exclude files_to_exclude --include files_to_include path_to_back_up sftp://root@backupHost//remotebackup/duplicityDroplet
~~~

Lancer la commande de restaure :

~~~
duplicity restore file:///var/backups/duplicity/ /any/directory/
~~~  

Vous pouvez sauvegarder une base de donnée en exportant la base puis en sauvegardant le .sql:

~~~
mysql -uroot -ppassword --skip-comments -ql my_database > my_database.sql
~~~

Pour plus de sécurité vous pouvez/devez exportez vos backup sur une autre machine avec la commande rcync:

~~~
rsync -rvP --partial-dir=/my/local/tmpbackup --ignore-existing --stats -h server:/var/backups/duplicity/ /my/local/backup/
~~~
## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Vous pouvez commencer a élaborer votre plan de sauvegarde voici les points d'entrée utiles:

* `/etc/duplicity` : ensemble des clés & passphrase nécessaire au fonctionnement de duplicityDroplet

* voici quelques sites d'informations afin d'aller plus loin :

    - http://duplicity.nongnu.org/
    - https://doc.ubuntu-fr.org/duplicity
    - https://help.ubuntu.com/community/DuplicityBackupHowto

-----
Have fun. Hack in peace.
