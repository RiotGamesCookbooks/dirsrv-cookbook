#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_proxyproxyhub
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

include_recipe "dirsrv"

dirsrv_instance node[:hostname] + '_389' do
  has_cfgdir    true
  cfgdir_addr   '29.29.29.10'
  cfgdir_domain "vagrant"
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
  id           5
  role         :hub
end

# link back to secondary master
dirsrv_agreement 'proxyhub-secondary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.14'
  suffix 'o=vagrant'
  description 'supplier link from proxyhub to secondary'
  replica_host '29.29.29.11'
  replica_credentials 'CopyCat!'
end

# Request initialization from secondary
dirsrv_agreement 'secondary-proxyhub' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.11'
  suffix 'o=vagrant'
  description 'supplier link from secondary to proxyhub'
  replica_host '29.29.29.14'
  replica_credentials 'CopyCat!'
  action :create_and_initialize
end
