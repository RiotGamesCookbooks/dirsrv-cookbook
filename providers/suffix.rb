#
# Cookbook Name:: dirsrv
# Provider:: suffix
#
# Copyright 2015 Riot Games, Inc.
# Author:: Alan Willis <alwillis@riotgames.com>
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use_inline_resources

def whyrun_supported?
  true
end

action :create do

  converge_by("Creating new suffix #{new_resource.suffix}") do

    # ldbm database

    backend_name = new_resource.nsslapd_backend.nil? ? new_resource.suffix.gsub(/(,|=)/, '_') : new_resource.nsslapd_backend

    backend_attrs = { 'nsslapd-suffix' => new_resource.suffix.to_s }

    if new_resource.nsslapd_cachememsize
        backend_attrs['nsslapd-cachememsize'] = new_resource.nsslapd_cachememsize.to_s
    end

    if new_resource.nsslapd_dncachememsize
        backend_attrs['nsslapd-dncachememsize'] = new_resource.nsslapd_cachememsize.to_s
    end

    ldap_entry "cn=#{backend_name},cn=ldbm database,cn=plugins,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes({ 'objectClass' => [ 'top', 'extensibleObject', 'nsBackendInstance' ] })
      seed_attributes backend_attrs
    end

    # mapping tree

    maptree_attrs = { 'nsslapd-state' => 'backend', 'nsslapd-backend' => backend_name }

    if new_resource.parent
      maptree_attrs.merge!({ "nsslapd-parent-suffix" => new_resource.parent.to_s })
    end

    ldap_entry "cn=\"#{new_resource.suffix}\",cn=mapping tree,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes({ 'objectClass' => [ 'top', 'extensibleObject', 'nsMappingTree' ], 
                   'cn' => new_resource.suffix })
      seed_attributes maptree_attrs
    end

    # suffix entry

    ldap_entry new_resource.suffix do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes({ 'objectClass' => new_resource.entry_object_class_list })
    end
  end
end
