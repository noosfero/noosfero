# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = ENV.fetch('VAGRANT_BOX', "debian/jessie64")
  config.vm.network :forwarded_port, host: 3000, guest: 3000
  config.vm.provision :shell do |shell|
    shell.inline = 'su vagrant -c /vagrant/script/vagrant'
  end
end
