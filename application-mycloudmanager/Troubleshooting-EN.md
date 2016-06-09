# MyCloudManager Troubleshooting

Although it's architecture is based on Docker containers and orchestrator Kubernetes it may MyCloudManager having trouble to instrumentalize instances. Some hints :


## Launcing MyCloudManager
* When your stack heat is completed and all the resources are "green", wait REALLY 5 minutes before you setup the VPN connection
* Make sure your VPN connection is active
* Otherwise restart your VPN
* Refresh the page MyCloudManager by refreshing your browser ( F5 )
* If your toolbox is active , you are connected to the VPN, but you do not get access to the http://manager.default.svc.mycloudmanager try with http://10.0.1.254:30000. If this URL works is that the DNS has not been changed on your computer, you must then either disable your various Antivirus or firewall that could possibly block this connection. The DNS are located in 10.0.2.2.
* If you are unable to launch applications when you click GO to DNS problems, try the address
http://10.0.1.254:30000, then re-click GO. Your applications will launch with the fixed IP address (eg http://10.0.1.254:30601/ for Zaabix).
* Feel free to do a flushdns via the command ` ipconfig / flushdns` it will effectively flush the DNS cache.

## Attach Instances
* If your new instance does not appear in MyCloudManager, check you if you have includes the security group of your stack MyCloudManager in your instance. Be carrefull of networks aspects: your instance has to communicate with your MyCloudManager to be instrumentalised.
* To use the `CloudConfig` in the wizard, we need the user **cloud** in the image to deploy. FYI, it is present on all the images provided by Cloudwatt.However you can use the `Curl` once deployed VM.

## Removing the stack
* If you want to remove the stack running MyCloudManager (for exemple to launch an other one), ensure that you do not have instances on which the security group and/or the subnet is mentionned

## Good to know
* We have tested MyCloudManager with Chrome. Some ergonomic differences can appear with other web browsers.
* We have tested MyCloudManager with the official Cloudwatt distributions. We cannot warantee the good run of MyCloudManager on instances launched with imported or modified images
