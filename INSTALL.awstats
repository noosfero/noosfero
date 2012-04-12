= AWStats setup for Noosfero

AWStats is a free powerful and featureful tool that generates advanced web,
streaming, ftp or mail server statistics, graphically.

See http://awstats.sourceforge.net/

This guide supposes that the Noosfero server is running GNU/Linux Debian Squeeze.

1. Install AWStats

# apt-get install awstats libgeo-ip-perl geoip-database

2. Basic setup

Create AWStats config file:

 * /etc/awstats/awstats.<domain>.conf

Include "/etc/awstats/awstats.conf"
Include "/etc/noosfero/awstats-noosfero.conf"
SiteDomain="<domain>"
HostAliases="<domain-aliases>"

<domain> should be the domain used in your Noosfero server (eg.:
softwarelivre.org) and the <domain-aliases> should be a list with all aliases
that you configured in apache (eg.: www.softwarelivre.org
www2.softwarelivre.org etc).

This setup is considering that the Noosfero server is running varnish (see
INSTALL.varnish) and varnishncsa-vhost [1].

[1] http://gitorious.org/varnisnncsa-vhost

3. Running AWStats for the first time

Run awstats by hand via command line:

# /usr/lib/cgi-bin/awstats.pl -config=<domain>

You should see something as below as output of this command:

# /usr/lib/cgi-bin/awstats.pl -config=softwarelivre.org
Create/Update database for config "/etc/awstats/awstats.softwarelivre.org.conf" by AWStats version 6.7 (build 1.892)
From data in log file "/var/log/varnish/varnishncsa-vhost.log"...
Phase 1 : First bypass old records, searching new record...
Searching new records from beginning of log file...
Phase 2 : Now process new records (Flush history on disk after 20000 hosts)...
Jumped lines in file: 0
Parsed lines in file: 452
 Found 0 dropped records,
 Found 0 corrupted records,
 Found 0 old records,
 Found 452 new qualified records.

4. Setup frontend

You should create a new subdomain to have access to the AWStats, usually
something like tools.<domain> (eg.: tools.softwarelivre.org). Don't include
this subdomain in HostAliases in the AWStats neither in SiteAlias in the
Apache.

# cp /usr/share/doc/awstats/examples/apache.conf /etc/apache2/conf.d/awstats.conf
# invoke-rc.d apache2 restart

ps.: Don't forget to change the port /etc/apache/sites-enabled/000-default to
8080.

Try: http://tools.<domain>/cgi-bin/awstats.pl?config=<domain>
(eg.: http://tools.softwarelivre.org/cgi-bin/awstats.pl?config=softwarelivre.org).

5. Schedule AWStats in crontab

 * /etc/cron.d/awstats

0,10,20,30,40,50 * * * * www-data [ -x /usr/lib/cgi-bin/awstats.pl -a -f /etc/awstats/awstats.<domain>.conf -a -r /var/log/apache/access.log ] && /usr/lib/cgi-bin/awstats.pl -config=<domain> -update >/dev/null

Done, check the AWStats frontend after one or two days to see if everything is working properly.
