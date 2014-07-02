#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_replication
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

# Audit log
dirsrv_config "nsslapd-auditlog-logging-enabled" do
  credentials  node[:dirsrv][:credentials]
  value  'on'
end

dirsrv_config "nsslapd-auditlog-logrotationsync-enabled" do
  credentials  node[:dirsrv][:credentials]
  value  'on'
end

# Replication Debug
dirsrv_config "nsslapd-errorlog-level" do
  credentials  node[:dirsrv][:credentials]
  value  '8192'
end

# cn=Replication Manager,cn=config

dirsrv_user "Replication Manager" do
  credentials  node[:dirsrv][:credentials]
  basedn 'cn=config'
  relativedn_attribute 'cn'
  password 'CopyCat!'
  is_posix false
end

