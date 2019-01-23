FROM ruby:2.1.5

LABEL Maintainer="Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>"

LABEL Description="This dockerfile builds a noosfero production environment."

RUN apt-get update && apt-get install -y sudo cron nodejs postgresql-client

WORKDIR /root
RUN echo "IRB.conf[:SAVE_HISTORY] = 100" >> .irbrc
RUN echo "IRB.conf[:HISTORY_FILE] = '~/.irb-history'" >> .irbrc

# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT /var/www/app_name
RUN mkdir -p $RAILS_ROOT 

# Set working directory
WORKDIR $RAILS_ROOT

# Setting env up
ENV RAILS_ENV production
ENV RACK_ENV production

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --jobs 20 --retry 5 --without development test 

# Adding project files
COPY . .

ENTRYPOINT ["config/docker/prod/entrypoint.sh"]

EXPOSE 3000
CMD ["script/production", "run"]



