class Chef
  class Dirsrv
  
    # Chef libraries are evaluated before recipes which places two constraints on this library:
    # 1) A 'require' must be done in a method
    # 2) This class cannot use 'Subclass < Superclass'
    # As Net::LDAP is a class it cannot be included as a module
  
    attr_accessor :ldap
  
    def initialize
      require 'net-ldap'
    end
  
    def bind ( host, port, userdn, pass )
      @ldap = Net::LDAP.new host: host,
                            port: port,
                            auth: { 
                              method:   :simple,
                              username: userdn,
                              password: pass
                            }
  
      raise "Unable to bind: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message == 'Success'
      @ldap
    end
  
    def get_entry ( r )
  
      self.bind( r.host, r.port, r.userdn, r.pass ) unless @ldap
  
      entry = @ldap.search( 
                base:   r.dn, 
                filter: Net::LDAP::Filter.eq( 'objectClass', '*' ),
                scope:  Net::LDAP::SearchScope_BaseObject
              )
  
      raise "Error while searching: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
      return entry ? entry.first : entry
    end
  
    def add_entry ( r )
  
      self.bind( r.host, r.port, r.userdn, r.pass ) unless @ldap
  
      relativedn = r.dn.split(',').first
      attrs = r.attributes.merge(Hash[*relativedn.split('=').flatten])
      @ldap.add dn: r.dn, attributes: attrs
      raise "Unable to add record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|Entry Already Exists)/
    end
  
    def modify_entry ( r, ops )
  
      entry = self.get_entry( r )

      @ldap.modify dn: r.dn, operations: ops
      raise "Unable to modify record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Attribute)/
    end
  
    def delete_entry ( r )
  
      self.bind( r.host, r.port, r.userdn, r.pass ) unless @ldap
      @ldap.delete dn: r.dn
      raise "Unable to remove record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
    end
  end
end
