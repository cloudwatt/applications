#!/usr/local/bin/php -f
<?php

# PROVIDE: cw_setup.sh
### Written by the CAT (Cloudwatt Automation Team)
#/usr/local/etc/rc.d/cw_setup.sh
require("globals.inc");
require("config.inc");
require("auth.inc");
require("interfaces.inc");
require_once("functions.inc");
require_once("filter.inc");

function retrieveMetaData($url) {

        if (!$url)
                return;

        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $url);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_FAILONERROR, true);
        curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 15);
        curl_setopt($curl, CURLOPT_TIMEOUT, 30);
        $metadata = curl_exec($curl);
        curl_close($curl);

        return($metadata);
}


function addSSHkey(){

$key=retrieveMetaData("http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key");
shell_exec ('echo "' . $key .'">>~/.ssh/authorized_keys');

}

####main#################################


$tmp=retrieveMetaData("http://169.254.169.254/openstack/latest/user_data");
parse_str($tmp);
parse_config(true);

$config['system']['hostname'] = $hostname;
$config['system']['domain'] = $domain;
$config['system']['dnsserver']['0'] = '185.23.94.244';
$config['system']['dnsserver']['1'] = '185.23.94.245';


$config['interfaces']['wan']['enable'] = 'true';
$config['interfaces']['wan']['if'] = 'vtnet0';
$config['interfaces']['wan']['descr'] = 'WAN';
$config['interfaces']['wan']['ipaddr'] = 'dhcp';


if($config['interfaces']['lan']['ipaddr'] != $ip_lan)
{

addSSHkey();
$config['interfaces']['lan']['enable'] = true;
$config['interfaces']['lan']['if'] = 'vtnet1';
$config['interfaces']['lan']['descr'] = 'LAN';
$config['interfaces']['lan']['ipaddr']= $ip_lan;
$config['interfaces']['lan']['subnet']= 24;

###conf synnc interface


if($type) {

$config['interfaces']['pfsync']['enable'] = 'true';
$config['interfaces']['pfsync']['if'] = 'vtnet2';
$config['interfaces']['pfsync']['descr'] = 'PFSYNC';
$config['interfaces']['pfsync']['ipaddr'] = $ip_sync ;
$config['interfaces']['pfsync']['subnet'] = 24;

$config['filter']['rule']['2']['type'] = 'pass';
$config['filter']['rule']['2']['interface'] = 'pfsync';
$config['filter']['rule']['2']['ipprotocol'] = 'inet';
$config['filter']['rule']['2']['tracker']= '0100000103';
$config['filter']['rule']['2']['source']['any']= '';
$config['filter']['rule']['2']['destination']['any'] = '';
$config['filter']['rule']['2']['descr'] = 'Allow PFSYNC';


$config['hasync']['pfsyncenabled'] = 'on';
$config['hasync']['pfsyncpeerip'] = $ip_peer;# ip backup or master
$config['hasync']['pfsyncinterface'] = 'pfsync';

$config['hasync']['synchronizeusers'] = 'on';
$config['hasync']['synchronizeauthservers'] = 'on';
$config['hasync']['synchronizecerts'] = 'on';
$config['hasync']['synchronizerules'] = 'on';
$config['hasync']['synchronizeschedules'] = 'on';
$config['hasync']['synchronizealiases'] = 'on';
$config['hasync']['synchronizenat'] = 'on';
$config['hasync']['synchronizeipsec'] = 'on';
$config['hasync']['synchronizeopenvpn'] = 'on';
$config['hasync']['synchronizedhcpd'] = 'on';
$config['hasync']['synchronizewol'] = 'on';
$config['hasync']['synchronizestaticroutes'] = 'on';
$config['hasync']['synchronizelb'] = 'on';
$config['hasync']['synchronizevirtualip'] = 'on';
$config['hasync']['synchronizetrafficshaper'] = 'on';
$config['hasync']['synchronizetrafficshaperlimiter'] = 'on';
$config['hasync']['synchronizetrafficshaperlayer7'] = 'on';
$config['hasync']['synchronizednsforwarder'] = 'on';
$config['hasync']['synchronizecaptiveportal'] = 'on';




if($type == 'MASTER') {

$config['virtualip']['vip']['0']['mode'] = 'carp';
$config['virtualip']['vip']['0']['interface'] = 'lan';
$config['virtualip']['vip']['0']['vhid'] = '1';
$config['virtualip']['vip']['0']['advskew'] = '0';
$config['virtualip']['vip']['0']['advbase'] = '1';
$config['virtualip']['vip']['0']['password'] = 'pfsense';
$config['virtualip']['vip']['0']['descr'] = '';
$config['virtualip']['vip']['0']['type'] = 'single';
$config['virtualip']['vip']['0']['subnet_bits'] = '24';
$config['virtualip']['vip']['0']['subnet'] = $vip_lan; #vip lan


$config['hasync']['synchronizetoip'] = $ip_peer;
$config['hasync']['username'] = 'admin';
$config['hasync']['password'] = 'pfsense';

                    }
}

shell_exec('rm -rf /tmp/config.cache');
write_config();
shell_exec('/etc/rc.reload_all');
exit();


}

else

echo('This configuration is already existed');
exit();


?>
