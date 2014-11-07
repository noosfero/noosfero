Noosfero installation instructions from source for production environments
==========================================================================

The instructions below can be used for setting up a Noosfero production environment from the Noosfero sources.

Before you start installing Noosfero manually, see the information about the Noosfero Debian package at http://noosfero.org/Development/DebianPackage. Using the Debian packages on a Debian stable system is the recommended method for installing production environments.

If you want to setup a development environment instead of a production one, stop reading this file right now and read the file `HACKING.md` instead.

For a complete installation guide, please see the following web page: http://noosfero.org/Development/HowToInstall

If you have problems with the setup, please feel free to ask questions in the development mailing list.

Requirements
------------

**DISCLAIMER**: this installation procedure is tested with Debian stable, which is currently the only recommended operating system for production usage. It is possible that you can install it on other systems, and if you do so, please report it on one of the Noosfero mailing lists, and please send a patch updating these instructions.

Noosfero is written in Ruby with the "[Rails framework](http://www.rubyonrails.org)", so the process of setting it up is pretty similar to other Rails applications.

You need to install some packages Noosfero depends on. On Debian GNU/Linux or Debian-based systems, all of these packages are available through the Debian archive. You can install them with the following command:

    # apt-get install ruby rake po4a libgettext-ruby-util libgettext-ruby1.8 \
      libsqlite3-ruby rcov librmagick-ruby libredcloth-ruby \
      libwill-paginate-ruby iso-codes libfeedparser-ruby libdaemons-ruby thin \
      tango-icon-theme

On other systems, they may or may not be available through your regular package management system. Below are the links to their homepages.

* Ruby: http://www.ruby-lang.org
* Rake: http://rake.rubyforge.org
* po4a: http://po4a.alioth.debian.org
* Ruby-sqlite3: http://rubyforge.org/projects/sqlite-ruby
* rcov: http://eigenclass.org/hiki/rcov
* RMagick: http://rmagick.rubyforge.org
* RedCloth: http://redcloth.org
* will_paginate: http://github.com/mislav/will_paginate/wikis
* iso-codes: http://pkg-isocodes.alioth.debian.org
* feedparser: http://packages.debian.org/sid/libfeedparser-ruby
* Daemons - http://daemons.rubyforge.org
* Thin: http://code.macournoyer.com/thin
* tango-icon-theme: http://tango.freedesktop.org/Tango_Icon_Library

If you manage to install Noosfero successfully on other systems than Debian,
please feel free to contact the Noosfero development mailing with the
instructions for doing so, and we'll include it here.

As root user
============

Install memcached. On Debian:

    # apt-get install memcached

Study whether you need to raise the ammount of memory it uses for caching, depending on the demand you expect for your site. If you are going to run a high-traffic site, you will want to raise the ammount of memory reserved for caching.

It is recommended that you run noosfero with its own user account. To create such an account, please do the following:

    # adduser --system --group noosfero --shell /bin/sh --home /var/lib/noosfero

(note that you can change the `$HOME` directory of the user if you wish, here we are using `/var/lib/noosfero`)

The `--system` option will tell adduser to create a system user, i.e. this user will not have a password and cannot login to the system directly. To become this user, you have to use sudo:

    # sudo -u noosfero -i
    or
    # su - noosfero

As noosfero user
================

downloading from git
--------------------

Here we are cloning the noosfero repository from git. Note: you will need to install git before.

    $ git clone git://gitorious.org/noosfero/noosfero.git current
    $ cd current
    $ git checkout -b stable origin/stable

downloading tarball
-------------------

Note: replace 0.39.0 below from the latest stable version.

    $ wget http://noosfero.org/pub/Development/NoosferoVersion00x39x00/noosfero-0.39.0.tar.gz
    $ tar -zxvf noosfero-0.39.0.tar.gz
    $ ln -s noosfero-0.39.0 current
    $ cd current

Create the thin configuration file:

    $ thin -C config/thin.yml -e production config

Edit config/thin.yml to suit your needs. Make sure your apache configuration matches the thin cluster configuration, specially in respect to the ports and numbers of thin instances.

*Note*: currently Noosfero only supports Rails 2.3.5, which is the version in Debian Squeeze. If you have a Rails version newer than that, Noosfero will probably not work. You can install Rails 2.3.5 into your Noosfero installation with the following procedure:

    $ cd /var/lib/noosfero/current/vendor
    $ wget http://ftp.de.debian.org/debian/pool/main/r/rails/rails_2.3.5.orig.tar.gz
    $ tar xzf rails_2.3.5.orig.tar.gz
    $ ln -s rails-2.3.5 rails

As root user
============

Setup Noosfero log and tmp directories:

    # cd /var/lib/noosfero/current
    # ./etc/init.d/noosfero setup

Now it's time to setup the database. In this example we are using PostgreSQL, so if you are planning to use a different database this steps won't apply. Pay special attention to the default collation defined on your setup by the environment variable LC_COLLATE because it might interfere in some sorting operations on your database. For more information checkout `man locale`.

    # apt-get install postgresql libpgsql-ruby
    # su postgres -c 'createuser noosfero -S -d -R'

