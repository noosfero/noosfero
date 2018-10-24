FROM ruby:2.4.4-jessie
LABEL Maintainer="Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>"

LABEL Description="This dockerfile builds a noosfero production environment."

EXPOSE 3000

ENV RAILS_ENV production
RUN apt-get update && apt-get install -y sudo cron nodejs postgresql-client

WORKDIR /noosfero
ADD . /noosfero/
RUN ./script/quick-start -i

RUN bundle install

ENTRYPOINT ["/noosfero/config/docker/prod/entrypoint.sh"]

CMD ["/noosfero/script/production", "run"]
