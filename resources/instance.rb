#
# Cookbook Name:: dirsrv
# Resource:: instance
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

actions :create, :start, :stop, :restart
default_action :create

attribute :instance, :kind_of => String, :name_attribute => true
attribute :suffix, :kind_of => String, :required => true
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default'
attribute :host, :kind_of => String, :default => node[:fqdn]
attribute :port, :kind_of => Integer, :default => 389
attribute :cfgdir_domain, :kind_of => String
attribute :cfgdir_credentials, :kind_of => [ String, Hash ], :default => 'default'
attribute :cfgdir_host, :kind_of => String
attribute :cfgdir_port, :kind_of => Integer, :default => 9830
attribute :has_cfgdir, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :add_org_entries, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :add_sample_entries, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :preseed_ldif, :kind_of => String
attribute :conf_dir, :kind_of => String, :default => node[:dirsrv][:conf_dir]
attribute :base_dir, :kind_of => String, :default => node[:dirsrv][:base_dir]
