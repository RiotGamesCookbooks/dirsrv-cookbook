#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_primary
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
  id           1
  role         :multi_master
end

# admin server replica

dirsrv_replica 'o=NetscapeRoot' do
  instance     node[:hostname] + '_389'
  id           1
  role         :multi_master
end
