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

    raise IOError, 'Unable to bind' unless @ldap.get_operation_result.message == 'Success'
    @ldap
  end

  def get_entry ( r )

    self.bind( r.host, r.port, r.userdn, r.pass )

    entry = self.ldap.search( 
              base:   r.dn, 
              filter: Net::LDAP::Filter.eq( 'objectClass', '*' ),
              scope:  Net::LDAP::SearchScope_BaseObject
            )

    return [] unless entry
    entry = entry.first
    entry
  end

  def get_entry_attrs ( r ) 

    entry = self.get_entry( r )
    entry.attribute_names
  end
end
