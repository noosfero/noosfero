FROM ruby:2.3-stretch
LABEL Maintainer="Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>"

RUN echo 'LANG=C.UTF-8' > /etc/default/locale
RUN apt-get update && apt-get install -y sudo cron nodejs postgresql-client

WORKDIR /noosfero

ADD ./Gemfile /noosfero/Gemfile
ADD ./Gemfile.lock /noosfero/Gemfile.lock
ADD ./debian/control /noosfero/debian/control
ADD ./script/quick-start /noosfero/script/
ADD ./script/install-dependencies /noosfero/script/install-dependencies/

RUN ./script/quick-start -i
