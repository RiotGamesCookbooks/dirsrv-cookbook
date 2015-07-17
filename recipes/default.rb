#
# Cookbook Name:: dirsrv
# Recipe:: default
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

include_recipe "ldap"

if node[:dirsrv][:use_yum_epel] and platform_family?("rhel")
  yum_repository 'epel' do
    description 'Extra Packages for Enterprise Linux'
    mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
    gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
    action :create
  end
end

node[:dirsrv][:packages].each do |pkg|
  package pkg
end

chef_gem "orderedhash" do
  compile_time true
end

chef_gem "json" do
  compile_time true
end

user "dirsrv" do
  system true
  home node[:dirsrv][:base_dir]
  shell "/sbin/nologin"
end
