# 5 Minutes Stacks, episode 26 : Blueprint 3 tier#

## Episode 26 : Blueprint 3 tier

This blueprint will help you to set up a 3-tier architecture.
We have automated the deployment of various nodes component architecture.
Through this blueprint we propose to set up web front-end, the glusterfs with a database cluster.
You can choose to deploy on different Web front-end applications (Apache & php, tomcat 8 or nodejs).
Here is the architecture diagram.

![arch](img/arch.png)

## Preparations

### The version
 - Ubuntu Trusty 14.04
 - Ubuntu Xenial 16.04
 - Debian Jessie
 - Centos 7.2
 - Glustefs 3
 - Mariadb 10.1
 - Lvm2
 - Mylvmbackup
 - Galeracluster 3
 - Nodejs 6.x
 - Apache 2.4
 - Php 5 & 7
 - Openjdk 8
 - Tomcat 8
 - Nginx 1.10

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

## Initialize Blueprint

### The 1-click

![from1](img/1.png)
![form2](img/2.png)
![form3](img/3.png)

Complete this fields and click LAUNCH.

**SSH Keypair :** your key pair.

**Artefact in zip ,git, tar.gz or war :** Put the url artifact of your application, it must be in git, zip or tar.gz for PHP and nodejs applications and war for tomcat applications.
**Application type :** If you choose php, you are going to have apache2 server and php environment, if you choose nodejs you are going to have an environment that runs nodejs applications with reverse proxy nginx and if you choose tomcat you will have a tomcat environment 8 and openjdk8 with nginx as a reverse proxy.
**Flavor Type for nodes :** Web front nodes flavor.

**Number of front nodes :** Number of front web nodes.

**Flavor Type for glusterfs :**  Nodes Glusterfs flavor.

**/24 cidr of fronts network :** The network address of the web front nodes and glusterfs (like 192.168.0.0/24).

**Database user :** Database user.

**Database password :** Database password user.

**Database name :** Database name.

**Flavor Type for databases :** Database nodes flavor

**Number of database clusters :** Number of databases nodes

**/24 cidr of databases network :** The network address of database nodes (like 192.168.0.0/24)

**OS type :** You may choose the OS Ubuntu 14.04, Ubuntu 16.04, Debian or Centos 7.2 Jessie

Stack form :

![stack](img/5.png)

Outputs:

![output](img/4.png)

**Database_ip :** Load blancer database cluster ip addresse.

**Database_name :** Database name.

**Database_user :** Database username.

**Database_port :** Database port.

**App_url_external :** Your application external url.

**App_url_internal :** Your application internal url.

## Enjoy

#### Front nodes configuration Folders and files:

* php

`/etc/apache2/sites-available/vhost.conf`: Default apache configuration on Debian and Ubuntu.

`/etc/http/conf.d/vhost.conf`: Default apache configuration on Centos.

`/var/www/html`: The php application deployment directory.

* tomcat

`/usr/share/tomcat`: Tomcat directory.

`/user/share/tomcat/webapps`: The java application deployment directory.

`/etc/nginx/conf.d/default`: Reverse proxy configuration.

* nodejs

`/nodejs`: The nodejs application deployment directory.

`/etc/nginx/conf.d/default`: Reverse proxy configuration.

#### Two Glusterfs nodes configuration Folders and files :

`/srv/gluster/brick`: le répertoire qui est repliqué entre les deux noeuds glusterfs.

#### Galera nodes configuration Folders and files :

`/DbStorage/mysql`: Mariadb nodes datadir is a cinder volume.

`/etc/mysql`: Mariadb configuration directory on Debian and Ubuntu.

`/etc/mysql.cnf`: Mariadb configuration file on Centos.

`/etc/my.cnf.d`: Mariadb configuration directory on Centos.

#### Restart services for every application

* php

On Debian & ubuntu :
~~~ bash
service apache2 restart
~~~
On Centos :
~~~ bash
service httpd restart
~~~
* nodejs
~~~ bash
service nginx restart
/etc/init.d/nodejs restart
~~~

* tomcat
~~~ bash
service tomcat restart
service nginx restart
~~~

* Glasterfs

On Debian & Ubuntu :
~~~ bash
service glusterfs-server restart
~~~
On Centos :
~~~ bash
service glusterd restart
~~~
* Galera

On the first node :
~~~ bash
service mysql restart --wsrep-new-cluster
~~~
On the others :
~~~ bash
service mysql restart
~~~

#### Exploitation

**Front Nodes :**

`/root/deploy.sh` :is a cron for deploying the application, you can stop it if your application is well deployed,
if you want to redeploy the application, just delete the older application, run this commands:
~~~bash
rm -rf /var/www/html/*
##if php.
/root/deploy.sh /var/www/html php url_artifact
##if tomcat
/root/deploy.sh /opt/tomcat/webapps tomcat war_url
##if nodejs
/root/deploy.sh /nodejs nodejs url_artifact
~~~
**Les deux noeuds Glusterfs:**

Gluster volume is in the form ip:/gluster, for testing it works well, type the following command:
~~~bash
gluster volume info
~~~
**Les noeuds de Galeracluster :**

`/root/sync.sh`:is a cron  to start Mariadb nodes, you can stop if the nodes are well started,
for testing, type the following command:
~~~bash
mysql -u root -e 'SELECT VARIABLE_VALUE as "cluster size" FROM INFORMATION_SCHEMA.GLOBAL_STATUS  WHERE VARIABLE_NAME="wsrep_cluster_size"'
+--------------+
| cluster size |
+--------------+
| number mariadb nodes |
+--------------+
~~~

**Backup Galeracluster nodes :**
You have two solutions for backuping the database :

1) Run a cron in order to make snapshots of cinder volumes that are attached to database nodes :

~~~bash
cinder snapshot-create --display-name snapshot_name.$(date +%Y-%m-%d-%H.%M.%S) id_volume
~~~
2) Run a cron in order to make database datadir snapshots then upload it in swift containers :
~~~bash
#/bin/bash
mylvmbackup --user=root --mycnf=/etc/mysql/my.cnf --vgname=vg0 --lvname=global --backuptype=tar
swift upload your_back_contenair /var/cache/mylvmbackup/backup/*
rm -rf /var/cache/mylvmbackup/backup/*
~~~

### Resources you could be interested in:
* [ Apache Home page](http://www.apache.org/)
* [ Galera Documentation](http://galeracluster.com/support)
* [ Glusterfs Documentation](https://www.gluster.org/)
* [ Tomcat Documentation](http://tomcat.apache.org/)
* [ Nodejs Documentation](https://nodejs.org/en/)
* [ Nginx Documentation](https://www.nginx.com/resources/wiki/)

----
Have fun. Hack in peace.
