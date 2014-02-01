if node.app[:sphinx]
  apt_repository "sphinx-beta" do
    uri "http://ppa.launchpad.net/builds/sphinxsearch-beta/ubuntu "
    distribution 'precise'
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "16932B16"
  end

  package 'sphinxsearch' do
    action :upgrade
  end

  # install mysql client (sphinx)
  include_recipe 'mysql::client'


  template "/home/deploy/app/shared/config/thinking_sphinx.yml" do
    source "thinking_sphinx.yml"
    mode 0600
    owner node.app.user
    group node.app.user
  end
end
