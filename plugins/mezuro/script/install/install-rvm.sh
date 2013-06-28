#!/bin/bash --login

#Ubuntu Package Dependencies
sudo apt-get update
sudo apt-get install build-essential curl libxslt1-dev git git-core tango-icon-theme sqlite3 libsqlite3-dev patch bzip2 openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev libgdbm-dev ncurses-dev automake libtool bison subversion pkg-config libffi-dev openjdk-6-jre

#RVM Installation for Ubuntu 12.10
curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --version 1.19.0

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi
rvm reload

#Complements the RVM installation
rvm requirements run
#rvm pkg install zlib --verify-downloads 1

#Ruby installation and setup
CFLAGS="-O2 -fno-tree-dce -fno-optimize-sibling-calls" rvm install 1.8.7-p302
rvm use ruby-1.8.7-p302@global
gem install rubygems-update -v 1.3.7
update_rubygems
gem install rake -v 0.8.7
yes | gem uninstall rake -v 10.0.4
rvm gemset create mezuro
rvm use ruby-1.8.7-p302@mezuro

#Gems installation
#The order really matters here, so if you see an output like "2 gems instaled" something should be wrong
gem install --no-ri --no-rdoc rack -v 1.0.1
gem install --no-ri --no-rdoc rack-test -v 0.6.2
gem install --no-ri --no-rdoc httpi -v 1.0
gem install --no-ri --no-rdoc nokogiri -v 1.5.5
gem install --no-ri --no-rdoc wasabi -v 2.0.0
gem install --no-ri --no-rdoc json -v 1.7.5
gem install --no-ri --no-rdoc gherkin -v 2.5.4
gem install --no-ri --no-rdoc multi_json -v 1.3.7
gem install --no-ri --no-rdoc rubyzip -v 0.9.9
gem install --no-ri --no-rdoc ffi -v 1.2.0
gem install --no-ri --no-rdoc childprocess -v 0.3.6
gem install --no-ri --no-rdoc websocket -v 1.0.4
gem install --no-ri --no-rdoc libwebsocket -v 0.1.6.1
gem install --no-ri --no-rdoc selenium-webdriver -v 2.30.0
gem install --no-ri --no-rdoc activesupport -v 2.3.5
gem install --no-ri --no-rdoc actionpack -v 2.3.5
gem install --no-ri --no-rdoc actionmailer -v 2.3.5
gem install --no-ri --no-rdoc activerecord -v 2.3.5
gem install --no-ri --no-rdoc activeresource -v 2.3.5
gem install --no-ri --no-rdoc addressable -v 2.2.2
gem install --no-ri --no-rdoc builder -v 3.1.4
gem install --no-ri --no-rdoc gyoku -v 0.4.6
gem install --no-ri --no-rdoc akami -v 1.2.0
gem install --no-ri --no-rdoc xpath -v 0.1.4
gem install --no-ri --no-rdoc mime-types -v 1.19
gem install --no-ri --no-rdoc capybara -v 1.1.1
gem install --no-ri --no-rdoc term-ansicolor -v 1.0.7
gem install --no-ri --no-rdoc diff-lcs -v 1.1.3
gem install --no-ri --no-rdoc cucumber -v 1.1.0
gem install --no-ri --no-rdoc cucumber-rails -v 0.3.2
gem install --no-ri --no-rdoc culerity -v 0.2.15
gem install --no-ri --no-rdoc database_cleaner -v 0.9.1
gem install --no-ri --no-rdoc exception_notification -v 1.0.20090728
gem install --no-ri --no-rdoc googlecharts -v 1.6.8
gem install --no-ri --no-rdoc hpricot -v 0.8.2
gem install --no-ri --no-rdoc httpi -v 0.9.7
gem install --no-ri --no-rdoc i18n -v 0.4.1
gem install --no-ri --no-rdoc metaclass -v 0.0.1
gem install --no-ri --no-rdoc mocha -v 0.9.8
gem install --no-ri --no-rdoc nori -v 1.1.3
gem install --no-ri --no-rdoc ntlm-http -v 0.1.1
gem install --no-ri --no-rdoc polyglot -v 0.3.3
gem install --no-ri --no-rdoc rails -v 2.3.5
gem install --no-ri --no-rdoc rcov -v 0.9.7.1
gem install --no-ri --no-rdoc RedCloth -v 4.2.2
gem install --no-ri --no-rdoc rspec -v 1.2.9
gem install --no-ri --no-rdoc rspec-rails -v 1.2.9
gem install --no-ri --no-rdoc savon -v 0.9.7
gem install --no-ri --no-rdoc Selenium -v 1.1.14
gem install --no-ri --no-rdoc selenium-client -v 1.2.18
gem install --no-ri --no-rdoc sqlite3 -v 1.3.6
gem install --no-ri --no-rdoc system_timer -v 1.2.4
gem install --no-ri --no-rdoc tango -v 0.1.15
gem install --no-ri --no-rdoc tidy -v 1.1.2
gem install --no-ri --no-rdoc treetop -v 1.4.10
gem install --no-ri --no-rdoc webrat -v 0.5.1
gem install --no-ri --no-rdoc will_paginate -v 2.3.12
gem install --no-ri --no-rdoc gettext -v 1.8.0

#Mezuro installation
git clone git@gitorious.org:+mezuro/noosfero/mezuro.git
cd mezuro
git checkout mezuro-dev
rvm use ruby-1.8.7-p302@mezuro
cp config/database.yml.sqlite3 config/database.yml
cp plugins/mezuro/service.yml.example plugins/mezuro/service.yml
cp plugins/mezuro/licenses.yml.example plugins/mezuro/licenses.yml
mkdir tmp
rake db:schema:load
rake db:migrate
rake makemo
./script/sample-data
./script/noosfero-plugins enable mezuro
cd public/designs/themes
rm -f default
git clone https://git.gitorious.org/mezuro/mezuro-theme.git
ln -s mezuro-theme/ default
cd ../../../

#Prepare Mezuro for running functional and unit tests
rake db:test:prepare