By default Rails will try to connect on postgresql through 5432 port, you can check it on `/etc/postgresql/8.4/main/postgresql.conf` file.

Restart postgresql:
    # invoke-rc.d postgresql restart

Noosfero needs a functional e-mail setup to work: the local mail system should be able to deliver e-mail to the internet, either directly or through an external SMTP server. Please check the documentation at the INSTALL.email file.

As noosfero user
================

Now create the databases:

    $ cd /var/lib/noosfero/current
    $ createdb noosfero_production
    $ createdb noosfero_development
    $ createdb noosfero_test

The development and test databases are actually optional. If you are creating a stricly production server, you will probably not need them.

Now we want to configure Noosfero for accessing the database we just created. To do that, you can 1) copy `config/database.yml.pgsql` to `config/database.yml`, or create `config/database.yml` from scratch with the following content:

    production:
      adapter: postgresql
      encoding: unicode
      database: noosfero_production
      username: noosfero

Now, to test the database access, you can fire the Rails database console:

    $ ./script/dbconsole production

If it connects to your database, then everything is fine. If you got an error message, then you have to check your database configuration.

Create the database structure:

    $ RAILS_ENV=production rake db:schema:load

Compile the translations:

    $ RAILS_ENV=production rake noosfero:translations:compile

Now we must create some initial data. To create your default environment (the first one), run the command below:

    $ RAILS_ENV=production ./script/runner 'Environment.create!(:name => "My environment", :is_default => true)'

(of course, replace "My environment" with your environment's name!)

And now you have to add the domain name you will be using for your noosfero site to the list of domains of that default environment you just created:

    $ RAILS_ENV=production ./script/runner "Environment.default.domains << Domain.new(:name => 'your.domain.com')"

(replace "your.domain.com" with your actual domain name)

Add at least one user as admin of environment:

    $ RAILS_ENV=production ./script/runner "User.create(:login => 'adminuser', :email => 'admin@example.com', :password => 'admin', :password_confirmation => 'admin', :environment => Environment.default, :activated_at => Time.new)"

(replace "adminuser", "admin@example.com", "admin" with the login, email and password of your environment administrator)

To start the Noosfero application servers:

    $ ./script/production start

At this point you have a functional Noosfero installation running, the only thing left is to configure your webserver as a reverse proxy to pass requests to them.


Apache instalation
==================

    # apt-get install apache2

Configuration - noosfero at /
-----------------------------

First you have to enable the following some apache modules:

 * deflate
 * expires
 * proxy
 * proxy_balancer
 * proxy_http
 * rewrite

On Debian GNU/Linux system, these modules can be enabled with the following command line, as root:

    # a2enmod deflate expires proxy proxy_balancer proxy_http rewrite

In other systems the way by which you enable apache modules may be different.

Now with the Apache configuration. You can use the template below, replacing `/var/lib/noosfero/current` with the directory in which your noosfero installation is, your.domain.com with the domain name of your noosfero site. We are assuming that you are running two thin instances on ports 3000 and 3001. If your setup is different you'll need to adjust `<Proxy>` section. If you don't understand something in the configuration, please refer to the apache documentation.

Add a file called "mysite" (or whatever name you want to give to your noosfero site) to `/etc/apache2/sites-available` with the following content, and customize as needed (as usual, make sure you replace "your.domain.com" with you actual domain name, and "`/var/lib/noosfero/current`" with the directory where Noosfero is installed):

    <VirtualHost *:80>
      ServerName your.domain.com

      DocumentRoot "/var/lib/noosfero/current/public"
      <Directory "/var/lib/noosfero/current/public">
        Options FollowSymLinks
        AllowOverride None
        Order Allow,Deny
        Allow from all
      </Directory>

      RewriteEngine On

      # Rewrite index to check for static index.html
      RewriteRule ^/$ /index.html [QSA]

      # Rewrite to check for Rails cached page
      RewriteRule ^([^.]+)$ $1.html [QSA]

      RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
      RewriteRule ^.*$ balancer://noosfero%{REQUEST_URI} [P,QSA,L]

      ErrorDocument 503 /503.html

      ErrorLog /var/log/apache2/noosfero.log
      LogLevel warn
      CustomLog /var/log/apache2/noosfero.access.log combined

      Include /var/lib/noosfero/current/etc/noosfero/apache/cache.conf

    </VirtualHost>

    <Proxy balancer://noosfero>
      BalancerMember http://127.0.0.1:3000
      BalancerMember http://127.0.0.1:3001
      Order Allow,Deny
      Allow from All
    </Proxy>

The cache.conf file included in the end of the <VirtualHost> section is important, since it will tell apache to pass expiration and cache headers to clients so that the site feels faster for users. Do we need to say that using that configuration is strongly recommended?

Enable that site with (as root, replace "mysite" with the actual name you gave to your site configuration):

    # a2ensite mysite

Now restart your apache server (as root):

    # invoke-rc.d apache2 restart

Configuration - noosfero at a /subdirectory
-------------------------------------------

This section describes how to configure noosfero at a subdirectory, what is
specially useful when you want Noosfero to share a domain name with other
applications. For example you can host noosfero at yourdomain.com/social, a
webmail application at yourdomain.com/webmail, and have a static HTML website
at yourdomain.com/.

**NOTE:** Some plugins might not work well with this setting. Before deploying
this setting, make sure you test that everything  you need works properly with
it.

The configuration is similar to the main configuration instructions, except for
the following points. In the description below, replace '/subdirectory' with
the actual subdirectory you want.

1) add a `prefix: /subdirectory` line to your thin configuration file (thin.yml).

