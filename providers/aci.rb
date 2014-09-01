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

  current_aci = @current_resource[new_resource.label.to_s]

  converge_by("Setting ACI '#{new_resource.label}' on #{new_resource.distinguished_name}") do

    pp current_aci.inspect

    # combine in this order:
    # ( targetattr )
    # ( target )
    # ( targetfilter )
    # ( version 3.0;
    #   acl <label>
    #   allow ( rights )
    #   ( users_OR_groups )
    #   and ( ip_OR_dns )
    #   and ( days )
    #   and ( hours );
    # )
    # (targetattr != "userPassword") 
    # (version 3.0;
    # acl "Enable anonymous access";
    # allow (read,compare,search)
    # (userdn = "ldap:///uid=awillis,ou=People,o=org" or 
    # groupdn = "ldap:///cn=HR Managers,ou=Groups,o=org") and 
    # (ip="10.0.0.1" or 
    # ip="10.0.0.2" or 
    # dns="einstein.local") and 
    # (dayofweek = "Mon,Tue,Wed,Thu") and 
    # (timeofday >= "100" and timeofday < "2000")
    # ;)
    #
    # (targetattr != "uid || sn || cn") 
    # (target = "ldap:///ou=People,o=org") 
    # (targetfilter = (ou=Product Development)) 
    # (version 3.0;
    # acl "Engineering Group Permissions";
    # allow (compare,write)
    # (groupdn = "ldap:///cn=PD Managers,ou=Groups,o=org" or 
    # userdn = "ldap:///uid=awillis,ou=People,o=org") and 
    # (dns=".vagrant" or 
    # ip="10.0.0.1") and 
    # (dayofweek = "Tue,Wed,Thu") and 
    # (timeofday >= "800" and timeofday < "1800")
    # ;)

#    ldap_entry dn do
#      host   new_resource.host
#      port   new_resource.port
#      credentials new_resource.credentials
#      databag_name new_resource.databag_name
#      attributes ({ aci: access_control_instruction })
#    end
  end
end

action :extend do
# add values
end

action :restrict do
# remove values
end

action :unset do

  @current_resource = load_current_resource

  if @current_resource
    converge_by("Removing #{new_resource.label} from #{new_resource.distinguished_name}") do

      access_control_instruction = @current_resource[new_resource.label.to_s]

      ldap_entry @current_resource[:dn] do
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

  ldap = Chef::Ldap.new
  @connectinfo = load_connection_info
  @current_resource = OrderedHash.new
  entry = ldap.get_entry( @connectinfo, @new_resource.distinguished_name )

  entry[:aci].each do |aci|
    label = aci.match(/acl \"(.*?)\";/).captures.first
    @current_resource[label] = { aci: aci }

    # Permission
    permission = aci.match(/(allow|deny)\s*\((.*?)\)/)
    ( permit, rights ) = permission.captures
    rights = rights.split(/\,\s*/)
    @current_resource[label][:permission] = { permit: permit, rights: rights }

    target_aci = permission.pre_match
    bind_rules = permission.post_match

    # Targets 

    # (targetattr != "uid || sn || cn") 
    targetattr = target_aci.match(/\(\s*targetattr\s*(\!?=)\s*\"(.*?)\"\)/)

    if targetattr
      ( equality, tgtattrs ) = targetattr.captures
      tgtattrs = tgtattrs.split(/\s*\|\|\s*/)
      @current_resource[label][:targetattr] = { equality: equality, attrs: tgtattrs }
    end

    # (target = "ldap:///ou=People,o=org") 
    target = target_aci.match(/\(\s*target\s*=\s*\"ldap:\/\/\/(.*?)\"\)/)

    if target
      @current_resource[label][:target] = target.captures.first
    end

    # (targetfilter = (ou=Product Development)) 
    targetfilter = target_aci.match(/\(\s*targetfilter\s*=\s*(.*?)\)/)

    if targetfilter
      @current_resource[label][:targetfilter] = targetfilter.captures.first
    end

    # Bind Rules

    bind_rules.scan(/(\w+)\s*(\!?>?=?<?)\s*\"(.*?)\"/) do |rule, equality, value|

      if rule.match(/^ip|dns|userdn|groupdn|dayofweek$/)
        if @current_resource[label][rule].nil?
          @current_resource[label][rule] = { equality => [ value ] }
        else
          @current_resource[label][rule][equality].push(value)
        end
      end

      if rule.match(/timeofday/)
        if @current_resource[label]['timeofday'].nil?
          @current_resource[label]['timeofday'] = OrderedHash.new
          @current_resource[label]['timeofday'][equality] = [ value ]
        else
          @current_resource[label][rule][equality].push(value)
        end
      end
    end
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
