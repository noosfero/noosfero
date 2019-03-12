FROM ruby:2.6.1-stretch

LABEL Maintainer="Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>"
LABEL Description="This dockerfile builds a noosfero production environment."

EXPOSE 3000

RUN apt-get update && apt-get install -y sudo cron nodejs postgresql-client

WORKDIR /noosfero
ADD . /noosfero/

COPY config/database.yml.docker config/database.yml

RUN echo "IRB.conf[:SAVE_HISTORY] = 100" >> .irbrc
RUN echo "IRB.conf[:HISTORY_FILE] = '~/.irb-history'" >> .irbrc

RUN bundle install --jobs 20 --retry 5 --without development test 

ENTRYPOINT ["config/docker/prod/noosfero-entrypoint.sh"]
CMD ["script/production", "run"]
