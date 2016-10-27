---
layout: applications-fiche
pictonic: true
title: "blueprint3tierauto"
url: blueprint3tierauto.html
date: 2016-10-24 00:00:00
date-creation: "24 octobre 2016"
date-maj: "24 octobre 2016"
description: "Ce blueprint va vous aider à mettre en place une architecture 3-tiers. Nous avons automatisé le déploiement des différents noeuds composant l'architecture. A travers ce blueprint nous vous proposons de mettre en place frontaux web, du glusterfs avec un cluster de base de données. Vous aurez le choix de déployer sur les frontaux web différentes applications (Apache & php, tomcat 8 ou nodejs). Grace à l'autoscaling, ce blueprint s'adapte à la charge à la charge d'une application lors d'un pic de charge."
github: https://github.com/cloudwatt/applications/tree/master/blueprint-3tiers-autoscaling
siteofficiel: 
sitesupport: 
composants:
 - logo: ""
   version: "Glustefs 3.8"
 - logo: ""
   version: "Mariadb 10.1"
 - logo: ""
   version: "Lvm2"
 - logo: ""
   version: "Galeracluster 3.8"
 - logo: ""
   version: "Nodejs 6.x"
 - logo: ""
   version: "Apache 2.4"
 - logo: ""
   version: "Php 5 & 7"
 - logo: ""
   version: "Openjdk 8"
 - logo: ""
   version: "Tomcat 9"
 - logo: ""
   version: "Nginx 1.10"   
 - logo: ""
   version: "Zabbix 3.2"      
 - logo: ""
   version: "Ubuntu Trusty 14.04"
 - logo: ""
   version: "Ubuntu Xenial 16.04"
solutions: "Ce blueprint 3 tier autoscalé est particulièrement utile pour les solutions Cloudwatt suivantes :"
solutions-list: 
 - text: "Développement et test"
prix: "Gratuit pour le blueprint + consommation à l'usage"
logo: 
blogpost-url: http://dev.cloudwatt.com/fr/blog/5-minutes-stacks-episode-trente-sept-blueprint-3tier-autoscale.html
install-url: oneclick/#/heat/blueprint-3tiers
comingsoon: false
type: application
categories: ["devtest"]
---
