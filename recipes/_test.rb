#
# Cookbook Name:: dirsrv
# Recipe:: _test
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

include_recipe "dirsrv"

dirsrv_instance node[:hostname] + '_388' do
  is_cfgdir     true
  has_cfgdir    true
  cfgdir_addr   node[:ipaddress]
  cfgdir_domain "testdomain"
  cfgdir_ldap_port 388
  host         node[:fqdn]
  port         388
  suffix       'o=testorg'
  action       [ :create, :start ]
end

dirsrv_user "Replication Manager" do
  port 388
  basedn 'cn=config'
  relativedn_attribute 'cn'
  is_posix false
end

dirsrv_instance node[:hostname] + '_389' do
  has_cfgdir    true
  cfgdir_addr   node[:ipaddress]
  cfgdir_domain "testdomain"
  cfgdir_ldap_port 388
  host         node[:fqdn]
  port         389
  suffix       'o=testorg'
  action       [ :create, :start ]
end

dirsrv_user "Replication Manager" do
  basedn 'cn=config'
  relativedn_attribute 'cn'
  is_posix false
end

dirsrv_entry 'ou=test,o=testorg' do
  port        389
  attributes  ({ objectClass: [ 'top', 'organizationalUnit' ], l: [ 'PA', 'CA' ], telephoneNumber: '215-310-5555' })
  prune      ([ :postalCode, :description ])
end

dirsrv_config "nsslapd-auditlog-logging-enabled" do
  value  'on'
end

dirsrv_config "nsslapd-auditlog" do
  value  '/var/log/dirsrv/slapd-test/audit'
end

dirsrv_plugin "MemberOf Plugin"

dirsrv_plugin "Posix Winsync API" do
  attributes ({ posixwinsynccreatememberoftask: 'true' })
end

dirsrv_plugin "referential integrity postoperation" do
  attributes ({ :'nsslapd-pluginEnabled' => 'on' })
  action     :modify
end

