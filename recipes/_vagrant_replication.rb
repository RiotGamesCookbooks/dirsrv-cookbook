#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_replication
#
# Copyright 2014, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

# Audit log
dirsrv_config "nsslapd-auditlog-logging-enabled" do
  value  'on'
end

dirsrv_config "nsslapd-auditlog-logrotationsync-enabled" do
  value  'on'
end

# Replication Debug
dirsrv_config "nsslapd-errorlog-level" do
  value  '8192'
end

# cn=Replication Manager,cn=config

dirsrv_user "Replication Manager" do
  basedn 'cn=config'
  relativedn_attribute 'cn'
  password 'CopyCat!'
  is_posix false
end
