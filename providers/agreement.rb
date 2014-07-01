# Cookbook Name:: dirsrv
# Provider:: agreement
#
# Copyright 2014, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

action :create do

  # if windows sync agreement
  # default
  # nsDS7NewWinUserSyncEnabled: on
  # nsDS7NewWinGroupSyncEnabled: on
  # object class: nsDSWindowsReplicationAgreement
  # nsds7WindowsReplicaSubtree: windows suffix to be synced ( required )
  # nsds7DirectoryReplicaSubtree: directory server suffix to be synced ( default to replicaroot + windows subtree )
  # nsds7WindowsDomain: windows domain, analogous to nsDS5ReplicaHost
  # nsDS5ReplicaPort
  # nsDS5ReplicaTransportInfo
  # nsDS5ReplicaBindDN
  # nsDS5ReplicaBindMethod
  # nsDS5ReplicaBindCredentials
  # nsDS5ReplicaRoot
  # description
  # nsDS5ReplicaUpdateSchedule
  # oneWaySync ( optional 'fromWindows' or 'toWindows' ) default to bidirectional
  # winSyncInterval: ( sync interval in seconds, default 300 )
  # winSyncMoveAction: 'none' default do nothing, 'delete' assume items were moved and remove from subtree, 'unsync' stop synchronizing the object entirely. Prefer none or delete, unsync sounds like it could cause issues across service restarts

  attrs = {
      objectClass: [ 'top', 'nsDS5ReplicationAgreement' ],
      cn: new_resource.label,
      nsDS5ReplicaHost: new_resource.replica_host,
      nsDS5ReplicaPort: new_resource.replica_port,
      nsDS5ReplicaBindDN: new_resource.replica_binddn,
      nsDS5ReplicaBindMethod: new_resource.replica_bind_method,
      nsDS5ReplicaTransportInfo: new_resource.replica_transport_info,
      nsDS5ReplicaUpdateSchedule: new_resource.replica_update_schedule,
      nsDS5ReplicaRoot: new_resource.suffix
  }

  # nsDS5ReplicaCredentials Only with SASL/DIGEST-MD5 and SIMPLE
  # SIMPLE requires the presence of nsDS5ReplicaCredentials, which is a password hash. Use same method from dirsrv_user ( salted sha )

  case new_resource.role
  when :single_master, :multi_master
    attrs[:nsDS5ReplicaId] = replid
    attrs[:nsDS5ReplicaType] = '3'
    attrs[:nsDS5Flags] = '1'
  when :hub
    attrs[:nsDS5ReplicaId] = replid
    attrs[:nsDS5ReplicaType] = '2'
    attrs[:nsDS5Flags] = '1'
  when :consumer
    attrs[:nsDS5ReplicaId] = '65535'
    attrs[:nsDS5ReplicaType] = '2'
    attrs[:nsDS5Flags] = '0'
  end

  unless new_resource.role == :single_master
    attrs[:nsDS5ReplicaBindDN] = 'cn=Replication Manager,cn=config'
  end

  converge_by("Registering as a #{new_resource.role} replica of #{new_resource.suffix}") do

    dirsrv_plugin "Legacy Replication Plugin" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      action :disable
    end

    netscaperoot = Regexp.new('o=NetscapeRoot$', Regexp::IGNORECASE)
    if netscaperoot.match(new_resource.suffix)
      dirsrv_plugin "Pass Through Authentication" do
        host   new_resource.host
        port   new_resource.port
        credentials new_resource.credentials
        action :disable
      end
    end

    unless new_resource.role == :consumer
      dirsrv_entry "cn=changelog5,cn=config" do
        host   new_resource.host
        port   new_resource.port
        credentials new_resource.credentials
        attributes logattrs
      end
    end

    dirsrv_entry "cn=replica,cn=\"#{new_resource.suffix}\",cn=mapping tree,cn=config" do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      attributes attrs
    end
  end
end

action :start do
  # Check status
  # Get current value of nsDS5ReplicaUpdateSchedule
  # Set nsDS5ReplicaUpdateSchedule to '0000 0001 0'
  # Check status
  # Set nsDS5ReplicaUpdateSchedule to old value
  # Check status
end

action :initialize do

  # Check status
  # Set nsDS5BeginReplicaRefresh: start
  # Check status
end
