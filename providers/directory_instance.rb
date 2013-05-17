#
# Cookbook Name:: dirsrv
# Provider:: directory_instance
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

action :create do

  tmpl = File.join new_resource.conf_dir, 'setup-' + new_resource.instance + '.inf'
  setup = new_resource.is_admin ? 'setup-ds-admin.pl' : 'setup-ds.pl'
  instdir = File.join new_resource.conf_dir, 'slapd-' + new_resource.instance
  config = new_resource

  if config.admin_bindaddr and not config.admin_host
    config.admin_host = config.admin_bindaddr
  end

  if Dir.exists(instdir)
    Chef::Log.info("Create: Instance '#{config.instance}' already exists!")
  else
    converge_by("Creating new instance #{config.instance}") do
      template tmpl do
        source "setup.inf.erb"
        mode "0600"
        owner "root"
        group "root"
        cookbook "dirsrv"
        variables config
      end

      execute setup do
        command "#{setup} --silent --file #{tmpl}"
        creates File.join instdir, 'dse.ldif'
      end

      service "dirsrv" do
        supports :status => true, :restart => true
        action :enable
        notifies :restart, "service[dirsrv-#{config.instance}]"
      end
    end
  end
end

action :start do

  service "dirsrv-#{new_resource.instance}" do
    service_name "dirsrv"
    supports :status => true
    start_command "/sbin/service dirsrv start #{new_resource.instance}"
    status_command "/sbin/service dirsrv status #{new_resource.instance}"
    action :start
  end

  if new_resource.is_admin
    service "dirsrv-admin" do
      action [ :enable, :start ]
    end
  end
end

action :stop do

  service "dirsrv-#{new_resource.instance}" do
    service_name "dirsrv"
    supports :status => true
    stop_command "/sbin/service dirsrv stop #{new_resource.instance}"
    status_command "/sbin/service dirsrv status #{new_resource.instance}"
    action :stop
  end

  if new_resource.is_admin
    service "dirsrv-admin" do
      action :stop
    end
  end
end

action :restart do

  service "dirsrv-#{new_resource.instance}" do
    service_name "dirsrv"
    supports :status => true
    restart_command "/sbin/service dirsrv restart #{new_resource.instance}"
    status_command "/sbin/service dirsrv status #{new_resource.instance}"
    action :restart
  end

  if new_resource.is_admin
    service "dirsrv-admin" do
      action :restart
    end
  end
end

