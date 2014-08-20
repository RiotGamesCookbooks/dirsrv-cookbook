# Cookbook Name:: dirsrv
# Resource:: user
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

actions :create, :delete
default_action :create

attribute :common_name, :kind_of => String, :name_attribute => true
attribute :surname, :kind_of => String
attribute :password, :kind_of => String
attribute :home, :kind_of => String
attribute :shell, :kind_of => String
attribute :basedn, :kind_of => String, :required => true
attribute :relativedn_attribute, :kind_of => String, :default => 'uid'
attribute :uid_number, :kind_of => Integer
attribute :gid_number, :kind_of => Integer
attribute :is_person, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :is_posix, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :is_extensible, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :databag_name, :kind_of => String
