# 5 Minutes Stacks, 29 episode : MyStart #

## Episode 29 : MyStart

This stack helps you to initialize your tenant, it helps you to create a keypair, a network and security group. These resources are required to create instances in the cloud.

## Preparations


### The prerequisites to deploy this stack

 * an internet acces
 * a [Cloudwatt account](https://www.cloudwatt.com/cockpit/#/create-contact)
 * a local clone of the git repository [Cloudwatt applications](https://github.com/cloudwatt/applications)

### A one-click chat sounds really nice...

Go to the [Apps page](https://www.cloudwatt.com/fr/applications/index.html) on the Cloudwatt website, choose the apps, press **DEPLOYER** and follow the simple steps... 2 minutes later, a green button appears... **ACCEDER**: you have your starter kit!

### You do not have a way to create the stack from the console?

 We do indeed! Using the console, you can deploy your starting kit:

 1.	Go the Cloudwatt Github in the [applications/blueprint-mystart](https://github.com/cloudwatt/applications/tree/master/blueprint-mystart) repository
 2.	Click on the file named `blueprint-mystart.heat.yml` (or `blueprint-mystart.restore.heat.yml` to [restore from backup](#backup))
 3.	Click on RAW, a web page will appear containing purely the template
 4.	Save the file to your PC. You can use the default name proposed by your browser (just remove the .txt)
 5.  Go to the « [Stacks](https://console.cloudwatt.com/project/stacks/) » section of the console
 6.	Click on « Launch stack », then « Template file » and select the file you just saved to your PC, and finally click on « NEXT »
 7.	Name your stack in the « Stack name » field
 8. Fill the two fields « Name prefix key » and «/ 24 cidr of private network » and click "LAUNCH"

 The stack will be automatically generated (you can see its progress by clicking on its name). When all modules become green, the creation will be complete.
 If you've reached this point, you're already done!

## Enjoy
 For downloading your private key, consult this url `https://console.cloudwatt.com/project/access_and_security/keypairs/nom_votre_stack-prefix/download/`.
 Then click on `Download key pair "prefix-your_stack_name"`.

 Now you can launch your first instance

### Other resources you could be interested in:
* [ Openstack Home page](https://www.openstack.org/)

----
Have fun. Hack in peace.
