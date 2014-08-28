#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_replication
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

# Audit log
dirsrv_config "nsslapd-auditlog-logging-enabled" do
  value  'on'
end

dirsrv_config "nsslapd-auditlog-logrotationsync-enabled" do
  value  'on'
end

# Replication Debug
dirsrv_config "nsslapd-errorlog-level" do
  value  '8192'
end

# cn=Replication Manager,cn=config

ldap_user "Replication Manager" do
  basedn 'cn=config'
  relativedn_attribute 'cn'
  password 'CopyCat!'
  is_posix false
end
