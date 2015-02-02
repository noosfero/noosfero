# Setup Noosfero to use HTTPS

This document assumes that you have a fully and clean Noosfero
installation as explained at the `INSTALL.md` file.

## Creating a self-signed SSL certificate

You should get a valid SSL certificate, but if you want to test
your setup before, you could generate a self-signed certificate
as below:

    # mkdir /etc/noosfero/ssl
    # cd /etc/noosfero/ssl
	  # openssl genrsa 1024 > noosfero.key
    # openssl req -new -x509 -nodes -sha1 -days $[10*365] -key noosfero.key > noosfero.cert
    # cat noosfero.key noosfero.cert > noosfero.pem

## Web server configuration

There are two ways of using SSL with Noosfero: 1) If you are not using
Varnish; and 2) If you are using Varnish.

### 1) If you are are not using Varnish

Simply do a redirect in apache to force all connections with SSL:

```
<VirtualHost *:8080>
  ServerName test.stoa.usp.br
  Redirect / https://example.com/
</VirtualHost>
```

And set a vhost to receive then:

```
<VirtualHost *:443>
  ServerName example.com
  SSLEngine On
  SSLCertificateFile    /etc/ssl/certs/cert.pem
  SSLCertificateKeyFile /etc/ssl/private/cert.key
  Include /etc/noosfero/apache/virtualhost.conf
</VirtualHost>
```

Be aware that if you had configured varnish, the requests won't reach
it with this configuration.

### 2) If you are using Varnish

Varnish isn't able to communicate with the SSL protocol, so we will need some
one else who do this and [Pound](http://www.apsis.ch/pound) can do the job. In
order to install it in Debian based systems:

```
$ sudo apt-get install pound
```

Set Varnish to listen in other port than 80 in `/etc/defaults/varnish`:

```
DAEMON_OPTS="-a localhost:6081 \
             -T localhost:6082 \
             -f /etc/varnish/default.vcl \
             -S /etc/varnish/secret \
             -s file,/var/lib/varnish/$INSTANCE/varnish_storage.bin,1G"
```

Configure Pound:

```
# cp /usr/share/noosfero/etc/pound.cfg /etc/pound/
```

Edit `/etc/pound.cfg` and set the IP and domain of your server.

Configure Pound to start at system initialization. At `/etc/default/pound`:
------------------

```
startup=1
```

Set Apache to only listen to localhost, at `/etc/apache2/ports.conf`:

```
Listen 127.0.0.1:8080
```

Restart the services:

```
$ sudo service apache2 restart
$ sudo service varnish restart
```

Start pound:

```
$ sudo service pound start
```

## Noosfero XMPP chat

If you want to use chat over HTTPS, then you should add the domain
and IP of your server in the /etc/hosts file, example

`/etc/hosts:`

```
192.168.1.86	mydomain.example.com
```

Also, it's recomended that you remove the lines below from the file
`/etc/apache2/sites-enabled/noosfero`:

```
RewriteEngine On
Include /usr/share/noosfero/util/chat/apache/xmpp.conf
```
