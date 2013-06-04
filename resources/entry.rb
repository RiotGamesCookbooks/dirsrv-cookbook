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
attribute :append_attributes, :kind_of => Hash, :default => {}
attribute :prune, :kind_of => [ Array, Hash ], :default => []
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :userdn, :kind_of => String, :required => true
attribute :pass, :kind_of => String, :required => true
