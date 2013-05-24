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

  ldap = Dirsrv.new
  entry = ldap.get_entry(new_resource)

  unless entry
    converge_by("Adding new entry #{new_resource.dn}") do
      ldap.add_entry(new_resource)
    end
  else

    cur_attrs = entry.attribute_names.map{ |a| a.downcase }
    new_attrs = new_resource.attributes.keys.map{ |a| a.downcase }
    converge_keys = new_attrs - cur_attrs

    # Look for differences in the attribute values, case sensitive
    ( entry.attribute_names | new_resource.attributes.keys ).each do |attr|
      unless entry.respond_to?(attr) and new_resource.attributes[attr] == entry.send(attr)
        converge_keys.push(attr)
      end
    end

    # Ignore objectClass, DN, and the RDN. These should only be modified upon object creation
    rdn = new_resource.dn.split('=').first
    converge_keys.reject!{ |attr| attr =~ /(objectClass|DN)/i || attr == :"#{rdn}" }

    if converge_keys.size == 0
      Chef::Log.info("Entry #{new_resource.dn} exists, no update needed")
    else
      converge_by("Updating attributes for #{new_resource.dn}") do
        ldap.modify_entry(new_resource, converge_keys)
      end
    end
  end
end

action :delete do
end
