# dirsrv cookbook

Installs and configures 389 Directory Server / RedHat Directory Server

See http://port389.org/wiki/Main_Page

### Yum cookbook / EPEL repository

For RHEL based systems, the yum cookbook can be used to install the software packages from the EPEL repo (https://fedoraproject.org/wiki/EPEL). Just set the ':use_yum_epel' flag to true.

```
default[:dirsrv][:use_yum_epel] = false
default[:dirsrv][:packages] = %w{389-ds}
```

### Sysctls 

The following sysctls are recommended for 389DS. You may want to tune these to values appropriate to your system.

- fs.file_max = 64000
- net.ipv4.tcp_keepalive_time = 30
- net.ipv4.ip_local_port_range = '1024 65000'

### Resources

#### dirsrv_instance

  Configures a 389 Directory Server instance. See [this installation guide](http://www.centos.org/docs/5/html/CDS/install/8.0/Installation_Guide-Preparing_for_a_Directory_Server_Installation-Installation_Overview.html) for more details.

Name | Description | Type | Default
-----|-------------|------|----------
instance | The name for the instance which must be unique to the system. You can have multiple instances running on the same system | String | Name Attribute
suffix | This is the name of the root of the instance's LDAP heirarchy | String 
credentials | See the 'Credentials' section below | String or Hash | 'default'
host | The hostname that should be used to create the instance. This must include at least one dot ('.') so as to appear to be an FQDN. | String | node[:fqdn]
port | The port that this instance will listen on. | Integer | 389
add_org_entries | 389DS comes with a suggested skeleton directory structure. Set this to true if you want it | Boolean | false
add_sample_entries | 389DS comes with a set of sample top level entries. Set this to true if you want it | Boolean | false
preseed_ldif | If you would like to preseed your directory server with an LDIF file, specify the path the file here | String |
conf_dir | The directory that contains configuration files for all of the 389DS instances on a system. | String | '/etc/dirsrv'
base_dir | The directory that contains the application data for the 389DS service. | String | '/var/lib/dirsrv'

The Administration server is an httpd service that can be installed alongside the directory server to enable remote administration ( e.g. starting and stopping the service, managing ssl certificates, configuring replication, editing ldap entries). You can designate one particular node to run an admin service that also acts as a 'Configuration Directory' in 389DS parlance. Connecting to the admin service on a configuration directory node allows you to see and manage all of the directories who have registered their presence with the config directory. The following options will enable you to configure this. 

Name | Description | Type | Default
-----|-------------|------|----------
admin_domain | The name of the configuration directory domain. See 389DS docs. | String
admin_credentials | See the 'Credentials' section below | String 
cfgdir_addr | The ip address that this service should listen on | String | node[:ipaddress]
cfgdir_http_port | The http port that the admin service should listen on | 9830
cfgdir_ldap_port | The ldap port for the instance that the admin console service is running on | Integer | 389
is_cfgdir | Set to true if the instance is the config directory | Boolean | false
has_cfgdir | Set to true if the instance should register with a config directory | Boolean | false

#### dirsrv_entry

After the initial setup of the directory server, all subsequent configuration can be accomplished by manipulating LDAP entries in the directory itself. This resource is used to manage generic LDAP entries. It makes use of the ruby net-ldap library, and can be used with any LDAP directory service.

Name | Description | Type | Default
-----|-------------|------|----------
dn | Distinguished Name (DN) | String | Name Attribute
attributes | Attributes to be set on the entry. Existing attributes of the same name will have their contents replaced | Hash 
append_attributes | Attributes whose values are to be appended to any existing values, if any | Hash
seed_attributes | Attributes whose values are to be set once and not modified again | Hash
prune | List of attributes to be removed, or a Hash of attributes with specific values to be removed | Array or Hash 
host | The host to connect to | String | localhost
port | The port to connect to | Integer | 389
credentials | See the 'Credentials' section below | String or Hash | 'default'

_* The resources below all make use of this one to create objects in the directory server. This means that they also require the 'host', 'port' and 'credentials' parameters which are simply passed through to this resource. Omitting these common parameters from the resource descriptions below for brevity *_

#### dirsrv_config

  Configure attributes of the directory server instance itself. The configuration file for the directory server instance is a file called 'dse.ldif' in the instance specific config directory under /etc/dirsrv. This ldif object is loaded upon startup and is best modified at runtime. This resource modifies the attributes of the 'cn=config' ldap entry. You can find a full list of the configuration options available by using "ldapsearch -x -b cn=config -s base -D 'cn=Directory Manager' -W".

  * attr
    The name of the attribute to be modified
  * value
    The value to be set. This can be either a single value or a list.
  * host
  * port
  * credentials
    These values are passed directly to dirsrv_entry

#### dirsrv_plugin

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

#### dirsrv_index

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

#### dirsrv_user

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

#### dirsrv_replica

* suffix
* instance
* id
* role
* purge_delay
* base_dir

#### dirsrv_agreement

label 
suffix 
directory_type 
replica_host 
replica_port 
replica_bind_dn 
replica_update_schedule 
replica_bind_method 
replica_transport 
replica_credentials 
ds_replicated_attribute_list 
ds_replicated_attribute_list_total 
ad_domain 
ad_new_user_sync 
ad_new_group_sync 
ad_one_way_sync 
ad_sync_interval 
ad_sync_move_action 
ad_replica_subtree 


### Credentials

The 'credentials' attribute found on many of these resources provides a way to use credentials stored in a databag. It can either be a Hash object with the keys defined below, or a String. If this specified a String, it should contain the name of a databag item within the 'dirsrv' databag that contains a Hash object as specified above. This attribute defaults to the string 'default'. If you create a databag named 'dirsrv' and put a databag item in it named 'default' with these two keys, then it will be used by default and you will not need to specify this option.

key      | value
---------|-------
userdn   | The bind DN used to initialize the instance and create the initial set of LDAP entries. Example: 'cn=Directory Manager'
password | The password, in plain text
user     | Used exclusively by the cfgdir_credentials attribute to create management credentials for an administrative configuration directory service.

## Examples

The included Vagrantfile and vagrant specific recipes are used to spin up a test environment demonstrating four-way multi-master replication, a proxy/hub and a consumer.  These recipes can be used as a template for use in your wrapper cookbooks. You can read more about various cookbook patterns (here)[http://blog.vialstudios.com/the-environment-cookbook-pattern]

## TODO

* Read credentials from a databag named for the calling cookbook, instead of 'dirsrv'.

# Author

Author:: Alan Willis (<alwillis@riotgames.com>)

# License

See LICENSE for license details
