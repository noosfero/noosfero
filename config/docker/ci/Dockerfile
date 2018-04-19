FROM ruby:2.4.4-jessie
MAINTAINER Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>

RUN apt-get update \
    && apt-get install -y git sudo \
    && bash -c "echo 'LANG=C.UTF-8' > /etc/default/locale" \
    && git clone --depth 1 https://gitlab.com/alaxalves/noosfero.git /noosfero

WORKDIR /noosfero

RUN bash -c "./script/set-apt-proxy" \
    && mkdir -p locale \
    && apt-get clean
