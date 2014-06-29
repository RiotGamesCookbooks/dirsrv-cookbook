#
# Cookbook Name:: dirsrv
# Resource:: replica
#
# Copyright 2014, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

actions :create
default_action :create

attribute :suffix, :kind_of => String, :name_attribute => true
attribute :instance, :kind_of => String, :required => true
attribute :id, :kind_of => Integer
attribute :role, :kind_of => Symbol, :required => true
attribute :purge_delay, :kind_of => String, :default => '604800'
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default'
attribute :base_dir, :kind_of => String, :default => '/var/lib/dirsrv'
