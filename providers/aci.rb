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

     permit = new_resource.permit? 'allow' : 'deny'
     new_aci = { permit: permit, rights: new_resource.rights }

     new_aci = compose_aci( new_resource.label, new_aci )

    # ldap_entry doesn't have a specific parameter that allows 
    # us to control just one value of a multi-valued attribute, 
    # so we need to check whether or not we should update

    if current_aci.nil? or current_aci[:aci] != new_aci
      ldap_entry new_resource.distinguished_name do
        host   new_resource.host
        port   new_resource.port
        credentials new_resource.credentials
        databag_name new_resource.databag_name
        unless current_aci.nil?
          prune ({ aci: current_aci[:aci] })
        end
        append_attributes({ aci: new_aci })
      end
    end
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

def compose_aci( label, rules )

  pp rules.inspect

  aci = Array.new

  if rules.key?(:targetattr)
    rules['targetattr'].each do |equality, attributes|
      attributes = attributes.join(' || ')
      aci.push("(targetattr#{equality}\"#{attributes}\")")
    end
  end

  if rules.key?(:target)
    rules['target'].each do |equality, dn|
      unless dn.match(/^ldap:\/\/\//)
        dn = "ldap:///" + dn
      end
      aci.push("(target#{equality}\"#{dn}\")")
    end
  end

  if rules.key?(:targetfilter)
    rules['targetfilter'].each do |equality, filter|
      aci.push("(targetattr#{equality}\"#{filter}\")")
    end
  end

  aci.push("(version 3.0; acl #{label};")
  aci.push("#{rules[:permission][:permit]} (#{rules[:permission][:rights].join(',')})" )

  # users, groups and roles
  userspec = Array.new

  [ :userdn, :userdnattr, :groupdn, :groupdnattr, :roledn ].each do |rule|
    if rules.key?(rule)
      rules[rule].each do |equality, dn|
        userspec.push("#{rule}#{equality}\"#{dn}\"")
      end
    end
  end

  unless userspec.size > 0
    userspec.push("userdn=\"ldap:///all\"")
  end

  userspec = userspec.join(' or ')
  aci.push("(#{userspec})")

  # IPs and DNS names
  hostspec = Array.new

  [ :ip, :dns ].each do |rule|
    if rules.key?(rule)
      rules[rule].each do |equality, host|
        hostspec.push("#{rule}#{equality}\"#{host}\"")
      end
    end
  end

  hostspec = hostspec.join(' or ')
  aci.push("and (#{hostspec})") unless hostspec.empty?

  # Days of the week
  if rules.key?(:dayofweek)
    rules[:dayofweek].each do |equality, days|
      aci.push("and (dayofweek#{equality}\"#{days.join(',')}\"")
    end
  end

  # Time of day
  timespec = Array.new

  if rules.key?(:timeofday)
    rules[:timeofday].each do |equality, time|
      timespec.push("timeofday#{equality}\"#{time}\"")
    end
  end

  timespec = timespec.join(' and ')
  aci.push("and (#{timespec})") unless timespec.empty?

  aci.push(';)')
  aci = aci.join(' ')
  aci
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

    # permission
    permission = aci.match(/(allow|deny)\s*\((.*?)\)/)
    ( permit, rights ) = permission.captures
    rights = rights.split(/\,\s*/)
    @current_resource[label][:permission] = { permit: permit, rights: rights }

    # everything else

    aci.scan(/(\w+)\s*(\!?>?=?<?)\s*["(](.*?)[")]/) do |rule, equality, value|

      if rule.match(/target|ip|dns|userdn|groupdn|roledn|dayofweek|timeofday|authmethod/)

        case rule
        when 'targetattr'
          value = value.split(/\s*||\s*/)
        when 'dayofweek'
          value = value.split(/\,/)
        end

        if @current_resource[label][rule].nil?
          @current_resource[label][rule] = OrderedHash.new
          @current_resource[label][rule][equality] = [ value ]
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
