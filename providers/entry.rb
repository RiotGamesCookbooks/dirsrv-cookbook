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
    modify_entry
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
    @new_resource.updated_by_last_action(true)
  else

    # Add keys that are missing
    add_keys = ( @new_resource.attributes.keys - @current_resource.attribute_names ).map{ |attr|
      [ :add, attr, @new_resource.attributes[attr].is_a?(String) ? [ @new_resource.attributes[attr] ] : @new_resource.attributes[attr] ]
    }

    # Update existing keys, do not remove existing values unless no_clobber is set
    update_keys = Array.new
    ( @new_resource.attributes.keys & @current_resource.attribute_names ).each do |attr|

      # Ignore objectClass, Distinguished Name (DN), and the Relative DN. 
      # These should only be modified upon entry creation to avoid schema violations
      rdn = @new_resource.dn.split('=').first
      next if attr =~ /(objectClass|DN)/i || attr <=> rdn 

      # Values supplied to new_resource may be a string or a list
      new_values = @new_resource.attributes[attr].is_a?(String) ? [ @new_resource.attributes[attr] ] : @new_resource.attributes[attr]
      cur_values = @current_resource.send(attr)
      noclobber_values = ( new_values - cur_values )

      if @new_resource.no_clobber and noclobber_values.size > 0
        update_keys.push([ :add, attr, noclobber_values ])
      elsif new_values.size > 0
        update_keys.push([ :replace, attr, new_values ])
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
      @new_resource.prune.each do |attr, value|
        next unless @current_resource.respond_to?(attr)
        prune_keys.push([ :delete, attr, [ value ]])
      end
    end

    # Modify entry 
    if ( add_keys | update_keys | prune_keys ).size > 0
      Chef::Log.info("Updating #{@new_resource.dn}")
      dirsrv.modify_entry(@new_resource, ( add_keys | update_keys | prune_keys ))
      @new_resource.updated_by_last_action(true)
    end
  end
end
