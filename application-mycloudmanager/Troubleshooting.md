## MyCloudManager Troubleshooting

Bien que son architecture soit basée sur des conteneurs Docker et l'orchestrateur Kubernetes, il se peut que MyCloudManager rencontre des difficultés pour instrumentaliser des instances. Quelques pistes :
* Assurez vous que votre connexion VPN est active
* Sinon redemarrez votre VPN
* Actualisez la page MyCloudManager en rafraichissant votre browser (touche F5)
* Si votre MyCloudManager est bien actif, que vous êtes bien connecté au VPN, mais que vous n'arrivez pas à acceder à l'adresse http://manager.default.svc.mycloudmanager, essayez avec l'adresse http://10.0.1.254:30000. Si cette URL fonctionne c'est que le DNS n'a pas été modifié sur votre poste, il faut alors soit désactiver vos divers par-feu ou Antivirus qui pourraient eventuellement bloquer cette connexion, soit renseigner à la main l'adresse du DNS qui est 10.0.2.2.
* Si vous n'arrivez pas à lancer les applications après avoir cliqué sur GO pour des problèmes de DNS, essayez avec l'adresse http://10.0.1.254:30000, puis re-cliquez sur GO. Vos applications se lanceront avec l'adresse IP fixe (par exemple http://10.0.1.254:30601/ pour Zabbix).
* N'hésitez pas à faire un flushDNS via la commande `ipconfig /flushdns` cela aura pour effet de vider le cache DNS.
* Si vos nouvelles instances n'apparaissent pas dans MyCloudManager, vérifier pour vous avez bien inclut le security group de votre stack MyCloudManager dans votre instance. Attention aussi aux aspects réseaux: vos instances doivent pouvoir communiquer avec votre MyCloudManager pour être instrumentalisées.
* Nous avons testé MyCloudManager avec le browser Chrome. Des différences ergonomiques peuvent apparaitre avec d'autres browsers.

