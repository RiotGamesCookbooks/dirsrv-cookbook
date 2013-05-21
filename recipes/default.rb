#
# Cookbook Name:: dirsrv
# Recipe:: default
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

if node[:dirsrv][:use_epel]
  include_recipe "yum::epel"
end

if node[:dirsrv][:do_tuning]
  include_recipe "sysctl"
end

node[:dirsrv][:packages].each do |pkg|
  package pkg
end

chef_gem "net-ldap"

user "dirsrv" do
  system true
  home node[:dirsrv][:base_dir]
  shell "/sbin/nologin"
end
