#
# Cookbook Name:: dirsrv
# Attributes:: default
#
# Copyright 2013, Alan Willis
#
# All rights reserved - Do Not Redistribute
#

default[:dirsrv][:use_yum_epel] = false
default[:dirsrv][:packages] = %w{389-ds}
