name             'dirsrv'
maintainer       'Alan Willis'
maintainer_email 'alwillis@riotgames.com'
license          'All rights reserved'
description      'Installs and configures 389 Directory Server'
version          '0.1.1'

depends 'ldap', '~> 1.0'
depends 'yum', '~> 3.0'
depends 'hostsfile'

supports 'centos'
supports 'fedora'
supports 'oracle'
supports 'redhat'
supports 'scientific'
supports 'debian'
supports 'ubuntu'
