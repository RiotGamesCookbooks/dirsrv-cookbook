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

  @current_resource = load_current_resource

  # LDAP instances are not case sensitive
  @new_resource.attributes.keys.each do |k|
    @new_resource.attributes[k.downcase] = @new_resource.attributes.delete(k)
  end

  converge_by("Updating entry #{@new_resource.dn}") do
    create_update_entry
  end
end

action :delete do

  @current_resource = load_current_resource

  if @current_resource
    converge_by("Removing #{@new_resource.dn}") do
      dirsrv.delete_entry(@new_resource)
    end
  end
end

def load_current_resource

  dirsrv = Dirsrv.new
  @current_resource = dirsrv.get_entry(@new_resource)
  @current_resource.attribute_names.map!{ |k| k.downcase }
  @current_resource
end

def create_update_entry

  dirsrv = Dirsrv.new

  if @current_resource.nil?
    Chef::Log.info("Adding #{@new_resource.dn}")
    dirsrv.add_entry(@new_resource)
    @new_resource.updated_by_last_action(true)
  else

    # Add keys that are missing to the update list
    update_keys = @new_resource.attributes.keys - @current_resource.attribute_names

    # Look for differences in the attribute values for common keys
    ( @new_resource.attributes.keys & @current_resource.attribute_names ).each do |attr|

      # Permit either a string or a single valued list
      values = @new_resource.attributes[attr].is_a?(String) ? [ @new_resource.attributes[attr] ] : @new_resource.attributes[attr]

      unless values == @current_resource.send(attr)
        update_keys.push(attr)
      end
    end

    # Ignore objectClass, Distinguished Name (DN), and the Relative DN. 
    # These should only be modified upon entry creation to avoid schema violations
    rdn = @new_resource.dn.split('=').first
    update_keys.reject!{ |attr| attr =~ /(objectClass|DN)/i || attr <=> rdn }

    # Don't attempt to remove nonexistent attributes
    @new_resource.prune_attributes.select!{ |attr| @current_resource.respond_to?(attr) }

    # Prune 
    if @new_resource.prune_attributes.size > 0
      Chef::Log.info("Removing #{@new_resource.prune_attributes} from #{@new_resource.dn}")
      dirsrv.modify_entry(@new_resource, @new_resource.prune_attributes, :delete)
      @new_resource.updated_by_last_action(true) 
    end

    # Update 
    if update_keys.size > 0
      Chef::Log.info("Updating #{update_keys} on #{@new_resource.dn}")
      dirsrv.modify_entry(@new_resource, update_keys)
      @new_resource.updated_by_last_action(true)
    end
  end
end
