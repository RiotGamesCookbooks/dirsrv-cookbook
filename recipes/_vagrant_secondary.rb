#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_secondary
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

include_recipe "dirsrv"

dirsrv_instance node[:hostname] + '_389' do
  is_cfgdir     true
  has_cfgdir    true
  cfgdir_addr   '29.29.29.11'
  cfgdir_domain 'vagrant'
  cfgdir_ldap_port 389
  credentials  node[:dirsrv][:credentials]
  cfgdir_credentials  node[:dirsrv][:cfgdir_credentials]
  cfgdir_service_start false
  host         node[:fqdn]
  suffix       'o=vagrant'
  action       [ :create, :start ]
end

include_recipe "dirsrv::_vagrant_replication"

# o=vagrant replica

dirsrv_replica 'o=vagrant' do
  credentials  node[:dirsrv][:credentials]
  instance     node[:hostname] + '_389'
  id           2
  role         :multi_master
end

# link back to primary master
dirsrv_agreement 'secondary-primary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.11'
  suffix 'o=vagrant'
  description 'supplier link from secondary to primary'
  replica_host '29.29.29.10'
  replica_credentials 'CopyCat!'
end

# Request initialization from primary
dirsrv_agreement 'primary-secondary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.10'
  suffix 'o=vagrant'
  description 'supplier link from primary to secondary'
  replica_host '29.29.29.11'
  replica_credentials 'CopyCat!'
  action [ :create, :initialize ]
end

# admin server replica

dirsrv_replica 'o=NetscapeRoot' do
  credentials  node[:dirsrv][:cfgdir_credentials]
  instance     node[:hostname] + '_389'
  id           2
  role         :multi_master
end

# link back to primary master
dirsrv_agreement 'cfgdir-secondary-primary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.11'
  suffix 'o=NetscapeRoot'
  description 'supplier link from secondary to primary'
  replica_host '29.29.29.10'
  replica_credentials 'CopyCat!'
end

# Request initialization from primary
dirsrv_agreement 'cfgdir-primary-secondary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.10'
  suffix 'o=NetscapeRoot'
  description 'supplier link from primary to secondary'
  replica_host '29.29.29.11'
  replica_credentials 'CopyCat!'
  action [ :create, :initialize ]
end

service "dirsrv-admin" do
  action :start
end

# Write an entry for this node
dirsrv_entry "ou=#{node[:hostname]},o=vagrant" do
  credentials  node[:dirsrv][:credentials]
  port        389
  attributes  ({ objectClass: [ 'top', 'organizationalUnit' ], l: [ 'PA', 'CA' ], telephoneNumber: '215-310-5555' })
  prune      ([ :postalCode, :description ])
end
