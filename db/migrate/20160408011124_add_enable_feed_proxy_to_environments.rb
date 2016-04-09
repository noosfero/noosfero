class AddEnableFeedProxyToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :enable_feed_proxy, :boolean, default: false
  end
end
