# Blueprint: Kubernetes HA #

![Kubernetes](img/kube.png)

When you work with a lot of containers, it quickly becomes essential to orchestrate them.

That's where Kubernetes comes in.

Kubernetes is a Docker and Rkt container orchestrator initiated by Google.

This stack will allow you to deploy a production cluster in a few clicks.

## Preparations

### Versions

  - CoreOS Stable 1010.6
  - Docker 1.10.3
  - Kubernetes 1.5.1
  - Ceph 10

### The prerequisites

This should be a routine now:

 * Internet access

 * A linux shell or an access to the Cloudwatt console

 * A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with an [ existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)

 * The Openstack Client [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)

 * A local clone of the [Cloudwatt applications](https://github.com/cloudwatt/applications) repository

### Instance Size

By default, the script proposes a deployment on an instance of type "standard-1" (n1.cw.standard-1). There are a variety of other types of instances for meeting your multiple needs. The instances are invoiced per minute, allowing you to pay only for the services you have consumed and capped at their monthly price (you will find more details on the [rates page](https://www.cloudwatt.com/en/pricing.html) of the Cloudwatt website).

You can adjust the stack parameters to suit your taste.

### By the way...

If you do not like the command lines, you can go directly to the version **"I launch in 1-click"** or **"I launch with the console"** by clicking on [this link](#console) ...


## Tour of the owner

Once the repository is cloned, you will find the `blueprint-kubernetes-ha/` directory

* `stack-fr1.yml`: HEAT orchestration template for region FR1, it will be used to deploy the necessary infrastructure.
* `stack-fr2.yml`: HEAT orchestration template for region FR2, it will be used to deploy the necessary infrastructure.
* `stack-start.sh`: Script to launch the stack, which simplifies the input of the parameters.

## Start-up

### Initializing the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
If you are not logged in yet, you will go thru the authentication screen then the script download will start. Thanks to it, you will be able to initiate the shell accesses towards the Cloudwatt APIs.

Source the downloaded file in your shell. Your password will be requested.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:
~~~

Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Launch the stack

In a shell, run the `stack-start.sh` script:

 ~~~ bash
 $ ./stack-start.sh
 ~~~

The script will ask you several questions, then, once the stack create you will display four lines:

 ~~~ bash
scale_dn_url: ...
scale_up_url: ...
scale_storage_dn_url: ...
scale_storage_up_url: ...
 ~~~

scale_dn_url is a url that you can call to decrease the capacity of your cluster

scale_up_url is a url that you can call to increase the capacities of your cluster

scale_storage_up_url is a url that you can call to increase the capacity of the cluster Ceph

scale_storage_dn_url is a url that you can call to decrease the capacity of the cluster Ceph, in this scenario, please look at the FAQ.

### Et ensuite

Each node has a public and private ip.

The cluster will take about ten minutes to initialize, once this time has elapsed, you can connect throught ssh to the public ip of one of them.

Then, to list the state of the Kubernetes components, you can execute this command:

~~~bash
$ fleetctl list-units
~~~

It should show you this:

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

Pidalio is a utility to easily bootstrapp a Kubernetes cluster.

It is composed of six parts:

	- pidalio: It makes available all the certificates and resources necessary for the operation of the cluster.
	- pidalio-apiserver: corresponds to the Kubernetes API Server component
	- pidalio-controller: corresponds to the Controller Manager component of Kubernetes, it takes care of your Pods
	- pidalio-scheduler: corresponds to the Scheduler component, it distributes the pods in your cluster
	- pidalio-proxy: corresponds to the Kube Proxy component, it takes care of your iptables to automatically route Kubernetes services ip to the correct pods
	- pidalio-node: corresponds to the Kubelet, the Kubernetes agent on each node.

You can use the Kubernetes client from any node.

We will use it to run a nginx server in our cluster :

~~~bash
kubectl run --image=nginx --port=80 nginx
~~~

Then we will make this server available on the internet :

~~~bash
kubectl expose deployment nginx --type=NodePort
kubectl describe service nginx
~~~

This last command will show you the details about the nginx service:

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

Look at the NodePort, it's the one you can use to access to this service throught any public ip of your cluster, be careful to open the ports on the cluster security group.

To access nginx, you can go to any public ip in your cluster on port 24466.

### J'aimerai persister mes données

Il est parfois utile de persister les données des conteneurs mais la tâche est souvent loins d'être facile.

C'est pourquoi, vous disposez d'un cluster Ceph prêt à l'emploi.

Tappez cette commande pour lister les volumes :

```bash
rbd ls
```

Tout d'abord, executez cette commande pour créer un volume de 10Go

```bash
rbd create db --size=10G
```

Nous allons maintenant lancer une base de donnée MariaDB avec un volume attaché.

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
          env:
            - name: MYSQL_ALLOW_EMPTY_PASSWORD
              value: "true"
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
               name: ceph-admin-key
EOF
```

Depuis Kubernetes 1.5, vous pouvez également utiliser l'autoprovisionning de volumes.

Un exemple :

```bash
cat <<EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
   name: ceph
provisioner: kubernetes.io/rbd
parameters:
  monitors: ceph-mon.ceph:6789
  adminId: admin
  adminSecretName: ceph-admin-key
  adminSecretNamespace: ceph
  userId: admin
  userSecretName: ceph-admin-key
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db
  annotations: 
    "volume.beta.kubernetes.io/storage-class": ceph
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi
---
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
          env:
            - name: MYSQL_ALLOW_EMPTY_PASSWORD
              value: "true"
          volumeMounts:
            - name: mariadb-persistent-storage
              mountPath: /var/lib/mysql
      volumes:
        - name: mariadb-persistent-storage
          persistentVolumeClaim:
            claimName: db
EOF
```

### Monitoring

Il est très important de surveiller l'état de votre cluster, c'est pourquoi, si vous avez coché l'option Monitoring durant la création de la stack, un Grafana est automatiquement disponnible sur n'importe quel machine depuis le port 31000.

Vous obtiendrez une liste des différents dashboards en cliquand sur le menu Home :

![Monitoring](img/monitoring.png)

Cliquez par exemple sur Kubernetes resources usage monitoring (via Prometheus) pour obtenir un monitoring détailé de votre cluster Kubernetes.

Vous devriez obtenir cet écran :

![Monitoring](img/monitoring2.png)


### Et la haute disponibilitée dans tout ça ?

Rien de plus simple, lancez à nouveau le script stack-start.sh mais sur une région différente de la première et choisissez le mode Join.
Une fois la stack créée, les deux clusters vont se rejoindre pour ne former plus qu'un. Simple non ?

### C'est magique mais comment ça fonctionne ?

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

Si votre cluster ne se lance pas correctement, essayer de reconstruire la stack.

### Vous avez perdu un noeud Ceph, comment correctement le supprimmer

Lorsque vous ajoutez un noeud de storage, votre cluster Ceph aumente automatiquement.
Mais lorsqu'un noeud tombe ou est supprimé, nous ne pouvons pas savoir si il reviendra un jour, c'est pourquoi il n'est pas automatiquement supprimé de Ceph.

Avant de supprimer votre noeud, déterminez l'osd à supprimmer :

```bash
echo $(kubectl --namespace=ceph get pods -o json | jq -r '.items[] | select(.metadata.labels.daemon=="osd") | select(.spec.nodeName=="ip_de_la_machine") | .metadata.name')
```

Ceci va vous donner le nom d'un des osd, exemple: ceph-osd-5mi7g

Ensuite, il vous faut trouver le numéro de cet osd : 

```bash
echo $(ceph osd crush tree | jq '.[].items[] | select(.name=="ceph-osd-5mi7g") | .items[].id')
```

Nous allons maintenant sortir cet OSD du cluster :

```bash
ceph osd out numero_de_l_osd
```

Ensuite il faut attendre que Ceph ai finit de déplacer les données, vous pouvez vérifier l'état d'avancement grâce à la commande :

```bash
ceph -s
```

Lorsque le cluster est de nouveau dans un état normal (HEALTH_OK), vous pouvez passer à la suite :

```bash
ceph osd crush remove nom_de_l_osd
ceph auth del osd.numero_de_l_osd
ceph osd rm numero_de_l_osd
```

Et voila ! Vous pouvez désormais supprimer la machine.

### Certains volumes Ceph sont verrouillés

Parfois, un conteneur bloque un volume Ceph, pour supprimer le verrou, executez ceci :

```bash
rbd lock list nom_du_volume
```

Devrais afficher ceci :

```bash
rbd lock rm nom_du_volume id_du_lock locker
```

Exemple:

```bash
rbd lock rm grafana kubelet_lock_magic_to-hfw3u7-e3pnkzd34lhp-22iuiamqx2s4-node-f644cpr26t7l.novalocal client.14105
```

## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade **vous** êtes maître(sse) à bord.

Vous avez un point d'entrée sur votre machine virtuelle en SSH via l'IP flottante exposée et votre clé privée (utilisateur `core` par défaut).

### Autres sources pouvant vous intéresser

* [CoreOS homepage](https://coreos.com/)
* [Docker Documentation](https://docs.docker.com/)
* [Kubernetes Documentation](https://kubernetes.io/)

-----
Have fun. Hack in peace.
