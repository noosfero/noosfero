README - Social Statistcs (Social Statistics Plugin)
================================

Social Statistics is a plugin that provides custom Noosfero's network graphs
and checks. It comes with a default set of queries and dashboards but can be
customized through the web interface with new ones.

This plugins is a wrapper for the blazer gem.

INSTALL
=======

Dependencies
-----------

This plugin depends on the following gems:
* blazer
  * chartkick
  * safely\_block
    * errbase

This gems are packaged (debian packages) and available on Noosfero's
repository. If you have this repository properly configured the
`script/debian-install.rb` should do all the work and install this dependencies
on its own.

If you want to install them manually you can do it as well:

```
# apt-get install ruby-errbase ruby-safely-block ruby-chartkick ruby-blazer
```

Configuration
-------------

This plugin needs a configuration file that define all of its basic behavior.
This configuration file should be created on `config/blazer.yml`. You may copy
`config/blazer.yml.dist` as a starting point since it also defines necessary
configurations for the default queries.

If you are using this plugin on production environment should be concerned with
the `data_sources[main][url]` option which defines the url for database
connection. This url may be passed as an environment variable (as it is used in
the `config/blazer.yml.dist` file) or be added directly on the
`config/blazer.yml` file. This configuration follows the following format:

```
postgres://user:password@hostname:5432/database
```

Another thing you should also be aware on production setups is the use of a
read-only database user for security reasons. Although accesses to the database
are treated by the gem, any vulnerability bug may expose your database to an
attacker. In order to have a higher level of security you should create a
specific user with read-only permissions to access the database for this plugin.

On Postgresql, this can be done with the following code:

```
BEGIN;
CREATE ROLE blazer LOGIN PASSWORD 'secret123';
GRANT CONNECT ON DATABASE database_name TO blazer;
GRANT USAGE ON SCHEMA public TO blazer;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO blazer;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO blazer;
COMMIT;
```

You can check how to setup this user on different databases here:
https://github.com/ankane/blazer#permissions

Theme Customization
-------------------

This plugin extends Blazer's layout file to allow a Noosfero environment theme
to customize its appearance. To use this customization, create a folder named
"blazer" inside your theme folder and use the following files:

* style.css
* header.html.erb
* footer.html.erb


Enable Plugin
-------------

To enable this plugin do:

cd <your_noosfero_dir>
./script/noosfero-plugins enable social\_statistics

Activate Plugin
-------------

As a Noosfero administrator user, go to administrator panel:

- Click on "Plugins" option
- Click on "Social Statistics" check-box
- Save the changes


DEVELOPMENT
===========

Get Noosfero's development repository:

$ git clone https://gitlab.com/noosfero/noosfero.git

Running tests
--------------------

$ rake test:noosfero\_plugins:social\_statistics

Get Involved
============

If you found any bug and/or want to collaborate, please send an e-mail to noosfero-dev@listas.softwarelivre.org

LICENSE
=======

Copyright (c) The Author developers.

See Noosfero license.


AUTHORS
=======

Rodrigo Souto (rodrigo at colivre.coop.br)
