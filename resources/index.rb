#
# Cookbook Name:: dirsrv
# Resource:: index
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :database, :kind_of => String, :default => 'userRoot'
attribute :equality, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :presence, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :substring, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default'
