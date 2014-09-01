#
# Cookbook Name:: dirsrv
# Resource:: aci
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

actions :set, :extend, :rescind, :unset
default_action :set

# The :set action allows for setting a new access control instruction
# The :extend action can introduce new users, groups, attributes, and hosts to the existing permission
# The :rescind action can remove existing users, groups, attributes and hosts from the existing permission
# The :unset action removes the whole permission from the entry. 
# NOTE: An entry may have multiple access control instructions
# NOTE: You can use this resource to express double negatives which can be confusing 
# ( e.g. :rescind action on a not_* list ). This is not the same as granting access
# as that is determined by all of the ACIs collectively, including inherited ACIs.
# There is a lot expressive power here, be careful :)

attribute :label, :kind_of => String, :name_attribute => true
attribute :distinguished_name, :kind_of => String, :required => true
attribute :permit, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :permissions, :kind_of => Array, :default => [ 'all' ]
# positive
attribute :userdn, :kind_of => [ Array, String ]
attribute :groupdn, :kind_of => [ Array, String ]
attribute :attribute_list, :kind_of => Array, :default => [ '*' ]
attribute :access_hosts, :kind_of => [ Array, String ]
# negative
attribute :not_userdn, :kind_of => [ Array, String ]
attribute :not_groupdn, :kind_of => [ Array, String ]
attribute :not_attribute_list, :kind_of => Array
attribute :not_access_hosts, :kind_of => [ Array, String ]
# time spec
attribute :days_of_week, :kind_of => [ Array, String ]
attribute :time_of_day_start, :kind_of => String
attribute :time_of_day_end, :kind_of => String
# for ldap_entry
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :databag_name, :kind_of => String
