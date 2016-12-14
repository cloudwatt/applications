# Innovation Beta: MyCloudManager

 ![logo](img/mycloudmanager.png)


La troisième version de MyCloudManager (version Beta) est maintenant disponible. Celle-ci a pour but de vous apporter un ensemble d'outils afin **d'unifier, d'harmoniser et monitorer votre tenant**. En effet celui-ci renferme un lot d'applications variées qui a pour vocation de vous aider dans la gestion au jour le jour de vos instances **Linux**:
* Monitoring et Supervision
* Log management
* Planificateur de taches
* Miroir Antivirus
* Gestionnaire de répertoire applicatif
* Backup full ou incremental
* Synchronisation de temps
* Gestion multi-tenant, multi-région

MyCloudManager a entièrement été développé par l'équipe CAT - Cloudwatt Automation Team.
* MyCloudManager est entièrement HA (Haute Disponibilité)
* Il repose sur une instance CoreOS
* L'ensemble des applications se déploient dans des conteneurs Docker orchestrés par Kubernetes
* L'interface utilisateur est developpée en React
* De plus vous pouvez installer ou configurer, depuis l'interface graphique, l'ensemble des applications sur vos instances via des playbooks Ansible
* Afin de sécuriser au maximum votre MyCloudManager, aucun port n'est exposé sur internet mis à part le port 22 pour le management des instances de la stack ainsi que le port 1723 pour l'accès VPN PPTP.

## Préparations

### Les pré-requis

 * Un accès internet
 * Un shell linux
 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)


### Initialiser l'environnement

