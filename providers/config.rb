#
# Cookbook Name:: dirsrv
# Provider:: config
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

def whyrun_supported?
  true
end

action :enable do

  converge_by("Setting #{new_resource.attr}: #{new_resource.value}") do
    dirsrv_entry new_resource.attr do
      dn     'cn=config'
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      attributes ({ new_resource.attr.to_sym => new_resource.value.to_s })
    end
  end
end

action :disable do

  converge_by("Unsetting #{new_resource.key}") do
    dirsrv_entry new_resource.attr do
      dn     'cn=config'
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      prune  new_resource.value ? { new_resource.attr.to_sym => new_resource.value.to_s } : [ new_resource.attr.to_sym ]
    end
  end
end
