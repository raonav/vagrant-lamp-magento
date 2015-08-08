# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.synced_folder "./www", "/var/www", create: true

  config.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "1024"
      vb.name = "vagrant-lamp-magento"
  end

  config.vm.provision "shell", path: "bootstrap.sh", :args => "magento.dev"

end
