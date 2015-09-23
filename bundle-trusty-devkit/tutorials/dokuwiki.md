
#### Dokuwiki

**Dokuwiki** has it's own port, `:8081`, so validate the HTTPS certificate again (depending on your browser) and you will reach the homepage, `:8081/doku.php`. (For convenience, `/dokuwiki` rewrites to `:8081`.)

Don't worry, it looks worse than it is! Dokuwiki just wants you to finish the setup. Simply go to `:8081/install.php` to "install" Dokuwiki.

![Dokuwiki install.php](img/dokuwiki_install_php.png)

A few things of note here:

* Name the wiki whatever you wish.
* You definitely want ACL enabled.
* The `Superuser` **must be a valid LDAP user**. They will be the only one with access to the Dokuwiki admin panel by default.
* The `Real Name` and `E-Mail` and `Password` fields will not be taken into account at all, and will be replaced with what you entered in LAM (LDAP).
* Set the ACL level to suit your needs.
* Allowing users to register themselves is counterproductive, unless you don't mind your wiki being a free-for-all. LDAP users will automatically have access.

Below it will ask you to pick a license for your wiki, study up if you wish, then make your pick and save. Dokuwiki is now ready: follow the link on the page you were redirected to (or go to `:8081/doku.php?id=wiki:welcome`) and sign in to start using your wiki!

![Start using Dokuwiki](img/dokuwiki_start_using.png)
