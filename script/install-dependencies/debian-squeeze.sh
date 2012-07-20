# needed to run noosfero
runtime_dependencies=$(sed -e '1,/^Depends:/d; /^Recommends:/,$ d; s/([^)]*)//g; s/,\s*/\n/g' debian/control | grep -v 'memcached\|debconf\|dbconfig-common\|postgresql\|misc:Depends\|adduser\|mail-transport-agent')
run sudo apt-get -y install $runtime_dependencies

# needed for development
run sudo apt-get -y install libtidy-ruby libhpricot-ruby libmocha-ruby imagemagick po4a xvfb libxml2-dev libxslt-dev
gem which bundler >/dev/null 2>&1 || run gem install bundler
run bundle install
