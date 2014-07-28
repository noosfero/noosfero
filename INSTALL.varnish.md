Setting up Varnish for your Noosfero site
=========================================

Varnish is a HTTP caching server, and using it together with Noosfero is highly recommended. See http://www.varnish-cache.org/ for more information on Varnish.

Varnish can be set up to use with Noosfero with the following steps:

1) setup Noosfero with apache according to the `INSTALL.md` file. If you used the Debian package to install noosfero, you don't need to do anything about this.

2) install Varnish

    # apt-get install varnish

Install the RPAF apache module (or skip this step if not using apache):

    # apt-get install libapache2-mod-rpaf

3) Change Apache to listen on port `8080` instead of `80`

3a) Edit `/etc/apache2/ports.conf`, and:

  * change `NameVirtualHost *:80` to `NameVirtualHost *:8080`
  * change `Listen 80` to `Listen 127.0.0.1:8080`

3b) Edit `/etc/apache2/sites-enabled/*`, and change `<VirtualHost *:80>` to `<VirtualHost *:8080>`

4) Varnish configuration

4a) Edit `/etc/default/varnish`

   * change the line that says `START=no` to say `START=yes`
   * change `-a :6081` to `-a :80`

4b) Edit `/etc/varnish/default.vcl` and add the following lines at the end:

    include "/etc/noosfero/varnish-noosfero.vcl";
    include "/etc/noosfero/varnish-accept-language.vcl";

On manual installations, change `/etc/noosfero/*` to `{Rails.root}/etc/noosfero/*`

**NOTE**: it is very important that the `*.vcl` files are included in that order, i.e. *first* include `varnish-noosfero.vcl`, and *after* `noosfero-accept-language.cvl`.

5) Enable varnish logging:

5a) Edit `/etc/default/varnishncsa` and uncomment the line that contains:

    VARNISHNCSA_ENABLED=1

The varnish log will be written to `/var/log/varnish/varnishncsa.log` in an apache-compatible format. You should change your statistics generation software (e.g. awstats) to use that instead of apache logs.

Thanks to Cosimo Streppone for varnish-accept-language. See http://github.com/cosimo/varnish-accept-language for more information.

6) Restart services

    # service apache2 restart
    # service varnish restart
    # service varnishncsa restart
