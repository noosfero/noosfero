class AddHttpsFeedProxyToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :https_feed_proxy, :string
  end
end
