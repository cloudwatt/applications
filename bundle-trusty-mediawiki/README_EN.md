# 5 Minutes Stacks, épisode 20 : Mediawiki #

## Episode 20 : Mediawiki

![mediawikilogo](https://upload.wikimedia.org/wikipedia/commons/0/01/MediaWiki-smaller-logo.png)

MediaWiki is a free and open-source wiki application. It was originally developed by the Wikimedia Foundation and runs on many websites, including Wikipedia, Wiktionary and Wikimedia Commons.It is written in the PHP programming language and uses a backend database.

## Preparations

### The version
 - Ubuntu Trusty 14.04.2
 - MediaWiki 1.26.0
 - Mysql  5.7

### The prerequisites to deploy this stack

 * an internet acces
 * a Linux shell
 * a [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact), with an [existing keypair](https://console.cloudwatt.com/project/access_and_security/?tab=access_security_tabs__keypairs_tab)
 * the tools [OpenStack CLI](http://docs.openstack.org/cli-reference/content/install_clients.html)
 * a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### Size of the instance

 Per default, the script is proposing a deployement on an instance type "Small" (s1.cw.small-1).  Instances are charged by the minute and capped at their monthly price (you can find more details on the [Pricing page](https://www.cloudwatt.com/en/pricing.html) on the Cloudwatt website). Obviously, you can adjust the stack parameters, particularly its defaut size.

### By the way...

 If you do not like command lines, you can go directly to the "run it thru the console" section by clicking [here](#console)

## What will you find in the repository

 Once you have cloned the github, you will find in the `bundle-trusty-mediawiki/` repository:

 * `bundle-trusty-mediawiki.heat.yml`: HEAT orchestration template. It will be use to deploy the necessary infrastructure.
 * `stack-start.sh`: Stack launching script. This is a small script that will save you some copy-paste.
 * `stack-get-url.sh`: Flotting IP recovery script.


## Start-up

### Initialize the environment

 Have your Cloudwatt credentials in hand and click [HERE](https://console.cloudwatt.com/project/access_and_security/api_access/openrc/).
 If you are not logged in yet, you will go thru the authentication screen then the script download will start. Thanks to it, you will be able to initiate the shell accesses towards the Cloudwatt APIs.

 Source the downloaded file in your shell. Your password will be requested.

 ~~~ bash
 $ source COMPUTE-[...]-openrc.sh
 Please enter your OpenStack Password:

 ~~~

 Once this done, the Openstack command line tools can interact with your Cloudwatt user account.

### Adjust the parameters

 With the `bundle-trusty-mediawiki.heat.yml` file, you will find at the top a section named `parameters`. The sole mandatory parameter to adjust is the one called `keypair_name`. Its `default` value must contain a valid keypair with regards to your Cloudwatt user account. This is within this same file that you can adjust the instance size by playing with the `flavor` parameter.

 ~~~ yaml
 heat_template_version: 2013-05-23


 description: Basic all-in-one MEDIAWIKI stack


 parameters:
   keypair_name:
     default: keypair_name        <-- Indicate here your keypair
     description: Keypair to inject in instances
     type: string

   flavor_name:
     default: s1.cw.small-1              <-- indicate here the flavor size
     description: Flavor to use for the deployed instance
     type: string
     constraints:
       - allowed_values:
           - s1.cw.small-1
           - n1.cw.standard-1
           - n1.cw.standard-2
           - n1.cw.standard-4
           - n1.cw.standard-8
           - n1.cw.standard-12
           - n1.cw.standard-16

 [...]
 ~~~

 In a shell, run the script `stack-start.sh`:

 ~~~ bash
 $ ./stack-start.sh MEDIAWIKI «my-keypair-name»
 Enter your new admin password:
 Enter your new password once more:
 Creating stack...
 +--------------------------------------+------------+--------------------+----------------------+
 | id                                   | stack_name | stack_status       | creation_time        |
 +--------------------------------------+------------+--------------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | MEDIAWIKI | CREATE_IN_PROGRESS | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+--------------------+----------------------+
 ~~~

 Within 5 minutes the stack will be fully operational. (Use watch to see the status in real-time)

 ~~~ bash
 $ watch -n 1 heat stack-list
 +--------------------------------------+------------+-----------------+----------------------+
 | id                                   | stack_name | stack_status    | creation_time        |
 +--------------------------------------+------------+-----------------+----------------------+
 | xixixx-xixxi-ixixi-xiixxxi-ixxxixixi | MEDIAWIKI | CREATE_COMPLETE | 2025-10-23T07:27:69Z |
 +--------------------------------------+------------+-----------------+----------------------+
 ~~~

### Enjoy

Once all this makes you can connect via a Web browser on your mediawiki server to begin to parametrize him

http://floatingIP/mediawiki

You have to arrive on this page:

![imagesetup](https://www.siteground.com/img/knox/tutorials/uploaded_images/images/mediawiki/new/image1.jpg)

The login of your base is 'mediawiki' and the password are in /etc/mediawiki/pasword_db

![confBDD](https://www.siteground.com/img/knox/tutorials/uploaded_images/images/mediawiki/new/inst3.jpg)

When you the generated the file `LocalSettings.php` backup her,

Now have to copy the `LocalSettings.php` it in the directory `/etc/mediawiki` to your server via the following command :

~~~bash
$ scp /Telechargement/LocalSettings.php -oIdentityFile "directory ssh key" cloud@floattingIP:/var/www/html/mediawiki/
~~~

Once this operation made to launch the command

```
# service apache2 restart
```

Make a refresh on the url http://floatingIP/mediawiki

Mediawiki is now configured you can begin to write your articles,


#### Other resources you could be interested in:

* [Mediawiki Homepage](https://www.mediawiki.org/wiki/MediaWiki/fr)
* [Mediawiki Documentation](https://www.mediawiki.org/wiki/Documentation/fr)
