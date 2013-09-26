class Chef
  class Dirsrv
  
    # Chef libraries are evaluated before recipes which places two constraints on this library:
    # 1) A 'require' must be done in a method
    # 2) This class cannot use 'Subclass < Superclass'
    # As Net::LDAP is a class it cannot be included as a module
  
    attr_accessor :ldap
  
    def initialize
      require 'rubygems'
      require 'net-ldap'
      require 'cicphash'
    end
  
    def bind ( host, port, credentials )

      credentials = credentials.kind_of?(Hash) ? credentials.to_hash : credentials

      if credentials.instance_of?(String) and credentials.length > 0

        # Pull named credentials from the dirsrv databag

        require 'chef/data_bag_item'
        require 'chef/encrypted_data_bag_item'

        secret = Chef::EncryptedDataBagItem.load_secret
        credentials = Chef::EncryptedDataBagItem.load( 'dirsrv', credentials, secret ).to_hash
      end

      unless credentials.kind_of?(Hash) and credentials.key?('userdn') and credentials.key?('password')
        raise "Invalid credentials: #{credentials}"
      end

      @ldap = Net::LDAP.new host: host,
                            port: port,
                            auth: { 
                              method:   :simple,
                              username: credentials['userdn'],
                              password: credentials['password']
                            }
  
      raise "Unable to bind: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message == 'Success'
      @ldap
    end
 
    def search ( r, basedn, *constraints )

      self.bind( r.host, r.port, r.credentials ) unless @ldap

      raise "Must specify base dn for search" unless basedn

      ( filter, scope ) = constraints
      filter = filter.nil? ? Net::LDAP::Filter.eq( 'objectClass', '*' ) : filter

      case scope
      when 'base'
        scope = Net::LDAP::SearchScope_BaseObject
      when 'one'
        scope = Net::LDAP::SearchScope_SingleLevel
      else
        scope = Net::LDAP::SearchScope_WholeSubtree
      end

      scope = scope.nil? ? Net::LDAP::SearchScope_BaseObject : scope

      entries = @ldap.search( 
                  base:   basedn, 
                  filter: filter,
                  scope:  scope
                )

      raise "Error while searching: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
      return entries
    end
 
    def get_entry ( r )
 
      self.bind( r.host, r.port, r.credentials ) unless @ldap
  
      entry = @ldap.search( 
                base:   r.dn, 
                filter: Net::LDAP::Filter.eq( 'objectClass', '*' ),
                scope:  Net::LDAP::SearchScope_BaseObject
              )
  
      raise "Error while searching: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
      return entry ? entry.first : entry
    end
  
    def add_entry ( r )
  
      self.bind( r.host, r.port, r.credentials ) unless @ldap
  
      relativedn = r.dn.split(',').first
      # Cast as a case insensitive, case preserving hash
      attrs = CICPHash.new.merge!(r.attributes)
      attrs.merge(Hash[*relativedn.split('=').flatten])
      @ldap.add dn: r.dn, attributes: attrs
      raise "Unable to add record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message == 'Success'
    end
  
    def modify_entry ( r, ops )
  
      entry = self.get_entry( r )

      @ldap.modify dn: r.dn, operations: ops
      raise "Unable to modify record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Attribute)/
    end
  
    def delete_entry ( r )
  
      self.bind( r.host, r.port, r.credentials ) unless @ldap
      @ldap.delete dn: r.dn
      raise "Unable to remove record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
    end
  end
end
