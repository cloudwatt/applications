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
  - Kubernetes 1.5.1
  - Ceph 10

### Les pré-requis pour déployer cette stack

Ceci devrait être une routine à présent:

 * Un accès internet

 * Un shell linux ou avoir accès à la console Cloudwatt

 * Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact) avec une [ paire de clés existante](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)

 * Les outils [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)

 * Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Taille de l'instance

Par défaut, le script propose un déploiement sur une instance de type "standard-1" (n1.cw.standard-1). Il existe une variété d'autres types d'instances pour la satisfaction de vos multiples besoins. Les instances sont facturées à la minute, vous permettant de payer uniquement pour les services que vous avez consommés et plafonnées à leur prix mensuel (vous trouverez plus de détails sur la [Page tarifs](https://www.cloudwatt.com/fr/produits/tarifs.html) du site de Cloudwatt).

Vous pouvez ajuster les parametres de la stack à votre goût.

### Au fait...

Si vous n’aimez pas les lignes de commande, vous pouvez passer directement à la version **"Je lance en 1-clic"** ou **"Je lance avec la console"** en cliquant sur [ce lien](#console)...

## Tour du propriétaire

Une fois le dépôt cloné, vous trouverez le répertoire `blueprint-kubernetes-ha/`

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
scale_storage_dn_url: ...
scale_storage_up_url: ...
 ~~~

scale_dn_url est une url que vous pouvez appeler pour diminuer la capacitée de votre cluster

scale_up_url est une url que vous pouvez appeler pour augmenter la capatictée de votre cluster

scale_storage_up_url est une url que vous pouvez appeler pour augmenter la capacitée du cluster Ceph

scale_storage_dn_url est une url que vous pouvez appeler pour diminuer la capacitée du cluster Ceph

### Et ensuite

Chaque noeud possède une ip publique et privée.

Le cluster va mettre une dixaine de minutes à s'initialiser, une fois cette durée écoulée, vous pouvez vous connecter en ssh sur l'ip publique de l'un d'entre eux.

Pour lister l'état des composants Kubernetes, vous pouvez executer cette commande :

~~~bash
$ fleetctl list-units
~~~

Elle devrais vous afficher ceci :

~~~
UNIT                       MACHINE                  ACTIVE SUB
pidalio-apiserver.service  62bf699b.../84.39.36.87  active running
pidalio-controller.service b8cc10ee.../84.39.35.207 active running
pidalio-node.service       4f723b52.../84.39.36.13  active running
pidalio-node.service       62bf699b.../84.39.36.87  active running
pidalio-node.service       b8cc10ee.../84.39.35.207 active running
pidalio-proxy.service      4f723b52.../84.39.36.13  active running
pidalio-proxy.service      62bf699b.../84.39.36.87  active running
pidalio-proxy.service      b8cc10ee.../84.39.35.207 active running
pidalio-scheduler.service  4f723b52.../84.39.36.13  active running
pidalio.service            4f723b52.../84.39.36.13  active running
~~~

Pidalio est un utilitaire permettant de bootstrappé facilement un cluster Kubernetes.

Il est composé de six parties :

	- pidalio : Il met a disposition l'ensemble des certificats et resources nécessaires au fonctionnement du cluster.
	- pidalio-apiserver : correspond au composant API Server de Kubernetes, il fait office de point central des différents composants
	- pidalio-controller : correspond au composant Controller Manager de Kubernetes, il s'occupe de vos Pods
	- pidalio-scheduler : correspond au composant Scheduler, il s'occupe de répartir les Pods dans votre cluster
	- pidalio-proxy : correspond au composant Kube Proxy, il prend soin de votre table iptable pour rediriger automatiquement les services Kubernetes vers les bons pods
	- pidalio-node : correspond au Kubelet, l'agent Kubernetes responsable de chaque Noeud.


Vous pouvez utiliser le client Kubernetes depuis n'importe quel noeud, nous allons donc lancer un serveur nginx dans notre cluster.

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

### J'aimerai persister mes données

Il est parfois utile de persister les données des conteneurs mais la tâche est souvent loins d'être facile.

C'est pourquoi, vous disposez d'un cluster Ceph prêt à l'emploi.

Tappez cette commande pour lister les volumes :

```bash
rbd ls
```

Nous allons maintenant lancer une base de donnée MariaDB avec un volume attaché.

Tout d'abord, executez cette commande pour créer un volume de 10Go

```bash
rbd create db --size=10G
```

Maintenanrt que notre volume est prêt, vous pouvez lancer un Pod mariadb avec votre volume ceph attaché.

```bash
cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: mariadb
  labels:
    app: mariadb
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
        - image: mariadb
          name: mariadb
          volumeMounts:
            - name: mariadb-persistent-storage
              mountPath: /var/lib/mysql
      volumes:
	     - name: mariadb-persistent-storage
	       rbd:
	         monitors:
	           - ceph-mon.ceph:6789
	             user: admin
	             image: db
	             pool: rbd
	             secretRef:
	               name: ceph-client-key
EOF
```

Depuis Kubernetes 1.5, vous pouvez également utiliser l'autoprovisionning de volumes.

### Et la haute disponibilitée

Et la haute disponibilitée dans tout ça ?

Rien de plus simple, lancez à nouveau le script stack-start.sh mais sur une région différente de la première et choisissez le mode Join.
Une fois la stack créée, les deux clusters vont se rejoindre pour ne former plus qu'un. Simple non ?

### C'est magique, comment ça fonctionne ?

Chaque noeud se connecte de manière sécurisée à un réseau virtuel Weave, de cette façon, tous les conteneurs peuvent discuter les un avec les autres quelque soit leurs localisation.

Une fois interconnecté, Fleet prend le relai pour dispatcher les différents composants Kubernetes à travers le cluster et Pidalio leurs fournit tout ce dont ils ont besoin pour fonctionner correctement.

Et voila !

### Un petit schéma ?

![Architecture Réseau](img/archi.png)


## C’est bien tout ça, mais...

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Bon... en fait oui ! Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/index.html) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider... 2 minutes plus tard un bouton vert apparait... ACCEDER : Et oui, c'est aussi simple que cela de lancer un cluster Kubernetes !


## Huston we have a problem !

### Le cluster ne se lance pas correctement


### Vous avez perdu un noeud Ceph, comment correctement le supprimmer


### Certains volumes Ceph sont verrouillés




## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `core` par défaut).

### Autres sources pouvant vous intéresser

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)
* [Kubernetes Documentation](https://kubernetes.io/)

-----
Have fun. Hack in peace.
