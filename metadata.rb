name             'dirsrv'
maintainer       'Alan Willis'
maintainer_email 'alwillis@riotgames.com'
license          'All rights reserved'
description      'Installs/Configures 389ds'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          lambda { IO.read(File.join(File.dirname(__FILE__), 'VERSION')) rescue "0.0.1" }.call

depends 'yum', '~> 3.0'
