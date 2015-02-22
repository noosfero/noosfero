Multitenancy support
====================

Multitenancy refers to a principle in software architecture where a single instance of the software runs on a server, serving multiple client organizations (tenants). Multitenancy is contrasted with a multi-instance architecture where separate software instances (or hardware systems) are set up for different client organizations. With a multitenant architecture, a software application is designed to virtually partition its data and configuration, and each client organization works with a customized virtual application instance.

Today this feature is available only for PostgreSQL databases.

This document assumes that you have a new fully PostgresSQL default Noosfero installation as explained at the `INSTALL.md` file.

Separated data
--------------

The items below are separated for each hosted environment:

* Uploaded files
* Database
* Solr index
* ActiveRecord#cache_key
* Feed updater
* Delayed Job Workers

Database configuration file
---------------------------

The file config/database.yml must follow a structure in order to achieve multitenancy support. In this example, we will set 3 different environments: env1, env2 and env3.

Each "hosted" environment must have an entry like this:

    env1_production: &DEFAULT
      adapter: postgresql
      encoding: unicode
      database: noosfero
      schema_search_path: public
      username: noosfero
      domains:
        - env1.com
        - env1.org

    env2_production:
      adapter: postgresql
      encoding: unicode
      database: noosfero
      schema_search_path: env2
      username: noosfero
      domains:
        - env2.com
        - env2.org

    env3_production:
      adapter: postgresql
      encoding: unicode
      database: noosfero
      schema_search_path: env3
      username: noosfero
      domains:
        - env3.com
        - env3.net

The "hosted" environments define, besides the `schema_search_path`, a list of domains that, when accessed, tells which database the application should use. Also, the environment name must end with "`_<hosting>`", where `<hosting>` is the name of the hosting environment.

You must also tell the application which is the default environment.

    production:
      <<: *DEFAULT

On the example above there are only three hosted environments, but it can be more than three. The schemas `env2` and `env3` must already exist in the same database of the hosting environment. As postgres user, you can create them typing:

    $ psql database_name -c "CREATE SCHEMA env2 AUTHORIZATION database_user"
    $ psql database_name -c "CREATE SCHEMA env3 AUTHORIZATION database_user"

Replace `database_name` and `database_user` above with your stuff.

So, yet on this same example, when a user accesses http://env2.com or http://env2.org, the Noosfero application running on production will turn the database schema to `env2`. When the access is from domains http://env3.com or http://env3.net, the schema to be loaded will be `env3`.

There is an example of this file in `config/database.yml.multitenancy`

Preparing the database
----------------------

Now create the environments:

    $ RAILS_ENV=production rake multitenancy:create

This command above will create the hosted environment files equal to their hosting environment, here called 'production'.

Run db:schema:load for each other environment:

    $ RAILS_ENV=env2_production rake db:schema:load
    $ RAILS_ENV=env3_production rake db:schema:load

Then run the migrations for the hosting environment, and it will run for each of its hosted environments:

    RAILS_ENV=production rake db:migrate

Start Noosfero
--------------

Run Noosfero init file as root:

    # invoke-rc.d noosfero start

Feed updater & Delayed job
--------------------------

Just for your information, a daemon of `feed-updater` and `delayed_job` must be running for each environment. Noosfero initializer do this, relax.

Uploaded files
--------------

When running with PostgreSQL, Noosfero uploads stuff to a folder named the same way as the running schema. Inside the upload folder root, for example, will be `public/image_uploads/env2` and `public/image_uploads/env3`.

Adding multitenancy support to an existing Noosfero environment
---------------------------------------------------------------

If you already have a Noosfero environment, you can turn it multitenant by following the steps below in addition to the previous steps:

### 1. Reindex your database

Rebuild the Solr index by running the following task just for your hosting environment, do this as noosfero user:

    $ RAILS_ENV=production rake multitenancy:reindex

### 2. Move the uploaded files to the right place

Add a directory with the same name as your schema name (by default this name is `public`) in the root of each upload directory, for example, `public/articles/0000` will be moved to `public/articles/public/0000`. Do this with the directories `public/image_uploads`, `public/articles` and `public/thumbnails`.

### 3. Fix paths on activities

The profile activities store static paths to the images, so it's necessary to fix these paths. You can do this easily by setting an alias on your webserver. On Apache you can add the three rules below, where 'public' is the schema name:

    RewriteRule ^/articles(.+) /articles/public$1
    RewriteRule ^/image_uploads(.+) /image_uploads/public$1
    RewriteRule ^/thumbnails(.+) /thumbnails/public$1
