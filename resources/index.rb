#
# Cookbook Name:: dirsrv
# Resource:: index
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

actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :database, :kind_of => String, :default => 'userRoot'
attribute :equality, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :presence, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :substring, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :databag_name, :kind_of => String
