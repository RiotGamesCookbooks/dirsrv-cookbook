class Chef # :nodoc:
  class Dirsrv

    # == About
    # 
    # Configuration of the directory server is almost entirely via ldap objects.
    # This class enables LDAP connectivity to the directory server via the net-ldap library.
    #
    # To make use of most methods in this library, you will need to pass in a resource object for the connection that has the following methods:
    #
    # host:: the ldap host to connect to.
    # port:: the ldap port to connect to
    # credentials:: either a hash with the userdn and password to use, or a string that identifies the name of a databag item.
    #               see the documentation in the README.md for details.
    # databag_name:: the name of the databag in which to lookup the credentials
    #
    # The main user of this library is the dirsrv_entry resource, which has sensible defaults for these three items.
  
    attr_accessor :ldap
 
    # == Constraints
    #
    # Chef libraries are evaluated before the recipe that places the chef_gem that it needs is put into place.
    # This places two constraints on this library:
    # 1) A 'require' must be done in a method
    # 2) This class cannot use 'Subclass < Superclass'
    # As Net::LDAP is a class it cannot be included as a module

    def initialize
      # 
      require 'rubygems'
      require 'net-ldap'
      require 'cicphash'
    end

    # == Bind
    #
    # This method should not be used directly. It is used to bind to the directory server.
    # The databag_name is the name of the databag that is used for looking up connection credentials.
    # It returns a connected ruby Net::LDAP object
  
    def bind( host, port, credentials, databag_name ) # :yields: host, port, credentials, databag_name

      credentials = credentials.kind_of?(Hash) ? credentials.to_hash : credentials.to_s

      if credentials.instance_of?(String) and credentials.length > 0

        # Pull named credentials from the databag

        require 'chef/data_bag_item'
        require 'chef/encrypted_data_bag_item'

        secret = Chef::EncryptedDataBagItem.load_secret
        credentials = Chef::EncryptedDataBagItem.load( databag_name, credentials, secret ).to_hash
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

    # == Search
    #
    # This method is used to search the directory server. It accepts the connection resource object described above
    # along with the basedn to be searched. Optionally it also accepts an LDAP filter and scope. 
    # The default filter is objectClass=* and the default scope is 'base'
    # It returns a list of entries.
 
    def search( c, basedn, *constraints ) # :yields: connection_info, basedn, filter, scope

      self.bind( c.host, c.port, c.credentials, c.databag_name ) unless @ldap

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
                  scope:  scope,
                  attributes: [ '*' ]
                )

      raise "Error while searching: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
      return entries
    end

    # == Get Entry
    # 
    # This method accepts a connection resource object. It is intended to be used with
    # Chef::Resource::DirsrvEntry objects that will also have a .dn method indicating
    # Distinguished Name to be retrieved. It returns a single entry.
 
    def get_entry( c, dn ) # :yields: connection_info, distinguished_name
 
      self.bind( c.host, c.port, c.credentials, c.databag_name ) unless @ldap
  
      entry = @ldap.search( 
                base:   dn, 
                filter: Net::LDAP::Filter.eq( 'objectClass', '*' ),
                scope:  Net::LDAP::SearchScope_BaseObject,
                attributes: [ '*' ]
              )
  
      raise "Error while searching: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
      return entry ? entry.first : entry
    end
  
    # == Add Entry
    # 
    # This method accepts a connection resource object. It is intended to be used with
    # Chef::Resource::DirsrvEntry objects that will also have a .dn method and attributes 
    # to be set on the entry to be created.

    def add_entry( c, resource ) # :yields: connection_info, resource
  
      self.bind( c.host, c.port, c.credentials, c.databag_name ) unless @ldap
  
      relativedn = resource.dn.split(',').first
      # Cast as a case insensitive, case preserving hash
      attrs = CICPHash.new.merge!(resource.attributes)
      attrs.merge!(resource.seed_attributes)
      attrs.merge!(Hash[*relativedn.split('=').flatten])
      @ldap.add dn: resource.dn, attributes: attrs
      raise "Unable to add record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message == 'Success'
    end
  
    # == Modify Entry
    # 
    # Accepts a connection resource object as the first argument, followed by an Array
    # of ldap operations. It is intended to be used with Chef::Resource::DirsrvEntry 
    # objects that will also have a .dn method that returns the DN of the entry to be modified.
    #
    # Each ldap operation in the ldap operations list is an Array object with the following items:
    # 1. LDAP operation ( e.g. :add, :delete, :replace )
    # 2. Attribute name ( String or Symbol )
    # 3. Attribute Values ( String or Symbol, or Array of Strings or Symbols )
    # 
    # So an example of an operations list to be passed to this method might look like this:
    # [ [ :add, 'attr1', 'value1' ], [ :replace, :attr2, [ :attr2a, 'attr2b', :attr2c ] ], [ :delete, 'attr3' ], [ :delete, :attr4, 'value4' ] ]
    # Note that none of the values passed can be Integers. They must be STRINGS ONLY! This is a limitation of the ruby net-ldap library.

    def modify_entry( c, dn, ops ) # :yields: connection_info, distinguished_name, operations
  
      entry = self.get_entry( c, dn )

      @ldap.modify dn: dn, operations: ops
      raise "Unable to modify record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|Attribute or Value Exists)/
    end
  
    # == Delete Entry
    # 
    # Expects a connection resource object, along with a .dn method that returns the
    # Distinguished Name of the entry to be deleted.

    def delete_entry( c, dn ) # :yields: connection_info, distinguished_name
  
      self.bind( c.host, c.port, c.credentials, c.databag_name ) unless @ldap
      @ldap.delete dn: dn
      raise "Unable to remove record: #{@ldap.get_operation_result.message}" unless @ldap.get_operation_result.message =~ /(Success|No Such Object)/
    end
  end
end
