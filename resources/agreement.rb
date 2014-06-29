#
# Cookbook Name:: dirsrv
# Resource:: agreement
#
# Copyright 2014, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

actions :create, :start, :initialize
default_action :create

attribute :description, :kind_of => String, :name_attribute => true
attribute :suffix, :kind_of => String, :required => true
attribute :replica_host, :kind_of => String, :required => true
attribute :replica_port, :kind_of => Integer, :default => 389
attribute :replica_binddn, :kind_of => String, :default => 'cn=Replication Manager,cn=config'
attribute :replica_bind_method, :kind_of => String, :default => 'SIMPLE'
attribute :replica_credentials, :kind_of => String
attribute :update_schedule, :kind_of => String, :default => 'SIMPLE'
attribute :replicated_attribute_list, :kind_of => String, :default => '(objectclass=*) $ EXCLUDE authorityRevocationList accountUnlockTime memberof'
attribute :replicated_attribute_list_total, :kind_of => String, :default => '(objectclass=*) $ EXCLUDE accountUnlockTime'
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default'
