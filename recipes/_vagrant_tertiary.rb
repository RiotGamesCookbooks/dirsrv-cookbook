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
  cfgdir_addr   '29.29.29.10'
  cfgdir_domain 'vagrant'
  cfgdir_ldap_port 389
  credentials  node[:dirsrv][:credentials]
  cfgdir_credentials  node[:dirsrv][:cfgdir_credentials]
  host         node[:fqdn]
  suffix       'o=vagrant'
  action       [ :create, :start ]
end

include_recipe "dirsrv::_vagrant_replication"

# o=vagrant replica

dirsrv_replica 'o=vagrant' do
  credentials  node[:dirsrv][:credentials]
  instance     node[:hostname] + '_389'
  id           3
  role         :multi_master
end

# link back to primary master
dirsrv_agreement 'tertiary-primary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.12'
  suffix 'o=vagrant'
  replica_host '29.29.29.10'
  replica_credentials 'CopyCat!'
end

# Request initialization from primary
dirsrv_agreement 'primary-tertiary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.10'
  suffix 'o=vagrant'
  replica_host '29.29.29.12'
  replica_credentials 'CopyCat!'
  action :create_and_initialize
end

# link back to secondary master
dirsrv_agreement 'tertiary-secondary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.12'
  suffix 'o=vagrant'
  replica_host '29.29.29.11'
  replica_credentials 'CopyCat!'
end

# link from secondary
dirsrv_agreement 'secondary-tertiary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.11'
  suffix 'o=vagrant'
  replica_host '29.29.29.12'
  replica_credentials 'CopyCat!'
end

