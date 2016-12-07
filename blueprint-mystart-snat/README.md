# 5 Minutes Stacks, épisode 44 : MyStart snat #

## Episode 44 : MyStart snat

Cette stack vous permet d'intialiser votre tenant par la création rapide d'une keypair, d'un réseau, d'un security group et d'un routeur de type SNAT (qui a accès à internet). Ces ressources sont des pré-requis pour la création d'instances dans le cloud.


## Preparations

### Les pré-requis pour déployer cette stack

* Un accès internet
* Un [compte Cloudwatt](https://www.cloudwatt.com/cockpit/#/create-contact)
* Un clone local du dépôt git [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Vous n’auriez pas un moyen de lancer l’application en 1-clic ?

Allez sur la page [Applications](https://www.cloudwatt.com/fr/applications/) du site de Cloudwatt, choisissez l'appli, appuyez sur DEPLOYER et laisser vous guider...

### Vous n’auriez pas un moyen de lancer l’application par la console ?

Et bien si ! En utilisant la console, vous pouvez déployer votre kit de démarrage :

1.	Allez sur le Github Cloudwatt dans le répertoire
[applications/blueprint-mystart](https://github.com/cloudwatt/applications/tree/master/blueprint-mystart-snat)
2.	Cliquez sur le fichier nommé `blueprint-mystart-snat.heat.yml`
3.	Cliquez sur RAW, une page web apparait avec le détail du script
4.	Enregistrez-sous le contenu sur votre PC dans un fichier avec le nom proposé par votre navigateur (enlever le .txt à la fin)
5.  Rendez-vous à la section « [Stacks](https://console.cloudwatt.com/project/stacks/) » de la console.
6.	Cliquez sur « Lancer la stack », puis cliquez sur « fichier du modèle » et sélectionnez le fichier que vous venez de sauvegarder sur votre PC, puis cliquez sur « SUIVANT »
7.	Donnez un nom à votre stack dans le champ « Nom de la stack »
8.	Remplissez les deux champs  « key Name prefix » et « /24 cidr of private network » puis cliquez sur « LANCER »

La stack va se créer automatiquement (vous pouvez en voir la progression cliquant sur son nom). Quand tous les modules deviendront « verts », la création sera terminée.
C’est (déjà) FINI !

## Enjoy

Pour télécharger votre clé privée, consultez cet url
`https://console.cloudwatt.com/project/access_and_security/keypairs/prefix-nom_votre_stack/download/`.
Puis cliquez sur `Download key pair "prefix-nom_votre_stack"`.

Maintenant vous pouvez lancer votre première instance

### Autres sources pouvant vous intéresser:
* [Openstack Home page](https://www.openstack.org/)
* [Cloudwatt Home page](https://www.cloudwatt.com/fr/)

----
Have fun. Hack in peace.
