#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_consumer
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

include_recipe "dirsrv"
include_recipe "dirsrv::_vagrant_hosts"

dirsrv_instance node[:hostname] + '_389' do
  has_cfgdir    true
  cfgdir_addr   '29.29.29.10'
  cfgdir_domain "vagrant"
  cfgdir_ldap_port 389
  host         node[:hostname] + '.vagrant'
  suffix       'o=vagrant'
  action       [ :create, :start ]
end

include_recipe "dirsrv::_vagrant_replication"

# o=vagrant replica

dirsrv_replica 'o=vagrant' do
  instance     node[:hostname] + '_389'
  id           6
  role         :consumer
end

# link back to proxyhub
dirsrv_agreement 'consumer-proxyhub' do
  host '29.29.29.15'
  suffix 'o=vagrant'
  replica_host '29.29.29.14'
  replica_credentials 'CopyCat!'
end

# Request initialization from proxyhub
dirsrv_agreement 'proxyhub-consumer' do
  host '29.29.29.14'
  suffix 'o=vagrant'
  replica_host '29.29.29.15'
  replica_credentials 'CopyCat!'
  action :create_and_initialize
end
