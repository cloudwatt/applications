
#### LAM

**LAM** se trouve au chemin `/lam` de votre instance, les mots de passe par défaut de
l'utilisateur *Administrator* ( *master password* et *server preferences* password) sont définis à **c10udw477**.
![LAM Login](img/lam_login.png)

Vous pouvez maintenant créer votre premier compte. Le compte "cloudwatt" est déjà présent et est le compte
d'administration de LDAP. Il est vitale de changer son mot de passe mais délicat de modifier d'autres
attributs du compte. Cela pourrait avoir des effets néfastes sur le fonctionnement de LAM. Ne changez autre
chose que son mot de passe que si vous savez ce que vous faites.

![Create LAM user](img/create_ldap_user.png)

Une fois sur la page de création de compte, entrez les détails de votre nouvel utilisateur. Sur le premier onglet
(Personal), la seule information obligatoire est le "last name", il vous faut également remplir l'email
qui est nécessaire pour GitLab, Dokuwiki et Let's Chatt. Une fois ceci fait, affichez l'onglet "Unix".

![Enter user information](img/enter_user_info.png)

![Enter user email](img/enter_user_email.png)

Les champs `User name` et `Common name` sont remplis avec des exemples générés par LAM. Remplacez les avec
 vos valeurs. `User name` sera votre identifiant pour tous les outils du DevKit. C'est le **seul champ qui ne
 peut être modifié à l'avenir**. Le champ `Common name` sera utilisé par les outils du DevKit pour faire référence
 à l'utilisateur.

![Enter user data](img/enter_user_data.png)

N'enregistrez pas encore votre compte ! Avant cela, définissez le mot de passe utilisateur. Le bouton est
placé à droite du bouton de sauvegarde.

![Set user password](img/set_user_pw.png)

Vous pouvez générer un mot de passe aléatoire ou en rentrer un en dur. Quel que soit votre choix, les
modifications seront active après sauvegarde du compte. Si vous générez un mot de passe, pensez à le copier
quelques part avant la sauvegarde.

![Random password](img/random_pw.png)

Bien, vous avez créé votre utilisateur. A l'avenir, les utilisateurs se connectant à LAM ne pourront modifier que
leur propre compte.

![LAM Main Login Settings](img/lam_login_settings.png)

Avant de passer à la suite, **changez le mot de passe master et le mot de passe des préférences serveur**.

`Edit general settings`

![LAM Change Master Password](img/lam_master_pw.png)

`Edit server profiles`

![LAM Change Master Password](img/lam_confmain_pw.png)
