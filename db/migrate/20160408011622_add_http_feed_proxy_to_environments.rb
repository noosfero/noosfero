class AddHttpFeedProxyToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :http_feed_proxy, :string
  end
end
