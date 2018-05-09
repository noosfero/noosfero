FROM ruby:2.4.4-jessie
MAINTAINER Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>

LABEL Description="This dockerfile builds a noosfero development environment."

EXPOSE 3000

ENV RAILS_ENV development
RUN apt-get update && apt-get install -y sudo cron nodejs postgresql-client

WORKDIR /noosfero

ENTRYPOINT ["/noosfero/config/docker/dev/entrypoint.sh"]
