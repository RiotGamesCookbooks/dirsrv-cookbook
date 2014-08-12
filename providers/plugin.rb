#
# Cookbook Name:: dirsrv
# Provider:: plugin
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
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
