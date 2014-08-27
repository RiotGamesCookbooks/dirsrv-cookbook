#
# Cookbook Name:: dirsrv
# Provider:: admin
#
# Copyright 2014 Riot Games, Inc.
# Author:: Alan Willis <alwillis@riotgames.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def whyrun_supported?
  true
end

action :register do

  #converge_by("Registering with #{new_resource.cfgdir_host}) do
  # 
  #end
end

action :start do
end

action :stop do
end

# %admpw%
# %as_access%
# %as_addr%
# %as_buildnum%
# %as_console_jar%
# %as_error%
# %as_help_path%
# %asid%
# %as_pid%
# %as_port%
# %as_sie%
# %as_user%
# %as_version%
# %brand%
# %domain%
# %fqdn%
# %timestamp%
# %uname_a%
# %uname_m%
# %vendor%

