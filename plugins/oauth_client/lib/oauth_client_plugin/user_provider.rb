class OauthClientPlugin::UserProvider < ActiveRecord::Base

   belongs_to :user, :class_name => 'User'
   belongs_to :provider, :class_name => 'OauthClientPlugin::Provider'

   self.table_name = :oauth_client_plugin_user_providers

   attr_accessible :user, :provider, :enabled

end
