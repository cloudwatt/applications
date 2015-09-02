# 5 Minutes Stacks, Episode sept : GitLab

## Episode sept : GitLab

Pour ce septième episode, nous vous livrons Gitlab. Gitlab est un outil génial qui apporte la puissance et la fléxibilité à des applications telles que BitBucket et Github à vos serveurs personels. Il permet à quiconque de devenir maître à distance de leur propre dépôt Git et de contrôler / visualiser les modifications effectuées à ses projets par ses contributeurs en utilisant l’interface de GitLab (conçue par sa communauté dédiée).

En suivant ce tutoriel, vous obtiendrez une instance Ubuntu Trusty Tahr, pré-configurée avec GitLab sur le port https 443 (redirigé automatiquement depuis le port 80). Toutes les données de GitLab seront stockées dans un volume dédié adapté à vos besoins et que vous pourrez sauvegarder à la demande.
À partir du panneau d'administration intégré de GitLab, vous serez en mesure d'ajuster les contrôles d’accès ainsi que divers autres paramètres de votre instance Gitlab permettant à vous et votre équipe de bénéficier de toute la puissance de Git.


## Preparations

### Les versions

* GitLab (gitlab-ce) 7.14.0-ce.0 via omnibus

### Les pré-requis pour déployer cette stack

Ce devrait être la routine maintenant :

