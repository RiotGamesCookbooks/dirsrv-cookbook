dirsrv cookbook
===============

Installs and configures 389 Directory Server / RedHat Directory Server

See http://port389.org/wiki/Main_Page

## Dependencies and Attributes

This is a library cookbook. The default recipe is capable of installing the software packages and setting certain tuning values, 
but this is disabled by default assuming that it will likely be done by a wrapper cookbook.

### Yum cookbook / EPEL repository

The yum cookbook can be used to install the software packages from the EPEL repo (https://fedoraproject.org/wiki/EPEL)

default[:dirsrv][:use_yum_epel] = false
default[:dirsrv][:packages] = %w{389-ds}

### Sysctl cookbook

default[:dirsrv][:use_sysctl] = false
default[:sysctl][:params][:fs][:file_max] = 64000
default[:sysctl][:params][:net][:ipv4][:tcp_keepalive_time] = 30
default[:sysctl][:params][:net][:ipv4][:ip_local_port_range] = '1024 65000'

## Resources

* dirsrv_instance

  Configures a 389 Directory Server instance. See http://www.centos.org/docs/5/html/CDS/install/8.0/Installation_Guide-Preparing_for_a_Directory_Server_Installation-Installation_Overview.html for more details.

  * instance
    The name for the instance. This must be unique to the system. An example of a good instance name might be '$HOSTNAME_$PORT'. You can have multiple instances running on the same system, and this cookbook supports this behavior. See Testing for examples.

  * suffix
    This is the name of the root of the instance's LDAP heirarchy, which is suffixed to the name of each object within the instance.

  * credentials
    This can either be a Hash object with the following structure:

key      | value
---------|-------
userdn   | The bind DN used to initialize the instance and create the initial set of LDAP entries. This should be an administrative DN, such as 'cn=Directory Manager'
password | The password, in plain text

    Also this could be a String that contains the name of a databag item within the 'dirsrv' databag that contains a Hash object as specified above. This attribute defaults to the string 'default'. If you create a databag named 'dirsrv' and put a databag item in it named 'default' with these two keys, then it will be used by default and you will not need to specify this option.

  * host
    The hostname that should be used to create the instance. By default this is set to node[:fqdn], which is defined by `hostname -f`. You may want to specify it if your host is known by multiple names.

  * port
    The port that this instance will listen on. By default, this is 389

  * add_org_entries
  * add_sample_entries
    389DS comes with a default set of top level entries, and a suggested skeleton directory structure. If you would find this useful, you might set this value to true. If you know exactly how you want to organize and arrange your directory tree, then you can leave these options out. Default: false.

  * preseed_ldif
    If you have an LDIF file with the entries that you would like to use to seed the directory server instance, you should specify the path to the file here. The deployment of this file on the intended system is outside the scope of this cookbook.

  * conf_dir
    The directory that contains configuration files for all of the 389DS instances on a system.  Default: '/etc/dirsrv'

  * base_dir
    The directory that contains the application data for the 389DS service. Default: '/var/lib/dirsrv'

  The administrative node in a 389DS deployment that is used to view and edit the configurations of other 389DS instances is called a 'Configuration Directory' in 389DS parlance. The admin software is an https based application which is used by the graphical 389DS administrative console software to perform advanced administration tasks. If this instance should be configured to either *be* an administrative node, or to *use* an administrative node, the following options will enable you to configure this. 

  * cfgdir_domain
    The name of the configuration directory domain. 389DS instances that *are* or *use* a configuration directory instance must supply this. The mechanism can be used to allow multiple groups of administrators access to manage specific sets of instances.

  * cfgdir_credentials
    In the same style as the 'credentials' attribute above, this defines either a String or a Hash that contains the keys below:

key      | value
---------|-------
user     | The username used to administer the configuration directory. Note that this is a free form string, *not* a DN.
password | The password, in plain text

    The default value is 'default'. If this option is used, you will probably want to redefine it so as to be different from the 'credentials' attribute above. Alternatively, yo
u could have the dirsrv->default databag item include all three keys: user, userdn, and password.

  * cfgdir_addr
    The ip address that this service should listen on. Defaults to node[:ipaddress]

  * cfgdir_http_port
    The http port that the admin service should listen on. Defaults to 9830.

  * cfgdir_ldap_port
    The ldap port for the instance that the admin console service is running on. Defaults to 389.

  * is_cfgdir
    This should be set to true if the instance should be configured as the administrative configuration directory for the specified domain. This can only be set on one system per cfgdir_domain. Default: false

  * has_cfgdir
    This should be set to true if the instance should be connected to and use an administrative configuration directory service. Multple instances can be connected to the same cfgdir_domain. Default: false

* dirsrv_entry
  * dn
  * attributes
  * append_attributes
  * seed_attributes
  * prune
  * host
  * port
  * credentials

* dirsrv_config
  * attr
  * value
  * host
  * port
  * credentials

* dirsrv_plugin
  * common_name
  * attributes
  * append_attributes
  * host
  * port
  * credentials

* dirsrv_index
  * name
  * instance
  * equality
  * presence
  * substring
  * host
  * port
  * credentials

* dirsrv_user
  * common_name
  * surname
  * password
  * home
  * shell
  * basedn
  * relativedn_attribute
  * uid_number
  * gid_number
  * is_person
  * is_posix
  * is_extensible
  * host
  * port
  * credentials

# Testing

# TODO

Figure out a non-destructive way to do replication agreements

# Author

Author:: Alan Willis (<alan@amekoshi.com>)

# License

See LICENSE for license details
