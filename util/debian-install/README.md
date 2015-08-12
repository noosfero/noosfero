This directory contains the basic structure to test the installation of
Noosfero debian packages, using a fresh Vagrant VM and packages built in
${NOOSFEROROOT}/pkg/.

To perform a test, do

```
$ cd /path/to/noosfero
$ rake noosfero:deb
$ cd util/debian-install/
$ vagrant up
```

To reset the environment in preparation for a new test, destroy the VM and
remove any local `*.deb` files :

```
$ cd util/debian-install/
$ vagrant halt
$ vagrant destroy
$ rm -f *.deb
```

To test upgrades:

```
$ rm -f pkg/
$ cd utils/debian-install/
$ vagrant destroy
$ rm -f *.deb
$ REPOSITORY=wheezy vagrant up              # install current stable version
$ cd ../../
$ make noosfero:deb                         # build current packages
$ REPOSITORY=wheezy-next vagrant provision  # upgrade
```
