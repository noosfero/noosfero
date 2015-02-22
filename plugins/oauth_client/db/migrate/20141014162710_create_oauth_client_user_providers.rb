class CreateOauthClientUserProviders < ActiveRecord::Migration
  def self.up
    create_table :oauth_client_plugin_user_providers do |t|
      t.references :user
      t.references :provider
      t.boolean :enabled
      t.timestamps
    end
  end

  def self.down
    drop_table :oauth_client_plugin_user_providers
  end
end
