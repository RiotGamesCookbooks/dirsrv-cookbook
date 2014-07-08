#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_primary
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

include_recipe "dirsrv"

dirsrv_instance node[:hostname] + '_389' do
  is_cfgdir     true
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
  id           1
  role         :multi_master
end

# admin server replica

dirsrv_replica 'o=NetscapeRoot' do
  credentials  node[:dirsrv][:cfgdir_credentials]
  instance     node[:hostname] + '_389'
  id           1
  role         :multi_master
end
