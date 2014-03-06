XMPP/Chat Setup
===============

The samples of config file to configure a XMPP/BOSH server with ejabberd,
postgresql and apache2 can be found at util/chat directory.

This setup supposes that you are using Noosfero installed via Debian package
in a production environment.

Steps
=====

This is a step-by-step guide to get a XMPP service working, in a Debian system.

## 1. Install the required packages

    # apt-get install ejabberd odbc-postgresql librestclient-ruby pidgin-data ruby1.8-dev
    # gem install SystemTimer

## 2. Ejabberd configuration

    # cp /usr/share/noosfero/util/chat/ejabberd.cfg /etc/ejabberd/

Edit the /etc/ejabberd/ejabberd.cfg file and set your domain on the first 2 lines.

## 3. Configuring Postgresql

Give permission to noosfero user create new roles, login as
postgres user and execute:

    $ psql
    postgres=# GRANT CREATE ON DATABASE noosfero TO noosfero;

Change the postgresql authentication method to md5 instead of ident,
add the following line to the file /etc/postgresql/8.4/main/pg_hba.conf:

   # Noosfero user
   local   noosfero    noosfero                          md5

(add this line before the following line)

   # "local" is for Unix domain socket connections only
   local   all         all                               ident

Restart postgresql server:

    # service postgresql restart

Login as noosfero user, and execute:

    $ psql -U noosfero -W noosfero < /usr/share/noosfero/util/chat/postgresql/ejabberd.sql

(see database password in the /etc/noosfero/database.yml file)

This will create a new schema inside the noosfero database, called `ejabberd`.

Note that there should be at least one domain with `is_default = true` in
`domains` table, otherwise people won't be able to see their friends online.

## 4. ODBC configuration

Create the following files:

    # cp /usr/share/noosfero/util/chat/odbc.ini /etc/
    # cp /usr/share/noosfero/util/chat/odbcinst.ini /etc/

Edit the odbc.ini file and set the password for the database user, see
the file /etc/noosfero/database.yml to get the password.

Adjust premissions:

    # chmod 640 /etc/odbc.ini
    # chown ejabberd /etc/odbc.ini

## 4.1 testing all:

    # isql 'PostgreSQLEjabberdNoosfero'

If the configuration was done right, the message "Connected!" will be displayed.

## 5. Enabling kernel polling and SMP in `/etc/default/ejabberd`

    POLL=true
    SMP=auto

## 6. Increase the file descriptors limit for user ejabberd

### 6.1. Uncomment this line in file `/etc/pam.d/su`:

    session required pam_limits.so

### 6.2. Add this lines to file `/etc/security/limits.conf`:

    ejabberd       hard    nofile  65536
    ejabberd       soft    nofile  65536

Now, test the configuration:

    # cat /proc/<EJABBERD_BEAM_PROCESS_PID>/limits

## 7. Apache Configuration

Apache server must be configurated as follow:

`/etc/apache2/sites-enabled/noosfero`:

    RewriteEngine On
    Include /usr/share/noosfero/util/chat/apache/xmpp.conf

`/etc/apache2/apache2.conf`:

    <IfModule mpm_worker_module>
       StartServers          8
       MinSpareThreads       25
       MaxSpareThreads       75
       ThreadLimit           128
       ThreadsPerChild       128
       MaxClients            2048
       MaxRequestsPerChild   0
    </IfModule>

Note: module proxy_http must be enabled:

    # a2enmod proxy_http

Restart services:

    # service ejabberd restart
    # service noosfero restart
    # service apache2 restart

## 8. Test Apache Configuration

Open in your browser the address:

    http://<yout domain>/http-bind

You should see a page with a message like that:

   ejabberd mod_http_bind
   An implementation of XMPP over BOSH (XEP-0206)
   This web page is only informative. To use HTTP-Bind you need a Jabber/XMPP
   client that supports it.

## 9. Test chat session

Open Noosfero console and execute:

>> environment = Environment.default
>> user = Person['guest']
>> password = user.user.crypted_password
>> login = user.jid
>> RubyBOSH.initialize_session(login, password, "http://#{environment.default_hostname}/http-bind", :wait => 30, :hold => 1, :window => 5

If you have luck, should see something like that:

Ruby-BOSH - SEND
<body window="5" rid="60265" xmlns="http://jabber.org/protocol/httpbind" xmlns:xmpp="urn:xmpp:xbosh" to="vagrant-debian-squeeze.vagrantup.com" wait="30" xmpp:version="1.0" hold="1"/>
Ruby-BOSH - SEND
<body rid="60266" xmlns="http://jabber.org/protocol/httpbind" sid="24cdfc43646a2af1059a7060b677c2e11b26f34f" xmlns:xmpp="urn:xmpp:xbosh" xmpp:version="1.0"><auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">Z3Vlc3RAdmFncmFudC1kZWJpYW4tc3F1ZWV6ZS52YWdyYW50dXAuY29tAGd1ZXN0ADEzZTFhYWVlYjRhYjZlMTA0MmRkNWI1YWY0MzM4MjA1OGJiOWZmNzk=</auth></body>
Ruby-BOSH - SEND
<body xmpp:restart="true" rid="60267" xmlns="http://jabber.org/protocol/httpbind" sid="24cdfc43646a2af1059a7060b677c2e11b26f34f" xmlns:xmpp="urn:xmpp:xbosh" xmpp:version="1.0"/>
Ruby-BOSH - SEND
<body rid="60268" xmlns="http://jabber.org/protocol/httpbind" sid="24cdfc43646a2af1059a7060b677c2e11b26f34f" xmlns:xmpp="urn:xmpp:xbosh" xmpp:version="1.0"><iq type="set" xmlns="jabber:client" id="bind_29330"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><resource>bosh_9631</resource></bind></iq></body>
Ruby-BOSH - SEND
<body rid="60269" xmlns="http://jabber.org/protocol/httpbind" sid="24cdfc43646a2af1059a7060b677c2e11b26f34f" xmlns:xmpp="urn:xmpp:xbosh" xmpp:version="1.0"><iq type="set" xmlns="jabber:client" id="sess_21557"><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/></iq></body>
=> ["guest@vagrant-debian-squeeze.vagrantup.com", "24cdfc43646a2af1059a7060b677c2e11b26f34f", 60270]
