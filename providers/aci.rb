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

  converge_by("Adding ACI #{new_resource.label} on #{new_resource.dn}") do

    # Target should always be for this DN

    # users
    # Who has access permission? Specify if userdn or groupdn
    # ( userdn = "" or groupdn = "" ) and any other method
    # default to ldap:///anyone

    # rights
    # allow set list of items (all), (all,proxy), (read,compare,search,selfwrite,write,delete,add,proxy)
    # default to (all)

    # targets
    # Collect attribute list ino targetattr
    # if all, then targetattr = "*"
    # otherwise = "attr1 || attr2 || attr3"
    # also permit negative list
    # Accept optional ldap filter, set it as the value of 'targetfilter'
    # default to "*"

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
      attributes ({ aci: access_control_instruction }
    end
  end
end

action :unset do

  @current_resource = load_current_resource

  if @current_resource
    converge_by("Removing #{@current_resource[:dn]}") do
      dirsrv_entry @current_resource[:dn] do
        host   new_resource.host
        port   new_resource.port
        credentials new_resource.credentials
        databag_name new_resource.databag_name
        prune [ 'aci' ]
      end
    end
  end
end

def load_current_resource

  dirsrv = Chef::Dirsrv.new
  @connectinfo = load_connection_info
  @current_resource = dirsrv.get_entry( @connectinfo, @new_resource.dn )
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

