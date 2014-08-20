#
# Cookbook Name:: dirsrv
# Resource:: agreement
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

actions :create, :create_and_initialize
default_action :create

attribute :label, :kind_of => String, :name_attribute => true
attribute :suffix, :kind_of => String, :required => true
attribute :directory_type, :kind_of => [ :AD, :DS ], :default => :DS
attribute :replica_host, :kind_of => String, :required => true
attribute :replica_port, :kind_of => [ Integer, String ], :default => 389
attribute :replica_bind_dn, :kind_of => String, :default => 'cn=Replication Manager,cn=config'
attribute :replica_update_schedule, :kind_of => String, :default => '0000-2359 0123456'
attribute :replica_bind_method, :kind_of => [ 'SIMPLE', 'SSLCLIENTAUTH', 'SASL/GSSAPI', 'SASL/DIGEST-MD5' ], :default => 'SIMPLE'
attribute :replica_transport, :kind_of => [ 'LDAP', 'SSL', 'TLS' ], :default => 'LDAP'
attribute :replica_credentials, :kind_of => String
attribute :ds_replicated_attribute_list, :kind_of => String, :default => '(objectclass=*) $ EXCLUDE authorityRevocationList accountUnlockTime memberof'
attribute :ds_replicated_attribute_list_total, :kind_of => String, :default => '(objectclass=*) $ EXCLUDE accountUnlockTime'
attribute :ad_domain, :kind_of => String
attribute :ad_new_user_sync, :kind_of => String
attribute :ad_new_group_sync, :kind_of => String
attribute :ad_one_way_sync, :kind_of => String
attribute :ad_sync_interval, :kind_of => Integer, :default => 300
attribute :ad_sync_move_action, :kind_of => [ 'none', 'delete', 'unsync' ], :default => 'none'
attribute :ad_replica_subtree, :kind_of => String
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :databag_name, :kind_of => String
