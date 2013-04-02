README - Mezuro Plugin
======================

Mezuro is a source code tracking platform based on Noosfero social networking
platform with Mezuro Plugin actived to access Kalibro Web Service.


INSTALL
=======

Dependences
-----------

See the Noosfero INSTALL (and HACKING) file. After install Noosfero, you must
install Mezuro dependences:

$ gem install --no-ri --no-rdoc nokogiri -v 1.5.0
$ gem install --no-ri --no-rdoc wasabi -v 2.0.0
$ gem install --no-ri --no-rdoc savon -v 0.9.7
$ gem install --no-ri --no-rdoc googlecharts

$ gem uninstall rack
$ gem install --no-ri --no-rdoc rack -v 1.0.1


*with RVM*

if you want to use RVM (Ruby Version Manager) environment, just run:

$ plugins/mezuro/script/install/install-rvm.sh


Enable Mezuro Plugin
--------------------

Also, you need to enable Mezuro Plugin at your Noosfero installation:

cd <your_noosfero_dir>
./script/noosfero-plugins enable mezuro


Install Service
---------------

To run Mezuro (Noosfero with Mezuro Plugin), you need to install the Kalibro
Service. For that, see:
https://gitorious.org/kalibro/kalibro/blobs/master/INSTALL


Configure Service Address
-------------------------

Addictionaly, copy service.yml.example to service.yml and define your Kalibro
Service address:

$ cd <your_noosfero_dir>/plugin/mezuro
$ cp service.yml.example service.yml

If you install Kalibro Service at localhost, just keep the default
adress:

http://localhost:8080/KalibroService/


Set Licences list
-----------------

$ cd <your_noosfero_dir>/plugin/mezuro
$ cp licence.yml.example licence.yml


Apply Mezuro Theme
---------------------

(Our RVM install script already do that)

If you want, you can use the Mezuro default theme:

$ cd public/designs/themes && rm -f default
$ git clone git://gitorious.org/mezuro/mezuro-theme.git
$ ln -s mezuro-theme/ default && cd ../../../


Active Mezuro Plugin on Noosfero Environment
--------------------------------------------

As a Noosfero administrator user, go to administrator panel:

- Click on "Enable/disable plugins" option
- Click on "Mezuro Plugin" check-box


DEVELOPMENT
===========

Get the Mezuro (Noosfero with Mezuro Plugin) development repository:

$ git clone https://gitorious.org/+mezuro/noosfero/mezuro
$ cd mezuro
$ git checkout mezuro

Running Mezuro tests
--------------------

$ rake test:noosfero_plugins:mezuro

or just:

$ rake test:noosfero_plugin_mezuro:units
$ rake test:noosfero_plugin:mezuro:functionals


Get Involved
============

If you found any bug and/or want to collaborate, please send an e-mail to
paulo@softwarelivre.org


LICENSE
=======

Copyright (c) The Author developers.

See Noosfero license.


AUTHORS
=======

Please, see the Mezuro AUTHORS file.


ACKNOWLEDGMENTS
===============

The authors have been supported by organizations:

University of São Paulo (USP)
FLOSS Competence Center
http://ccsl.ime.usp.br

Brazilian National Research Council (CNPQ)
http://www.cnpq.br/
