Noosfero instructions for developers
====================================

A work about your the development platform
------------------------------------------

These instructions are tested and known to work on Debian stable and via Rubygems, which is the system that the Noosfero core developers use to work on Noosfero.

If you want to use another OS, read "Instructions for other systems" below.

Download the source code:

    $ git clone https://gitlab.com/noosfero/noosfero.git
    $ cd noosfero


Instructions for Debian stable
------------------------------

Run the quick start script:

    $ ./script/quick-start

Now you can execute the development server with:

    $ rails s

You will be able to access Noosfero at http://localhost:3000/

If you want to use a different port than 3000, pass `-p <PORT>` to `./script/development`


Instructions for Rubygems
------------------------------

Setup an RVM development environment. Further instructions can be found on: http://noosfero.org/bin/view/Development/DepsWithRVMAndGems

Run the bundle command

    $ bundle install

Configure your PostgreSQL database on:

    $ vim config/database.yml
   
You should see an example of configuration here 'config/database.yml.pgsql'

Now you can execute the development server with:

    $ rails s

You will be able to access Noosfero at http://localhost:3000/


Instructions for other systems
------------------------------

On other OS, you have many options:

### 1) using a chroot or a VM with Debian stable (easier)

Use a chroot (http://wiki.debian.org/Schroot) or a Virtual Machine (e.g. with VirtualBox) with a Debian stable system and follow the instructions above for Debian stable.

### 2) Installing dependencies on other OS (harder)

If you want to setup a development environment in another OS, you can create a file under `./script/install-dependencies/`, called `<OS>-<CODENAME>.sh`, which installed the dependencies for your system. With this script in place, `./script/quick-start` will call it at the point of installing the required packages for Noosfero development.

You can check `./script/install-dependencies/debian-squeeze.sh` to have an idea of what kind of stuff that script has to do.

If you write such script for your own OS, *please* share it with us at the development mailing list so that we can include it in the official repository. This way other people using the same OS will have to put less effort to develop Noosfero.

### 3) Using a docker image

Use a docker image to run an out-of-the-box development environment. Further information can be found on: https://hub.docker.com/r/noosfero/dev-rails4/

#### Building the image locally

The configuration is setup to run two containers, one with postgres and the other with noosfero. There are two options, development and production mode.
- Development:  
```
docker-compose -f dev.yml up --build
```
This configuration synchronize noosfero local repository with the code into the container. You'll be able to edit the code outside the docker container.  
You still able to use bash and other commands inside the container. After it is running, type the command:  
```
docker-compose -f dev.yml exec noosfero bash
```
You can access the web interface at `http://localhost:3000`

- Production:
```
docker-compose -f prod.yml up --build
```
Before you run this command be aware that there are default database credentials in the `prod.yml` file. So, for several security reasons change it locally in both yml sections `postgres` and `noosfero`. Everything else is done automatically and you'll be able to access the production server at `http://localhost`

#### Using the docker-compose alternative in OSX

If you are using OSX, you may experience performance issues when using local volumes (more [here](https://github.com/docker/for-mac/issues/77)). You can use docker-sync as an alternative to regular file system mounted volumes.

Before starting the containers, start the sync daemon and wait until the command returns (it might take a bit).

```
docker-sync start
```

Then, start the containers using the OSX docker-compose file.

```
docker-compose -f osx.yml up --build
```

If you experience syncing issues, stop the containers and run `docker-sync clean`. Then, start docker-sync again before starting the containers.

Submitting your changes back
----------------------------

For now please read:

- Coding conventions
  http://noosfero.org/Development/CodingConventions
- Patch guidelines
  http://noosfero.org/Development/PatchGuidelines
