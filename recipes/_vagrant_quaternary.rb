#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_quaternary
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

include_recipe "dirsrv"

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
  id           4
  role         :multi_master
end

# link back to primary master
dirsrv_agreement 'quaternary-primary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.13'
  suffix 'o=vagrant'
  description 'supplier link from quaternary to primary'
  replica_host '29.29.29.10'
  replica_credentials 'CopyCat!'
end

# Request initialization from primary
dirsrv_agreement 'primary-quaternary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.10'
  suffix 'o=vagrant'
  description 'supplier link from primary to quaternary'
  replica_host '29.29.29.13'
  replica_credentials 'CopyCat!'
end

# link back to secondary master
dirsrv_agreement 'quaternary-secondary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.13'
  suffix 'o=vagrant'
  description 'supplier link from quaternary to secondary'
  replica_host '29.29.29.11'
  replica_credentials 'CopyCat!'
end

# link from secondary
dirsrv_agreement 'secondary-quaternary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.11'
  suffix 'o=vagrant'
  description 'supplier link from secondary to quaternary'
  replica_host '29.29.29.13'
  replica_credentials 'CopyCat!'
end

# link back to tertiary master
dirsrv_agreement 'quaternary-tertiary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.13'
  suffix 'o=vagrant'
  description 'supplier link from quaternary to secondary'
  replica_host '29.29.29.12'
  replica_credentials 'CopyCat!'
end

# link from tertiary
dirsrv_agreement 'tertiary-quaternary' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.12'
  suffix 'o=vagrant'
  description 'supplier link from secondary to quaternary'
  replica_host '29.29.29.13'
  replica_credentials 'CopyCat!'
end

# Write an entry for this node
dirsrv_entry "ou=#{node[:hostname]},o=vagrant" do
  credentials  node[:dirsrv][:credentials]
  port        389
  attributes  ({ objectClass: [ 'top', 'organizationalUnit' ], l: [ 'PA', 'CA' ], telephoneNumber: '215-310-5555' })
  prune      ([ :postalCode, :description ])
end
