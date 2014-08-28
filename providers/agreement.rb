# Cookbook Name:: dirsrv
# Provider:: agreement
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

action :create do

  # Start with attributes that are common to both Active Directory and Directory Server

  description = { sync_from: new_resource.host, sync_to: new_resource.replica_host, initialized: false }

  attrs = {
      cn: new_resource.label,
      description: JSON.generate(description),
      nsDS5ReplicaPort: new_resource.replica_port.to_s,
      nsDS5ReplicaBindDN: new_resource.replica_bind_dn,
      nsDS5ReplicaBindMethod: new_resource.replica_bind_method,
      nsDS5ReplicaTransportInfo: new_resource.replica_transport,
      nsDS5ReplicaUpdateSchedule: new_resource.replica_update_schedule,
      nsDS5ReplicaRoot: new_resource.suffix
  }

  # Ensure that bind method requirements are satisfied 
  case new_resource.replica_bind_method
  when 'SIMPLE', 'SASL/DIGEST-MD5'
    if new_resource.replica_bind_dn.nil?
      Chef::Application.fatal!("The SIMPLE and SASL/DIGEST-MD5 bind methods require replica_bind_dn")
    end
  when 'SSLCLIENTAUTH'
    if new_resource.replica_transport == 'LDAP'
      Chef::Application.fatal!("The SSLCLIENTAUTH bind method requires replica_transport to be either SSL or TLS")
    end
  when 'SASL/GSSAPI'
    unless new_resource.replica_transport == 'LDAP'
      Chef::Application.fatal!("The SASL/GSSAPI bind method requires replica_transport to be set to LDAP")
    end
  end

  # Setup remote directory type stuff

  if new_resource.directory_type == :AD
    attrs[:objectClass] = [ 'top', 'nsDSWindowsReplicationAgreement' ]
    attrs[:nsDS7NewWinUserSyncEnabled] = new_resource.ad_new_user_sync if new_resource.ad_new_user_sync
    attrs[:nsDS7NewWinGroupSyncEnabled] = new_resource.ad_new_group_sync if new_resource.ad_new_group_sync
    attrs[:oneWaySync] = new_resource.ad_one_way_sync if new_resource.ad_one_way_sync
    attrs[:winSyncInterval] = new_resource.ad_sync_interval.to_s if new_resource.ad_sync_interval
    attrs[:winSyncMoveAction] = new_resource.ad_sync_move_action if new_resource.ad_sync_move_action

    if new_resource.ad_domain.nil?
      Chef::Application.fatal!("Must specify ad_domain to synchronize with Active Directory") 
    else
      attrs[:nsDS7WindowsDomain] = new_resource.ad_domain
    end

    if new_resource.ad_replica_subtree.nil?
      Chef::Application.fatal!("Must specify ad_replica_subtree to synchronize with Active Directory")
    else
      attrs[:nsDS7WindowsReplicaSubtree] = new_resource.ad_replica_subtree
      attrs[:nsDS7DirectoryReplicaSubtree] = "#{new_resource.ad_replica_subtree},#{new_resource.suffix}"
    end
  else
    attrs[:objectClass] = [ 'top', 'nsDS5ReplicationAgreement' ]
    attrs[:nsDS5ReplicaHost] =  new_resource.replica_host
    attrs[:nsDS5ReplicatedAttributeList] = new_resource.ds_replicated_attribute_list
    attrs[:nsDS5ReplicatedAttributeListTotal] = new_resource.ds_replicated_attribute_list_total
  end

  converge_by("Replication agreement #{new_resource.label} for #{new_resource.suffix}") do

    if new_resource.directory_type == :AD
      dirsrv_plugin "Posix Winsync API" do
        host   new_resource.host
        port   new_resource.port
        credentials new_resource.credentials
        databag_name new_resource.databag_name
        action :enable
      end
    end

    ldap_entry "cn=#{new_resource.label},cn=replica,cn=\"#{new_resource.suffix}\",cn=mapping tree,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes attrs
      if new_resource.replica_credentials and new_resource.directory_type == :AD
        seed_attributes ({ 'nsDS5ReplicaBindCredentials' => new_resource.replica_credentials })
      elsif new_resource.replica_credentials
        seed_attributes ({ 'nsDS5ReplicaCredentials' => new_resource.replica_credentials })
      end
    end
  end
end

action :create_and_initialize do

  action_create

  converge_by("Conditional initialization of #{new_resource.label} agreement for #{new_resource.suffix} database on #{new_resource.replica_host}") do

    ruby_block "initialize-#{new_resource.label}-#{new_resource.replica_host}" do
      block do

        # Setup connection info
        ldap = Chef::Ldap.new
        connectinfo = Hash.new
        connectinfo.class.module_eval { attr_accessor :dn, :host, :port, :credentials, :databag_name }
        connectinfo.host = new_resource.host
        connectinfo.port = new_resource.port
        connectinfo.credentials = new_resource.credentials
        # default to cookbook_name
        databag_name = new_resource.databag_name.nil? ? new_resource.cookbook_name : new_resource.databag_name
        connectinfo.databag_name = databag_name

        dn = "cn=#{new_resource.label},cn=replica,cn=\"#{new_resource.suffix}\",cn=mapping tree,cn=config"

        # why run check
        entry = ldap.get_entry( connectinfo, dn )
        description = JSON.parse(entry[:description].first, { symbolize_names: true })

        if entry[:nsDS5ReplicaUpdateInProgress].first != 'FALSE'
          Chef::Log.info("Skipping initialization of #{new_resource.label} for replica #{new_resource.suffix}: update in progress")
        elsif ( entry[:nsDS5ReplicaLastInitStart].first != '0' and entry[:nsDS5ReplicaLastInitEnd].first != '0' or description[:initialized] )
          Chef::Log.info("Skipping initialization of #{new_resource.label} for replica #{new_resource.suffix}: already initialized")
        else

          # Initialize and verify
          ldap.modify_entry( connectinfo, dn, [ [ :add, :nsDS5BeginReplicaRefresh, 'start' ] ] )

          for count in 1 .. 5

            sleep 1
            entry = ldap.get_entry( connectinfo, dn )
            init_status = entry[:nsDS5ReplicaLastInitStatus].first

            if /^0/.match( init_status )
              description[:initialized] = true
              ldap.modify_entry( connectinfo, dn, [ [ :replace, :description, JSON.generate(description) ] ] )
              break
            end

            if count == 5
              Chef::Log.error("Error during initialization: #{init_status}")
            end
          end
        end
      end
    end
  end
end
