#
# Cookbook Name:: dirsrv
# Resource:: instance
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

actions :create, :start, :stop, :restart
default_action :create

attribute :instance, :kind_of => String, :name_attribute => true
attribute :suffix, :kind_of => String, :required => true
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :host, :kind_of => String, :default => node[:fqdn]
attribute :port, :kind_of => Integer, :default => 389
attribute :cfgdir_domain, :kind_of => String
attribute :cfgdir_credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :cfgdir_addr, :kind_of => String, :default => node[:ipaddress]
attribute :cfgdir_http_port, :kind_of => Integer, :default => 9830
attribute :cfgdir_ldap_port, :kind_of => Integer, :default => 389
attribute :cfgdir_service_start, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :is_cfgdir, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :has_cfgdir, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :add_org_entries, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :add_sample_entries, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :preseed_ldif, :kind_of => String
attribute :conf_dir, :kind_of => String, :default => '/etc/dirsrv'
attribute :base_dir, :kind_of => String, :default => '/var/lib/dirsrv'
