#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_hosts
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

# Setup hosts file entries so that the hostnames 
# used by Vagrant appear to be fully qualified
# to the 389-ds setup scripts

hosts = { 
  primary:    '172.31.255.10',
  secondary:  '172.31.255.11',
  tertiary:   '172.31.255.12',
  quaternary: '172.31.255.13',
  proxyhub:   '172.31.255.14',
  consumer:   '172.31.255.15'
}

hosts.each do |hostname, ipaddress|
  hostsfile_entry ipaddress do
    hostname "#{hostname}.vagrant"
  end
end
