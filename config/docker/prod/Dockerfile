FROM ruby:2.4.2-jessie
MAINTAINER Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>

LABEL Description="This dockerfile builds a noosfero production environment."

EXPOSE 80

ENV RAILS_ENV production
RUN apt-get update && apt-get install -y sudo cron nodejs postgresql-client

WORKDIR /noosfero
ADD Gemfile /noosfero/Gemfile
WORKDIR /noosfero
RUN bundle install

ADD . /noosfero/

COPY ./config/docker/prod/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/noosfero/script/production", "run"]
