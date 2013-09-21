#
# Cookbook Name:: dirsrv
# Provider:: user
#
# Copyright 2013, Alan Willis <alan@amekoshi.com>
#
# All rights reserved - Do Not Redistribute


def whyrun_supported?
  true
end

action :create do

  @current_resource = load_current_resource

  converge_by("Creating #{new_resource.common_name}") do

    dn = "#{new_resource.relativedn_attribute}=#{new_resource.common_name},#{new_resource.basedn}"

    objclass = [ 'top', 'account' ]
    attrs = { uid: new_resource.common_name }
    attrs[new_resource.relativedn_attribute.to_sym] = new_resource.common_name

    objclass.push( 'extensibleObject' ) if new_resource.is_extensible

    if new_resource.is_person
      objclass.push( 'person', 'organizationalPerson', 'inetOrgPerson' )
      attrs[:cn] = new_resource.common_name
      attrs[:sn] = new_resource.surname ? new_resource.surname : new_resource.common_name
    end

    if new_resource.is_person and new_resource.password
      require 'digest'
      require 'base64'
      salt = ( rand * 10 ** 5 ).to_s
      attrs[:userPassword] = '{SSHA}' + Base64.encode64(Digest::SHA1.digest( new_resource.password + salt ) + salt ).chomp!
    end

    if new_resource.is_posix
      objclass.push( 'shadowAccount', 'posixAccount', 'posixGroup' )
      raise 'Must specify home directory' unless new_resource.home
      attrs[:homeDirectory] = new_resource.home

      dirsrv = Chef::Dirsrv.new

      if current_resource and current_resource.attribute_names.include?('uidnumber')
        unless new_resource.uid_number == current_resource.uid_number
          attrs[:uidNumber] = new_resource.uid_number.to_s
        end
      else
        entries = dirsrv.search( new_resource, new_resource.basedn, '(objectClass=posixAccount)' )
        maxuid = entries.empty? ? 1000 : entries.map{ |e| e.uidnumber.max }.max.to_i + 1
        uid = new_resource.uid_number.nil? ? maxuid : new_resource.uid_number
        attrs[:uidNumber] = uid.to_s
      end

      if current_resource and current_resource.attribute_names.include?('gidnumber')
        unless new_resource.gid_number == current_resource.gid_number
          attrs[:gidNumber] = new_resource.gid_number.to_s
        end
      else
        entries = dirsrv.search( new_resource, new_resource.basedn, '(objectClass=posixAccount)' )
        maxgid = entries.empty? ? 1000 : entries.map{ |e| e.gidnumber.max }.max.to_i + 1
        gid = new_resource.gid_number.nil? ? maxgid : new_resource.gid_number
        attrs[:gidNumber] = gid.to_s
      end
    end

    dirsrv_entry dn do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      attributes ({ objectClass: objclass }.merge(attrs))
    end
  end
end

action :delete do

  @current_resource = load_current_resource

  if @current_resource
    converge_by("Removing #{@current_resource.dn}") do
      dirsrv_entry dn do
        host   new_resource.host
        port   new_resource.port
        credentials new_resource.credentials
        action :delete
      end
    end
  end
end

def load_current_resource
  dirsrv = Chef::Dirsrv.new
  @current_resource = dirsrv.search( new_resource, new_resource.basedn, "(#{new_resource.relativedn_attribute}=#{new_resource.common_name})" ).first
  @current_resource.attribute_names.map!{ |k| k.downcase } if @current_resource
  @current_resource
end