* un accès internet
* un shell Linux
* un [compte Cloudwatt](https://www.cloudwatt.com/authentification), avec une [paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)


### Taille de l'instance

Contrairement aux stacks précédentes, le type d'instance minimum que nous recommandons est une "Standard" (n1.cw.standard-1). Ceci est dû à l'espace mémoire minimum recommandé par GitLab. Il est possible de déployer Gitlab sur un plus petit gabarit, mais cela induirait probablement des conséquences inattendues.
La tarification est à l'usage (les prix à l'heure et au mois sont disponibles sur la [page Tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

En outre, notre stack GitLab est adaptée pour faire bon usage du stockage bloc Cinder. Cela garantit la protection de vos projets et vous permet de ne payer que pour l'espace que vous utilisez. La taille du volume peut être ajustée dans la console. La stack GitLab peut supporter des dizaines à des teraoctets d'espace de stockage.

Les paramètres de la stack sont bien sur modifiables à volonté.

### Au fait...

Vous avez peut-être remarqué quelques fichiers supplémentaires dans le répertoire. Le nouveau script `backup.sh` et le template heat `.restore` vous permettent de faire usage du stockage bloc Cinder par la création de volume de sauvegarde. Ainsi vous pouvez sauvegarder votre Gitlab et le restaurer à votre convenance en utilisant le template heat `.restore`.

La restauration d’un Gitlab à partir d’une sauvegarde peut être réalisée à partir de la [console] (# console). Pour cela, les sauvegardes doivent être initialisées avec notre script de sauvegarde et la restauration prend environ 5 minutes du début au plein retour de la fonctionnalité. [(En savoir plus sur la sauvegarde de votre GitLab ...)] (#backup)

D’autre part, comme d’habitude, si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version « lancement par la console » en cliquant sur [ce lien](#console)

## Tour du propriétaire

Une fois le répertoire cloné, vous trouvez, dans le répertoire `bundle-trusty-gitlab/`:

* `bundle-trusty-gitlab.heat.yml` : Template d'orchestration HEAT, qui va servir à déployer l'infrastructure nécessaire.
* `bundle-trusty-gitlab.restore.heat.yml` : Template d'orchestration HEAT. Il déploie l’infrastructure necessaire et restaure vos données depuis un backup !
* `backup.sh` : Script de création de sauvegarde. Ce script magique permet la sauvegarde de vos données dans un volume de stockage bloc prêt à l’emploi en cas de malheur (redéploiement en seulement 5 minutes)
* `stack-start.sh` : Script de lancement de la stack. C'est un micro-script pour vous économiser quelques copier-coller.
* `stack-get-url.sh` : Script de récupération de l'IP d'entrée de votre stack.

## Démarrage

### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis vous le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell. Votre mot de passe vous sera demandé.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

$ [whatever mind-blowing stuff you have planned...]
~~~

Une fois ceci fait, les outils ligne de commande OpenStack peuvent interagir avec votre compte Cloudwatt.

### Ajuster les paramètres

Dans le fichier `bundle-trusty-gitlab.heat.yml` vous trouverez en haut une section `parameters`. Le seul paramètre obligatoire à ajuster est celui nommé `keypair_name` dont la valeur `default` doit contenir le nom d'une paire de clés valide dans votre compte utilisateur.

C'est dans ce même fichier que vous pouvez ajuster la taille de l'instance, la taille du volume, et le type du stockage en jouant sur les paramètres `flavor`, `volume_size` et `volume_type`.

Par défaut, un réseau et un sous-réseau sont automatiquement créés. Ce comportement peut être modifié aussi en éditant le fichier ` bundle-trusty-gitlab.heat.yml`.


~~~ yaml
heat_template_version: 2013-05-23


description: All-in-one GitLab stack


parameters:
  keypair_name:
    default: my-keypair-name                <-- Indiquer ici votre paire de clés par défaut
    description: Paire de cles a injecter dans instance - Keypair to inject in instance
    label: Paire de cles SSH - SSH Keypair
    type: string

  flavor_name:
    default: n1.cw.standard-1               <-- Indiquer ici la taille de l’instance par défaut
    description: Type instance a deployer - Flavor to use for the deployed instance
    type: string
    label: Type instance - Instance Type (Flavor)
    constraints:
      - allowed_values:
          [...]

  volume_size:
    default: 10                             <-- Indiquer ici la taille du volume par défaut
    description: Size of Volume for GitLab Storage (Gigabytes)
    label: GitLab Volume Size
    type: number
    constraints:
      - range: { min: 10, max: 10000 }
        description: Volume must be at least 10 gigabytes

  volume_type:
    default: standard                       <-- Indiquer ici le type du volume par défaut
    description: Performance flavor of the linked Volume for GitLab Storage
    label: GitLab Volume Type
    type: string
    constraints:
      - allowed_values:
          - standard
          - performant

resources:
  network:                                  <-- Paramètres réseau
    type: OS::Neutron::Net

  subnet:                                   <-- Paramètres sous-réseau
    type: OS::Neutron::Subnet
    properties:
      network_id: { get_resource: network }
      ip_version: 4
      cidr: 10.0.1.0/24
      allocation_pools:
        - { start: 10.0.1.100, end: 10.0.1.199 }
[...]
~~~

### Démarrer la stack

Dans un shell, lancer le script `stack-start.sh` en passant en paramètre le nom que vous souhaitez lui attribuer :

~~~ bash
$ ./stack-start.sh GitCERN
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | GitCERN    | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~

Enfin, attendez **5 minutes** que le déploiement soit complet (vous pouvez utiliser la commande `watch` pour voir le statut en temps réel).

~~~ bash
$ watch heat stack-list
+--------------------------------------+------------+-----------------+----------------------+
| id                                   | stack_name | stack_status    | creation_time        |
+--------------------------------------+------------+-----------------+----------------------+
| xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | GitCERN    | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
+--------------------------------------+------------+-----------------+----------------------+
~~~

### Enjoy

Une fois tout ceci fait, vous pouvez lancez le script `stack-get-url.sh` en passant en paramètre le nom de la stack.

~~~ bash
$ ./stack-get-url.sh GitCERN
GitCERN http://70.60.637.17
~~~

qui va récupérer l'IP flottante attribuée à votre stack. Vous pouvez alors attaquer cette IP avec votre navigateur préféré et confirmer votre intérêt en **acceptant le certificat de sécurité**.


## Dans les coulisses

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour exécuter le script heat :

* démarrer une instance basée sur Ubuntu Trusty Tahr
* l'exposer sur Internet via une IP flottante
* démarrer, attacher et formater un volume de stockage pour Gitlab
* reconfigurer Gitlab pour que le stockage des données se fasse sur le volume et pour utiliser l’adresse IP flottante

<a name="console" />

### C’est bien tout ça, mais vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer un serveur GitLab:

1.	Allez sur le Github Cloudwatt dans le répertoire [applications/bundle-trusty-gitlab](https://github.com/cloudwatt/applications/tree/master/bundle-trusty-gitlab)
2.	Cliquez sur le fichier nommé `bundle-trusty-gitlab.heat.yml` ou `bundle-trusty-gitlab.restore.heat.yml` pour [restaurer depuis une sauvegarde](#backup))
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Entrez votre keypair dans le champ « keypair_name »
9.	confirmez la taille du volume de stockage (en Go) dans le champ « GitLab Volume Size »
10.	Choisissez la taille de votre instance parmi le menu déroulant « flavor_name » et cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée. Vous pourrez alors aller dans le menu « Instances » pour découvrir l’IP flottante qui a été générée automatiquement ou simplement recharger la page et allez dans l’onglet « vue d’ensemble ». Ne vous reste plus qu’à lancer votre IP dans votre navigateur.

C’est (déjà) FINI ! A vous de jouer maintenant.

<a name="backup" />

## Sauvegarde et Restauration

Sauvegarder votre travail semble une bonne idée, n’est-ce pas ? Nous avons développé une méthode vous permettant de sauvegarder votre travail rapidement et facilement.

~~~ bash
$ ./backup.sh GitCERN
~~~

Et 5 minutes plus tard, vous retrouvez votre environnement Gitlab.
La restauration est aussi simple que reconstruire une nouvelle stack mais cette fois avec le fichier heat `.restore.heat.yml`, et en indiquant l’ID de la sauvegarde que vous souhaitez restaurer. Vous pouvez voir la liste des sauvegardes dans la console dans l’onglet « Sauvegardes de Volume » du menu « Volume » ou par les lignes de commandes :

~~~ bash
$ cinder backup-list

+------+-----------+-----------+-----------------------------------+------+--------------+---------------+
|  ID  | Volume ID |   Status  |                Name               | Size | Object Count |   Container   |
+------+-----------+-----------+-----------------------------------+------+--------------+---------------+
| XXXX | XXXXXXXXX | available | gitlab-backup-2025/10/23-07:27:69 |  10  |     206      | volumebackups |
+------+-----------+-----------+-----------------------------------+------+--------------+---------------+
~~~

Toutefois, notez que même si cette méthode permet de restaurer facilement votre service, Gitlab ne prendra pas en compte le changement d’adresse IP. Votre paire de clés reste valide mais vous devez vous assurer de **corriger l’adresse IP d’accès à Gitlab** avant de continuer votre travail.


## So watt?

Ce tutoriel a pour but d'accélérer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en ssh via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Les chemins intéressants sur votre machine :

- `/etc/gitlab/gitlab-secrets.json`: Secret tokens, keys, and salts unique to each GitLab
- `/etc/gitlab/gitlab-volume.sh`: Script run upon reboot to remount the volume and verify GitLab is ready to function again
- `/etc/gitlab/gitlab.rb`: Omnibus GitLab's master settings file
- `/etc/gitlab/ssl/`: GitLab's '.key' and '.crt' for HTTPS
- `/var/opt/gitlab/`: GitLab stores all data here, and `/mnt/vdb/gitlab/` is mounted here
- `/dev/vdb`: Volume mount point
- `/mnt/vdb/`: `/dev/vdb` mounted here
- `/mnt/vdb/gitlab/`: Mounts onto `/var/opt/gitlab/` and contains all of GitLab's data
- `/mnt/vdb/gitlab/.gitlab-secrets.json`: Copy of GitLab's secrets in volume for safekeeping and restoration
- `/mnt/vdb/stack_public_entry_point`: Contains last known IP address, used to replace IP address in all locations when it changes

Quelques ressources qui pourraient vous intéresser :

* [GitLab NGinx Settings](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/629def0a7a26e7c2326566f0758d4a27857b52a3/doc/settings/nginx.md)
* [GitLab Settings Template/Example](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template)
* [Doc for Omnibus GitLab](http://doc.gitlab.com/omnibus/)
* [Doc for GitLab CE](http://doc.gitlab.com/ce/)


-----
Have fun. Hack in peace.
