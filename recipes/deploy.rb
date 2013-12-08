user node.app.user do
  home "/home/#{node.app.user}"
  shell "/bin/bash"
  supports :manage_home => true
end


directory "/home/#{node.app.user}/.ssh" do
  owner node.app.user
  group node.app.user
  mode 00700
  action :create
end

file "/home/#{node.app.user}/.ssh/authorized_keys" do
  owner node.app.user
  group node.app.user
  mode 00400
  action :create
  content node['app']['key']
end

dirs = %w{
  app
  app/releases
  app/shared
  app/shared/system
  app/shared/log
  app/shared/pids
  app/shared/config
}

dirs.each do |dir|
  directory "/home/#{node.app.user}/#{dir}" do
    owner node.app.user
    group node.app.user
    mode 00755
    action :create
  end
end


# DB

info = {
  :host => "localhost",
  :port => 5432,
  :username => 'postgres',
  :password => node.postgresql.password.postgres
}

postgresql_database node.app.dbname do
  action :create
  connection info
end

postgresql_database_user node.app.dbuser do
  action :create
  connection info
  password node.app.dbpass
end

# APP CONFIG

template "/home/#{node.app.user}/app/shared/config/database.yml" do
  source 'database.yml.erb'
  mode 00600
  owner node.app.user
  group node.app.user
end

template "#{node.nginx.dir}/sites-available/#{node.app.name}" do
  source 'nginx.conf.erb'
  mode 00600
  owner node.nginx.user
  group node.nginx.user
  variables({
    :app => node.app.name,
    :user => node.app.user,
    :server => node.app.hostname
  })
end
nginx_site node.app.name

service 'nginx' do
  action :reload
end


# puma
directory "/home/deploy/app/shared/puma" do
  owner node.app.user
  group node.app.user
  mode 00777
  action :create
end


template "/home/deploy/app/shared/puma/puma.config" do
  source "puma_config.erb"
  mode 0600
  owner node.app.user
  group node.app.user
end

node.default['authorization']['sudo']['include_sudoers_d'] = true
include_recipe 'sudo'

sudo node.app.user do
  user node.app.user
  runas 'root'
  nopasswd true
  commands  ["/usr/bin/monit -g #{node.app.name} restart"]
end

# monit confi for puma

template "/etc/monit/conf.d/#{node.app.name}.conf" do
  source "monit_config.erb"
  mode 0600
  owner 'root'
  group 'root'
end


# ENV FILE

if node.app[:env]
  template "/home/#{node.app.user}/app/shared/.env" do
    source "env.erb"
    mode 0600
    owner node.app.user
    group node.app.user
  end
end