Munissez-vous de vos identifiants Cloudwatt, et cliquez [ICI](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
Si vous n'êtes pas connecté, vous passerez par l'écran d'authentification, puis le téléchargement d'un script démarrera. C'est grâce à celui-ci que vous pourrez initialiser les accès shell aux API Cloudwatt.

Sourcez le fichier téléchargé dans votre shell et entrez votre mot de passe lorsque vous êtes invité à utiliser les clients OpenStack.

 ~~~ bash
 $ source COMPUTE-[...]-openrc.sh
 Please enter your OpenStack Password:
 ~~~

Une fois ceci fait, les outils de ligne de commande d'OpenStack peuvent interagir avec votre compte Cloudwatt.


## Installer MyCloudManager

### Le 1-clic

MyCloudManager se lance par le **1-clic** de **Cloudwatt** via la page web
[Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt. Choisissez l'application MyCloudManager et appuyez sur **DEPLOYER**.

Après avoir entré vos login/password de votre compte, le wizard de lancement apparait :

![oneclick](img/oneclick.png)

Comme vous avez pu le constater le wizard du 1-Clic vous demande de saisir votre mot de passe Openstack. En effet ces informations vont permettre à la stack de sauvegarder la configuration du cluster dans un conteneur Swift sur votre tenant.

Par défaut, le wizard propose un déploiement de trois instances de type "n2.cw.standard-2" qui seront les instances `node` composant un cluster de machines basées sur CoreOS. Elles porteront l'ensemble des *"pods" (applications)* déployés sur la stack ainsi que l'ensemble des applications proposées par MyCloudManager.

Ces instances `node` doivent être taillées en fonction de l'utilisation que vous souhaitez faire de MyCloudManager et de la charge que vous estimez car, comme vous le savez, il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

De plus deux noeuds de type 'storage' seront déployés par la stack. Ils porteront les services de stockage par Ceph.
Ceph est un logiciel permettant la gestion de volumes, ici `cinder`, afin de persister les données applicatives en cas de crash d'un composant du cluster.

Maintenant que vous connaissez l'ensemble des ressources composant la stack, vous pouvez appuyer sur **LANCER**.

Le **1-clic** s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer l'ensemble des instances du cluster basée sur CoreOS,
* lancer le conteneur **toolbox-backend**,
* lancer le conteneur **toolbox-frontend**,
* lancer le conteneur **rethinkdb**,
* lancer le conteneur **rabbitmq**,
* lancer le conteneur **traefik**

La stack se crée automatiquement. Vous pouvez en voir la progression en cliquant sur son nom ce qui vous menera à la console Horizon. Quand tous les modules deviendront « verts », la création sera terminée.

Attendez **10 vraies minutes** que l'ensemble du cluster soit complètement initialisé.

![startopo](img/stacktopo.png)

### Finaliser l'accès VPN

Afin d'avoir accès à l'ensemble des fonctionnalités, nous avons mis en place une connexion VPN.

Voici la démarche à suivre :

* Dans un premier temps, récupérez les informations de sortie de votre stack, à savoir une des FloatingIP du cluster ainsi que les login et mot de passe fournis en sortie de la stack.

![stack](img/sortie-stack.png)

#### Windows 7


* Il faut maintenant créer une connexion VPN depuis votre poste, rendez-vous dans "le panneau de configuration > Tous les Panneaux de configuration > Centre Réseau et partage". Cliquez ensuite sur "Configurer une nouvelle connexion ..... "

![start](img/startvpn.png)
![vpn](img/vpn.png)
![internet](img/internet.png)

* Entrez à présent les informations récupérées en sortie de la stack: dans un premier temps récupérer une des *FloatingIP* du cluster, puis le *login* et ensuite le *mot de passe* fournis.

![info](img/infoconnexion.png)
![login](img/loginmdp.png)

Après avoir suivi cette procédure vous pouvez maintenant lancer la connexion VPN.

![vpnstart](img/launchvpn.png)

-----
#### Windows 10

* rendez-vous dans Paramètres > RESEAU ET INTERNET > Réseau privé virtuel

![configwin10](img/configwin10.png)


* Entrez à présent les informations récupérées en sortie de la stack : dans un premier temps une des *FloatingIP* du cluster, puis le *login* et ensuite le *mot de passe* fournis. Vous pouvez aussi préciser le type de réseau privé virtuel en sélectionnant le protocole PPTP, cela accélérera la création du VPN.

![configipwin10](img/configipwin10.png)
![configuserwin10](img/configuserwin10.png)


Après avoir suivi cette procédure vous pouvez maintenant lancer la connexion VPN.

![vpnstart](img/connexwin10.png)

-------


Vous pouvez dès lors accéder à l'interface d'administration de MyCloudManager via l'url **http://ip-privée-instance-cluster:30000** (exemple: **http://10.1.1.10:30000**) et commencer à en tirer tout le bénéfice.

C’est (déjà) FINI !


## Enjoy

L'accès à l'interface et aux différents services se fait via l'adresse **IP**.
Vous pourrez accéder aux différentes interfaces web des applications en cliquant sur **GO** ou via une requête URL (par exemple : http://10.1.1.10:30601/).

Comme précisé précédemment des volumes de stockage bloc Cinder ont été provisionné au sein du cluster afin de sauvegarder l'ensemble des **datas** des conteneurs de l'application. Cela permet à notre stack d'être beaucoup plus robuste. Pour information l'ensemble des données contenu dans `Ceph` est accessible depuis n'importe quelle machine du cluster.

### Présentation de l'interface

Voici l'accueil de MyCloudManager: chaque vignette représente une application prête à être lancée. Afin d'être le plus scalable et flexible possible, les applications de MyCloudManager sont des conteneurs Docker.

![accueil](img/accueil.png)

Grâce au menu présent en haut en gauche de la page, vous pouvez vous déplacer dans les différentes sections de MyCloudManager. Nous allons vous les détailler par la suite.
* Apps : liste des applications
* Instances : liste des instances visibles de MyCloudManager
* Tasks : ensemble des taches en cours ou terminées
* Audit : liste des actions effectuées
* Backups: liste l'ensemble des backups avec MyCloudManager
* Volumes: Liste l'ensemble des volumes Ceph du cluster
* Networks: Gère les différents tenants ou régions utilisés dans MyCloudManager
* My Instances > Console : accès à la console Horizon
* My Account > Cockpit : accès à mon compte
* Support: permet l'envoi de mail aux équipes Support ou Cloud Coach de Cloudwatt


![menu](img/menu.png)

L'ensemble des applications présentes dans la section **Apps** sont paramétrables grâce au bouton **Settings** ![settings](img/settings.png) présent sur chaque vignette.

Comme vous pouvez le constater, nous les avons séparés en différentes sections.
 ![params](img/params.png)

Dans la section **Infos** vous allez retrouver une présentation de l'application avec quelques liens utiles sur l'application concernée.
![appresume](img/appresume.png)


Dans la section **Parameters** vous pouvez ici modifier le fichier de configuration qui sera lancé à la création du conteneur, disponible uniquement pour Rundeck. Pour l'ensemble des applications la configuration se fera directement depuis l'interface.
![paramapp](img/paramapp.png)


Afin d'identifier les applications lancées de celles qui ne le sont pas, nous avons mis en place un code couleur: une application démarrée sera entourée d'un **halo vert** et d'un **halo jaune** pendant l'installation.
![appstart](img/appstart.png)


Les **tasks** permettent un suivi des actions effectuées sur MyCloudManager. Elles sont indiquées en temps relatif.

![tasks](img/tasks.png)

Il vous est possible d'annuler une tache en attente en cas d'erreur dans le menu **Tasks** en cliquant sur ![horloge](img/horloge.png) ce qui vous affichera ensuite ce logo ![poubelle](img/poubelle.png).

Nous avons mis en place une section **Audit** afin que vous puissiez voir l'ensemble des actions effectuées sur chacune de vos instances et un export en Excel (.xlsx) si vous souhaitez effectuer un post-processing ou garder ces informations pour des raisons de sécurité via le bouton ![xlsx](img/xlsx.png).

![audit](img/audit.png)


Les menus **My Instances** et **My Account** servent respectivement à accéder à la console Horizon Cloudwatt et à la gestion de votre compte utilisateur (vous y trouverez par exemple vos factures) via l'interface Cockpit.

La section **Support** va vous permettre, comme son nom l'indique, de contacter notre service Support en cas de demande ou incident sur MyCloudManager. Vous pouvez aussi contacter un **CloudCoach** afin d'avoir de plus amples informations en ce qui concerne notre écosysteme ou la faisabilité de vos différents projets que vous souhaitez porter sur le cloud public Cloudwatt.

Email :
* Choisissez votre besoin **Email Support** ou **Contact a Cloud Coach**,
* Le champ **type** va vous permettre de choisir entre **demande** ou **incident**,
* Le champ **Reply Email Address** va permettre à notre service Support ou à nos Cloud Coach d'avoir votre adresse afin de pouvoir vous répondre,
* Le champ **Request/Problems encountered** constitue le corps du mail ou nous vous demandons d'expliciter le plus précisement possible votre demande

![supportemail](img/supportemail.png)

L'envoi du mail se fait via le bouton ![sendmail](img/sendmail.png). Celui-ci devient ![mailsend](img/mailsend.png) si le mail est correctement envoyé ou ![mailfail](img/mailfail.png) si le serveur mail a rencontré une erreur pendant l'envoi.

### Gestion des volumes

Afin de vous faciliter le plus possible la gestion de vos ressources Cloudwatt, nous vous avons créé une interface de gestion des volumes que vous retrouverez dans le menu de votre MyCloudManager.

Dans cette interface vous trouverez le détail de vos différents volumes Ceph.

![volumes](img/volumes.png)

Vous pouvez les redimensionner selon votre besoin en cliquant sur le bouton resize ![resize](img/resize.png)

A savoir: la vue que vous avez sur cette interface n'est autre que l'ensemble des volumes Ceph. En aucun cas cette page ne permet de redimensionner un volume de stockage Cinder. Cette partie reste possible mais il faudra le faire depuis la console Horizon de Cloudwatt.

### Monitoring du cluster


Celui-ci va vous permettre de voir l'ensemble de l'activité du cluster et donc de vous assurez que votre MyCloudManager est totalement fonctionnel.

Nous vous avons fournis par défaut un ensemble de dashboards qui vous permettront d'avoir une vue d'ensemble de l'activité de votre cluster, mais ils vous permettront aussi de descendre beaucoup plus bas dans les couches pour analyser en profondeur le comportement de votre MyCloudManager.

Vous pouvez y accéder, si vous avez choisi l'option monitoring au lancement de votre stack, depuis n'importe quelle adresse privée du cluster sur le port 31000 (ex: http://10.1.1.10:31000)

**Monitoring Ceph**
![cephdashboard](img/cephdashboard.png)

**Monitoring Docker**
![dockerdashboard](img/dockerdashboard.png)

### Ajouter un nouveau réseau à monitorer

Pour ajouter un tenant ou une nouvelle région à monitorer, vous devez vous rendre dans la partie `Network` du menu de votre MyCloudManager.

Pour ajouter un tenant ou une région à monitorer il vous faudra cliquer sur le bouton ![plus](img/plus.png).

Entrez à présent l'ensemble des informations du tenant comme présenté ci-dessous :

![tenantadd](img/tenantadd.png)

A savoir, une fois que vous avez entré votre OpenStack Username ainsi que votre OpenStack Password et la region souhaitée, il vous suffit de cliquer sur le bouton ![refresh](img/refresh.png) afin que MyCloudManager aille interroger l'API Cloudwatt pour récupérer l'ensemble des informations dont vous avez besoin pour remplir les paramètres suivants.

![networkinfo](img/networkinfo.png)

Définissez sur quel réseau vous souhaitez attacher votre MyCloudManager, ainsi que le security groupe et la keypair qui vont s'appliquer à l'instance CoreOS de type "s1.cw.small-1" qui va se déployer dans le tenant en question. Car, oui, MyCloudManager à besoin d'une instance de type `worker` dans le tenant de destination afin de pouvoir communiquer avec les machines qui sont rattachées au réseau.

**Attention:**
Le réseau sur lequel vous attachez votre instance `worker` doit avoir accès à internet. En effet comme vous le savez l'ensemble des fonctionnalités de MyCloudManager repose sur des conteneur Docker. Ceux-ci étant hébergés sur le hub.docker il faut que l'instance puisse les télécharger.

Pour faire communiquer votre instance `worker` avec le reste du monde, vous avez deux possibilités, il faut que le SNAT soit activé sur votre routeur neutron ou que votre instance `worker` ait une adresse ip publique.

Pour activer le snat, il faut lors de la création de votre routeur dans la console horizon Cloudwatt, spécifier le réseau `public` sur l'interface externe de votre routeur, comme ci-dessous :

![networkpublic](img/networkpublic.png)

Vous n'avez rien compris ? Pas de panique, nous vous avons mis à disposition une stack heat afin de faire l'ensemble des actions:

* Création d'une keypair,
* Création d'un réseau,
* Création d'un routeur ayant accès à internet via le réseau public de votre tenant,

Vous pourrez la retrouver ![ici](https://github.com/cloudwatt/applications/tree/master/blueprint-mystart-snat)

Une fois les informations entrées, une ligne avec les informations du tenant doit apparaître comme ceci :

![networkadd](img/networkadd.png)

Il vous reste plus qu'à activer le **toggle**![toggle](img/toggle.png) de couleur jaune pour déployer l'instance `worker` dans le tenant de destination.

Lorsque l'instance s'est correctement créée et a rejoint le cluster, le **toggle**![toggle](img/toggle.png) passe au bleu et le statut vous donne l'ip de ce nouveau noeud.

![networkstatus](img/networkstatus.png)

Voila, vous venez en quelques clics d'ajouter la gestion d'une nouvelle région ou d'un nouveau tenant au cluster MyCloudManager !

#### Supprimer un réseau

Nous vous avons aussi donné la possibilité de supprimer la visibilité d'une région ou un tenant dans MyCloudManager. Pour cela rien de plus simple, il vous suffit de cliquer sur le **toggle** de couleur bleu.
Cela aura pour effet de supprimer l'instance `worker` de votre tenant. Une fois ceci fait il ne vous restera plus qu'à supprimer la ligne concernée grâce au bouton ![trash](img/trash.png).

### Ajouter des instances à MyCloudManager

Afin d'ajouter des instances à MyCloudManager, 3 étapes :

  1. Attacher votre instance au routeur du `worker` ajouté dans le tenant
  2. Lancer la commande curl ou le cloudconfig selon votre besoin
  3. Lancer les services souhaités


#### 1. Attacher son instance au routeur de MyCloudManager

 ~~~bash
 $ neutron router-interface-add $Worker_ROUTER_ID $Instance_subnet_ID
 ~~~

Une fois ceci effectué vous êtes maintenant dans la capacité d'ajouter votre instance à MyCloudManager afin de l'instrumentaliser.


#### 2. Lancer le script d'attachement

Dans MyCloudManager, aller dans le menu **Instances** et cliquer sur le bouton ![bouton](img/plus.png) en bas à droite.

Dans un premier temps choisissez dans le cartouche le réseau sur lequel la future instance sera attachée afin que l'on vous donne les bonnes commandes à copier sur l'instance.

Nous proposons une commande de type **Curl** ainsi qu'un **Copy to Clipboard** permettant de lancer un script à la création de l'instance.
![addinstance](img/addinstance.png)

Une fois le script appliqué sur l'instance choisie, elle apparait dans le menu **Instances** de votre MyCloudManager avec la possibilité de déployer les applications que vous avez précédemment déployées.

![appdisable](img/appdisable.png)

**Astuce :** Si vous souhaitez créer une instance via la console Horizon Cloudwatt et la déclarer **directement** dans votre MyCloudManager, il vous faut sélectionner le réseau de MyCloudManager ainsi que le security group de MyCloudManager et coller la commande précedemment copiée via le **Copy to Clipboard** dans le champ Script personnalisé.

![networkchoose](img/networkchoose.png)

![launchinstance](img/launchinstance.png)

#### 3. Lancer les services souhaités sur l'instance

Afin de vous aider au maximum, nous avons créé des playbooks Ansible permettant d'installer et configurer automatiquement les agents des différentes applications sur vos instances.

Pour cela il suffit de cliquer sur la ou les application(s) que vous souhaitez installer sur votre machine. Le playbook Ansible concerné va s'installer automatiquement.
Ceci fait, le logo de l'application passe en couleur, ce qui vous permet, d'un simple coup d'oeil, d'identifier les applications en fonctionnement sur vos instances.

![appenable](img/appenable.png)

### Backup des instances

La section **Backups** vous permet de sauvegarder l'ensemble des instances rattachées à MyCloudManager. Le backup peut être effectué de deux façons, via un **snapshot** ou via **duplicity** que l'on a appelé **soft**.
* Le **backup snapshot** va prendre une photo de l'instance au moment ou vous avez schedulé le backup. Vous pourrez ensuite le retrouver dans la liste de vos images sur votre tenant.
* Le **backup soft** va lui déployer un conteneur duplicity et sauvegarder l'ensemble du contenu du ou des répertoires que vous avez sélectionné (`/data`ou `/config`) dans un conteneur **swift** que vous pourrez également retrouver dans la partie **containers** de votre tenant (stockage objet).
Si vous souhaitez sauvegarder un groupe de serveurs, il vous faudra alors les sélectionner lors de la création du backup.
En ce qui concerne la programmation des backups, plusieurs choix s'offre à vous :

* **Daily**: un backup par jour à l'heure souhaitée,
* **Weekly**: un backup par semaine au jour et à l'heure souhaité,
* **Montly**: un backup par mois à la date et à l'heure souhaitée.

Afin de commencer une nouvelle configuration de backup, il faut cliquer sur le bouton![bouton](img/plus.png)

Donner un nom à votre configuration de backup :
![newconfig](img/backupinfo.png)

Sélectionner les serveurs que vous voulez ajouter :
![Backupselectsrv](img/selectsrv.png)

Définissez maintenant **quand** et **comment** le backup de ces serveurs sera fait :

* Backup Snapshot : Prend une "photo" de votre instance et la dépose dans votre bibliothèque d'image sur votre tenant (attention: un snapshot s'éxecute à froid comme indiqué dans cet article [Fin du Hot Snapshot, place au Cold Snapshot pour une sauvegarde plus consistante !](https://dev.cloudwatt.com/fr/blog/fin-du-hot-snapshot-place-au-cold-snapshot.html) )

![bkpsnapshot](img/bkpsnapshot.png)

* Backup Soft : Copie l'intégralité des répertoires cochés dans un conteneur de stockage objet swift

![bkpsoft](img/bkpsoft.png)


Une fois que vous avez cliqué sur le bouton FINISH votre configuration est à présent sauvegardée :

![bkpsvg](img/bkpsvg.png)

Vous pouvez à tout moment modifier la configuration d'un backup via le bouton **editer** ![bkpedit](img/bkpedit.png) qui vous permet d'ajouter ou de supprimer des serveurs, de modifier le ou les répertoires à sauvegarder ainsi que le moment où ce backup sera exécuté.  Le bouton **supprimer** ![bkpdelete](img/bkpdelete.png), quant à lui, permet de supprimer complètement le job de backup selectionné.

#### Qui dit backup dit restauration :

Afin de restorer un backup qu'il soit **soft** ou **snapshot** la démarche reste là même. Il faut vous rendre dans le menu **instances** de votre MycloudManager. Comme vous pouvez le constater un nouveau bouton ![restore](img/restore.png) est apparu sur l'ensemble des serveurs qui ont été sauvegardés.

Lorsque vous cliquez dessus un pop-up s'ouvre et vous pouvez maintenant choisir, via le menu déroulant, le backup que vous voulez restorer. ![chooserestore](img/chooserestore.png)

Une fois cette action effectuée, si votre backup était de type **snapshot**, l'image selectionnée va être restorée à la place de l'instance en cours, sinon pour le backup **soft** l'integralité des dossiers sélectionnés seront restaurés dans le répertoire `restore` de votre instance.

## Les Services de MyCloudManager fournis par les applications

Dans cette section, nous allons vous présenter les différents services de MyCloudManager.

### Monitoring et Supervision
Nous avons choisi d'utiliser *Zabbix*, l'application la plus en vogue pour le monitoring, supervision et alerting.
L'application Zabbix est un logiciel libre permettant de **surveiller l'état de divers services réseau, serveurs et autres matériels réseau** mais aussi des **applications et logiciels** portés sur les instances surveillées; et produisant des graphiques dynamiques de consommation des ressources. Zabbix utilise MySQL, PostgreSQL ou Oracle pour stocker les données. Selon l'importance du nombre de machines et de données à surveiller, le choix du SGBD influe grandement sur les performances. Son interface web est écrite en PHP et fournit une vision temps réel sur les métriques collectées.

Pour aller plus loin voici quelques liens utiles:
  * http://www.zabbix.com/
  * https://www.zabbix.com/documentation/3.0/start

### Log Management
Nous avons choisi *Graylog* qui est le produit du moment pour la gestion des logs; en voici une petite présentation :
C'est une plateforme open source de **gestion de logs** capable de manipuler et présenter les données à partir de pratiquement n'importe quelle source. Ce conteneur est celui proposer officiellement par les équipes Graylog.
  * L'interface graphique web de Graylog est un outil puissant qui permet à quiconque de manipuler la totalité de ce que Graylog a à offrir grâce à cette application Web intuitive et attrayante.
  * Le cœur de Graylog est son moteur. Le serveur Graylog interagit avec tous les autres composants à l'aide d'interfaces API REST de sorte que chaque composant du système peut être adapté sans pour autant compromettre l'intégrité du système dans son ensemble.
  * Des résultats de recherche en temps réel quand vous les voulez et comment vous les voulez: Graylog est en mesure de vous fournir ceci grâce à la puissance éprouvée d'ElasticSearch. Les nœuds ElasticSearch donnent à Graylog la vitesse qui en fait un vrai plaisir à utiliser.

Bénéficiant de cette architecture impressionnante ainsi que d'une vaste bibliothèque de plugins, Graylog se place comme une solution solide et polyvalente de **gestion des logs à la fois des instances** mais aussi des **applications et logiciels** portés sur les instances surveillées.

Pour aller plus loin voici quelques liens utiles:
  * https://www.graylog.org/
  * http://docs.graylog.org/en/1.2/pages/getting_started.html#get-messages-in
  * http://docs.graylog.org/en/1.3/pages/architecture.html
  * https://www.elastic.co/products/elasticsearch
  * https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/


### Planificateur de taches
Pour répondre à ce besoin nous avons choisi d'utiliser *Rundeck*.
L'application Rundeck vous permet de **programmer et d'organiser l'ensemble des taches** que vous voulez déployer régulièrement sur  votre tenant via son interface web.

Dans cette version de MyCloudManager, nous avons automatisé la sauvegarde de vos serveurs comme nous l'avons vu dans le cadre du *bundle* Duplicity.

Pour aller plus loin voici quelques liens utiles:
  * http://rundeck.org/
  * http://blog.admin-linux.org/administration/rundeck-ordonnanceur-centralise-opensource-vient-de-sortir-sa-v2-0
  * http://dev.cloudwatt.com/fr/blog/5-minutes-stacks-episode-vingt-trois-duplicity.html


### Miroir Antivirus
Cette application est un serveur Ngnix. Un script *CRON* va s'exécuter chaque jour afin d'aller chercher la dernière définition des **virus** distribuées par *ClamAV*. Le paquet récupéré sera exposé à vos instances via Ngnix ce qui vous permettra d'avoir des clients **ClamAV** à jour sans que vos instances n'aient forcément accès à internet.

Pour aller plus loin voici quelques liens utiles:
  * https://www.clamav.net/documents/private-local-mirrors
  * https://github.com/vrtadmin/clamav-faq/blob/master/mirrors/MirrorHowto.md


### Gestionnaire de répertoire applicatif
Nous avons choisi d'utiliser *Artifactory*.
Artifactory est une application pouvant exposer n'importe quel type de répertoire via un serveur Ngnix. Ici, notre volonté est de vous proposer une application pouvant **exposer un répertoire** à l'ensemble de vos instances.

Pour aller plus loin voici quelques liens utiles:
  * https://www.jfrog.com/open-source/
  * https://www.jfrog.com/confluence/display/RTF/Welcome+to+Artifactory


### Synchronisation de temps
Nous avons choisi d'utiliser NTP.
Le conteneur NTP est ici utilisé afin que l'ensemble de vos instances n'ayant pas accès à internet puissent être synchronisées à la même heure et aient accès à un **serveur de temps**.

Pour aller plus loin voici quelques liens utiles:
  * http://www.pool.ntp.org/fr/


## Les versions

### MyCloudManager **v3** (Beta)

  - CoreOS Stable 1010.6
  - Docker 1.10.3
  - Kubernetes 1.3
  - Zabbix 3.0
  - Rundeck 2.6.2
  - Graylog 2.0
  - Artifactory 4.9.1
  - Nginx 1.11.2
  - SkyDNS 2.5.3a
  - Etcd 2.0.3

### Liste des distributions Linux supportées par MyCloudManager

* Ubuntu 16.04
* Ubuntu 14.04
* Debian Jessie
* Debian Wheezy
* CentOS 7.2
* CentOS 7.0
* CentOS 6.7

### Configuration des applications (par defaut)

Comme expliqué précédemment nous vous avons laissé la possibilité via le bouton **Settings** ![settings](img/settings.png) présent sur chaque vignette, de saisir l'ensemble des paramètres applicatifs au lancement du conteneur. Cependant le login et le mot de passe ne peuvent pas être changé partout, il faudra le faire à l'intérieur de l'application une fois celle-ci lancée.

Login et mot de passe par défaut des applications MyCloudManager:
* Zabbix - Login : **Admin** - Mot de passe : **zabbix**
* Graylog - Login : **admin** - Mot de passe : **admin**
* Rundeck - Login : **admin** - Mot de passe: **admin**

Les autres applications n'ont pas d'interface web, donc pas de login/mot de passe, excepté **Artifactory** qui n'a pas d'authentification.

### Exemples de déploiement

#### Mono-tenant, Mono-region

![monotenant](img/monotenant.png)

#### Mono-tenant, Multi-region

![mutli-region](img/multiregion.png)

#### Multi-tenant, mutli-region

![multitenant](img/multitenant-multiregion.png)

## So watt  ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `core` par défaut).

Vous pouvez accéder à l'interface d'administration de MyCloudManager via l'url **[MyCloudManager](http://10.1.1.10:30000)**

## Et la suite ?

Cet article permet de vous familiariser avec cette nouvelle version de MyCloudManager. Elle est mise à la disposition de tous les utilisateurs Cloudwatt en **mode Beta** et donc pour le moment gratuitement.

L'intention de la CAT (Cloudwatt Automation Team) est de fournir des améliorations sur une base bimestrielle (tous les 2 mois). Dans notre roadmap, nous prévoyons entre autre :

* l'instrumentalisation d'instances Windows
* une version francaise,
* bien d'autres choses

Des suggestions d'améliorations ? Des services que vous souhaiteriez voir ? N'hésitez pas à nous contacter [apps.cloudwatt@orange.com](mailto:apps.cloudwatt@orange.com)

-----
Have fun. Hack in peace.

The CAT
