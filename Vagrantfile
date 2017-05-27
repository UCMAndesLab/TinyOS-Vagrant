# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

$script = <<SCRIPT
apt-get -y install puppet
mkdir -p /etc/puppet/modules
puppet module install puppetlabs/apt 
puppet module install puppetlabs/vcsrepo
SCRIPT

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  ## Set Name
  config.vm.provider "virtualbox" do |vb|
    vb.name = "TinyOS"
  end

  ## Get Puppet Ready
  config.vm.provision "shell", inline:$script


  ## Provision
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    run = "always"
    puppet.manifest_file = "default.pp"
  end

end
