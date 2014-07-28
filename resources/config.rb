# Cookbook Name:: dirsrv
# Resource:: config
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

actions :enable, :disable
default_action :enable

attribute :attr, :kind_of => String, :name_attribute => true
attribute :value, :kind_of => [ String, Array ], :default => []
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
