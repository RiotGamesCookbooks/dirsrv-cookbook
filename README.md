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

### Sysctls 

The following sysctls are recommended for 389DS. This cookbook does not attempt to put them into place.

fs.file_max = 64000
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = '1024 65000'

## Resources

* dirsrv_instance

  Configures a 389 Directory Server instance. See [this installation guide](http://www.centos.org/docs/5/html/CDS/install/8.0/Installation_Guide-Preparing_for_a_Directory_Server_Installation-Installation_Overview.html) for more details.

  * Attributes

Name | Description | Type | Default
-----|-------------|------|----------
instance | The name for the instance. This must be unique to the system. An example of a good instance name might be '$HOSTNAME_$PORT'. You can have multiple instances running on the same system, and this cookbook supports this behavior. See Testing for examples. | String |
suffix | This is the name of the root of the instance's LDAP heirarchy, which is suffixed to the name of each object within the instance. | String |
credentials | See the 'Credentials' section below | String or Hash | 'default'
host | The hostname that should be used to create the instance. You may want to specify it if your host is known by multiple names. | String | node[:fqdn]
port | The port that this instance will listen on. | Integer | 389
add_org_entries | 389DS comes with a suggested skeleton directory structure. If you would find this useful, you might set this value to true. If you know exactly how you want to organize and arrange your directory tree, then you can leave these options out. | Boolean | false
add_sample_entries | 389DS comes with a default set of top level entries, and a suggested skeleton directory structure. If you would find this useful, you might set this value to true. If you know exactly how you want to organize and arrange your directory tree, then you can leave these options out. | Boolean | false
preseed_ldif | If you have an LDIF file with the entries that you would like to use to seed the directory server instance, you should specify the path to the file here. The deployment of this file on the intended system is outside the scope of this cookbook. | String |
conf_dir | The directory that contains configuration files for all of the 389DS instances on a system. | String | '/etc/dirsrv'
base_dir | The directory that contains the application data for the 389DS service. | String | '/var/lib/dirsrv'

  The administrative node in a 389DS deployment that is used to view and edit the configurations of other 389DS instances is called a 'Configuration Directory' in 389DS parlance. The admin software is an https based application which is used by the graphical 389DS administrative console software to perform advanced administration tasks. If this instance should be configured to either *be* an administrative node, or to *use* an administrative node, the following options will enable you to configure this. 

Name | Description | Type | Default
-----|-------------|------|----------
cfgdir_domain | The name of the configuration directory domain. 389DS instances that *are* or *use* a configuration directory instance must supply this. The mechanism can be used to allow multiple groups of administrators access to manage specific sets of instances. | String | 
cfgdir_credentials | See the 'Credentials' section below | String | 

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

  This resource is used to manage generic LDAP entries. It makes use of the ruby net-ldap library to write entries entirely from scratch in Chef and can be used with any LDAP directory service, not just 389DS. The resources that follow this one *are* specific to the 389DS server and they depend upon dirsrv_entry under the hood.

  * dn
    The Distinguished Name (DN) of the entry

  * attributes
    A Hash of attributes whose values are to be set upon the LDAP entry. If an entry has an existing attribute of the same name as one specified here, the contents will be overwritten by the values in this hash.

  * append_attributes
    A Hash of attributes whose values are to be appended to an existing attribute, if any. This is useful to ensure that the supplied values exist without clobbering existing values that were not specified.

  * seed_attributes
    A Hash of attributes whose values are used to initialize the attribute, and are to be ignored if the attribute exists. This is useful for setting values that should change over time outside of Chef's control. Examples: user passwords, serial number for a DNS domain.

  * prune
    This can either be an Array of attributes that should be removed entirely, or a Hash of attributes with specific values that should be removed.

  * host
    The LDAP host to connect to. Default: localhost

  * port
    The LDAP port to connect to. Default: 389

  * credentials
    A Hash or String used to specify which credentials will be used to manage the LDAP entry. See dirsrv_instance.


* dirsrv_config

  Configure attributes of the directory server instance itself. The configuration file for the directory server instance is a file called 'dse.ldif' in the instance specific config directory under /etc/dirsrv. This ldif object is loaded upon startup and is best modified at runtime. This resource modifies the attributes of the 'cn=config' ldap entry. You can find a full list of the configuration options available by using "ldapsearch -x -b cn=config -s base -D 'cn=Directory Manager' -W".

  * attr
    The name of the attribute to be modified
  * value
    The value to be set. This can be either a single value or a list.
  * host
  * port
  * credentials
    These values are passed directly to dirsrv_entry

* dirsrv_plugin

  Modify the plugins available to the directory server. To get a full list of the plugins available, use the following command: "ldapsearch -x -b cn=plugins,cn=config -s one -D 'cn=Directory Manager' -W cn dn"

  * common_name
    The name of the plugin, including spaces.

  * attributes
    The attributes to be set upon the plugin. You should only use this when you are certain that you know all of the values that a given attribute should have.

  * append_attributes
    Adds attributes in append-only mode. Existing values will not be replaced.

  * host
  * port
  * credentials
    These values are passed directly to dirsrv_entry

* dirsrv_index

  Creates an index on an attribute.

  * name
    The name of the attribute to be indexed

  * database
    The name of the underlying Berkeley database that contains the data. Defaults to 'userRoot' which is probably what you want.

  * equality
    Set to true if an equality index should be present. Default false.

  * presence
    Set to true if an presence index should be present. Default false.

  * substring
    Set to true if an substring index should be present. Default false.

  * host
  * port
  * credentials
    These values are passed directly to dirsrv_entry

* dirsrv_user

  Creates a user for various kinds of identity management purposes. This is useful to create users who can bind (connect) and use the LDAP instance. It can also be used to create users with posix attributes on them for use with UNIX systems.

  * common_name
    The name of the user

  * surname
    The surname of the user. Should be set on accounts that will be used by individual people. Defaults to the value of common_name.

  * password
    The password that the user should have. (Optional)

  * home
    The home directory. Required for posix accounts

  * shell
    The login shell. Required for posix accounts.

  * basedn
    The distinguished name that should contain the user account entry. Usually this will be something like 'ou=people,...'. This will vary according to your directory hierarchy/layout.

  * relativedn_attribute
    The relative distinguished name attribute. This is the attribute that will name the common_name attribute from above. Default is 'uid'. Given a common_name of 'bjensen' and a basedn attribute of 'ou=people,o=myorg,c=US' the distinguished name would be 'uid=bjensen,ou=people,o=myorg,c=US'.

  * uid_number
  * gid_number
    The uid and gid values required by posix accounts. Duplicate ids will cause permissions and security problems for posix systems. If this is not specified, a search will be performed under the basedn for posixAccount objects, and the maximum values found will be incremented by one and used. If there are no existing entries and if no value is provided, the default value is 1000.

  * is_person
    Should be set if the user credentials being created are to be used by a person. Includes the use of the 'person', 'organizationalPerson', and 'inetOrgPerson' object classes, which require that surname is set.

  * is_posix
    Should be set if the user credentials are to be used on a posix system. Includes the use of the 'shadowAccount', 'posixAccount', and 'posixGroup' object classes, which require that uid_number and gid_number are set.

  * is_extensible
    Includes the use of the 'extensibleObject' object class. This class allows for any attribute to be set on the LDAP entry, so that you can set arbitrary attributes on a user entry without object class violations. Will not allow you to violate the schema restrictions on attributes that are defined by other object classes.

  * host
  * port
  * credentials
    These values are passed directly to dirsrv_entry

## Credentials

The 'credentials' attribute found on many of these resources provides a way to use credentials stored in a databag. It can either be a Hash object with the keys defined below, or a String. If this specified a String, it should contain the name of a databag item within the 'dirsrv' databag that contains a Hash object as specified above. This attribute defaults to the string 'default'. If you create a databag named 'dirsrv' and put a databag item in it named 'default' with these two keys, then it will be used by default and you will not need to specify this option.

key      | value
---------|-------
userdn   | The bind DN used to initialize the instance and create the initial set of LDAP entries. Example: 'cn=Directory Manager'
password | The password, in plain text
user     | Used exclusively by the cfgdir_credentials attribute to create management credentials for an administrative configuration directory service.

# Testing

# TODO

*) Figure out a non-destructive way to do replication agreements
*) Read credentials from a databag named for the calling cookbook, instead of 'dirsrv'.

# Author

Author:: Alan Willis (<alan@amekoshi.com>)

# License

See LICENSE for license details
