#
# Cookbook Name:: dirsrv
# Provider:: instance
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

action :create do

  tmpl = ::File.join new_resource.conf_dir, 'setup-' + new_resource.instance + '.inf'
  setup = new_resource.is_admin ? 'setup-ds-admin.pl' : 'setup-ds.pl'
  instdir = ::File.join new_resource.conf_dir, 'slapd-' + new_resource.instance
  config = Hash.new

  [
    'instance',
    'admin_domain',
    'admin_user',
    'admin_pass',
    'admin_port',
    'admin_bindaddr',
    'admin_host',
    'is_admin',
    'add_org_entries',
    'add_sample_entries',
    'preseed_ldif',
    'root_dn',
    'root_pass',
    'port',
    'suffix',
    'conf_dir',
    'base_dir'
  ].each do |attr|
    config[attr] = new_resource.send(attr)
  end

  if new_resource.admin_bindaddr and new_resource.is_admin
    config['admin_host'] = new_resource.admin_bindaddr
  end

  if ::Dir.exists?(instdir)
    Chef::Log.info("Create: Instance '#{new_resource.instance}' exists")
  else
    converge_by("Creating new instance #{new_resource.instance}") do
      template tmpl do
        source "setup.inf.erb"
        mode "0600"
        owner "root"
        group "root"
        cookbook "dirsrv"
        variables config 
        notifies :run, "execute[setup-#{new_resource.instance}]"
      end

      execute "setup-#{new_resource.instance}" do
        command "#{setup} --silent --file #{tmpl}"
        creates ::File.join instdir, 'dse.ldif'
        action :nothing
      end

      action_restart

    end
  end
end

action :start do

  converge_by("Starting #{new_resource.instance}") do
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
end

action :stop do

  converge_by("Starting #{new_resource.instance}") do
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
end

action :restart do

  converge_by("Starting #{new_resource.instance}") do
    service "dirsrv-#{new_resource.instance}" do
      service_name "dirsrv"
      supports :status => true, :restart => true
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
end

