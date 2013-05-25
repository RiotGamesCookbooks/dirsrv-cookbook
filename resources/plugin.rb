# Cookbook Name:: dirsrv
# Resource:: dirsrv_plugin
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

actions :enable, :disable, :modify
default_action :enable

attribute :common_name, :kind_of => String, :name_attribute => true
attribute :attributes, :kind_of => Hash, :default => {}
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :userdn, :kind_of => String, :required => true
attribute :pass, :kind_of => String, :required => true