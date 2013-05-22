#
# Cookbook Name:: dirsrv
# Recipe:: test_instance
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
    root_dn      'cn=Directory Manager'
    root_pass    "password"
    port         388
    suffix       'o=testorg'
    action       [ :create, :start ]
end

dirsrv_instance 'test' do
    admin_user   "admin"
    admin_pass   "password"
    admin_port   9830
    admin_host   node[:ipaddress]
    root_dn      'cn=Directory Manager'
    root_pass    "password"
    port         389
    suffix       'o=testorg'
    action       [ :create, :start ]
end

dirsrv_entry 'entryname'
