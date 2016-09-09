class AddExternalProfileToOauthAuth < ActiveRecord::Migration
  def up
    add_column :oauth_client_plugin_auths, :profile_type, :string
    add_index :oauth_client_plugin_auths, :profile_type

    add_column :oauth_client_plugin_auths, :external_person_uid, :string
    add_column :oauth_client_plugin_auths, :external_person_image_url, :string

    change_column_default :oauth_client_plugin_auths, :enabled, true
  end

  def down
    remove_index :oauth_client_plugin_auths, :profile_type
    remove_column :oauth_client_plugin_auths, :profile_type

    remove_column :oauth_client_plugin_auths, :external_person_uid
    remove_column :oauth_client_plugin_auths, :external_person_image_url

    change_column_default :oauth_client_plugin_auths, :enabled, nil
  end
end
