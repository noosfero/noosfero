# Noosfero development environment
#
# VERSION 0.0.1

FROM debian:wheezy
MAINTAINER Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>

LABEL Description="This dockerfile builds a noosfero development environment."
WORKDIR /src/noosfero

RUN apt-get update && apt-get install -y sudo git
RUN git clone --depth 1 https://gitlab.com/noosfero/noosfero.git .

RUN sh script/quick-start --skip-translations

EXPOSE 3000
