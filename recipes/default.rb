#
# Cookbook Name:: 389ds
# Recipe:: default
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

include_recipe "yum::epel"

node['389ds']['packages'].each do |pkg|
  package pkg
end

user 'dirsrv' do
  system true
  home node['389ds']['base_dir']
  shell "/sbin/nologin"
end

node['389ds']['instances'].each do |inst|
  directory_instance inst['name'] do
    notifies :start, "service[dirsrv]"
  end
end

service "dirsrv" do
  supports :status => true, :restart => true
  action :enable
end
