
#### GitLab

**GitLab** is next! You may have noticed you fell onto the GitLab login page when you entered the DevKit IP address. We put GitLab at the root to simplify the usage of Git. Before you begin using GitLab, you will want to configure the admin account.

![GitLab log in to admin account](img/gitlab_root_login.png)

To log into the admin account for the first time, switch to the `Standard` sign-in tab and log in with *root*, the admin username. The default password is **5iveL!fe**, but it won't stick: you will be prompted to make a new password immediately.

![GitLab change root password](img/gitlab_new_pw.png)

Log back in with your new password to access your GitLab for the first time! Since you are logged in as admin, you have access to a special configuration area of GitLab.

![GitLab go to admin section](img/gitlab_to_admin.png)

There's a ton of cool stuff here, but the GitLab documentation is better suited to teach you all about it. For the setup of the DevKit, you only really need to change a few settings.

![GitLab go to admin settings section](img/gitlab_to_settings.png)

By default, the GitLab's `Visibility and Access Controls` are pretty severe, I recommend the setup below, but of course it's up to you.

![GitLab settings: Visibility and Access Controls](img/gitlab_settings1.png)

The only setting that is truly important for the DevKit is likely the `Sign-up enabled` setting. **If this is left checked, then anyone can create an account and access your projects.** Without it, only accounts created through LDAP and the *root* admin account will still have access to GitLab; no one else can enter.

![GitLab settings: Sign-in Restrictions](img/gitlab_settings2.png)

**Don't forget to save at the bottom of the Settings page!** If you don't save, none of the changes will be taken into account. Also remember that only the *root* account has access to the administrative section of GitLab, and that the *root* account is NOT managed by LDAP.

On a side note, if you ever need to receive mail from the DevKit (whichever tool it's from), *check your Spam*. Email from fresh new servers behind an domain-less IP address is a surefire way to the Spam folder, so make that your first stop after your inbox.

That's it for the GitLab setup! Once you are satisfied with the settings, log out of the *root* account and head on to `/dokuwiki`!
