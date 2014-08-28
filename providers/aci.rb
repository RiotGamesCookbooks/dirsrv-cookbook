#
# Cookbook Name:: dirsrv
# Provider:: aci
#
# Copyright 2014 Riot Games, Inc.
# Author:: Alan Willis <alwillis@riotgames.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use_inline_resources

def whyrun_supported?
  true
end

action :set do

  @connectinfo = load_connection_info
  @current_resource = load_current_resource
  access_control_instruction = @current_resource[new_resource.label.to_s]

  converge_by("Setting ACI #{new_resource.label} on #{new_resource.distinguished_name}") do

    # Target should always be for this DN

    # users
    # Who has access permission? Specify if userdn or groupdn
    # ( userdn = "" or groupdn = "" ) and any other method
    # default to ldap:///anyone

    # rights
    rights = access_control_instruction.match(/(allow|deny)\s*\((.*?)\)/)
    ( permit, permissions ) = rights.captures
    permissions = permissions.split(/\,\s*/)
    rights_aci = Array.new

    case new_resource.mode
    when :set
      rights_aci.push(new_resource.aci_rights_permit)
      permissions = new_resource.aci_rights_permissions.join(',')
      rights_aci.push(permissions)
    when :append
      rights_aci.push(permit)
      permissions = ( permissions & new_resource.aci_rights_permissions ).join(',')
      rights_aci.push("\(#{permissions}\)")
    when :prune
      rights_aci.push(permit)
      permissions = ( permissions - new_resource.aci_rights_permissions ).join(',')
      rights_aci.push("\(#{permissions}\)")
    end

    rights_aci = rights_aci.join(' ')

    # targets
    tgtattrs = new_resource.aci_attrs_list
    tgtequal = new_resource.aci_attrs_not ? '!=' : '='
    targetattr = access_control_instruction.match(/\(\s*targetattr\s*(\!?=)\s*\"(.*)\"\)/)
    ( current_tgtequal, current_tgtattrs ) = targetattr.captures
    current_tgtattrs = current_tgtattrs.split(/\s*\|\|\s*/)

    if new_resource.aci_attrs_list.empty?
      tgtattrs = current_tgtattrs
      tgtequal = current_tgtequal
    end

    targetattr_aci = [ 'targetattr', tgtequal ]

    case new_resource.mode
    when :set
      tgtattrs = tgtattrs.join(' || ')
    when :append
      tgtattrs.push(current_tgtattrs)
      tgtattrs = tgtattrs.join(' || ')
    when :prune
      tgtattrs = ( current_tgtattrs - tgtattrs ).join(' || ')
    end

    targetattr_aci.push("\"#{tgtattrs}\"")
    targetattr_aci = targetattr_aci.join

    # hosts
    # This is combined with the users and groups who have access
    # ( users ) and ( ip = "ip" or dns = "domain.name" )

    # time
    # ( dayofweek = "Mon,Tue,Wed,Thu" ) and
    # ( timeofday = >= "100" and timeofday < "1900" )
    

    # Who has access permission? Specify if userdn or groupdn
    # ( userdn = "" or groupdn = "" ) and any other method
    # Target should always be for this DN
    # acl label matches the label attribute
    # allow set list of items (all), (all,proxy), (read,compare,search,selfwrite,write,delete,add,proxy)
    # userdn or groupdn and access object
    # if combined with some other method, then do (ldap:///anyone)


    # combine in this order:
    # ( targetattr )
    # ( target )
    # ( targetfilter )
    # ( version 3.0;
    #   acl <label>
    #   allow ( rights )( users )
    #   and ( hosts )
    #   and ( days )
    #   and ( hours );
    # )

    dirsrv_entry dn do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes ({ aci: access_control_instruction })
    end
  end
end

action :unset do

  @current_resource = load_current_resource

  if @current_resource
    converge_by("Removing #{new_resource.label} from #{new_resource.distinguished_name}") do

      access_control_instruction = @current_resource[new_resource.label.to_s]

      dirsrv_entry @current_resource[:dn] do
        host   new_resource.host
        port   new_resource.port
        credentials new_resource.credentials
        databag_name new_resource.databag_name
        prune ({ aci: access_control_instruction })
      end
    end
  end
end

def load_current_resource

  require 'orderedhash'

  dirsrv = Chef::Dirsrv.new
  @connectinfo = load_connection_info
  @current_resource = OrderedHash.new
  entry = dirsrv.get_entry( @connectinfo, @new_resource.distinguished_name )

  entry[:aci].each do |aci|
    label = aci.match(/acl \"(.*)\";/)
    @current_resource[label.captures.first] = aci
  end

  @current_resource
end

def load_connection_info

  @connectinfo = Hash.new
  @connectinfo.class.module_eval { attr_accessor :host, :port, :credentials, :databag_name }
  @connectinfo.host = new_resource.host
  @connectinfo.port = new_resource.port
  @connectinfo.credentials = new_resource.credentials
  # default databag name is cookbook name
  databag_name = new_resource.databag_name.nil? ? new_resource.cookbook_name : new_resource.databag_name
  @connectinfo.databag_name = databag_name
  @connectinfo
end
