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

* `stack-fr1.yml`: Template d'orchestration HEAT pour la région FR1, il servira à déployer l'infrastructure nécessaire.
* `stack-fr2.yml`: Template d'orchestration HEAT pour la région FR2, il servira à déployer l'infrastructure nécessaire.
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


### Et ensuite

Chaque noeud possède une ip publique et privée.
Connectez vous sur l'une d'elle en ssh et tappez cette comande pour identifier le rôle de chaque machine :

~~~bash
$ fleetctl list-units
~~~

Cette commande devrais vous afficher ceci :

~~~
UNIT                             MACHINE                      ACTIVE SUB
pidalio-master@fr1-1.service   	5b369d72.../84.39.40.167     active running
pidalio-node@fr1-1.service     	d940c6cd.../84.39.48.245     active running
pidalio-node@fr1-2.service     	51487df4.../84.39.49.15      active running
pidalio.service			          1337b168.../84.39.43.230     active running
~~~

Pidalio est un utilitaire permettant de bootstrappé facilement un cluster Kubernetes.

Il est composé de trois parties :

	- pidalio : Il met a disposition l'ensemble des certificats et resources nécessaires au fonctionnement du cluster.
	- pidalio-node : correspond a un noeud Kubernetes
	- pidalio-master : corresponse a un master Kubernetes


Nous allons donc nous connecter en ssh au noeud 84.39.40.167 et ensuite utiliser le client Kubernetes pour lancer, par exemple, un serveur nginx.

~~~bash
kubectl run --image=nginx --port=80 nginx
~~~

Ensuite nous allons rendre disponible ce serveur sur internet

~~~bash
kubectl expose deployment nginx --type=NodePort
kubectl describe service nginx
~~~

Cette dernière commande va vous afficher ceci :

~~~bash
Name:  					nginx
Namespace:     			default
Labels:					run=nginx
Selector:      			run=nginx
Type:  					NodePort
IP:    					10.18.203.177
Port:  					<unset>	80/TCP
NodePort:      			<unset>	24466/TCP
Endpoints:     			10.40.0.2:80
Session Affinity:      	None
No events.
~~~

Pour accéder à nginx, vous pouvez vous rendre sur n'importe quel ip publique de votre cluster sur le port 24466

### Et la haute disponibilitée

Et la haute disponibilitée dans tout ça ?

Avec Pidalio, rien de plus simple, lancez à nouveau le script stack-start.sh mais sur une région différente de la première et choisissez le mode Join.
Une fois la stack créée, les deux clusters vont se rejoindre pour ne former plus qu'un. Simple non ?


## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : Et oui, c'est aussi simple que cela de lancer un cluster Kubernetes !


## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `core` par défaut).

### Autres sources pouvant vous intéresser

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)
* [Kubernetes Documentation](https://kubernetes.io/)

-----
Have fun. Hack in peace.ccccccfngetrtbhbtueiiugnrvvitvgktnfehiuukreb
