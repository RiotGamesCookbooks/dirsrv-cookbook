#
# Cookbook Name:: dirsrv
# Recipe:: _test
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

include_recipe "dirsrv"

dirsrv_instance 'admin' do
  is_admin     true
  admin_domain "testdomain"
  admin_user   "admin"
  admin_pass   "password"
  admin_port   9830
  port         388
  suffix       'o=testorg'
  action       [ :create, :start ]
end

dirsrv_instance 'test' do
  admin_user   "admin"
  admin_pass   "password"
  admin_port   9830
  admin_host   node[:ipaddress]
  port         389
  suffix       'o=testorg'
  action       [ :create, :start ]
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

dirsrv_plugin "Posix Winsync API"
  attributes ({ posixwinsynccreatememberoftask: 'true' })
end

dirsrv_plugin "referential integrity postoperation" do
  attributes ({ :'nsslapd-pluginEnabled' => 'on' })
  action     :modify
end
