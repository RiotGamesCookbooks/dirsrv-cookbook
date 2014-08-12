#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_tertiary
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

include_recipe "dirsrv"
include_recipe "dirsrv::_vagrant_hosts"

dirsrv_instance node[:hostname] + '_389' do
  is_cfgdir     false
  has_cfgdir    true
  cfgdir_addr   '172.31.255.10'
  cfgdir_domain 'vagrant'
  cfgdir_ldap_port 389
  host         node[:hostname] + '.vagrant'
  suffix       'o=vagrant'
  action       [ :create, :start ]
end

include_recipe "dirsrv::_vagrant_replication"

# o=vagrant replica

dirsrv_replica 'o=vagrant' do
  instance     node[:hostname] + '_389'
  id           3
  role         :multi_master
end

# link back to primary master
dirsrv_agreement 'tertiary-primary' do
  host '172.31.255.12'
  suffix 'o=vagrant'
  replica_host '172.31.255.10'
  replica_credentials 'CopyCat!'
end

# Request initialization from primary
dirsrv_agreement 'primary-tertiary' do
  host '172.31.255.10'
  suffix 'o=vagrant'
  replica_host '172.31.255.12'
  replica_credentials 'CopyCat!'
  action :create_and_initialize
end

# link back to secondary master
dirsrv_agreement 'tertiary-secondary' do
  host '172.31.255.12'
  suffix 'o=vagrant'
  replica_host '172.31.255.11'
  replica_credentials 'CopyCat!'
end

# link from secondary
dirsrv_agreement 'secondary-tertiary' do
  host '172.31.255.11'
  suffix 'o=vagrant'
  replica_host '172.31.255.12'
  replica_credentials 'CopyCat!'
end

