#
# Cookbook Name:: dirsrv
# Provider:: plugin
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

action :enable do

  converge_by("Enabling plugin: #{@new_resource.common_name}") do

    ldap_entry "cn=#{new_resource.common_name},cn=plugins,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes new_resource.attributes.merge({ :'nsslapd-pluginEnabled' => 'on' })
      append_attributes new_resource.append_attributes
    end
  end
end

action :modify do

  converge_by("Updating plugin: #{@new_resource.common_name}") do
    ldap_entry "cn=#{new_resource.common_name},cn=plugins,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes new_resource.attributes
      append_attributes new_resource.append_attributes
    end
  end
end

action :disable do

  converge_by("Disabling plugin: #{@new_resource.common_name}") do
    ldap_entry "cn=#{new_resource.common_name},cn=plugins,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      attributes ({ :'nsslapd-pluginEnabled' => 'off' })
    end
  end
end