1.1) remember to restart the noosfero application server whenever you make
changes to that configuration file.

    # service noosfero restart

2) add a line saying `export RAILS_RELATIVE_URL_ROOT=/subdirectory` to
/etc/default/noosfero (you can create it with just this line if it does not
exist already).

3) You should add the following apache configuration to an existing virtual
host (plus the `<Proxy balancer://noosfero>` section as displayed above):

```
Alias /subdirectory /path/to/noosfero/public
<Directory "/path/to/noosfero/public">
  Options FollowSymLinks
  AllowOverride None
  Order Allow,Deny
  Allow from all

  Include /path/to/noosfero/etc/noosfero/apache/cache.conf

  RewriteEngine On
  RewriteBase /subdirectory
  # Rewrite index to check for static index.html
  RewriteRule ^$ index.html [QSA]
  # Rewrite to check for Rails cached page
  RewriteRule ^([^.]+)$ $1.html [QSA]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteRule ^(.*)$ http://localhost:3000%{REQUEST_URI} [P,QSA,L]
</Directory>
```

3.1) remember to reload the apache server whenever any apache configuration
file changes.

    # sudo service apache2 reload

Enabling exception notifications
================================

This is an optional step. You will need it only if you want to receive e-mail notifications when some exception occurs on Noosfero.

First, install this version of the gem. Others versions may not be compatible with Noosfero:

    # gem install exception_notification -v 1.0.20090728

You can configure the e-mails that will receive the notifications. Change the file config/noosfero.yml as the following example, replacing the e-mails by real ones:

    production:
      exception_recipients: [admin@example.com, you@example.com]


Maintainance
============

To ease the maintainance, install a symbolic link for the Noosfero startup script in your server and add it to the system initialization and shutdown sequences (as root):

    # ln -s /var/lib/noosfero/current/etc/init.d/noosfero /etc/init.d/noosfero
    # update-rc.d noosfero defaults
     Adding system startup for /etc/init.d/noosfero ...
       /etc/rc0.d/K20noosfero -> ../init.d/noosfero
       /etc/rc1.d/K20noosfero -> ../init.d/noosfero
       /etc/rc6.d/K20noosfero -> ../init.d/noosfero
       /etc/rc2.d/S20noosfero -> ../init.d/noosfero
       /etc/rc3.d/S20noosfero -> ../init.d/noosfero
       /etc/rc4.d/S20noosfero -> ../init.d/noosfero
       /etc/rc5.d/S20noosfero -> ../init.d/noosfero

Now to start Noosfero, you do as root:

    # invoke-rc.d noosfero start

To stop Noosfero:

    # invoke-rc.d noosfero start

To restart Noosfero:

    # invoke-rc.d noosfero restart

Noosfero will be automatically started during system boot, and automatically stopped if the system shuts down for some reason (or during the shutdown part of a reboot).

Rotating logs
=============

Noosfero provides an example logrotate configuation to rotate its logs. To use it, create a symbolic link in `/etc/logrotate.d/`:

    # cd /etc/logrotate.d/
    # ln -s /var/lib/noosfero/current/etc/logrotate.d/noosfero

Note that the provided file assumes Noosfero logging is being done in `/var/log/noosfero` (which is the case if you followed the instructions above correctly). If the logs are stored elsewhere, it's recommended that you copy the file over to `/etc/logrotate.d/` and modify it to point to your local log directly.

Upgrading
=========

If you followed the steps in this document and installed Noosfero from the git repository, then upgrading is easy. First, you need to allow the noosfero user to restart the memcached server with sudo, by adding the following line in `/etc/sudoers`:

    noosfero ALL=NOPASSWD: /etc/init.d/memcached

Then, to perform an upgrade, do the following as the noosfero user:

    $ cd /var/lib/noosfero/current
    $ ./script/git-upgrade

The `git-upgrade` script will take care of everything for you. It will first stop the service, then fetch the current source code, upgrade database, compile translations, and then start the service again.

*Note 1*: make sure your local git repository is following the "stable" branch, just like the instructions above. The `master` branch is **not** recommended for use in production environments.

*Note 2*: always read the release notes before upgrading. Sometimes there will be steps that must be performed manually. If that is the case, you can invoke the `git-upgrade` script with the special parameter `--shell` that will give you a shell after the upgrade, which you can use to perform any manual steps required:

    $ ./script/git-upgrade --shell
