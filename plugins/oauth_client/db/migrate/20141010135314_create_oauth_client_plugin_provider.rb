class CreateOauthClientPluginProvider < ActiveRecord::Migration

  def self.up
    create_table :oauth_client_plugin_providers do |t|
      t.integer :environment_id
      t.string :strategy
      t.string :name
      t.text :options
      t.boolean :enabled
      t.integer :image_id

      t.timestamps
    end
  end

  def self.down
    drop_table :oauth_client_plugin_providers
  end
end
