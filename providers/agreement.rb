# Cookbook Name:: dirsrv
# Provider:: agreement
#
# Copyright 2014, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

def whyrun_supported?
  true
end

action :create do

  # Start with attributes that are common to both Active Directory and Directory Server
  attrs = {
      cn: new_resource.label,
      description: new_resource.description,
      nsDS5ReplicaPort: new_resource.replica_port,
      nsDS5ReplicaBindDN: new_resource.replica_bind_dn,
      nsDS5ReplicaBindMethod: new_resource.replica_bind_method,
      nsDS5ReplicaTransportInfo: new_resource.replica_transport,
      nsDS5ReplicaUpdateSchedule: new_resource.replica_update_schedule,
      nsDS5ReplicaRoot: new_resource.suffix
  }

  # Ensure that bind method requirements are satisfied 
  case new_resource.replica_bind_method
  when 'SIMPLE', 'SASL/DIGEST-MD5'
    if new_resource.replica_bind_dn.nil? or new_resource.replica_credentials.nil?
      Chef::Application.fatal!("The SIMPLE and SASL/DIGEST-MD5 bind methods require both replica_bind_dn and replica_credentials")
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
    attrs[:winSyncInterval] = new_resource.ad_sync_interval if new_resource.ad_sync_interval
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
        action :enable
      end
    end

    dirsrv_entry "cn=#{new_resource.label},cn=\"#{new_resource.suffix}\",cn=mapping tree,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      attributes attrs
      if new_resource.replica_credentials and new_resource.directory_type == :AD
        seed_attributes ({ 'nsDS5ReplicaBindCredentials' => new_resource.replica_credentials })
      elsif new_resource.replica_credentials
        seed_attributes ({ 'nsDS5ReplicaCredentials' => new_resource.replica_credentials })
      end
    end
  end
end

action :start do

  dirsrv = Chef::Dirsrv.new
  @current_status = get_replication_status()
  original_update_schedule = @agreement[:update_schedule]

  converge_by("Syncing #{new_resource.label} agreement on replica #{new_resource.suffix}") do
    if @current_status[:update_in_progress] == 'FALSE'
      dirsrv.modify_entry(@agreement, 'nsDS5ReplicaUpdateSchedule', '0000 0001 0')
      @current_status = get_replication_status()
    else
      Chef::Log.info("Update in progress, skipping start action")
    end
  # Get current value of nsDS5ReplicaUpdateSchedule
  # Set nsDS5ReplicaUpdateSchedule to '0000 0001 0'
  # Check status
  # Set nsDS5ReplicaUpdateSchedule to old value
  # Check status
  end
end

action :initialize do

  # Check status
  # If update_in_progress, do not initialize
  # If init_start and init_end have valid values, do not initialize
  # To initialize set nsDS5BeginReplicaRefresh: start
  # Wait 3 seconds, and check status, Chef::Log init_status
end

def get_replication_status

  dirsrv = Chef::Dirsrv.new
  @resource = Hash.new
  @resource.class.module_eval { attr_accessor :dn, :host, :port, :credentials, :entry }
  @resource.dn = "cn=#{new_resource.label},cn=#{new_resource.suffix},cn=mapping tree,cn=config"
  @resource.host = new_resource.host
  @resource.port = new_resource.port
  @resource.credentials = new_resource.credentials

  entry = dirsrv.get_entry( @resource )

#  { 
#    init_start:         @agreement.entry[:nsDS5ReplicaLastInitStart],
#    init_end:           @agreement.entry[:nsDS5ReplicaLastInitEnd],
#    init_status:        @agreement.entry[:nsDS5ReplicaLastInitStatus],
#    update_start:       @agreement.entry[:nsDS5ReplicaLastUpdateStart],
#    update_end:         @agreement.entry[:nsDS5ReplicaLastUpdateEnd],
#    update_status:      @agreement.entry[:nsDS5ReplicaLastUpdateStatus],
#    update_in_progress: @agreement.entry[:nsDS5ReplicaUpdateInProgress],
#    update_schedule:    @agreement.entry[:nsDS5ReplicaUpdateSchedule]
#  }
end

