# Blueprint : Kubernetes HA #

![Kubernetes](img/kube.png)

Lorsque vous travaillez avec beaucoup de conteneurs, il devient vite indispensable de les orchestrer.

C'est là que Kubernetes entre en jeu.

Kubernetes est un orchestrateur de conteneur Docker et Rkt initié par Google grâce à son savoir-faire en la matière.

Cette stack va vous permettre de déployer un cluster de production en quelques clicks.

## Preparations

### Les versions
  - CoreOS Stable 1010.6
  - Docker 1.10.3
  - Kubernetes 1.3.6

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent:
 
 * Un accès internet

 * Un shell linux

 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)

 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)

 * Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance
Par défaut, le script propose un déploiement sur une instance de type "standard-1" (n1.cw.standard-1). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version **"Je lance en 1-clic"** ou **"Je lance avec la console"** en cliquant sur [ce lien](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `blueprint-coreos-kubernetes-ha/`

* `blueprint-kubernetes-ha.heat.yml`: Template d'orchestration HEAT, qui servira à déployer l'infrastructure nécessaire.

* `stack-start.sh`: Script de lancement de la stack, qui simplifie la saisie des parametres.

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

### Démarrer la stack

 Dans un shell, lancer le script `stack-start.sh` :

 ~~~ bash
 $ ./stack-start.sh
 ~~~
 
 Le script va vous poser plusieurs questions, puis, une fois la stack créer vous afficher deux lignes :

 ~~~ bash
scale_dn_url: ...
scale_up_url: ...
 ~~~

scale_dn_url est une url que vous pouvez appeler pour diminuer la capacitée de votre cluster

scale_up_url est une url que vous pouvez appeler pour augmenter la capatictée de votre cluster


## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : Et oui, c'est aussi simple que cela de lancer un cluster Kubernetes hautement disponible !


## Enjoy



## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `core` par défaut).

### Autres sources pouvant vous intéresser

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)
* [Kubernetes Documentation](https://kubernetes.io/)

-----
Have fun. Hack in peace.ccccccfngetrtbhbtueiiugnrvvitvgktnfehiuukreb
