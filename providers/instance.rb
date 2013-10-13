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
  setup = new_resource.is_cfgdir ? 'setup-ds-admin.pl' : 'setup-ds.pl'
  instdir = ::File.join new_resource.conf_dir, 'slapd-' + new_resource.instance
  mgrcreds = new_resource.credentials.kind_of?(Hash) ? new_resource.credentials.to_hash : new_resource.credentials.to_s
  admcreds = new_resource.cfgdir_credentials.kind_of?(Hash) ? new_resource.cfgdir_credentials.to_hash : new_resource.cfgdir_credentials.to_s

  config = {
    instance:    new_resource.instance,
    suffix:      new_resource.suffix,
    host:        new_resource.host,
    port:        new_resource.port,
    credentials:        mgrcreds,
    add_org_entries:    new_resource.add_org_entries,
    add_sample_entries: new_resource.add_sample_entries,
    preseed_ldif:       new_resource.preseed_ldif,
    conf_dir:           new_resource.conf_dir,
    base_dir:           new_resource.base_dir
  }

  if config[:credentials].kind_of?(String) and config[:credentials].length > 0

    # Pull named credentials from the dirsrv databag

    require 'chef/data_bag_item'
    require 'chef/encrypted_data_bag_item'

    secret = Chef::EncryptedDataBagItem.load_secret
    config[:credentials] = Chef::EncryptedDataBagItem.load( 'dirsrv', config[:credentials], secret ).to_hash
  end

  unless config[:credentials].kind_of?(Hash) and config[:credentials].key?('userdn') and config[:credentials].key?('password')
    raise "Invalid credentials: #{config[:credentials]}"
  end

  if new_resource.has_cfgdir or new_resource.is_cfgdir

    # Same as above, in case this is a configuration directory server, or is configured to use one

    config[:is_cfgdir] = new_resource.is_cfgdir
    config[:has_cfgdir] = new_resource.has_cfgdir
    config[:cfgdir_addr] = new_resource.cfgdir_addr
    config[:cfgdir_http_port] = new_resource.cfgdir_http_port
    config[:cfgdir_ldap_port] = new_resource.cfgdir_ldap_port
    config[:cfgdir_domain] = new_resource.cfgdir_domain
    config[:cfgdir_credentials] = admcreds

    if new_resource.cfgdir_credentials.kind_of?(String) and new_resource.cfgdir_credentials.length > 0

      require 'chef/data_bag_item'
      require 'chef/encrypted_data_bag_item'

      secret = Chef::EncryptedDataBagItem.load_secret
      config[:cfgdir_credentials] = Chef::EncryptedDataBagItem.load( 'dirsrv', config[:cfgdir_credentials], secret ).to_hash
    end

    unless config[:cfgdir_credentials].kind_of?(Hash) and config[:cfgdir_credentials].key?('username') and config[:cfgdir_credentials].key?('password')
      raise "Invalid credentials for config directory: #{new_resource.cfgdir_credentials}"
    end
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
      end

      execute "setup-#{new_resource.instance}" do
        command "#{setup} --silent --file #{tmpl}"
        creates ::File.join instdir, 'dse.ldif'
        action :nothing
        subscribes :run, "template[#{tmpl}]", :immediately
        notifies :restart, "service[dirsrv-#{new_resource.instance}]", :immediately
      end
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

    if new_resource.is_cfgdir
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

    if new_resource.is_cfgdir
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

    if new_resource.is_cfgdir
      service "dirsrv-admin" do
        action :restart
      end
    end
  end
end

