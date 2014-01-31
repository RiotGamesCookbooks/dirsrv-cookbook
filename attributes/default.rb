#
# Cookbook Name:: dirsrv
# Attributes:: default
#
# Copyright 2013, Alan Willis
#
# All rights reserved - Do Not Redistribute
#

include_attribute 'sysctl'
default[:dirsrv][:use_sysctl] = false
default[:sysctl][:params][:fs][:file_max] = 64000
default[:sysctl][:params][:net][:ipv4][:tcp_keepalive_time] = 30
default[:sysctl][:params][:net][:ipv4][:ip_local_port_range] = '1024 65000'

default[:dirsrv][:use_yum_epel] = false
default[:dirsrv][:packages] = %w{389-ds}
