#
# Cookbook Name:: dirsrv
# Resource:: directory_instance
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

actions :create, :start, :stop, :restart
default_action :create

attribute :instance, :kind_of => String, :name_attribute => true
attribute :admin_domain, :kind_of => String, :default => nil
attribute :admin_user, :kind_of => String, :default => nil
attribute :admin_pass, :kind_of => String, :default => nil
attribute :admin_port, :kind_of => Integer, :default => 9830
attribute :admin_bindaddr, :kind_of => String, :default => node[:ipaddress]
attribute :admin_host, :kind_of => String, :default => nil
attribute :is_admin, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :add_org_entries, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :add_sample_entries, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :preseed_ldif, :kind_of => String, :default => nil
attribute :root_dn, :kind_of => String, :default => 'cn=Directory Manager'
attribute :root_pass, :kind_of => String, :default => nil
attribute :port, :kind_of => Integer, :default => 389
attribute :suffix, :kind_of => String, :default => nil
attribute :conf_dir, :kind_of => String, :default => node[:dirsrv][:conf_dir]
attribute :base_dir, :kind_of => String, :default => node[:dirsrv][:base_dir]
