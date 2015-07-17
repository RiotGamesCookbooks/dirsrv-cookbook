# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.omnibus.chef_version = "12.3.0"
  config.vm.box = "opscode-centos-6.4"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4_chef-provisionerless.box"

  # Primary Master
  config.vm.define "primary" do |primary|

    primary.vm.hostname = "primary"
    primary.vm.network :private_network, ip: "172.31.255.10"

    primary.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    primary.vm.provider :virtualbox do |vb, o|

      o.vm.box = "opscode-centos-6.4"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4_chef-provisionerless.box"

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

    primary.vm.provider :vmware_workstation do |vmware, o|

      o.vm.box = "opscode-centos-6.4"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-6.4_chef-provisionerless.box"

      vmware.gui = true
      vmware.vmx["memsize"] = "1024"
      vmware.vmx["numvcpus"] = "2"
      vmware.vmx["ethernet0.virtualDev"] = "vmxnet"
      vmware.vmx["ethernet1.virtualDev"] = "vmxnet"
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
    secondary.vm.network :private_network, ip: "172.31.255.11"

    secondary.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    secondary.vm.provider :virtualbox do |vb, o|

      o.vm.box = "opscode-ubuntu-14.04"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"

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

    secondary.vm.provider :vmware_workstation do |vmware, o|

      o.vm.box = "opscode-ubuntu-14.04"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-14.04_chef-provisionerless.box"

      vmware.gui = true
      vmware.vmx["memsize"] = "1024"
      vmware.vmx["numvcpus"] = "2"
      vmware.vmx["ethernet0.virtualDev"] = "vmxnet"
      vmware.vmx["ethernet1.virtualDev"] = "vmxnet"
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
    tertiary.vm.network :private_network, ip: "172.31.255.12"

    tertiary.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    tertiary.vm.provider :virtualbox do |vb, o|

      o.vm.box = "opscode-centos-6.4"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4_chef-provisionerless.box"

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

    tertiary.vm.provider :vmware_workstation do |vmware, o|

      o.vm.box = "opscode-centos-6.4"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-6.4_chef-provisionerless.box"

      vmware.gui = true
      vmware.vmx["memsize"] = "1024"
      vmware.vmx["numvcpus"] = "2"
      vmware.vmx["ethernet0.virtualDev"] = "vmxnet"
      vmware.vmx["ethernet1.virtualDev"] = "vmxnet"
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
    quaternary.vm.network :private_network, ip: "172.31.255.13"

    quaternary.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    quaternary.vm.provider :virtualbox do |vb, o|

      o.vm.box = "opscode-ubuntu-14.04"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"

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

    quaternary.vm.provider :vmware_workstation do |vmware, o|

      o.vm.box = "opscode-ubuntu-14.04"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-14.04_chef-provisionerless.box"

      vmware.gui = true
      vmware.vmx["memsize"] = "1024"
      vmware.vmx["numvcpus"] = "2"
      vmware.vmx["ethernet0.virtualDev"] = "vmxnet"
      vmware.vmx["ethernet1.virtualDev"] = "vmxnet"
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
    proxyhub.vm.network :private_network, ip: "172.31.255.14"

    proxyhub.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    proxyhub.vm.provider :virtualbox do |vb, o|

      o.vm.box = "opscode-centos-6.4"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4_chef-provisionerless.box"

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

    proxyhub.vm.provider :vmware_workstation do |vmware, o|

      o.vm.box = "opscode-centos-6.4"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-6.4_chef-provisionerless.box"

      vmware.gui = true
      vmware.vmx["memsize"] = "1024"
      vmware.vmx["numvcpus"] = "2"
      vmware.vmx["ethernet0.virtualDev"] = "vmxnet"
      vmware.vmx["ethernet1.virtualDev"] = "vmxnet"
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
    consumer.vm.network :private_network, ip: "172.31.255.15"

    consumer.vm.provider :libvirt do |virt, o|

      o.vm.box = "centos64"
      o.vm.box_url = "http://kwok.cz/centos64.box"

      virt.cpus = 2
      virt.memory = 1024
    end

    consumer.vm.provider :virtualbox do |vb, o|

      o.vm.box = "opscode-ubuntu-14.04"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"

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

    consumer.vm.provider :vmware_workstation do |vmware, o|

      o.vm.box = "opscode-ubuntu-14.04"
      o.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-14.04_chef-provisionerless.box"

      vmware.gui = true
      vmware.vmx["memsize"] = "1024"
      vmware.vmx["numvcpus"] = "2"
      vmware.vmx["ethernet0.virtualDev"] = "vmxnet"
      vmware.vmx["ethernet1.virtualDev"] = "vmxnet"
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
