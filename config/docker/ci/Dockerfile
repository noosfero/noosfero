FROM debian:jessie
MAINTAINER Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>

RUN apt-get update && apt-get install -y sudo git
RUN git clone --depth 1 https://gitlab.com/noosfero/noosfero.git /var/tmp/noosfero
RUN cd /var/tmp/noosfero && ./script/set-apt-proxy
RUN cd /var/tmp/noosfero && ./script/quick-start
RUN rm -rf /var/tmp/noosfero
RUN apt-get clean
RUN rm -f /etc/apt/apt.conf.d/01proxy
