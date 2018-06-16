FROM ruby:2.4.4-jessie

LABEL Maintainer="Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>"
LABEL Description="This dockerfile builds a noosfero development environment."

EXPOSE 3000

RUN apt-get update && apt-get install -y sudo cron nodejs postgresql-client

WORKDIR /noosfero
ADD . /noosfero/

RUN ./script/quick-start -i

COPY ./config/docker/dev/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
