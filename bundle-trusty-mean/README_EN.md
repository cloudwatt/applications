
# 5 Minutes Stacks, episode three : MEAN - English version
## Work in progress
## Episode three : MEAN

Pour ce troisème volet, nous nous penchons sur la stack MEAN :

* MongoDB : Le désormais célèbre moteur NoSQL orienté document
* Express.js : Le framework web pour Node.js
* Angular.js : Framework d'applications Front-web
* Node.js : Le serveur d'application en Javascript

En suivant ce tutoriel, vous obtiendrez une instance Ubuntu Trusty Tahr, pré-configurée avec un serveur NGinx en frontal sur le port 80, forwardant vers un serveur Node.js, monitoré et maintenu en vie par [Foreverjs](https://github.com/foreverjs/forever), une instance MongoDB et un déploiement fonctionnel de l'application de démonstration de [MeanJS](http://meanjs.org/). Pour des considérations de sécurité, MongoDB n'accepte de connexions que depuis le serveur lui-même.

## Préparatifs

### The versions

* MongoDB
* Express
* Angular 
* Node.js

### The prerequisites to deploy this stack

Ce sont les mêmes que pour les épisodes précédents :

* an internet acces
* a Linux shell
* a [Cloudwatt account](https://www.cloudwatt.com/authentification), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
* the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
* a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

Per default, the script is proposing a deployement on an instance type "Small" (s1.cw.small-1).  Instances are charged by the minute and capped at their monthly price (you can find more details on the [Tarifs page](https://www.cloudwatt.com/fr/produits/tarifs.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console) 

## What will you find in the repository

Once you have cloned the github, you will find in the `bundle-trusty-mean/` repository:

* `bundle-trusty-mean.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
* `stack-start.sh`: Stack launching script. This is a small script that will save you some copy-paste.
* `stack-get-url.sh`: Flotting IP recovery script.

## Start-up

### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/). 
If you are not logged in yet, you will go thru the authentication screen then the script download will start. Thanks to it, you will be able to initiate the shell acccesses towards the Cloudwatt APIs.

Source the downloaded file in your shell. Your password will be requested. 

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:

~~~

Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Adjust the parameters


With the `bundle-trusty-lamp.mean.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

~~~ bash
heat_template_version: 2013-05-23


description: All-in-one MEAN stack


parameters:
  keypair_name:
    default: amaury-ext-compute         <-- Indicate here your keypair
    description: Keypair to inject in instances
    type: string

[...]
~~~ 

### Start up the stack

In a shell, run the script `stack-start.sh` with the name you want to give it as parameter:

~~~ bash
$ ./stack-start.sh IM_MEAN
+--------------------------------------+------------+--------------------+----------------------+
| id                                   | stack_name | stack_status       | creation_time        |
+--------------------------------------+------------+--------------------+----------------------+
| ed4ac18a-4415-467e-928c-1bef193e4f38 | IM_MEAN    | CREATE_IN_PROGRESS | 2015-04-21T08:29:45Z |
+--------------------------------------+------------+--------------------+----------------------+
~~~ 

Last, wait 5 minutes until the deployement been completed.

### Enjoy

Once all of this done, you can run the `stack-get-url.sh` script. It will gather the entry url of your stack.

~~~ bash
./stack-get-url.sh IM_MEAN
IM_MEAN 82.40.34.249
~~~ 

qui va récupérer l'IP flottante attribuée à votre stack. Vous pouvez alors attaquer cette IP avec votre navigateur préféré et commencer à configurer votre instance Wordpress.

## Dans les coulisses

Le script `start-stack.sh` s'occupe de lancer les appels nécessaires sur les API Cloudwatt pour :

* démarrer une instance basée sur Ubuntu Trusty Tahr
* l'exposer sur Internet via une IP flottante

<a name="console" />

### All of this is fine, but you do not have a way to run the stack thru the console ?

Yes ! Using the console, you can deploy a LAMP server:

1.	Go the Cloudwatt Github in the applications/bundle-trusty-lamp repository
2.	Click on the file nammed bundle-trusty-lamp.heat.yml
3.	Click on RAW, a web page appear with the script details
4.	Save as its content on your PC. You can use the default name proposed by your browser (just remove the .txt)
5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
6.	Click on « Launch stack », then click on « Template file » and select the file you've just saved on your PC, then click on « NEXT »
7.	Named your stack in the « Stack name » field
8.	Enter your keypair in the « keypair_name » field
9.	Choose the instance size using the « flavor_name » popup menu and click on « LAUNCH »

The stack will be automatically created (you can see its progress by clicking on its name). When all its modules will become "green", the creation will be completed. Then you can go on the "Instances" menu to discover the flotting IP value that has been automatically generated. Now, just run this IP adress in your browser and enjoy !

It is (already) FINISH !


## So watt ?

Ce tutoriel a pour but d'accélerer votre démarrage. A ce stade vous êtes maître(sse) à bord. 

Vous avez un point d'entrée sur votre machine virtuelle en ssh via l'IP flottante exposée et votre clé privée (utilisateur `cloud` par défaut).

Les chemins intéressants sur votre machine :

- `/var/lib/www` : Répertoire d'installation de l'application MeanJS. C'est le répertoire exposé par Node.js
- `/etc/nginx/sites-available/node_proxy` : Fichier de configuration de Nginx dédié au proxying HTTP vers Node.js
- `/etc/init.d/nodejs` : Script d'init du service Node.js via Foreverjs.

Quelques ressources qui pourraient vous intéresser :

* [Documentation NGinx](http://nginx.org/en/docs/)
* [Framework MeanJS](http://meanjs.org/)


-----
Have fun. Hack in peace.

