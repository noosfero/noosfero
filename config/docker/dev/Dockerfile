FROM ruby:2.4.2-jessie
MAINTAINER Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>

LABEL Description="This dockerfile builds a noosfero development environment."

EXPOSE 3000

ENV RAILS_ENV development
RUN apt-get update && apt-get install -y sudo cron nodejs tango-icon-theme postgresql-client

ADD Gemfile /tmp/Gemfile
WORKDIR /tmp
RUN bundle install

ADD . /noosfero/
WORKDIR /noosfero

COPY ./config/docker/dev/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
