class Dirsrv

  def initialize( host, port, userdn, pass )
    # This require is here because libraries are evaluated before the recipe that would install the gem
    require 'net-ldap'

    Net::LDAP.new host: host,
                  port: port,
                  auth: { 
                    method:   :simple,
                    username: userdn,
                    password: pass
                  }
  end

  def filter( attr, value )
    Net::LDAP::Filter.eq( attr, value )
  end
end
