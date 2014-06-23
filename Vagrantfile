# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "dirsrv"

  config.vm.box = "vagrant-centos-65-x86_64-minimal"
  config.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-x86_64-minimal.box"
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

  config.vm.provision :chef_solo do |chef|

    chef.data_bags_path = "data_bags"
    chef.cookbooks_path = "vagrant-cookbooks"
    chef.encrypted_data_bag_secret_key_path = "encrypted_data_bag_secret"

    chef.json = {
      :dirsrv => {
        :credentials => {
          "userdn" => 'cn=Directory Manager',
          "password" => 'Vagrant!'
        },
        :cfgdir_credentials => {
          "username" => 'manager',
          "password" => 'Vagrant!'
        },
        :use_yum_epel => true
      }
    }

    chef.run_list = [
      "recipe[dirsrv::_vagrant_node_one]"
    ]
  end
end
