require_dependency 'environment'

class Environment

  has_many :oauth_providers, :class_name => 'OauthClientPlugin::Provider'

end
