#
# Cookbook Name:: dirsrv
# Attributes:: default
#
# Copyright 2013, Alan Willis
#
# All rights reserved - Do Not Redistribute
#

include_attribute 'sysctl'
default[:sysctl][:params][:net][:ipv4][:tcp_keepalive_time] = 30

default[:dirsrv][:packages] = %w{389-ds}
default[:dirsrv][:use_epel] = false
default[:dirsrv][:do_tuning] = false
