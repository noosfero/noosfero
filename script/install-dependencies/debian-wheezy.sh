# needed to run noosfero
runtime_dependencies=$(sed -e '/^\s*#/d; 1,/^Depends:/d; /^Recommends:/,$ d; s/([^)]*)//g; s/,\s*/\n/g' debian/control | grep -v 'memcached\|debconf\|dbconfig-common\|postgresql\|misc:Depends\|adduser\|mail-transport-agent')
run sudo apt-get -y install $runtime_dependencies
sudo apt-get -y install iceweasel || sudo apt-get -y install firefox

# needed for development
run sudo apt-get -y install ruby-tidy ruby-mocha imagemagick po4a xvfb libxml2-dev libxslt1-dev

sudo apt-get -y install bundler

run ./script/debundler

run bundle --local
