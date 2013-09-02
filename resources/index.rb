#
# Cookbook Name:: dirsrv
# Resource:: index
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :instance, :kind_of => String, :default => 'userRoot'
attribute :equality, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :presence, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :substring, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :userdn, :kind_of => String, :required => true
attribute :pass, :kind_of => String, :required => true
