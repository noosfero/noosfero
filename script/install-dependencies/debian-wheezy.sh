binary_packages='deb http://download.noosfero.org/debian/wheezy-1.3 ./'

source_packages=$(echo "$binary_packages" | sed -e 's/^deb/deb-src/')

if ! grep -q "$binary_packages" /etc/apt/sources.list.d/noosfero.list; then
  sudo tee /etc/apt/sources.list.d/noosfero.list <<EOF
$binary_packages
$source_packages
EOF

  sudo apt-key add - <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.9 (GNU/Linux)

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
FPQAoNmiMgP6zGF9rgOEWMEiFEryayrz
=70DR
-----END PGP PUBLIC KEY BLOCK-----
EOF
fi

if grep -qrl wheezy /etc/apt/sources.list* && ! grep -qrl wheezy-backports /etc/apt/sources.list*; then
  sudo tee /etc/apt/sources.list.d/backports.list <<EOF
deb http://httpredir.debian.org/debian wheezy-backports main
EOF
fi


if test -f tmp/debian/Release.gpg; then
  echo "deb file://$(pwd)/tmp/debian/ ./" | sudo tee /etc/apt/sources.list.d/local.list
  sudo apt-key add tmp/debian/signing-key.asc
else
  sudo rm -f /etc/apt/sources.list.d/local.list
fi

run sudo apt-get update
run sudo apt-get -qy dist-upgrade

run sudo apt-get -y install dctrl-tools

# need these from backports
run sudo apt-get -y install -t wheezy-backports ruby-rspec unicorn

# needed to run noosfero
packages=$(grep-dctrl -n -s Build-Depends,Depends,Recommends -S -X noosfero debian/control | sed -e '/^\s*#/d; s/([^)]*)//g; s/,\s*/\n/g' | grep -v 'memcached\|debconf\|dbconfig-common\|misc:Depends\|adduser\|mail-transport-agent')
run sudo apt-get -y install $packages
sudo apt-get -y install iceweasel || sudo apt-get -y install firefox

run rm -f Gemfile.lock
run bundle --local
