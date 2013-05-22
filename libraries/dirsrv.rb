require 'net-ldap'

class Dirsrv
  def initialize( host, port, userdn, pass )
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
