#
# Cookbook Name:: 389ds
# Attributes:: default
#
# Copyright 2013, Alan Willis
#
# All rights reserved - Do Not Redistribute
#

include_attribute 'sysctl'
default['sysctl']['params']['net']['ipv4']['tcp_keepalive_time'] = 30

default['389ds']['packages'] = %w{389-ds}
default['389ds']['conf_dir'] '/etc/dirsrv'
default['389ds']['base_dir'] '/var/lib/dirsrv'
default['389ds']['instances'] = Array.new
