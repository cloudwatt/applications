# Innovation Beta: MyCloudManager

![logo](img/mycloudmanager.png)



This version of MyCloudManager (Beta) is a different stack of everything the team was able to share with you so far. It aims to bring you a set of tools to **unify, harmonize and monitor your tenant**. In fact it contains a lot of different applications that aims to help you manage day by day your **Linux** instances :
* Monitoring and Supervision
* Log management
* Jobs Scheduler
* Mirror ClamAV - Antivirus
* Repository app manager
* Backup snapshot or backup soft
* Time synchronization

MyCloudManager has been completely developed by the CAT team ( Cloudwatt Automation Team).
* MyCloudManager is fully HA (High Available)
* it is based on a CoreOS instance
* all applications are deployed via Docker containers orchestrated by Kubernetes
* The user interface is developed by React
* Also you can install or configure, from the GUI, all the applications on your instances via Ansible playbooks.
* To secure maximum your Cloudmanager, no port is exposed on the internet apart from port 22 to the management of the stack of bodies and port 1723 for PPTP VPN access.

## Preparations

### The prerequisites

 * Internet access
 * A Linux shell
 * A [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact) with a [valid keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * The tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)


### Initialize the environment

Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
If you are not logged in yet, you will go thru the authentication screen then the script download will start. Thanks to it, you will be able to initiate the shell accesses towards the Cloudwatt APIs.

Source the downloaded file in your shell. Your password will be requested.

~~~ bash
$ source COMPUTE-[...]-openrc.sh
Please enter your OpenStack Password:
~~~

Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

## Install MyCloudManager

### The 1-click

