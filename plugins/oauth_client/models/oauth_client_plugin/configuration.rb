class OauthClientPlugin::Configuration < ApplicationRecord

  belongs_to :environment
  attr_accessible :allow_external_login, :environment_id

  class << self
    def instance
      environment = Environment.default
      environment.oauth_client_plugin_configuration || create(environment_id: environment.id)
    end

    private :new
  end

end
