# Cookbook Name:: dirsrv
# Provider:: replica
#
# Copyright 2014, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

def whyrun_supported?
  true
end

action :create do

  logattrs = { 'objectClass' => [ 'top', 'extensibleObject' ],
               'cn' => 'changelog5',
               'nsslapd-changelogdir' => "#{new_resource.base_dir}/slapd-#{new_resource.instance}/changelogdb",
               'nsslapd-changelogmaxage' => '10d' }

  attrs = {
      objectClass: [ 'top', 'extensibleObject', 'nsDS5Replica' ],
      cn: 'replica',
      nsDS5ReplicaRoot: new_resource.suffix,
      nsDS5ReplicaPurgeDelay: new_resource.purge_delay.to_s,
      nsDS5ReplicaBindDN: 'cn=Replication Manager,cn=config'
  }

  # Generate a replica id by bit shifting the fourth octet rightward 8 bits, and adding the second octet
  second = node[:ipaddress].split('.').slice(1).to_i
  fourth = node[:ipaddress].split('.').slice(3).to_i
  replid = new_resource.id.nil? ? (( fourth << 8 ) + second ).to_s : new_resource.id.to_s

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