MyCloudManager start with the **1-click** of **Cloudwatt** via the web page [Apps page](https://www.cloudwatt.com/en/apps/) on the Cloudwatt website.
Choose MyCloudManager apps, press **DEPLOY**.

After entering your login / password to your account, launch the wizard appears:

![oneclick](img/oneclick.png)


As you may have noticed the 1-Click wizard asked to reenter your password Openstack (this will be fixed in a future version of MyCloudManager)
You will find [here](https://console.cloudwatt.com/project/access_and_security/api_access/view_credentials/) your **tenant ID**, it's  same as **Projet ID**. It will be necessary to complete the wizard.

By default, the wizard deploys two instances of type "small-1" who will be the `masters` instances, these are necessary for the proper functioning of Kubernetes HA. Regarding `nodes` they support all your *"pods "(applications)* on the stack. They should be size according to the use you want to make of MyCloudManager by default we proposed to deploy flavor type "n2.cw.standart-1".

You'll see later that 3 "tiny" instances  will be created, they help Kubernetes to know all of the nodes and the application deployed on the cluster.

Also a variety of other instance types exists to suit your various needs, allowing you to pay only for the services you need. Instances are charged by the minute and capped at their monthly price (you can find more details on the [Pricing page](https://www.cloudwatt.com/en/pricing.html) on the Cloudwatt website).


To persist the application data, we will create standard volume in your tenant and automatically attach to your stack to deploy each application through Kubernetes to contain all the data of your different applications.

By default, MyCloudManager will be deployed on two *master* instances, 3 *worker* instances and 3 *etcd* instances.

Press **DEPLOY**.

The **1-click** handles the launch of the necessary calls on Cloudwatt API :

* Start all cluster instances based on CoreOS,
* Start the **toolbox-backend** container,
* Start the **toolbox-frontend** container,
* Start the **rethinkdb** container,
* Start the **rabbitmq** container,
* Start the **traefik** container

The stack is created automatically. You can see its progression by clicking on its name which will take you to the Horizon console. When all modules become "green", the creation is finished.

Wait **5 minutes** that the entire stack is available.

![startopo](img/stacktopo.png)

### Finish OpenVPN access

In order to have access to all functionalities, we have set up a VPN connection.

Here are the steps to follow :

* First retrieve the output information of your stack,

![stack](img/sortie-stack.png)

#### Windows 7

* Must now create a VPN connection from your computer , go to "Control Panel > All Control Panel > Network and share center". Click " Set up a connection ....."

![start](img/startvpn.png)
![vpn](img/vpn.png)
![internet](img/internet.png)


* Entry now the retrieved information in the output stack. Initially the *FloatingIP*  and then *login* and *password* provided.

![info](img/infoconnexion.png)
![login](img/loginmdp.png)


After following this procedure you can now start the VPN connection.

![vpnstart](img/launchvpn.png)

-----
#### Windows 10


* Go to Settings> NETWORK AND INTERNET > Virtual Private Network

![configwin01](img/configwin10.png)

* Now enter the information retrieved out of the stack : firstly the FloatingIP and then login and password provided.

![configipwin10](img/configipwin10.png)
![configuserwin10](img/configuserwin10.png)

After following this procedure you can now start the VPN connection.

![vpnstart](img/connexwin10.png)

-----


You can now access in the MyCloudManager administration interface via the URL **http://manager.default.svc.mycloudmanager** and begin to reap the benefit.

It's (already) done !


## Enjoy

Interface access and the various applications is via **IP** address or **DNS** names if the user rights on your computer allow you to do this. Indeed a **SkyDNS** container is launched at startup allowing you to benefit all the names in place. You can access on the different web interfaces applications by clicking **Go** or via URL request (ex: http://10.0.1.250:30601/ or http://zabbix.default.svc.mycloudmanager/).

We place a block volume every time you deploy an application to save all the **datas**  of the application containers. The volume is mounted on the cluster node that support your application and automatically attached to the container. This makes our stack to be much more robust. For information if the application crash and goes on another node, Kubernetes will dismount and re-mount the volume on the new node, therefore the application finds all of its data.


#### Interface Overview

Here is the home of the MyCloudManager, each thumbnail representing an application ready to be launched. In order to be as scalable and flexible as possible, all applications of MyCloudManager are Docker's containers.

![accueil](img/accueil.png)

A menu is present in the top left of the page, it can move through the different sections of MyCloudManager, we'll detail them later.
* Apps: Application List
* Instances: list of visible instances of MyCloudManager
* Tasks : all ongoing or completed tasks
* Audit: list of actions performed
* Backups: list all backup jobs
* My Instances> Console: access to the console Horizon
* My account> Cockpit ; access to the dashboard
* Support: allows sending mail to support and cloud coach


![menu](img/menu.png)

All of the applications in the **Apps** section are configurable through by **Settings** button ![settings](img/settings.png) on each thumbnail.

As you can see, we have separated them into different sections.
![params](img/params.png)

In the **Info** section you will find a presentation of the application with some useful links on the application.
![appresume](img/appresume.png)

In the **Environments** section you can register here all the parameters to be used to configure the variables of the container to its launch environment.
![paramsenv](img/paramenv.png)

In the **Parameters** section you can register here all the different application configuration settings.
![paramapp](img/paramapp.png)


To identify the applications running on those that are not, we have set up a color code : An application is started will be surrounded by a **green halo** and a **yellow halo** during installation.
![appstart](img/appstart.png)

The **tasks** make the tracking of actions performed on MyCloudManager. It is reported in relative time.

![tasks](img/tasks.png)

It is possible for you to cancel pending on error spot in the **tasks** menu by clicking ![horloge](img/horloge.png) which will then show you what logo ![poubelle](img/poubelle.png).

We also implemented a **audit** section so you can see all actions performed on each of your instances and export to Excel (.xlsx ) if you want to make a post-processing or keep this information for safety reasons via the button ![xlsx](img/xlsx.png).

![audit](img/audit.png)


The **Backups** section allows you to backup all instances by your MyCloudManager. The backup may be performed in two ways, via a **snapshot** or via **duplicity** that has been called **soft**.
* The snapshot backup will take a picture of the instance when you have schedule the backup.
Then you can find it in the list of your images on your tenant.
* The soft backup will deploy a duplicity container and backup all data in the repository (`/data`or `/config`) in a **swift** container which can also be found in **containers** section of your tenant (object storage).
If you want to save a server group, then you have to select when creating the backup.
Regarding the scheduling of backups, several choices are available to you:

* **Daily**: one backup per day at the desired time,
* **weekly**: one backup per week at day and time desired,
* **Monthly**: one backup per month at day and time desired.


To start a new backup configuration you must click on the button![button](img/plus.png)

Give a name to your backup configuration:
![newconfig](img/backupinfo.png)

Select the servers to be added:
![Backupselectsrv](img/selectsrv.png)

Set now **when** and **how** the backup of those servers will be made:

* Snapshot : Takes a "picture" of your instance and deposited in your image library on your tenant (Warning: a snapshot runs cold as mentioned in this article [End of the hot snapshot place to the cold snapshot!](https://dev.cloudwatt.com/en/blog/end-of-the-hot-snapshot-place-to-the-cold-snapshot.html))
![bkpsnapshot](img/bkpsnapshot.png)

* Soft: Copy all the selected directories in a swift container
![bkpsoft](img/bkpsoft.png)

Once you have clicked the button FINISH your configuration is now saved:

![bkpsvg](img/bkpsvg.png)

You can always change the configuration of a backup via the button **edit**![bkpedit](img/bkpedit.png) that allows you to add or remove servers, change the backup directory and when it will run.
The **delete** button ![bkpdelete](img/bkpdelete.png), for its part, allows to completely remove the selected backup job.

#### Who says said backup said restore:

To restore a backup  **soft** or **snapshot** the approach stays the same. You must go to the menu **instances** of your MycloudManager. As you can see a new ![restore](img/restore.png) button appeared on all servers that have been saved.

When you click on a pop-up open, you can now choose from the list the backup to restore  ![chooserestore](img/chooserestore.png).
Once this has been done, if your backup was **snapshot**, the selected image will be restored instead of the current instance, if the backup is **soft** the selected files will be restored in the `restore` directory of your instance.

##### Back to menu
Finally , we integrated two navigation paths in the MyCloudManager menu : **My Instances** and **My Account**. They are respectively used to access the Cloudwatt Horizon console and to manage your account via the Cockpit interface.

The **Support** section will allow you, as the name implies, contacts the Cloudwatt support organization if requested or incident in your MyCloudManager. You can also contact a **cloud coach** to have more information regarding our ecosystem or feasibility of your projects that you want to focus on the Cloudwatt public cloud.

Email :
* Choose your need **Email Support** or  **Contact a Cloud Coach**,
* The  **type** field will allow you to choose between **demand** ** or **incident**,
* The **Reply Email Address** field will allow the support or cloud coach to have your address in order to respond,
* The  **Request / Problems Encountered** field constitutes the body of the email.

![supportemail](img/supportemail.png)

Sending email is via the button ![sendmail](img/sendmail.png). This becomes ![mailsend](img/mailsend.png) if the email has been sent or ![mailfail](img/mailfail.png) if the server encountered an error while sending.



### Add instances to MyCloudManager

To add instances to MyCloudManager, 3 steps:

  1. Attach your router instance of MyCloudManager
  1. Run the script attachment
  3. Start the desired services


#### 1. Attach the instance at the instance of router:

~~~bash
$ neutron router-interface-add $MyCloudManager_ROUTER_ID $Instance_subnet_ID
~~~

You will find all the information by inspecting the stack of resources via the command next heat :

~~~bash
$ heat resource-list $stack_name
~~~

Once this is done you are now in the ability to add your instance to MyCloudManager to instrumentalize .

#### 2. Start the attachment script:


On MyCloudManager, go to the **instance** menu and click the button ![bouton](img/plus.png) at the bottom right.

We offer two commands to choose: one **Curl** and one **Copy to Clipboard** command to run a script in instance build.

![addinstance](img/addinstance.png)


Once the script is applied to the selected instance it should appear in the menu **instance** of your MyCloudManager .

![appdisable](img/appdisable.png)


**Trick** If you want to create an instance via the console horizon Cloudwatt and declare **directly** in your MyCloudManager, you should to select - in step 3 of the instance launch wizard - MyCloudManager network and the Security Group and - in step 4 - you can paste the command **Copy to Clipboard** command in the Custom Script field.

![attachnetwork](img/attachnetwork.png)

![launchinstance](img/launchinstance.png)


#### 3. Start the required services on the instance :

To help you maximum we created playbooks Ansible to automatically install and configure the agents for different applications.

To do this, simply click on the application you want to install on your machine. The playbook Ansible concerned will be automatically installed.
Once the application is installed, the application logo switch to color, allowing you to identify the applications installed on your instances.

![appenable](img/appenable.png)


## The MyCloudManager services provided by applications


In this section, we will present different service MyCloudManager.

### Monitoring and supervision
We have chosen to use *Zabbix*, the most popular application for monitoring, supervision and alerting .
Zabbix application is free software **to monitor the status of various network services , servers and other network devices** but also **applications and software** worn on the supervised servers; and producing dynamic graphics resource consumption.
Zabbix uses MySQL, PostgreSQL or Oracle to store data. According to the large number of machines and data to monitor the choice of SGBD greatly affects performance. Its web interface is written in PHP and provided a real-time view on the collected metrics.

To go further, here are some helpful links :
* http://www.zabbix.com/
* https://www.zabbix.com/documentation/3.0/start

### Log Management

We chose Graylog which is the product of the moment for log management , here is a short presentation :
Graylog is an open source **log management** platform capable of manipulating and presenting data from virtually any source. This container is the offer officially by Graylog teams.
  * The Graylog Web Interface is a powerful tool that allows anyone to manipulate the entirety of what Graylog has to offer through an intuitive and appealing web application.
  * At the heart of Graylog is it's own strong software. Graylog Server interacts with all other components using REST APIs so that each component of the system can be scaled without comprimising the integrity of the system as a whole.
  * Real-time search results when you want them and how you want them: Graylog is only able to provide this thanks to the tried and tested power of Elasticsearch. The Elasticsearch nodes behind the scenes give Graylog the speed that makes it a real pleasure to use.

Enjoying this impressive architecture and a large library of plugins, Graylog stands as a strong and versatile solution for **log management both instances** but also worn **applications and software** on monitored instances.

To go further, here are some helpful links :
* https://www.graylog.org/
* http://docs.graylog.org/en/1.2/pages/getting_started.html#get-messages-in
* http://docs.graylog.org/en/1.3/pages/architecture.html
* https://www.elastic.co/products/elasticsearch
* https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/


### Job Scheduler
We have chosen to use *Rundeck*.
The Rundeck application will allow you **to schedule and organize all jobs** that you want to deploy consistently on all of your holding via its web interface.

In next version of MyCloudManager, we give you the possibility to backup your servers like as we saw in the *bundle* Duplicity.

To go further, here are some helpful links :
* http://rundeck.org/
* http://blog.admin-linux.org/administration/rundeck-ordonnanceur-centralise-opensource-vient-de-sortir-sa-v2-0
* http://dev.cloudwatt.com/fr/blog/5-minutes-stacks-episode-vingt-trois-duplicity.html


### Mirror Antivirus
This application is a Ngnix server. A *CRON* script will run every day to pick up the latest **virus** definition distributed by *ClamAV*. The recovered packet will be exposed to your instances via Ngnix allowing you to have customers **ClamAV** update without your instances not necessarily have access to the internet.

To go further, here are some helpful links :
* https://www.clamav.net/documents/private-local-mirrors
* https://github.com/vrtadmin/clamav-faq/blob/master/mirrors/MirrorHowto.md


### Software repository
We have chosen to use *Artifactory*.
Artifactory is an application that can display any type of directory server via a Ngnix . Here our aim is to offer an application that can **expose a repository** for all of your instances.

To go further, here are some helpful links :
* https://www.jfrog.com/open-source/
* https://www.jfrog.com/confluence/display/RTF/Welcome+to+Artifactory


### Time Synchronisation
We have chosen to use NTP.
NTP container is used here so that all of your instances without access to the internet can be synchronized to the same time and access to **a server time**.

To go further, here are some helpful links :
  * http://www.pool.ntp.org/fr/

### The MyCloudManager versions **v2** (Beta)

- CoreOS Stable 1010.6
- Docker 1.9.1
- Kubernetes 1.3
- Zabbix 3.0
- Rundeck 2.6.2
- Graylog 2.0
- Artifactory 4.9.1
- Nginx 1.11.2
- SkyDNS 2.5.3a
- Etcd 2.0.3


### List of distributions supported by MyCloudManager

* Ubuntu 14.04
* Debian Jessie
* Debian Wheezy
* CentOS 7.2
* CentOS 7.0
* CentOS 6.7

### Application configuration (by default)

As explained before, we left the possibility via the button **Settings** ![settings](img/settings.png) on each thumbnail, enter all application settings to launch the container.
However, the login and password can't be changed everywhere, it will do inside the application once it started.

Login and password by default of MyCloudManager applications :
* Zabbix - Login : **admin** - Password : **zabbix**
* Graylog - Login : **admin** - Password : **admin**
* Rundeck - Login : **admin** - Password: **admin**

Other applications have no web interface, so no login/ password, except **Artifactory** which has no authentication.

## So watt?

The goal of this tutorial is to accelerate your start. At this point **you** are the master of the stack.

You now have an SSH access point on your virtual machine through the floating-IP and your private keypair (default user name `core`).

You can access the MyCloudManager administration interface via the URL **[MyCloudManager](http://manager.default.svc.mycloudmanager)**


## And after?

This article will acquaint you with this first version of MyCloudManager. It is available to all Cloudwatt users in **Beta mode** and therefore currently free.

The intention of the CAT ( Cloudwatt Automation Team) is to provide improvements on a bimonthly basis. In our roadmap, we expect among others:
* Instrumentalisation of Ubuntu 16.04 instance (possible today but only with the CURL command),
* Instrumentalisation of Windows instances,
* A French version,
* not having to re-enter your credentials,
* many other things

Suggestions for improvement ? Services that you would like ? do not hesitate to contact us [apps.cloudwatt@orange.com](mailto:apps.cloudwatt@orange.com)

-----
Have fun. Hack in peace.

The CAT
