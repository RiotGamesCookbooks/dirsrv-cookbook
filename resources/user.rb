# Cookbook Name:: dirsrv
# Resource:: user
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

actions :create, :delete
default_action :create

attribute :common_name, :kind_of => String, :name_attribute => true
attribute :surname, :kind_of => String
attribute :password, :kind_of => String
attribute :home, :kind_of => String
attribute :shell, :kind_of => String
attribute :basedn, :kind_of => String, :required => true
attribute :relativedn_attribute, :kind_of => String, :default => 'uid'
attribute :uid_number, :kind_of => Integer
attribute :gid_number, :kind_of => Integer
attribute :is_person, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :is_posix, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :is_extensible, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :databag_name, :kind_of => String
