#
# Cookbook Name:: 389ds
# Recipe:: test_instance
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

include_recipe "389ds"

directory_instance 'test' do
    is_admin             true
    admin_domain         "testdomain"
    admin_id             "admin"
    admin_pass           "password"
    admin_port           9830
    admin_local_bindaddr "0.0.0.0"
    root_dn              'cn=Directory Manager'
    root_pass            "password"
    port                 389
    suffix               'o=testorg'
end
