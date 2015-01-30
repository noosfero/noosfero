#!/bin/bash

if [ ! -f /etc/yum.repos.d/isv:spb:noosfero.repo ]; then
  run sudo wget -P /etc/yum.repos.d/ http://download.opensuse.org/repositories/isv:/spb:/noosfero/CentOS_7/isv:spb:noosfero.repo
fi

DEPENDENCIES='make gcc gcc-c++ ruby ruby-devel rubygem-bundler
libicu-devel cmake postgresql-devel postgresql-server ImageMagick-devel
libxml2-devel libxslt-devel file-devel tango-icon-theme'

run sudo yum install -y $DEPENDENCIES

export GEM_HOME=$(ruby -e 'puts Gem.user_dir')
export PATH="${GEM_HOME}/bin:${PATH}"
(gem list | grep bundler) || run gem install --no-rdoc --no-ri bundler
run bundle install

sudo tee /etc/profile.d/rubygems-path.sh <<EOF
export GEM_HOME=\$(ruby -e 'puts Gem.user_dir')
PATH="\${GEM_HOME}/bin:\${PATH}"
EOF

run sudo postgresql-setup initdb
run sudo systemctl enable postgresql
run sudo systemctl start postgresql

