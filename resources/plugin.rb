# Cookbook Name:: dirsrv
# Resource:: plugin
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

actions :enable, :disable, :modify
default_action :enable

attribute :common_name, :kind_of => String, :name_attribute => true
attribute :attributes, :kind_of => Hash, :default => {}
attribute :append_attributes, :kind_of => Hash, :default => {}
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :databag_name, :kind_of => String
