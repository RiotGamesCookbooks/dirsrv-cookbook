# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.omnibus.chef_version = :latest
  config.vm.box = "vagrant-centos-65-x86_64-minimal"
  config.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-x86_64-minimal.box"

  # Primary Master
  config.vm.define "primary" do |primary|

    primary.vm.hostname = "primary"
    primary.vm.network :private_network, ip: "29.29.29.10"

    primary.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    primary.vm.provider :virtualbox do |vb, o|

      o.vm.box = "vagrant-centos-65-x86_64-minimal"
      o.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-x86_64-minimal.box"

      vb.customize [
        "modifyvm", :id, 
        "--memory", "1024",
        "--cpus", "2", 
        "--chipset", "ich9",
        "--vram", "10",
        "--nictype1", "virtio",
        "--nictype2", "virtio"
      ]
    end

    primary.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"
      chef.synced_folder_type = "rsync"

      chef.json = {
        :dirsrv => {
          :use_yum_epel => true
        }
      }

      chef.run_list = [
        "recipe[dirsrv::_vagrant_primary]"
      ]
    end
  end

  # Secondary Master
  config.vm.define "secondary" do |secondary|

    secondary.vm.hostname = "secondary"
    secondary.vm.network :private_network, ip: "29.29.29.11"

    secondary.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    secondary.vm.provider :virtualbox do |vb, o|

      o.vm.box = "trusty-server-cloudimg-amd64-vagrant-disk1"
      o.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

      vb.customize [
        "modifyvm", :id, 
        "--memory", "1024",
        "--cpus", "2", 
        "--chipset", "ich9",
        "--vram", "10",
        "--nictype1", "virtio",
        "--nictype2", "virtio"
      ]
    end

    secondary.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"
      chef.synced_folder_type = "rsync"

      chef.json = {
        :dirsrv => {
          :use_yum_epel => true
        }
      }

      chef.run_list = [
        "recipe[dirsrv::_vagrant_secondary]"
      ]
    end
  end

  # Tertiary Master
  config.vm.define "tertiary", autostart: false do |tertiary|

    tertiary.vm.hostname = "tertiary"
    tertiary.vm.network :private_network, ip: "29.29.29.12"

    tertiary.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    tertiary.vm.provider :virtualbox do |vb, o|

      o.vm.box = "vagrant-centos-65-x86_64-minimal"
      o.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-x86_64-minimal.box"

      vb.customize [
        "modifyvm", :id, 
        "--memory", "1024",
        "--cpus", "2", 
        "--chipset", "ich9",
        "--vram", "10",
        "--nictype1", "virtio",
        "--nictype2", "virtio"
      ]
    end

    tertiary.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"
      chef.synced_folder_type = "rsync"

      chef.json = {
        :dirsrv => {
          :use_yum_epel => true
        }
      }

      chef.run_list = [
        "recipe[dirsrv::_vagrant_tertiary]"
      ]
    end
  end

  # Quaternary Master
  config.vm.define "quaternary", autostart: false do |quaternary|

    quaternary.vm.hostname = "quaternary"
    quaternary.vm.network :private_network, ip: "29.29.29.13"

    quaternary.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    quaternary.vm.provider :virtualbox do |vb, o|

      o.vm.box = "trusty-server-cloudimg-amd64-vagrant-disk1"
      o.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

      vb.customize [
        "modifyvm", :id, 
        "--memory", "1024",
        "--cpus", "2", 
        "--chipset", "ich9",
        "--vram", "10",
        "--nictype1", "virtio",
        "--nictype2", "virtio"
      ]
    end

    quaternary.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"
      chef.synced_folder_type = "rsync"

      chef.json = {
        :dirsrv => {
          :use_yum_epel => true
        }
      }

      chef.run_list = [
        "recipe[dirsrv::_vagrant_quaternary]"
      ]
    end
  end

  # Hub
  config.vm.define "proxyhub" do |proxyhub|

    proxyhub.vm.hostname = "proxyhub"
    proxyhub.vm.network :private_network, ip: "29.29.29.14"

    proxyhub.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    proxyhub.vm.provider :virtualbox do |vb, o|

      o.vm.box = "vagrant-centos-65-x86_64-minimal"
      o.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-x86_64-minimal.box"

      vb.customize [
        "modifyvm", :id, 
        "--memory", "1024",
        "--cpus", "2", 
        "--chipset", "ich9",
        "--vram", "10",
        "--nictype1", "virtio",
        "--nictype2", "virtio"
      ]
    end

    proxyhub.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"
      chef.synced_folder_type = "rsync"

      chef.json = {
        :dirsrv => {
          :use_yum_epel => true
        }
      }

      chef.run_list = [
        "recipe[dirsrv::_vagrant_proxyhub]"
      ]
    end
  end

  # Consumer
  config.vm.define "consumer" do |consumer|

    consumer.vm.hostname = "consumer"
    consumer.vm.network :private_network, ip: "29.29.29.15"

    consumer.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    consumer.vm.provider :virtualbox do |vb, o|

      o.vm.box = "trusty-server-cloudimg-amd64-vagrant-disk1"
      o.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

      vb.customize [
        "modifyvm", :id, 
        "--memory", "1024",
        "--cpus", "2", 
        "--chipset", "ich9",
        "--vram", "10",
        "--nictype1", "virtio",
        "--nictype2", "virtio"
      ]
    end

    consumer.vm.provision :chef_solo do |chef|

      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "vagrant-cookbooks"
      chef.encrypted_data_bag_secret_key_path = "vagrant_encrypted_data_bag_secret"
      chef.synced_folder_type = "rsync"

      chef.json = {
        :dirsrv => {
          :use_yum_epel => true
        }
      }

      chef.run_list = [
        "recipe[dirsrv::_vagrant_consumer]"
      ]
    end
  end
end
