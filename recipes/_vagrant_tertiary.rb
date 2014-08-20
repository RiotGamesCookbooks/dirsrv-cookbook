#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_tertiary
#
# Copyright 2014 Riot Games, Inc.
# Author:: Alan Willis <alwillis@riotgames.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
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

