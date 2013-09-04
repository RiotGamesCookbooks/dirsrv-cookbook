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
  
    def bind ( host, port, userdn, password )

      unless ( userdn and password )

        # If userdn and pass were not specified, fall back onto the 
        # credentials provided by the directory_manager item in the dirsrv databag

        require 'chef/data_bag_item'
        require 'chef/encrypted_data_bag_item'

        secret = Chef::EncryptedDataBagItem.load_secret(Chef::Config[:encrypted_data_bag_secret])
        credentials = Chef::EncryptedDataBagItem.load( 'dirsrv', 'directory_manager', secret )
        userdn = credentials['rootdn']
        password = credentials['password']
      end

      @ldap = Net::LDAP.new host: host,
                            port: port,
                            auth: { 
                              method:   :simple,
                              username: userdn,
                              password: password
                            }
  
      raise "Unable to bind: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message == 'Success'
      @ldap
    end
  
    def get_entry ( r )
 
      self.bind( r.host, r.port, r.userdn, r.password ) unless @ldap
  
      entry = @ldap.search( 
                base:   r.dn, 
                filter: Net::LDAP::Filter.eq( 'objectClass', '*' ),
                scope:  Net::LDAP::SearchScope_BaseObject
              )
  
      raise "Error while searching: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
      return entry ? entry.first : entry
    end
  
    def add_entry ( r )
  
      self.bind( r.host, r.port, r.userdn, r.password ) unless @ldap
  
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
  
      self.bind( r.host, r.port, r.userdn, r.password ) unless @ldap
      @ldap.delete dn: r.dn
      raise "Unable to remove record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
    end
  end
end
