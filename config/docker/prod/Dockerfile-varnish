FROM million12/varnish

RUN yum update -y && \
    yum install -y wget
RUN source /etc/init.d/functions && \
    cd /usr/local/src && \
    wget http://developer.axis.com/download/distribution/apps-sys-utils-start-stop-daemon-IR1_9_18-2.tar.gz && \
    tar zxvf apps-sys-utils-start-stop-daemon-IR1_9_18-2.tar.gz && \
    cd apps/sys-utils/start-stop-daemon-IR1_9_18-2 && \
    gcc start-stop-daemon.c -o start-stop-daemon && \
    cp start-stop-daemon /usr/sbin/

VOLUME ["/var/lib/varnish", "/etc/varnish"]

COPY templates/ports-conf.template /etc/apache2/ports.conf
COPY templates/default-conf.template /etc/apache2/sites-enabled/000-default.conf
COPY templates/varnish.template /etc/default/varnish
COPY templates/default-vcl.template /etc/varnish/default.vcl
COPY templates/varnishncsa.template /etc/default/varnishncsa
COPY templates/tempfile.template /bin/tempfile
COPY templates/init-functions.template /lib/lsb/init-functions
COPY templates/init-varnish.template /etc/init.d/varnish
COPY ./varnish-start.sh /bin/varnish-start.sh

ENTRYPOINT ["sh", "/bin/varnish-start.sh"]
