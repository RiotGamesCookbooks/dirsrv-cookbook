define :directory_instance,
  {
    :admin_domain         => nil,
    :admin_id             => nil,
    :admin_pass           => nil,
    :admin_port           => nil,
    :admin_local_bindaddr => nil,
    :admin_remote_host    => nil,
    :add_org_entries      => 'no',
    :add_sample_entries   => 'no',
    :preseed_ldif         => nil,
    :root_dn              => 'cn=Directory Manager',
    :root_pass            => nil,
    :port                 => 389,
    :suffix               => nil,
    :instance             => nil
  } do

  params[:instance] = params[:instance] ? params[:instance] : params[:name]
  tmpl = File.join node['389ds']['conf_dir'], 'setup-' + params[:instance] + '.inf'
  setup = params[:is_admin] ? 'setup-ds-admin.pl' : 'setup-ds.pl'

  [ 
    'root_dn',
    'root_pass',
    'suffix'
  ].each do |p|
    unless params[:p]
      #Chef::Application.fatal! "You must specify the #{p}!"
    end
  end

  if params[:admin_local_bindaddr]
    params[:admin_remote_host] = node[:ipaddress]
  end

  template tmpl do
    source "setup.inf.erb"
    mode "0600"
    owner "root"
    group "root"
    cookbook "389ds"
    variables({ 
      :params   => params,
      :conf_dir => node['389ds']['conf_dir'],
      :base_dir => node['389ds']['base_dir']
    })
  end

  instdir = File.join node['389ds']['conf_dir'], "slapd-#{params[:instance]}"

  execute setup do
    command "#{setup} --silent --file #{tmpl}"
    creates File.join instdir, 'dse.ldif'
    notifies :restart, "service[dirsrv-#{params[:instance]}]"
  end

  service "dirsrv-#{params[:instance]}" do
    service_name "dirsrv"
    supports :status => true, :restart => true
    start_command "/sbin/service dirsrv start #{params[:instance]}"
    restart_command "/sbin/service dirsrv restart #{params[:instance]}"
    action [ :enable, :start ]
  end

  if params[:is_admin]
    service "dirsrv-admin" do
      action [ :enable, :start ]
    end
  end
end
