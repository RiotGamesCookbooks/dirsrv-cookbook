define :directory_instance,
  {
    :is_admin => nil,
    :admin_domain => nil,
    :admin_user => nil,
    :admin_pass => nil,
    :admin_port => 9830,
    :rootdn => nil,
    :rootdn_pass => nil,
    :instance => nil,
    :port => 389,
    :ssl_port => 636,
    :bind_address => nil,
    :org_entries => false,
    :sample_entries => false,
  } do

  instance = params[:instance] ? params[:instance] : params[:name]
  tmpl = File.join node['389ds']['conf_dir'], instance + '.inf'
  setup = params[:is_admin] ? 'setup-ds-admin.pl' : 'setup-ds.pl'

  template tmpl do
    source "setup.inf.erb"
    mode "0600"
    owner "root"
    group "root"
    variables({ 
      :general => params,
      :admin   => params,
      :slapd   => params,
      :conf_dir => node['389ds']['conf_dir'],
      :base_dir => node['389ds']['base_dir']
    })
  end

  instdir = File.join node['389ds']['conf_dir'], "slapd-#{instance}"

  execute setup do
    command "#{setup} --file #{tmpl}"
    creates File.join instdir, 'dse.ldif'
  end
end
