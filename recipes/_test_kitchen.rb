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

dirsrv_entry "ou=test,o=kitchen" do
  attributes ({ objectClass: [ 'organizationalUnit', 'top' ], ou: 'test' })
end

dirsrv_config "nsslapd-auditlog-logging-enabled" do
  value  'on'
end

dirsrv_plugin "MemberOf Plugin"

dirsrv_index "uid" do
  equality true
  presence true
  substring true
end

dirsrv_user "awillis" do
  basedn "ou=test,o=kitchen"
  surname 'Willis'
  home "/home/alan"
  shell "/bin/bash"
  is_extensible true
  password "Super Cool Passwords Are Super Cool!!!!!"
end
