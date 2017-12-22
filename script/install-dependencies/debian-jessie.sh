binary_packages='deb http://download.noosfero.org/debian/jessie-test ./'

source_packages=$(echo "$binary_packages" | sed -e 's/^deb/deb-src/')

if ! grep -q "$binary_packages" /etc/apt/sources.list.d/noosfero.list; then
  sudo tee /etc/apt/sources.list.d/noosfero.list <<EOF
$binary_packages
$source_packages
EOF

  sudo apt-key add - <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQENBFo9LwwBCACthrtkJxzKTfG1zL32IWDqemvdWwnfgLFBkZ7yr4lKy5dDIK1m
a8BpNjR/+nGOO3ujLvEc7eLGURoZRPH/+Z5ZfKtgrD5NWS7Kt5e8iTQoHcGcW1Sv
c6C+gU2DPOPjo/+N0MsIIJN6R7gTTY2tOH3ruPm0mmCRDZUIDH77Fz9XRnmZI0b+
lnH43HJR3jQSVMWOX6d3HQGTPfxgNebO3LniaRVA/cjaYPRYWzUlxxiJreTQlNTv
9c1rlQeRwu97MCS+UyAFRpwmBWHVp7W77jAH9o6ODntxRW67lJuGEFQJlgiCOJnZ
eeqObIxIFzWVG1mpc2yIRb55H5kP9RLG5dZZABEBAAG0RE5vb3NmZXJvIEFyY2hp
dmUgU2lnbmluZyBLZXkgPG5vb3NmZXJvLWRldkBsaXN0YXMuc29mdHdhcmVsaXZy
ZS5vcmc+iQFUBBMBCgA+FiEEJpI+nK5tSlqLUb7sAeYc3X1ajTcFAlo9LwwCGwMF
CQPCZwAFCwkIBwMFFQoJCAsFFgIDAQACHgECF4AACgkQAeYc3X1ajTe22Qf/ejSY
t452tX5d3/RtJnd4pNJhZNvt4cyNUkGkLAjJpgagsUqj7m17Tqc1rrrh6rb8/PXl
yZgSgcLG8XOOkkF5UgNujBXd4gLBnKb5UAem396fDmOBNdSr9lzbHyOwt43cYOFx
EEqqjcCr7kAOFGCfFOlBbCQ7yBJoix4iWelRxfDbzD/tiPYtDj/jPsg9+bFNU4Co
vidjjo79cyB19QyGv7UQAu1WY1CwzXYcoEYFrOiewQYmYdpzJaq26m04brVfBSW1
nEQHbVWGsUqUDmmqGHptd2auEI7WXP3JTkKhVbPmb85MMWuFe5Mz1YHMjwWXylyL
aSzN+MrXK0LmR2qnarkBDQRaPS8MAQgAxmCCLISCBb01CK3Nnz8HK6ccNPxn7y5I
beMjQec0ODdEAO7Xy3XWu8QW7Jq5GltxYuSJZh70SNM/G83qmPTZmw8NhxITLWly
CboobizSc8mD6R1mSDhd23Dnu8aejvqkE6Qr66hlTBqq3D7o2to2/Q5gOSIH3lP5
UZ24+FY1MmJ7vsSW+/AofgoKU8D7g9CbzOI/UOZqD12+xqDfY2B8nzE1NW8dKemv
76ejKP5nBgYPmHeQDb5Sqx8yZ2RbssNgPKTtp5t5BVFHpS7ZG+2qLUEgHx4kZilQ
5jYL9Bf6UoSJ/f0SgtT8SjeJn1oZC9C381FwcYgGdZyu+n4cWyuJfQARAQABiQE8
BBgBCgAmFiEEJpI+nK5tSlqLUb7sAeYc3X1ajTcFAlo9LwwCGwwFCQPCZwAACgkQ
AeYc3X1ajTdnwAf9GxIHcn0RS8PyJ3K4pxnko2tJ4gvt3PHVS3wLAlSI6vp3JQeR
PlR50LeG/3YFHSef48Kk8ZM/iVD5fpnnpaFk+j+ytLzTis6rneskufEZbCUyO055
UesXD1Oms06vc2QgFuqhTXR3ZvqN2yhdHSqCmc+sdQi612BH6b+RufTUFRd5U52b
lUjtdCHZ5vXPcQ67cGade8BU7DJY8abRb6r5lD8jvROxWL5k/iRlMwwgiRXC5Frd
CdUuv9egEIjH82viVMIjV67mxx0ifpRgIZsbktJvgElOqEzA8xxydU2NHUoVc6jb
+OB5skBulpAs0tokuToakNlMeZFA/mhEHjoiAA==
=JjJa
-----END PGP PUBLIC KEY BLOCK-----
EOF
fi


if test -f tmp/debian/Release.gpg; then
  echo "deb file://$(pwd)/tmp/debian/ ./" | sudo tee /etc/apt/sources.list.d/local.list
  sudo apt-key add tmp/debian/signing-key.asc
else
  sudo rm -f /etc/apt/sources.list.d/local.list
fi

retry() {
  local times="$1"
  shift
  local i=0
  local rc=0
  while [ $i -lt "$times" ]; do
    echo '$' "$@"
    "$@" && rc=0 || rc=$?
    i=$(($i + 1))
    if [ $rc -eq 0 ]; then return 0; fi
  done
  return $rc
}

# update system, at most every 6h (internal between Debian mirror pushes)
timestamp=/tmp/.noosfero.apt-get.update
now=$(date +%s)
if [ ! -f $timestamp ] || [ $(($now - $(stat --format=%Y $timestamp))) -gt 21600 ]; then
  run retry 3 sudo apt-get update
  run retry 3 sudo apt-get -qy dist-upgrade
  touch $timestamp
fi

run sudo apt-get -y install dctrl-tools

# needed to run noosfero
packages=$(grep-dctrl -n -s Build-Depends,Depends,Recommends -S -X noosfero debian/control | sed -e '/^\s*#/d; s/([^)]*)//g; s/,\s*/\n/g' | grep -v 'memcached\|debconf\|dbconfig-common\|misc:Depends\|adduser\|mail-transport-agent')
run sudo apt-get -y install $packages
sudo apt-get -y install iceweasel || sudo apt-get -y install firefox

run rm -f Gemfile.lock
run bundle --local

