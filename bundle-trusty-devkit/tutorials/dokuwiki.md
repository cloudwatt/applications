
#### Dokuwiki

**Dokuwiki** a son propre port `:8081`, vous devez donc accepter à nouveau le certificat auto-signé
en fonctionde votre navigateur avant d'arriver sur la homepage `:8081/doku.php`. (Par confort, `/dokuwiki`
redirige vers le bon port `:8081`.)

Vous aurez droit à une erreur pour votre premier passage, mais c'est moins grave qu'il n'y parait.
Dokuwiki veut seulement finir son installation avec vous : rendez vous à `:8081/install.php`
et laissez vous guider.

![Dokuwiki install.php](img/dokuwiki_install_php.png)

Quelques choses à garder à l'esprit :

* Nommez le wiki selon vos désirs.
* Definitivement, vous souhaitez activer les ACL.
* Le `Superuser` **doit être un utilisateur LDAP valide**. Il sera le seul à avoir accès à l'admin de Dokuwiki
par la suite.
* Les champs `Real Name` et `E-Mail` et `Password` ne seront pas pris en compte, puisque la référence sera
 le compte LDAP.
* Définissez les ACL selon vos désirs.
* Autoriser l'enregistrement d'utilisateur est une mauvaise idée, sauf si vous souhaitez un espace ouvert
 à la planète. Les utilisateur LDAP auront accès sans plus de configuration.

Enfin, choisissez une licence couvrant le contenu de votre Wiki et sauvegardez. Dokuwiki est maintenant prêt.
Suivez le lien fourni sur la dernière page ou rendez vous à `:8081/doku.php?id=wiki:welcome` et identifiez-vous pour
commencer à utiliser votre wiki !

![Start using Dokuwiki](img/dokuwiki_start_using.png)
