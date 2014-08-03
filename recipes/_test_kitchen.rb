#
# Cookbook Name:: dirsrv
# Recipe:: _test_kitchen
#
# Copyright 2014, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

# Test non-replication related LWRPs

include_recipe "dirsrv"

dirsrv_instance node[:hostname] + '_389' do
  is_cfgdir     true
  has_cfgdir    true
  cfgdir_addr   node[:ipaddress]
  cfgdir_domain 'kitchen'
  cfgdir_ldap_port 389
  host         node[:fqdn]
  suffix       'o=kitchen'
  action       [ :create, :start ]
end

# For each resource: remove, create, remove, create
# Exercises the code in creation and removal before and after its initial existence

## Entry

dirsrv_entry "ou=test,o=kitchen" do
  attributes ({ objectClass: [ 'organizationalUnit', 'top' ], ou: 'test' })
  action :delete
end

dirsrv_entry "ou=test,o=kitchen"

dirsrv_entry "ou=test,o=kitchen" do
  action :delete
end

dirsrv_entry "ou=test,o=kitchen"

## Config

dirsrv_config "nsslapd-auditlog-logging-enabled" do
  value  'on'
  action :disable
end

dirsrv_config "nsslapd-auditlog-logging-enabled"

dirsrv_config "nsslapd-auditlog-logging-enabled" do
  action :disable
end

dirsrv_config "nsslapd-auditlog-logging-enabled"

## Plugin

dirsrv_plugin "MemberOf Plugin" do
  action :disable
end

dirsrv_plugin "MemberOf Plugin"

dirsrv_plugin "MemberOf Plugin" do
  action :disable
end

dirsrv_plugin "MemberOf Plugin"

## Index
# No disable
dirsrv_index "uid" do
  equality true
  presence true
  substring true
end

## User

dirsrv_user "awillis" do
  basedn "o=kitchen"
  surname 'Willis'
  home "/home/alan"
  shell "/bin/bash"
  is_extensible true
  password "Super Cool Passwords Are Super Cool!!!!!"
  action :delete
end

dirsrv_user "awillis"

dirsrv_user "awillis" do
  action :delete
end

dirsrv_user "awillis"
