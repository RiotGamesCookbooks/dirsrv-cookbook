#
# Cookbook Name:: dirsrv
# Resource:: entry
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

actions :create, :delete
default_action :create

attribute :dn, :kind_of => String, :name_attribute => true
attribute :attributes, :kind_of => Hash, :default => {}
attribute :append_attributes, :kind_of => Hash, :default => {}
attribute :seed_attributes, :kind_of => Hash, :default => {}
attribute :prune, :kind_of => [ Array, Hash ], :default => []
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :databag_name, :kind_of => String
