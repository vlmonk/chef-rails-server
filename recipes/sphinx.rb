if node.app[:sphinx]
  package 'sphinxsearch'

  # install mysql client (sphinx)
  include_recipe 'mysql::client'


  template "/home/deploy/app/shared/config/thinking_sphinx.yml" do
    source "thinking_sphinx.yml"
    mode 0600
    owner node.app.user
    group node.app.user
  end
end
