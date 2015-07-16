# dirsrv cookbook

Installs and configures 389 Directory Server

From http://port389.org:

*"The enterprise-class Open Source LDAP server for Linux. It is hardened by real-world use, is full-featured, supports multi-master replication, and already handles many of the largest LDAP deployments in the world. The 389 Directory Server can be downloaded for free and set up in less than an hour using the graphical console."*

__... or even faster using Chef :)__

## Yum cookbook / EPEL repository

For RHEL based systems, the yum cookbook can be used to install the software packages from the [EPEL repo](https://fedoraproject.org/wiki/EPEL). Just set the 'use_yum_epel' flag to true.

```
default[:dirsrv][:use_yum_epel] = false
default[:dirsrv][:packages] = %w{389-ds}
```

## Sysctls 

The following sysctls are recommended for 389DS. You may want to tune these to values appropriate to your system.

- fs.file_max = 64000
- net.ipv4.tcp_keepalive_time = 30
- net.ipv4.ip_local_port_range = '1024 65000'

## Resources

### dirsrv_instance

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
cfgdir_domain | The name of the configuration directory domain. See 389DS docs. | String
cfgdir_credentials | See the 'Credentials' section below | String 
cfgdir_addr | The ip address that this service should listen on | String | node[:ipaddress]
cfgdir_http_port | The http port that the admin service should listen on | 9830
cfgdir_ldap_port | The ldap port for the instance that the admin console service is running on | Integer | 389
is_cfgdir | Set to true if the instance is the config directory | Boolean | false
has_cfgdir | Set to true if the instance should register with a config directory | Boolean | false

__ACTIONS__
* __create__
* start
* stop
* restart

__*The resources below all make use of the ldap_entry provider from the ldap cookbook. This means that they also use the 'host', 'port', 'credentials' and 'databag_name' parameters which are simply passed through to this resource. Omitting these common parameters from the resource descriptions below for brevity*__

### dirsrv_config

Configure attributes of the directory server instance itself. The configuration file for the directory server instance is a file called 'dse.ldif' in the instance specific config directory under /etc/dirsrv. This ldif object is loaded upon startup and is best modified at runtime. This resource modifies the attributes of the 'cn=config' ldap entry. You can find a full list of the configuration options available by using "ldapsearch -x -b cn=config -s base -D 'cn=Directory Manager' -W".

Name | Description | Type | Default
-----|-------------|------|----------
attr | The name of the attribute to be modified | String | Name Attribute
value | The value(s) to be set | String or Array |

__ACTIONS__
* __enable__
* disable

### dirsrv_plugin

Modify the plugins available to the directory server. To get a full list of the plugins available, use the following command: "ldapsearch -x -b cn=plugins,cn=config -s one -D 'cn=Directory Manager' -W cn dn"

Name | Description | Type | Default
-----|-------------|------|----------
common_name | The name of the plugin, including spaces | String | Name Attribute
attributes | The attributes/values to be set. See dirsrv_entry | Hash
append_attributes | The attributes/values to be appended to any existing values. See dirsrv_entry | Hash

__ACTIONS__
* __enable__
* disable
* modify

### dirsrv_index

Creates an index on an attribute.

Name | Description | Type | Default
-----|-------------|------|----------
name | The attribute to be indexed | String | Name Attribute
database | Name of the underlying BDB database | String | 'userRoot'
equality | Will this index be used to compare string equality? | Boolean | false
presence | Will this index be used to compare string presence? | Boolean | false
substring | Will this index be used to perform substring matches? | Boolean | false

__ACTIONS__
* __create__

### dirsrv_user

Creates a user for various kinds of identity management purposes. This is useful to create users who can bind (connect) and use the LDAP instance. It can also be used to create users with posix attributes on them for use with UNIX systems.

Name | Description | Type | Default
-----|-------------|------|----------
common_name | Value to be set as both uid and cn attributes. See relativedn_attribute | String  | Name Attribute
surname | The surname of the user. Should be set on accounts that will be used by people | String | Matches the value of common_name.
password | Optional password should be specified in plaintext. Will be converted to a salted sha (SSHA) hash before being sent to the directory | String 
home | home directory. Required for posix accounts | String
shell | login shell. Required for posix accounts. | String
basedn | The DN that will be the parent of the user account entry ( e.g. 'ou=people,... ). Required | String
relativedn_attribute | The relative distinguished name (RDN) attribute. This is will be used to name the common_name attribute from above. Given a common_name of 'bjensen' and a basedn attribute of 'ou=people,o=myorg,c=US' the distinguished name would be 'uid=bjensen,ou=people,o=myorg,c=US'. | 'uid'
uid_number | Required for posix accounts. If not supplied, the basedn will be searched for the highest value and the next increment will be used | Integer | 1000
gid_number | Required for posix accounts. If not supplied, the basedn will be searched for the highest value and the next increment will be used | Integer | 1000
is_person | Will this be used by a person? | Boolean | true
is_posix | Will this be used on a posix system? | Boolean | true
is_extensible | Can the entry be extended using custom attributes? | Boolean | false

__ACTIONS__
* __create__
* delete

### dirsrv_replica

A replica object is used to describe the role that the directory instance will play in a replication scheme. Replication documentation can be found [here](https://access.redhat.com/documentation/en-US/Red_Hat_Directory_Server/9.0/html/Administration_Guide/Managing_Replication.html)

Name | Description | Type | Default
-----|-------------|------|----------
suffix | root of ldap tree. See disrv_instance | String | Name Attribute
instance | name of the instance corresponding to the suffix | String
id | unique replica id | Integer | Generated from ip address. See below.
role | role that this replica plays in the replication scheme | Integer | See below
purge_delay | See nsDS5ReplicaPurgeDelay in documentation | Integer | 604800
base_dir | See dirsrv_instance | String | '/var/lib/dirsrv'

__ACTIONS__
* __create__

Replica IDs must be unique among all participants in a replication scheme. It is best if they are unique among all of the systems you plan to administer, so that you don't have to worry about overlap should you decide to reorient your replication scheme in the future. If not specified, the id will be generated from the hosts ip address by bitshifting the 4th octet eight bits to the left and adding the second octet.

```
second = node[:ipaddress].split('.').slice(1).to_i
fourth = node[:ipaddress].split('.').slice(3).to_i
replid = new_resource.id.nil? ? (( fourth << 8 ) + second ).to_s : new_resource.id.to_s
```

Replication roles must be one of the following: __:single_master__ __:multi_master__ __:hub__ and __:consumer__

Documentation about these roles can be found [here](https://access.redhat.com/documentation/en-US/Red_Hat_Directory_Server/9.0/html/Deployment_Guide/Designing_the_Replication_Process.html)

### dirsrv_agreement

Replication Agreements are used to describe a one-way direction for data to be pushed from supplier to consumer. Multiple agreements can be configured on a supplier to push the same set of data to multiple consumers. To accomplish bidirectional synchronization for multi-master replication, there must be two agreements in place, one for each node pushing data to each other, so a node participating in a __:multi_master__ role is both a supplier and a consumer of the dataset that it holds. 

In order to publish this data, each participating replica must have a DN to bind to that lies outside of the replicated dataset. Typically this replication bind dn is located at 'cn=Replication Manager,cn=config'. The *_vagrant_replication* recipe contains an example of how to use dirsrv_user to create this DN.

Please refer to the [documentation](https://access.redhat.com/documentation/en-US/Red_Hat_Directory_Server/9.0/html/Administration_Guide/Managing_Replication-Configuring-Replication-cmd.html) which covers the attributes used to configure both replicas and replication agreements.

Additionally, 389 Directory Server is able to synchronize with Active Directory and this resource can be used to create agreements with AD hosts as well.

Name | Description | Type | Default
-----|-------------|------|----------
label | label must have characters that can be used in an LDAP DN | String | Name Attribute
suffix | see dirsrv_instance | String
directory_type | 389DS or Active Directory | __:AD__ or __:DS__ | __:DS__
replica_host | The remote host that will be a consumer for this data | Integer |
replica_port | The port of the consumer replica | Integer | 389
replica_bind_dn | Bind DN for replication | String | 'cn=Replication Manager,cn=config'
replica_update_schedule | Corresponds to nsDS5ReplicaUpdateSchedule | String | '0000-2359 0123456'
replica_bind_method | Corresponds to nsDS5ReplicaBindMethod | String | 'SIMPLE'
replica_transport | Corresponds to nsDS5ReplicaTransportInfo | String | 'LDAP'
replica_credentials | Corresponds to nsDS5ReplicaBindCredentials for AD, nsDS5ReplicaCredentials for DS | String | 
ds_replicated_attribute_list  | Corresponds to nsDS5ReplicatedAttributeList | String | '(objectclass=*) $ EXCLUDE authorityRevocationList accountUnlockTime memberof'
ds_replicated_attribute_list_total | Corresponds to nsDS5ReplicatedAttributeListTotal | String | '(objectclass=*) $ EXCLUDE accountUnlockTime'
ad_domain | Active Directory Domain (nsDS7WindowsDomain) | String 
ad_new_user_sync | Corresponds to nsDS7NewWinUserSyncEnabled | String
ad_new_group_sync | Corresponds to nsDS7NewWinGroupSyncEnabled | String
ad_one_way_sync | Corresponds to oneWaySync | String
ad_sync_interval | Corresponds to winSyncInterval | Integer
ad_sync_move_action | Corresponds to winSyncMoveAction | 'none', 'delete', 'unsync' | 'none'
ad_replica_subtree | The Active Directory suffix to be replicated to 389DS (nsDS7WindowsReplicaSubtree) | String | 

__ACTIONS__
* __create__
* create_and_initialize

Initialization is an action that replaces the data in the current replica with the data in another replica. Since 389 has push-model replication, the process to setup multi-master replication should take the following steps:

1. Create the first replica on node A. For the purposes of demonstration, create a few entries on this replica to represent an existing dataset.
2. Create the second replica on node B.
3. Create an agreement on node B to push updates to node A. Since there is no data on the freshly created B, it has no updates to send.
4. Create an agreement on node A to push updates to node B __*and initialize it upon creation*__. Now B will have the dataset that was on A, and it will be able to publish any updates back to A using the agreement created in step 3.

If we are to introduce any additional nodes to this setup, we would have them request to be initialized from one designated node ( say node A ) and simply create agreements pointing to and from all of the other nodes within the replication scheme.

To see a real working example of this, check out the recipes named *___vagrant_xxx__* or simply 'vagrant up'

## Credentials

The 'credentials' attribute found on many of these resources provides a way to use credentials stored in a databag. It can either be a Hash object with the keys defined below, or a String. If this specified a String, it will look for a databag whose name matches the calling cookbook and pull out an item whose name matches the 'credentials' string. This data bag item should have the Hash keys described below. If no credentials are specified, it will look for a data bag item called 'default_credentials'.  

key      | value | example
---------|-------|--------
bind_dn  | The bind DN used to initialize the instance and create the initial set of LDAP entries | 'cn=Directory Manager' |
password | The password, in plain text | 'Super Cool Passwords Are Super Cool!!!!!'
username | Used by the admin_credentials attribute to setup the 389 admin server | 'manager'

You can specify userdn or user, or both of them if you want the user of the Admin Server to have the same password as the Directory Manager. Of course, you can have many different sets of credentials.

## Examples

The included Vagrantfile and vagrant specific recipes are used to spin up a test environment demonstrating four-way multi-master replication, a proxy/hub and a consumer.  These recipes can be used as a template for use in your wrapper cookbooks. You can read more about various cookbook patterns on Jamie's [blog](http://blog.vialstudios.com/the-environment-cookbook-pattern)

## TODO

* Register admin server with a remote configuration directory a la register-ds-admin
* Certificate management and replication via ssl
* Add schema files and create schema reload task
* Add support for editing ACIs

## Supports

This cookbook is tested and works on CentOS 6.x and it should also work on other RHEL derivatives that can use the EPEL repo. It is also tested and working on recent Ubuntu distributions. It should also work for Debian systems, but the 389-ds packages seem to only be available for Debian sid (unstable).

# Author

Author:: Alan Willis (<alwillis@riotgames.com>)

# License

See LICENSE for license details
