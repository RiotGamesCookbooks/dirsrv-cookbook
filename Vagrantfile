# -*- mode: ruby -*-
# vi: set ft=ruby :

unless Vagrant.has_plugin?("vagrant-omnibus")
  raise 'Omnibus plugin is required: vagrant plugin install vagrant-omnibus'
end

Vagrant.configure("2") do |config|

  config.omnibus.chef_version = :latest
  config.vm.box = "vagrant-centos-65-x86_64-minimal"
  config.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-x86_64-minimal.box"

  # Primary Master
  config.vm.define "primary" do |primary|

    primary.vm.hostname = "primary"
    primary.vm.network :private_network, ip: "29.29.29.10"

    primary.vm.provider :virtualbox do |vb|
      vb.customize [
        "modifyvm", :id, 
        "--memory", "2048",
        "--cpus", "2", 
        "--chipset", "ich9",
        "--vram", "10"
      ]
    end

    primary.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"

      chef.json = {
        :dirsrv => {
          :credentials => {
            "userdn" => 'cn=Directory Manager',
            "password" => 'Vagrant!'
          },
          :cfgdir_credentials => {
            "username" => 'manager',
            "userdn" => 'uid=manager,ou=administrators,ou=topologymanagement,o=netscaperoot',
            "password" => 'Vagrant!'
          },
          :use_yum_epel => true
        },
        :vagrant => {
          :ipaddress => '29.29.29.10',
          :replicaid => 1
        }
      }

      chef.run_list = [
        "recipe[dirsrv::_vagrant_multi_master]"
      ]
    end
  end

  # Secondary Master
  config.vm.define "secondary" do |secondary|

    secondary.vm.hostname = "secondary"
    secondary.vm.network :private_network, ip: "29.29.29.11"

    secondary.vm.provider :virtualbox do |vb|
      vb.customize [
        "modifyvm", :id, 
        "--memory", "2048",
        "--cpus", "2", 
        "--chipset", "ich9",
        "--vram", "10"
      ]
    end

    secondary.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"

      chef.json = {
        :dirsrv => {
          :credentials => {
            "userdn" => 'cn=Directory Manager',
            "password" => 'Vagrant!'
          },
          :cfgdir_credentials => {
            "username" => 'manager',
            "userdn" => 'uid=manager,ou=administrators,ou=topologymanagement,o=netscaperoot',
            "password" => 'Vagrant!'
          },
          :use_yum_epel => true
        },
        :vagrant => {
          :ipaddress => '29.29.29.11',
          :replicaid => 2
        }
      }

      chef.run_list = [
        "recipe[dirsrv::_vagrant_multi_master]"
      ]
    end
  end

  # Hub
  config.vm.define "hub" do |hub|

    hub.vm.hostname = "hub"
    hub.vm.network :private_network, ip: "29.29.29.12"

    hub.vm.provider :virtualbox do |vb|
      vb.customize [
        "modifyvm", :id, 
        "--memory", "1536",
        "--cpus", "1", 
        "--chipset", "ich9",
        "--vram", "10"
      ]
    end

    hub.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"

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
        "recipe[dirsrv::_vagrant_hub]"
      ]
    end
  end

  # Consumer
  config.vm.define "consumer" do |consumer|

    consumer.vm.hostname = "consumer"
    consumer.vm.network :private_network, ip: "29.29.29.13"

    consumer.vm.provider :virtualbox do |vb|
      vb.customize [
        "modifyvm", :id, 
        "--memory", "1536",
        "--cpus", "1", 
        "--chipset", "ich9",
        "--vram", "10"
      ]
    end

    consumer.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"

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
        "recipe[dirsrv::_vagrant_consumer]"
      ]
    end
  end
end
