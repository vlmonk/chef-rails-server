# apt-update
include_recipe 'apt'

# install nginx
include_recipe 'nginx'
node.default[:nginx][:client_max_body_size] = '64M'

nginx_site 'default' do
  enable false
end

# install monit
include_recipe 'monit'
node.normal[:monit][:notify_email] = "me@mvl.ru"
node.normal[:monit][:mail_format][:from] = "monit@#{node['hostname']}"


# ruby
node.default['rvm']['default_ruby'] = 'system'
node.default['rvm']['upgrade'] = 'stable'
include_recipe 'rvm::system'
rvm_ruby node.app.ruby

# nodejs
apt_repository "nodejs" do
  uri "http://ppa.launchpad.net/chris-lea/node.js/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "C7917B12"
end

package 'nodejs'

# postgresql server

include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'


# imagemagick
package 'imagemagick'

# install mysql client (sphinx)
include_recipe 'mysql::client'

# mailserver
include_recipe 'postfix::server'
