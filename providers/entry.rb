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

  dirsrv = Dirsrv.new
  entry = dirsrv.get_entry(new_resource)

  # LDAP instances are not case sensitive
  new_resource.attributes.keys.each do |k|
    new_resource.attributes[k.downcase] = new_resource.attributes.delete(k)
  end

  unless entry
    converge_by("Adding new entry #{new_resource.dn}") do
      dirsrv.add_entry(new_resource)
    end
  else

  new_attrs = new_resource.attributes.keys
  cur_attrs = entry.attribute_names.map{ |a| a.downcase }
  converge_keys = new_attrs - cur_attrs

  # Look for differences in the attribute values
  new_attrs.each do |attr|

    # Permit either a string or a single valued list
    new_value = new_resource.attributes[attr].is_a?(String) ? [ new_resource.attributes[attr] ] : new_resource.attributes[attr]

    unless entry.respond_to?(attr) and new_value == entry.send(attr)
      converge_keys.push(attr)
    end
  end

    # Ignore objectClass, DN, and the RDN. These should only be modified upon object creation
    rdn = new_resource.dn.split('=').first
    converge_keys.reject!{ |attr| attr =~ /(objectClass|DN)/i || attr == :"#{rdn}" }

    # Prune attributes

    if new_resource.prune_attributes.size > 0
      converge_by("Removing attributes from #{new_resource.dn}: #{new_resource.prune_attributes}") do
        dirsrv.modify_entry(new_resource, new_resource.prune_attributes, :delete)
      end
    end

    # Add/modify attributes

    if converge_keys.size == 0
      Chef::Log.info("Entry #{new_resource.dn} exists, no update needed")
    else
      converge_by("Updating attributes for #{new_resource.dn}") do
        dirsrv.modify_entry(new_resource, converge_keys)
      end
    end
  end
end

action :delete do

  dirsrv = Dirsrv.new
  entry = dirsrv.get_entry(new_resource)

  if entry
    converge_by("Removing #{new_resource.dn}") do
      dirsrv.delete_entry(new_resource)
    end
  end
end
