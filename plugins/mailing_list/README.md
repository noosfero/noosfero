Overview
========

This Noosfero plugin provides an integration between Sympa's mailing lists and
Noosfero groups. This integration is acomplished by mailing the group's topics,
posts and comments to the mailing list and also receiving replys from the
mailing list and creating the respective replies as Noosfero comments. 

Although the plugin assumes a connection with a working Sympa instance through
its SOAP API, it *does not* deploy the Sympa service. You must have a proper
Sympa service running in order to use this plugin.

Features
========

As an environment administrator
-------------------------------

First of all you need to access the plugin configuration page through
`Administration -> Plugins -> Mailing List (Configuration)`. In this page, if you
press the "Edit" button you can define the Sympa API Url and also the Sympa
Interface Url. In order to connect to the API, you must provide the
administrator email and passoword. This e-mail is also the one that Noosfero
will use to receive e-mails from the mailing lists.

Also in this page you can manage communities and enterprises mailing lists by
deploying (create the mailing list), activating or deactivating them.

As a group administrator
------------------------

The plugin will add a new button "Mailing List" on the group Control Panel.
This button leads to a page where you can configure the behaviour of the
group's mailing list. You can deploy, activate or deactivate the mailing list
and you can also manage the subscribers of the mailing list. By default, all
members of the group a subscribed on the list. You can unsubscribe any of
them anytime you want but you'll only be able to subscribe them back again
after their approval.

Here you can also define which blogs or foruns will be watched and have their
topics and comments sent to the mailing list.

As a member of a group
----------------------

Just like the with the group, the plugin also adds a "Mailing List" button on
the person's Control Panel. In this page you can manage in which groups you
want to be subscribed. If you unsubscribe for any group, you'll need the group
administrator's approval to subscribe back again.

Installation
============

Enable Plugin
-------------

You need to enable MailingListPlugin at your system:

```
# Development environment

cd <your_noosfero_dir>
./script/noosfero-plugins enable mailing_list

# Production environment

noosfero-console enable mailing_list

````
If you are on a Debian Stable OS, the dependencies will be installed
automatically as debian packages. If you are on any other SO, it's recommended
that you install the dependencies with `bundle` through rubygems.

Activate Plugin
-------------

As a Noosfero administrator user, go to administrator panel:

- Click on "Plugins" option
- Click on "Mailing List" check-box

In order to receive e-mails from the mailing list and convert them into
Noosfero comments, you need to have a local MTA that is capable of piping
e-mail to programs/scripts. The plugin provides the `script/mail_receiver.rb`
script which receives a piped e-mail and proxies it to the plugin to handle it.

MTA Configuration
=================

The plugin was currently only tested with `Postfix` as a local MTA. If you
prefer any other MTA, be warned that it was not properly tested and might
present unkownw problems. If you are able to use other MTA, please include the
instruction of how to use it here.

Postfix
-------

In order to redirect received e-mails to the application, you need to add the following line in the file `/etc/aliases`

```
noosfero: "| RAILS_ENV=production ruby --encoding utf-8 <RAILS_ROOT>/plugins/mailing_list/script/mail_receiver.rb" 
````

This assumes your are receiving e-mails in the server as `noosfero@<your.domain>`.

Then run:

```
# newaliases
# service postfix reload
```

Get Involved
============

If you found any bug and/or want to collaborate, please send an e-mail to noosfero-dev@listas.softwarelivre.org.br or noosfero-br@listas.softwarelivre.org.br.

LICENSE
=======

Copyright (c) The Author developers.

See Noosfero license.


AUTHORS
=======

* Rodrigo Souto (rodrigo at colivre.coop.br)
* Gabriel Silva (gabrielsilva at colivre.coop.br)

ACKNOWLEDGMENTS
===============

The author have been supported by Colivre.
