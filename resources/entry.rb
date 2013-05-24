#
# Cookbook Name:: dirsrv
# Resource:: dirsrv_entry
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

actions :create, :delete
default_action :create

attribute :dn, :kind_of => String, :name_attribute => true
attribute :attributes, :kind_of => Hash, :default => {}
attribute :prune_attributes, :kind_of => Array, :default => []
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :userdn, :kind_of => String, :default => 'cn=Directory Manager'
attribute :pass, :kind_of => String, :default => 'password'
