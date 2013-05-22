#
# Cookbook Name:: dirsrv
# Provider:: entry
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

action :create do
  ldap = bind
end

action :modify do
end

action :delete do
end

def bind
  Dirsrv.new( new_resource.host, 
              new_resource.port, 
              new_resource.userdn,
              new_resource.pass )
end
