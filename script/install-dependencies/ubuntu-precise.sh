#!/bin/sh

export DEBIAN_INTERFACE=noninteractive

#run sudo apt-get update
#run sudo apt-get dist-upgrade -qy

run sudo apt-get install -qy dctrl-tools

packages=$(grep-dctrl -n -s Build-Depends,Depends,Recommends -S -X noosfero debian/control | sed -e 's/([^)]*)//g; s/,\s*/\n/g' | grep -v 'rake\|ruby\|thin\|debhelper\|cucumber\|rail\|memcached\|debconf\|dbconfig-common\|misc:Depends\|adduser\|mail-transport-agent')

run sudo apt-get install -qy ruby1.9.1-full build-essential libxml2-dev libxslt-dev libpq-dev libmagickcore-dev libmagickwand-dev $packages


export GEM_HOME=$(ruby -e 'puts Gem.user_dir')
export PATH="${GEM_HOME}/bin:${PATH}"
(gem list | grep bundler) || run gem install --no-rdoc --no-ri bundler
run bundle install

sudo tee /etc/profile.d/rubygems-path.sh <<EOF
export GEM_HOME=\$(ruby -e 'puts Gem.user_dir')
PATH="\${GEM_HOME}/bin:\${PATH}"
EOF
