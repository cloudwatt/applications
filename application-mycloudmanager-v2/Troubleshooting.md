# MyCloudManager Troubleshooting

Bien que son architecture soit basée sur des conteneurs Docker et l'orchestrateur Kubernetes, il se peut que MyCloudManager rencontre des difficultés pour instrumentaliser des instances. Quelques pistes :

## Lancement de MyCloudManager
* Quand la stack heat est terminée et toutes les ressources "vertes", attendez VRAIMENT 5 minutes avant de créer votre connexion VPN
* Assurez vous que votre connexion VPN est active
* Sinon redemarrez votre VPN
* Actualisez la page MyCloudManager en rafraichissant votre browser (touche F5)
* Si votre MyCloudManager est bien actif, que vous êtes bien connecté au VPN, mais que vous n'arrivez pas à acceder à l'adresse http://manager.default.svc.mycloudmanager, essayez avec l'adresse http://10.0.1.254:30000. Si cette URL fonctionne c'est que le DNS n'a pas été modifié sur votre poste, il faut alors soit désactiver vos divers par-feu ou Antivirus qui pourraient eventuellement bloquer cette connexion, soit renseigner à la main l'adresse du DNS qui est 10.0.2.2.
* Si vous n'arrivez pas à lancer les applications après avoir cliqué sur GO pour des problèmes de DNS, essayez avec l'adresse http://10.0.1.254:30000, puis re-cliquez sur GO. Vos applications se lanceront avec l'adresse IP fixe (par exemple http://10.0.1.254:30601/ pour Zabbix).
* N'hésitez pas à faire un flushDNS via la commande `ipconfig /flushdns` cela aura pour effet de vider le cache DNS.


## Instrumentalisation d'instances
* Si vos nouvelles instances n'apparaissent pas dans MyCloudManager, vérifier pour vous avez bien inclut le security group de votre stack MyCloudManager dans votre instance. Attention aussi aux aspects réseaux: vos instances doivent pouvoir communiquer avec votre MyCloudManager pour être instrumentalisées.
* Pour pouvoir utiliser le `CloudConfig` dans le wizard de création d'instance, il faut que l'utilisateur **cloud** soit présent sur l'image à déployer. Pour info, celui-ci est présent sur l'ensemble des images fournies par Cloudwatt. Cependant vous pouvez utiliser la commande `Curl` une fois la VM déployée.

## Retirer la stack
* Si vous souhaitez détruire la stack (pour la reconstruire par exemple), assurez vous que vous n'avez plus d'instances qui se référent au security group ou au sous réseau de la stack à détruire.

## Bon à savoir
* Nous avons testé MyCloudManager avec le browser Chrome. Des différences ergonomiques peuvent apparaitre avec d'autres browsers.
* Nous avons testé avec les distributions standards fournies par Cloudwatt. Nous ne pouvons garantir le bon fonctionnement avec des images de distributions importées.
