#
# Cookbook Name:: dirsrv
# Recipe:: default
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

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

chef_gem "net-ldap"
chef_gem "cicphash"
chef_gem "json"

user "dirsrv" do
  system true
  home node[:dirsrv][:base_dir]
  shell "/sbin/nologin"
end
