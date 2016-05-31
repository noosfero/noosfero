class AddDisableFeedSslToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :disable_feed_ssl, :boolean, default: false
  end
end
