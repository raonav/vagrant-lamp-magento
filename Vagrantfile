# -*- mode: ruby -*-
# vi: set ft=ruby :

# check for vagrant-hostmanager and force installation
# need a better way to handle these but currently I only need the one plugin
unless Vagrant.has_plugin?("vagrant-hostmanager")
  system ('vagrant plugin install vagrant-hostmanager')
  abort "Ok you need to run vagrant up again :/"
end

Vagrant.configure(2) do |config|

  # custom variables
  # TODO: pass these to a separate config file, json or yaml
  hostname = 'magento.dev'

  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", type: "dhcp"
  config.vm.hostname = "#{hostname}"

  config.vm.synced_folder "./www", "/var/www", create: true

  # hostmanager stuff
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  # based off the custom ip resolver suggestion in hostmanager's readme
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
      if hostname = (vm.ssh_info && vm.ssh_info[:host])
        `vagrant ssh -c "hostname -I"`.split()[1]
      end
  end

  config.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "1536"
      vb.name = "vagrant-lamp-magento"
  end

  config.vm.provision "shell", path: "bootstrap.sh", :args => "#{hostname}"

end
