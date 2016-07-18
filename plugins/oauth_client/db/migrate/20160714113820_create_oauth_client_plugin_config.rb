class CreateOauthClientPluginConfig < ActiveRecord::Migration

  def change
    create_table :oauth_client_plugin_configurations do |t|
     t.belongs_to :environment
     t.boolean :allow_external_login, :default => false
    end
  end
end
