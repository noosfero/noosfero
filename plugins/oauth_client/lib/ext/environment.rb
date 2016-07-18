require_dependency 'environment'

class Environment
  has_one :oauth_client_plugin_configuration, :class_name => 'OauthClientPlugin::Configuration'
  has_many :oauth_providers, :class_name => 'OauthClientPlugin::Provider'
end
