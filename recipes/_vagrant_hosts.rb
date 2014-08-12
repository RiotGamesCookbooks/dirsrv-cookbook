#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_hosts
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

# Setup hosts file entries so that the hostnames 
# used by Vagrant appear to be fully qualified
# to the 389-ds setup scripts

hosts = { 
  primary:    '172.31.255.10',
  secondary:  '172.31.255.11',
  tertiary:   '172.31.255.12',
  quaternary: '172.31.255.13',
  proxyhub:   '172.31.255.14',
  consumer:   '172.31.255.15'
}

hosts.each do |hostname, ipaddress|
  hostsfile_entry ipaddress do
    hostname "#{hostname}.vagrant"
  end
end
