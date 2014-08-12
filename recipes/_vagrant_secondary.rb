#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_secondary
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

include_recipe "dirsrv"
include_recipe "dirsrv::_vagrant_hosts"

dirsrv_instance node[:hostname] + '_389' do
  is_cfgdir     true
  has_cfgdir    true
  cfgdir_addr   '172.31.255.11'
  cfgdir_domain 'vagrant'
  cfgdir_ldap_port 389
  cfgdir_service_start false
  host         node[:hostname] + '.vagrant'
  suffix       'o=vagrant'
  action       [ :create, :start ]
end

include_recipe "dirsrv::_vagrant_replication"

# o=vagrant replica

dirsrv_replica 'o=vagrant' do
  instance     node[:hostname] + '_389'
  id           2
  role         :multi_master
end

# link back to primary master
dirsrv_agreement 'secondary-primary' do
  host '172.31.255.11'
  suffix 'o=vagrant'
  replica_host '172.31.255.10'
  replica_credentials 'CopyCat!'
end

# Request initialization from primary
dirsrv_agreement 'primary-secondary' do
  host '172.31.255.10'
  suffix 'o=vagrant'
  replica_host '172.31.255.11'
  replica_credentials 'CopyCat!'
  action :create_and_initialize
end

# admin server replica

dirsrv_replica 'o=NetscapeRoot' do
  instance     node[:hostname] + '_389'
  id           2
  role         :multi_master
end

# link back to primary master
dirsrv_agreement 'cfgdir-secondary-primary' do
  host '172.31.255.11'
  suffix 'o=NetscapeRoot'
  replica_host '172.31.255.10'
  replica_credentials 'CopyCat!'
end

# Request initialization from primary
dirsrv_agreement 'cfgdir-primary-secondary' do
  host '172.31.255.10'
  suffix 'o=NetscapeRoot'
  replica_host '172.31.255.11'
  replica_credentials 'CopyCat!'
  action :create_and_initialize
end

service "dirsrv-admin" do
  action :start
end
