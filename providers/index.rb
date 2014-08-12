#
# Cookbook Name:: dirsrv
# Provider:: index
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

use_inline_resources

def whyrun_supported?
  true
end

action :create do

  attrs = Array.new
  attrs.push('eq') if new_resource.equality
  attrs.push('pres') if new_resource.presence
  attrs.push('sub') if new_resource.substring

  # Index is per database backend
  idxattrs = {
      objectClass: [ 'top', 'nsIndex' ],
      cn: new_resource.name,
      nsSystemIndex: 'false',
      nsIndexType: attrs
  }

  # The nsInstance attribute must correspond to the commonName (cn) of an entry under cn=ldbm database,cn=plugins,cn=config
  taskattrs = { 
    objectClass: [ 'top', 'extensibleObject' ],
    cn: new_resource.name,
    nsInstance: new_resource.database,
    nsIndexAttribute: new_resource.name + ':' + attrs.join(',') 
  }

  converge_by("Creating index for #{new_resource.name} attribute") do

    ldap_entry "cn=#{new_resource.name},cn=index,cn=#{new_resource.database},cn=ldbm database,cn=plugins,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes idxattrs
    end

    ldap_entry "cn=#{new_resource.name},cn=index,cn=tasks,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes taskattrs
      action :nothing
      subscribes :create, "ldap_entry[cn=#{new_resource.name},cn=index,cn=#{new_resource.database},cn=ldbm database,cn=plugins,cn=config]", :immediately
    end
  end
end

