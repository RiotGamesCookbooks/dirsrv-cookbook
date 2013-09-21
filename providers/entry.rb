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

  converge_by("Entry #{@new_resource.dn}") do
    modify_entry
  end
end

action :delete do

  @current_resource = load_current_resource

  if @current_resource
    converge_by("Removing #{@current_resource.dn}") do
      dirsrv = Chef::Dirsrv.new
      dirsrv.delete_entry(@current_resource)
    end
  end
end

def load_current_resource

  dirsrv = Chef::Dirsrv.new
  @current_resource = dirsrv.get_entry(@new_resource)
  @current_resource.attribute_names.map!{ |k| k.downcase } if @current_resource
  @current_resource
end

def modify_entry

  dirsrv = Chef::Dirsrv.new

  if @current_resource.nil?
    Chef::Log.info("Adding #{@new_resource.dn}")
    dirsrv.add_entry(@new_resource)
    new_resource.updated_by_last_action(true)
  else

    all_attributes = @new_resource.attributes.merge(@new_resource.append_attributes)

    # Add keys that are missing
    add_keys = ( all_attributes.keys - @current_resource.attribute_names ).map{ |attr|
      [ :add, attr, all_attributes[attr].is_a?(String) ? [ all_attributes[attr] ] : all_attributes[attr] ]
    }

    # Update existing keys, append values if necessary
    update_keys = Array.new

    ( all_attributes.keys & @current_resource.attribute_names ).each do |attr|

      # Ignore Distinguished Name (DN) and the Relative DN. 
      # These should only be modified upon entry creation to avoid schema violations
      rdn = @new_resource.dn.split('=').first
      next if attr =~ /DN/i || attr <=> rdn 

      if @new_resource.append_attributes[attr]

        append_values = @new_resource.append_attributes[attr].is_a?(String) ? [ @new_resource.append_attributes[attr] ] : @new_resource.append_attributes[attr]
        append_values -= @current_resource.send(attr)

        if append_values.size > 0 
          update_keys.push([ :add, attr, append_values ])
        end
      end

      if @new_resource.attributes[attr]

        replace_values = @new_resource.attributes[attr].is_a?(String) ? [ @new_resource.attributes[attr] ] : @new_resource.attributes[attr]

        if ( replace_values.size > 0 ) and ( replace_values != @current_resource.send(attr) )
          update_keys.push([ :replace, attr, replace_values ])
        end
      end
    end

    # Prune unwanted attributes and/or values
    prune_keys = Array.new
    if @new_resource.prune.is_a?(Array)
      @new_resource.prune.each do |attr|
        next unless @current_resource.respond_to?(attr)
        prune_keys.push([ :delete, attr, nil ])
      end
    elsif @new_resource.prune.is_a?(Hash)
      @new_resource.prune.each do |attr, values|
        next unless @current_resource.respond_to?(attr)
        values = values.is_a?(String) ? [ values ] : values
        values = ( values & @current_resource.send(attr) )
        prune_keys.push([ :delete, attr, values ]) if values.size > 0
      end
    end

    # Modify entry if there are any changes to be made
    if ( add_keys | update_keys | prune_keys ).size > 0
      # Submit one set of operations at a time, easier to debug

      if add_keys.size > 0
        Chef::Log.info("Add #{@new_resource.dn} #{ add_keys }")
        dirsrv.modify_entry(@new_resource, add_keys)
      end

      if update_keys.size > 0
        Chef::Log.info("Update #{@new_resource.dn} #{update_keys}")
        dirsrv.modify_entry(@new_resource, update_keys)
      end

      if prune_keys.size > 0
        Chef::Log.info("Delete #{@new_resource.dn} #{prune_keys}")
        dirsrv.modify_entry(@new_resource, prune_keys)
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
