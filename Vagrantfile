# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "389ds"

  config.vm.box = "CentOS-6.4-x86_64-v20130309.box"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130309.box"
  config.vm.network :private_network, ip: "29.29.29.10"
  config.berkshelf.enabled = true

  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id, 
      "--memory", "2048",
      "--cpus", "2", 
      "--chipset", "ich9",
      "--vram", "10"
    ]
  end

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.vm.provision :chef_solo do |chef|
    chef.json = {
    }

    chef.run_list = [
      "recipe[389ds::server]"
    ]
  end
end
