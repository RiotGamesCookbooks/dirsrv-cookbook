name             'dirsrv'
maintainer       'Alan Willis'
maintainer_email 'alwillis@riotgames.com'
license          'All rights reserved'
description      'Installs and configures 389 Directory Server. Provides generic lightweight resources for managing LDAP objects.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'yum', '~> 3.0'
depends 'hostsfile'

supports 'centos'
supports 'fedora'
supports 'oracle'
supports 'redhat'
supports 'scientific'
supports 'debian'
supports 'ubuntu'
