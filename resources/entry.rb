#
# Cookbook Name:: dirsrv
# Resource:: dirsrv_entry
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

actions :create, :modify, :delete
default_action :create

attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :userdn, :kind_of => String, :default => 'cn=Directory Manager'
attribute :pass, :kind_of => String, :default => 'password'
