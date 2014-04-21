#
# Cookbook Name:: collectd
# Recipe:: collectd_web
#
# Copyright 2010, Atari, Inc
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

include_recipe 'collectd'
include_recipe 'apache2'

if platform?('ubuntu')
  apache_site 'default' do
    enable false
  end
end

%w(libhtml-parser-perl liburi-perl librrds-perl libjson-perl).each do |name|
  package name
end

directory node[:collectd][:collectd_web][:path] do
  owner 'root'
  group 'root'
  mode '755'
end

git node[:collectd][:collectd_web][:path] do
  repository 'https://github.com/httpdss/collectd-web'
  action :sync
end

template '/etc/apache2/sites-available/collectd_web.conf' do
  source 'collectd_web.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
end

apache_site 'collectd_web.conf'

unless node['collectd']['collectd_web']['htpasswd_username'].nil? &&
   node['collectd']['collectd_web']['htpasswd_password'].nil?
  htpasswd '/etc/apache2/htpasswd' do
    user node['collectd']['collectd_web']['htpasswd_username']
    password node['collectd']['collectd_web']['htpasswd_password']
    notifies :restart, resources(service: 'apache2')
  end
end
