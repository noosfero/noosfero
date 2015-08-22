class DeserializeFieldsOnOauthClientPluginProvider < ActiveRecord::Migration

  def up
    add_column :oauth_client_plugin_providers, :client_id, :text
    add_column :oauth_client_plugin_providers, :client_secret, :text

    OauthClientPlugin::Provider.find_each batch_size: 50 do |provider|
      provider.client_id = provider.options.delete :client_id
      provider.client_secret = provider.options.delete :client_secret
      provider.save!
    end

    add_index :oauth_client_plugin_providers, :client_id
  end

  def down
    say "this migration can't be reverted"
  end

end
