#!/usr/local/bin/php -f
<?php

# PROVIDE: cw_setup
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

function retrievePublicIP() {

	$wanintf = get_real_wan_interface();

	$url = "http://169.254.169.254/latest/meta-data/public-ipv4";
	$public_ipv4 = retrieveMetaData($url);

	if (is_ipaddrv4($public_ipv4)) {
		$natipfile = "/var/db/natted_{$wanintf}_ip";
		file_put_contents($natipfile, $public_ipv4);

	}

}

function addSSHkey(){

$key=retrieveMetaData("http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key");
shell_exec ('echo "' . $key .'">>~/.ssh/authorized_keys');

}
####main#################################

$tmp=retrieveMetaData("http://169.254.169.254/openstack/latest/user_data");
parse_str($tmp);
parse_config(true);

if($config['interfaces']['lan']['ipaddr'] != $ip_lan)
{
addSSHkey();
#retrievePublicIP();
$config['interfaces']['lan']['enable'] = true;
$config['interfaces']['lan']['ipaddr']= $ip_lan;
$config['interfaces']['lan']['subnet']= $netmask;
$c=count($config['gateways']['gateway_item']);
$k=$c + 1;
$config['gateways']['gateway_item'][$c] = array('interface'=>'lan', 'gateway'=>$ip_gateway, 'name'=>'GW_LAN_'.$k,'weight'=>1,'ipprotocol'=>'inet','interval'=>'','descr'=>'Interface lan Gateway');
$config['interfaces']['lan']['gateway']= 'GW_LAN_'.$k;
$config['dhcpd']['lan']['enable'] = true;
$config['dhcpd']['lan']['range']['from']=$dhcp_to;
$config['dhcpd']['lan']['range']['to']=$dhcp_from;



	/* to save out the new configuration (config.xml) */
	write_config();
  log_error("rc.reload_all: Reloading all configuration settings.");
  shell_exec('/etc/rc.reload_all');
  wait(10);
 #shell_exec('pfSsh.php playback enableallowallwan');
  shell_exec('/etc/rc.initial');
}

else

  echo('This configuration is already existed');

?>
