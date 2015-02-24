# needed to run noosfero
runtime_dependencies=$(sed -e '1,/^Depends:/d; /^Recommends:/,$ d; s/([^)]*)//g; s/,\s*/\n/g' debian/control | grep -v 'memcached\|debconf\|dbconfig-common\|postgresql\|misc:Depends\|adduser\|mail-transport-agent')
run sudo apt-get update
run sudo apt-get -y install $runtime_dependencies
sudo apt-get -y install iceweasel || sudo apt-get -y install firefox

# needed for development
run sudo apt-get -y install libtidy-ruby libmocha-ruby imagemagick po4a xvfb libxml2-dev libxslt-dev postgresql openjdk-6-jre
gem which bundler >/dev/null 2>&1 || gem_install bundler
setup_rubygems_path
run bundle install
