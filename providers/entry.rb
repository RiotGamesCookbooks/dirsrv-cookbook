#
# Cookbook Name:: dirsrv
# Provider:: entry
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

action :create do
  current_attrs = get_current_attrs

  converge_keys = new_resource.attributes.keys - current_attrs

  if ( converge_keys.size > 0 )
    puts "Converge keys!"
    # Take all of the converge keys and converge by replacing all of their values
  end

end

action :modify do
end

action :delete do
end

def get_current_attrs
  ldap = Dirsrv.new
  ldap.get_entry_attrs(new_resource)
end
