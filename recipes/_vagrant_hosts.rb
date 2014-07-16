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
  primary:    '29.29.29.10',
  secondary:  '29.29.29.11',
  tertiary:   '29.29.29.12',
  quaternary: '29.29.29.13',
  proxyhub:   '29.29.29.14',
  consumer:   '29.29.29.15'
}

hosts.each do |hostname, ipaddress|
  hostsfile_entry ipaddress do
    hostname "#{hostname}.vagrant"
  end
end
